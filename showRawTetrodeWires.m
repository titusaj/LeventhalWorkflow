function showRawTetrodeWires(sessionConf,varargin)

    numSegments = 1;
    segmentLength = 1e5;

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

    figurePath = fullfile(leventhalPaths.graphs,'rawTetrodeWires');
    if ~isdir(figurePath)
        mkdir(figurePath);
    end

    for iTet=1:length(validTetrodes)
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(iTet)};
        tetrodeChannels = sessionConf.chMap(validTetrodes(iTet),2:end);
        tetrodeFilenames = fullSevFiles(tetrodeChannels);
        for iSeg=1:numSegments
            h = formatSheet();
            hold on;
            for iCh=1:4
                disp(['Reading ',tetrodeFilenames{iCh}]);
                [sev,header] = read_tdt_sev(tetrodeFilenames{iCh});
                segmentStart = round(length(sev)/(numSegments+1)*iSeg);
                segmentEnd = segmentStart + segmentLength;
                hsRaw(iCh) = subplot(4,2,iCh*2-1);
                plot(sev(segmentStart:segmentEnd));
                title([tetrodeName,'w',num2str(iCh),', ',num2str(segmentStart),...
                    ':',num2str(segmentEnd),' raw']);
                xlim([0 segmentLength]);
                ylabel('uV');
                xlabel('samples');
                hsHp(iCh) = subplot(4,2,iCh*2);
                plot(wavefilter(sev(segmentStart:segmentEnd),6));
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
    h = figure;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperType','A4');
    set(h,'PaperUnits','centimeters');
    set(h,'PaperPositionMode','auto');
    set(h,'PaperPosition', [1 1 28 19]);
end