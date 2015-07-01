function createPLXFiles(sessionName,wires,varargin)
%Function to create a PLX file in the correct format
%wires input is hard coded representation of the 50 micron wires
%Fred Edit. Now no need for sessionconf variable since waveLength,peakLoc,
%deadTime all are hardcoded. Also uses only 1 wire at a time. 
%
%wires = vector of known/good channels. 

% [] input for artifact thresh

%Start the stop watch
    tic;
    %Set default values
    onlyGoing = 'none';
    threshArtifacts = 500; %uV
    waveLength = 48;
    peakLoc = 16;
    deadTime = round(24414/1000);
    
   
    for iarg = 1 : 2 : nargin - 1
        switch varargin{iarg}
            case 'onlyGoing'
                onlyGoing = varargin{iarg + 1};
            case 'threshArtifact'
                threshArtifact = varargin{iarg + 1};
        end
    end

    % get paths, create: processed
    %leventhalPaths = buildLeventhalPaths(sessionConf,{'processed'});
    folderpath = uigetdir
   
    spikeParameterString = sprintf('WL%02d_PL%02d_DT%02d',waveLength,...
       peakLoc, deadTime);

    %validTetrodes = find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));
    fullSevFiles = getChFileMap(folderpath);
    
    stats = {};
    %Loop through the valid tetrodes to get the name, channel, valid mask,
    %and SEV filenames
    for ii=1:length(wires)
        %Filter the data and cure artifacts
        header = getSEVHeader(fullSevFiles{wires(ii)});
        dataLength = (header.fileSizeBytes - header.dataStartByte) / header.sampleWidthBytes;
        data = zeros(1,dataLength);
        data = read_tdt_sev(fullSevFiles{wires(ii)});
    disp('Bandpass filtering...');
    %Filter data, bandpass ~240Hz and ~2.4kHz
    [b,a] = butter(4, [0.02 0.2]);
    data(ii,:) = filtfilt(b,a,double(data));
    %valid mask is kind of redundant here, zeros already set above
    disp('Fixing high amplitude artifacts...');
    data = artifactThresh(double(data),[1 0 0 0],threshArtifacts);
    
    spikeExtractPath = fullfile(folderpath,'spikeExtract');
    if ~exist(spikeExtractPath,'dir')
       mkdir(spikeExtractPath);
    end
    
    spikeProcessedPath = fullfile(folderpath,'Processed');
    if ~exist(spikeProcessedPath,'dir')
       mkdir(spikeProcessedPath);
    end 
    
    locs = getSpikeLocations(data,[1 0 0 0],header.Fs,'onlyGoing',onlyGoing,...
    'saveDir',spikeExtractPath,'savePrefix',num2str(wires(ii)));


    PLXfn = fullfile(spikeProcessedPath,[sessionName,...
    '_',num2str(wires(ii)),'_',spikeParameterString,'.plx']);
    PLXid = makePLXInfo(PLXfn,sessionName,header.Fs, length(data),waveLength,peakLoc);
    
    
    makePLXChannelHeader(PLXid,sessionName, waveLength ,num2str(wires(ii)));
        
    disp('Extracting waveforms...');
    waveforms = extractWaveforms(data,locs,peakLoc,waveLength);
    disp('Writing waveforms to PLX file...');
    writePLXdatablock(PLXid,waveforms,locs);   
    
    stats{ii,1} = num2str(wires(ii));
    stats{ii,2} = length(locs);
    end
    
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

% function data = prepSEVData(filenames,validMask,threshArtifacts)
%     header = getSEVHeader(filenames{1});
%     dataLength = (header.fileSizeBytes - header.dataStartByte) / header.sampleWidthBytes;
%     data = zeros(length(validMask),dataLength);
%     for ii=1:length(filenames)
%         if ~validMask(ii)
%             disp(['Skipping ',filenames{ii}]);
%             continue;
%         end
%         disp(['Reading ',filenames{ii}]);
%         %Read in the data from the SEV files
%         [data(ii,:),~] = read_tdt_sev(filenames{ii});
%     end
%     disp('Bandpass filtering...');
%     %Filter data, bandpass ~240Hz and ~2.4kHz
%     [b,a] = butter(4, [0.02 0.2]);
%     for ii=1:size(data,1)
%         data(ii,:) = filtfilt(b,a,double(data(ii,:)));
%     end
%     %valid mask is kind of redundant here, zeros already set above
%     disp('Fixing high amplitude artifacts...');
%     data = artifactThresh(double(data),validMask,threshArtifacts);
% end

function makePLXChannelHeader(PLXid,sessionName, waveLength, tetrodeName)
%Function to prepare data in a format to make a channel header in a PLX
%file
        chInfo.tetName  = [sessionName,'_',tetrodeName];
        chInfo.wireName = sprintf('%s_50micron', tetrodeName);

        chInfo.wireNum   = str2num(tetrodeName); %tetrode number
        chInfo.WFRate    = 0; % sessionConf.Fs; !!!cant be Fs, gets converted to int
        chInfo.SIG       = 1;  %channel number
        chInfo.refWire   = 0;     % not sure exactly what this is; Alex had it set to zero
        chInfo.gain      = 300;
        chInfo.filter    = 0;    % not sure what this is; Alex had it set to zero
        chInfo.thresh    = 0; % does this even matter anywhere?
        chInfo.numUnits  = 0;    % no sorted units
        chInfo.sortWidth = waveLength;
        chInfo.comment   = 'created with Spikey, makePLXChannelHeader';

        writePLXChanHeader(PLXid, chInfo);
end

function PLXid = makePLXInfo(PLXfn,sessionName,Fs,dataLength, waveLength,peakLoc)
%Function to prepare data to make a header in the PLX file
    sessionDateStr = sessionName(7:14);
    sessionDateVec = datevec(sessionDateStr, 'yyyymmdd');

    plxInfo.comment    = '';
    plxInfo.ADFs       = Fs; % record the upsampled Fs as the AD freq for timestamps
    plxInfo.numWires   = 1;
    plxInfo.numEvents  = 0;
    plxInfo.numSlows   = 0;
    plxInfo.waveLength = waveLength;
    plxInfo.peakLoc    = peakLoc;

    plxInfo.year  = sessionDateVec(1);
    plxInfo.month = sessionDateVec(2);
    plxInfo.day   = sessionDateVec(3);

    timeVector = datevec('12:00','HH:MM');
    plxInfo.hour       = timeVector(4);
    plxInfo.minute     = timeVector(5);
    plxInfo.second     = 0;
    plxInfo.waveFs     = Fs; % record the upsampled Fs as the waveform sampling frequency
    plxInfo.dataLength = dataLength;

    plxInfo.Trodalness     = 1; %Trodalness - 0,1 = single electrode, 2 = stereotrode, 4 = tetrode
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