function createPLXFiles(sessionConf,varargin)
%Function to create a PLX file in the correct format

% [] input for artifact thresh
    %Start the stop watch
    tic;
    %Set default values
    onlyGoing = 'none';
    threshArtifact = 500; %uV
    
    for iarg = 1 : 2 : nargin - 1
        switch varargin{iarg}
            case 'onlyGoing'
                onlyGoing = varargin{iarg + 1};
            case 'threshArtifact'
                threshArtifact = varargin{iarg + 1};
        end
    end

    % get paths, create: processed
    leventhalPaths = buildLeventhalPaths(sessionConf,{'processed'});
    
    spikeParameterString = sprintf('WL%02d_PL%02d_DT%02d', sessionConf.waveLength,...
       sessionConf.peakLoc, sessionConf.deadTime);

    validTetrodes = find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    
    stats = {};
    %Loop through the valid tetrodes to get the name, channel, valid mask,
    %and SEV filenames
    for ii=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(ii)};
        disp(['PROCESSING ',tetrodeName]);
        tetrodeChannels = sessionConf.chMap(validTetrodes(ii),2:end);
        tetrodeValidMask = sessionConf.validMasks(validTetrodes(ii),:);
        
        tetrodeFilenames = fullSevFiles(tetrodeChannels);
        
        %Filter the data and cure artifacts
        data = prepSEVData(tetrodeFilenames,tetrodeValidMask,threshArtifact);
        %Get the locations of the spikes
        spikeExtractPath = fullfile(leventhalPaths.graphs,'spikeExtract');
        if ~exist(spikeExtractPath,'dir')
            mkdir(spikeExtractPath);
        end
        locs = getSpikeLocations(data,tetrodeValidMask,sessionConf.Fs,'onlyGoing',onlyGoing,...
            'saveDir',spikeExtractPath,'savePrefix',tetrodeName);
        
        PLXfn = fullfile(leventhalPaths.processed,[sessionConf.sessionName,...
            '_',tetrodeName,'_',spikeParameterString,'.plx']);
        PLXid = makePLXInfo(PLXfn,sessionConf,tetrodeChannels,length(data));
        makePLXChannelHeader(PLXid,sessionConf,tetrodeChannels,tetrodeName);
        
        disp('Extracting waveforms...');
        waveforms = extractWaveforms(data,locs,sessionConf.peakLoc,...
            sessionConf.waveLength);
        disp('Writing waveforms to PLX file...');
        writePLXdatablock(PLXid,waveforms,locs); %write waveform files right now?
        
        stats{ii,1} = tetrodeName;
        stats{ii,2} = length(locs);
    end
    %Display the number of spikes found
    echoStats(stats);
end

function echoStats(stats)
%Function to display to the user the number of spikes found
    %Display 20 periods
    disp(char(repmat(46,1,20)));
    disp('EXTRACTION COMPLETE');
    %Loop through tetrodes, display the name of the tetride and how many
    %spikes were found on that tetrode
    for ii=1:size(stats,1)
        disp([stats{ii,1},' - ',num2str(stats{ii,2}),' spikes']);
    end
    %Stop the stopwatch and display the amount of time
    toc;
    disp(char(repmat(46,1,20)));
end

function data = prepSEVData(filenames,validMask,threshArtifacts)
    header = getSEVHeader(filenames{1});
    dataLength = (header.fileSizeBytes - header.dataStartByte) / header.sampleWidthBytes;
    data = zeros(length(validMask),dataLength);
    for ii=1:length(filenames)
        if ~validMask(ii)
            disp(['Skipping ',filenames{ii}]);
            continue;
        end
        disp(['Reading ',filenames{ii}]);
        %Read in the data from the SEV files
        [data(ii,:),~] = read_tdt_sev(filenames{ii});
    end
    disp('Bandpass filtering...');
    %Filter data, bandpass ~240Hz and ~2.4kHz
    [b,a] = butter(4, [0.02 0.2]);
    for ii=1:size(data,1)
        data(ii,:) = filtfilt(b,a,double(data(ii,:)));
    end
    %valid mask is kind of redundant here, zeros already set above
    disp('Fixing high amplitude artifacts...');
    data = artifactThresh(double(data),validMask,threshArtifacts);
end

function makePLXChannelHeader(PLXid,sessionConf,tetrodeChannels,tetrodeName)
%Function to prepare data in a format to make a channel header in a PLX
%file
    for ii=1:length(tetrodeChannels)
        chInfo.tetName  = [sessionConf.sessionName,'_',tetrodeName];
        chInfo.wireName = sprintf('%s_W%02d', tetrodeName, ii);

        chInfo.wireNum   = ii; %tetrode number
        chInfo.WFRate    = sessionConf.Fs;
        chInfo.SIG       = tetrodeChannels(ii);  %channel number
        chInfo.refWire   = 0;     % not sure exactly what this is; Alex had it set to zero
        chInfo.gain      = 300;
        chInfo.filter    = 0;    % not sure what this is; Alex had it set to zero
        chInfo.thresh    = 0; % does this even matter anywhere?
        chInfo.numUnits  = 0;    % no sorted units
        chInfo.sortWidth = sessionConf.waveLength;
        chInfo.comment   = 'created with Spikey, makePLXChannelHeader';

        writePLXChanHeader(PLXid, chInfo);
    end
end

function PLXid = makePLXInfo(PLXfn,sessionConf,tetrodeChannels,dataLength)
%Function to prepare data to make a header in the PLX file
    sessionDateStr = sessionConf.sessionName(7:14);
    sessionDateVec = datevec(sessionDateStr, 'yyyymmdd');

    plxInfo.comment    = '';
    plxInfo.ADFs       = sessionConf.Fs; % record the upsampled Fs as the AD freq for timestamps
    plxInfo.numWires   = length(tetrodeChannels);
    plxInfo.numEvents  = 0;
    plxInfo.numSlows   = 0;
    plxInfo.waveLength = sessionConf.waveLength;
    plxInfo.peakLoc    = sessionConf.peakLoc;

    plxInfo.year  = sessionDateVec(1);
    plxInfo.month = sessionDateVec(2);
    plxInfo.day   = sessionDateVec(3);

    timeVector = datevec('12:00','HH:MM');
    plxInfo.hour       = timeVector(4);
    plxInfo.minute     = timeVector(5);
    plxInfo.second     = 0;
    plxInfo.waveFs     = sessionConf.Fs; % record the upsampled Fs as the waveform sampling frequency
    plxInfo.dataLength = dataLength;

    plxInfo.Trodalness     = length(tetrodeChannels); %Trodalness - 0,1 = single electrode, 2 = stereotrode, 4 = tetrode
    plxInfo.dataTrodalness = 0; %this is set to 0 in the Plexon tetrode sample file

    plxInfo.bitsPerSpikeSample = 16;
    plxInfo.bitsPerSlowSample  = 16;

    plxInfo.SpikeMaxMagnitudeMV = 10000;
    plxInfo.SlowMaxMagnitudeMV  = 10000;

    plxInfo.SpikePreAmpGain = 1; % gain before final amplification stage

    PLXid = fopen(PLXfn, 'w');
    disp('PLX file opened...')
    writePLXheader(PLXid, plxInfo);
end