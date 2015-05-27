function showRawTetrodeWires(sessionConf,varargin)
%function to graph the raw data and high-pass filtered data side by side to
%identify bad wires
%
%Inputs:
%   sessionConf
%   optional: numSegments -- the number of segments
%             segmentLength -- length of segment
%
%Outputs:
%   none
%   Displays figure with 8 graphs, raw data on the left and filtered data
%   on the right

    numSegments = 3;
    segmentLength = 5e4;

    for iarg = 1 : 2 : nargin - 1
        switch varargin{iarg}
            case 'numSegments',
                numSegments = varargin{iarg + 1};
            case 'segmentLength'
                segmentLength = varargin{iarg + 1};
        end
    end

    
    leventhalPaths = buildLeventhalPaths(sessionConf);
    fullSevFiles = getChFileMap(leventhalPaths.channels);
    disp(['Found ',num2str(length(fullSevFiles)),' SEV files...']);
    validTetrodes = sessionConf.chMap(:,1);

    %create a path for the figure to be saved
    figurePath = fullfile(leventhalPaths.graphs,'rawTetrodeWires');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

%     hsRaw = cell(4,1);
%     hsHp = cell(4,1);
    %Loop through valid tetrodes to get the tetrode names and channels
    for iTet=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(iTet)};
        tetrodeChannels = sessionConf.chMap(validTetrodes(iTet),2:end);
        % handle issue of only having 64 SEV files but 128 in chMap
        if min(tetrodeChannels) > length(fullSevFiles)
            disp(['Breaking at ',tetrodeName,' (no more SEV files)']);
            break;
        end
        tetrodeFilenames = fullSevFiles(tetrodeChannels);
        %Loop through each segment
        for iSeg=1:numSegments
            h = formatSheet();
            hold on;
            %Loop through each channel
            for iCh=1:4
                disp(['Reading ',tetrodeFilenames{iCh}]);
                %Read in data from eat SEV file
                [sev,header] = read_tdt_sev(tetrodeFilenames{iCh});
                %find the start and end points for the graph
                segmentStart = round(length(sev)/(numSegments+1)*iSeg);
                segmentEnd = segmentStart + segmentLength;
                %create a subplot where raw data is on the left side
                hsRaw(iCh) = subplot(4,2,iCh*2-1);
                %plot the SEV data
                plot(sev(segmentStart:segmentEnd));
                %Title the graph
                title([tetrodeName,'w',num2str(iCh),', ',num2str(segmentStart),...
                    ':',num2str(segmentEnd),' raw']);
                xlim([0 segmentLength]);
                ylabel('uV');
                xlabel('samples');
                %Put the subplots for filtered data on the right side
                hsHp(iCh) = subplot(4,2,iCh*2);
                %Plot data filtered through a high pass filter
                plot(wavefilter(sev(segmentStart:segmentEnd),6));
                %Name the graph
                title([tetrodeName,'w',num2str(iCh),', ',num2str(segmentStart),...
                    ':',num2str(segmentEnd),' raw']);
                ylim([-500 500]);
                xlim([0 segmentLength]);
                ylabel('uV');
                xlabel('samples');
            end
            linkaxes(hsRaw,'x');
            linkaxes(hsHp,'x');

            saveas(h,fullfile(figurePath,[tetrodeName,'_',num2str(segmentStart),...
                    '-',num2str(segmentEnd)]),'pdf');
            close(h);
        end
    end
end

function h = formatSheet()
% Function to formatht the page that the figure will be saved in
    h = figure;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperType','A4');
    set(h,'PaperUnits','centimeters');
    set(h,'PaperPositionMode','auto');
    set(h,'PaperPosition', [1 1 28 19]);
end