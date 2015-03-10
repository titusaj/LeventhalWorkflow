function sessionSummary = analyze_choiceRTlogDataWeekly2VPedit(ratID, implantSide, varargin)
%
% USAGE: sessionSummary = analyze_choiceRTlogDataWeekly2(ratID, implantSide, varargin)
%
% INPUTS:
%   ratID - string containing the rat ID (e.g., 'R0001'). Should have 5
%       characters
%   implantSide - use 'left' to indicate left implant. Anything else
%       assumed to be right. 'left' should be used as default (i.e., prior
%       to implantation)
%
% VARARGS:
%   'recordingdirectory' -
%
% OUTPUTS:
%   sessionSummary - structure containing session summary information from
%       the last .log file checked. This is mainly useful for
%       troubleshooting the software
%
% CHOICE RT DIFFICULTY LEVELS:
%   0 - Poke Any:
%   1 - Very Easy:
%   2 - Easy:
%   3 - Standard:
%   4 - Advanced:
%   5 - Choice VE:
%   6 - Choice Easy:
%   7 - Choice Standard:
%   8 - Choice Advanced:
%   9 - Testing:
%
% UPDATE LOG:
% 08/27/2014 - don't have to navigate to the parent folder first, requires
%   user to specify the rat ID as an input argument

%%  Obtain file path for behavioral data from standardized directory and create path where graphs will be saved. Create empty structure to fill with basic information about rat and task.
recordingDirectory = 'RecordingsLeventhal2';

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg}),
        case 'recordingdirectory',
            recordingDirectory = varargin{iarg + 1};
    end
end

if ismac;
    topLevelDir = fullfile('/Volumes',recordingDirectory);
elseif ispc;
    topLevelDir = fullfile('\\172.20.138.142\',recordingDirectory); %check if this actually works on PC
end


parentFolder = fullfile(topLevelDir, ...
    'ChoiceTask', ...
    ratID, ...
    [ratID '-rawdata']);


cd(parentFolder);

graphFolder=[parentFolder(1:end-7) 'graphs'];
if ~exist(graphFolder, 'dir')
    mkdir(graphFolder);
end

direct=dir;
count=0;

logDataWeek.date=[];
logDataWeek.subject=[];
logDataWeek.outcome=[];
logDataWeek.SideNP= [];
logDataWeek.Target= [];
logDataWeek.Center= [];
logDataWeek.RT= [];
logDataWeek.MT= [];
logDataWeek.startTime=[];

%% Set plot and figure properties

%ylim
ylimAccuracy=[0 1.1];
ylimipsiTrial=[0 100];
ylimcontraTrial=[0 100];
ylimallTrial=[0 200];
ylimallrtTrial=[0 70];
ylimipsirtTrial=[0 40];
ylimcontrartTrial=[0 40];

%paper dimensions # inches units
X = 8.5;                   %# US letter paper width
Y = 11;                    %# US letter paper height
xMargin = .5;               %# left/right margins from page borders
yMargin = .5;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (width & height)
ySize = Y - 2*yMargin;     %# figure size on paper (width & height)

%font
fontTitle= 8; %replace with fontTitle2 if appropriate
fontFigure= 10; %change variable to fontAxes? %controls axis label font size and title font size
fontTitle2 = 8; %controls legend font size and axes font size


%% Obtain data for analysis, fill in structure with basic rat and task info
numFolders = length(direct)-4;
for iDir=1:numFolders
    ii = iDir + 4;
    
    cd(direct(ii).name);
    fname=dir('*.log');
    
    %    outcome - 0 = successful
    %              1 = false start, started before GO tone
    %              2 = false start, failed to hold for PSSHT (for
    %                  stop-signal/go-nogo; not relevant for simple choice task)
    %              3 = rat started in the wrong port
    %              4 = rat exceeded the limited hold
    %              5 = rat went the wrong way after the tone
    %              6 = rat failed to go back into a side port in time
    %              7 = Outcome wasn't recorded in the data file
    
    RTbins = 0.05 : 0.05 : 0.95;
    MTbins = 0.05 : 0.05 : 0.95;
    
    dirs=dir(fullfile(pwd,'*.log'));
    numLogs = length(dirs);
    switch numLogs
        case 0,         % skip if no .log files present
            cd(parentFolder);
            continue;
        case 1,
            validLogIdx = 1;
        case 2,
            for iLog = 1 : length(dirs)
                if isempty(strfind(dirs(iLog).name, 'old'))
                    validLogIdx = iLog;
                    break;
                end
            end
        otherwise,      % skip if more than one .log files present
            cd(parentFolder);
            continue;
    end
    logData = readLogData(dirs(validLogIdx).name);   % only analyze data from valid log files with > 20 attempts
    
    if length(fieldnames(logData))>=27 && length(logData.Attempt)>20
        count=count+1;
        if count==1
            logDataWeek.date=[logData.date];
            logDataWeek.subject=[logData.subject];
            logDataWeek.startTime=[logData.startTime];
            logDataWeek.taskLevel=[int2str(logData.taskLevel)];
            logDataWeek.combined=[logDataWeek.date];
            
        elseif count==5
            logDataWeek.combined=[logDataWeek.combined '-' logData.date];
            logDataWeek.taskLevel=[logDataWeek.taskLevel,', ',int2str(logData.taskLevel)];
            logDataWeek.date=[logDataWeek.date,', ',logData.date];
            logDataWeek.subject=[logDataWeek.subject,', ',logData.subject];
        else
            
            logDataWeek.taskLevel=[logDataWeek.taskLevel,', ',int2str(logData.taskLevel)];
            logDataWeek.date=[logDataWeek.date,', ',logData.date];
            logDataWeek.subject=[logDataWeek.subject,', ',logData.subject];
        end
        
        textString{1} = [fname(1).name(1:5) '(' logDataWeek.combined ')_LogAnalysisOutcome.pdf'];
        graphName = fullfile(graphFolder, textString{1});
        if exist(graphName,'file')
            cd(parentFolder);
            count=0;
            continue;
        end
        
        logDataWeek.outcome=[logData.outcome];
        logDataWeek.SideNP= [logData.SideNP];
        logDataWeek.Target= [logData.Target];
        logDataWeek.Center= [logData.Center];
        logDataWeek.RT= [logData.RT];
        logDataWeek.MT= [logData.MT];
        
        
        sessionSummary.correct      = (logDataWeek.outcome == 0);
        sessionSummary.wrongMove    = (logDataWeek.outcome == 5);
        sessionSummary.complete     = sessionSummary.correct | sessionSummary.wrongMove;
        sessionSummary.falseStart   = (logDataWeek.outcome == 1);
        sessionSummary.wrongStart   = (logDataWeek.outcome == 3);
        sessionSummary.targetRight  = (logDataWeek.Target > logDataWeek.Center);
        sessionSummary.moveRight    = (logDataWeek.SideNP > logDataWeek.Center);
        sessionSummary.ftr          = (logDataWeek.outcome == 4 | logDataWeek.outcome == 6);
        sessionSummary.LHviol       = (logDataWeek.outcome == 4);
        sessionSummary.MHviol       = (logDataWeek.outcome == 6);
        
        if strcmpi(implantSide, 'left')
            sessionSummary.targetContra = sessionSummary.targetRight;
            sessionSummary.targetIpsi   = ~sessionSummary.targetRight;
            
            sessionSummary.moveContra   = sessionSummary.moveRight;
            sessionSummary.moveIpsi     = ~sessionSummary.moveRight & logDataWeek.SideNP > 0;
            
        else
            sessionSummary.targetContra = ~sessionSummary.targetRight;
            sessionSummary.targetIpsi   = sessionSummary.targetRight;
            
            sessionSummary.moveContra   = ~sessionSummary.moveRight & logDataWeek.SideNP > 0;
            sessionSummary.moveIpsi     = sessionSummary.moveRight;
        end
        
        correctTargetContra = sessionSummary.correct & sessionSummary.targetContra;
        correctTargetIpsi   = sessionSummary.correct & sessionSummary.targetIpsi;
        
        
        completeTargetContra = sessionSummary.complete & sessionSummary.targetContra;
        completeTargetIpsi   = sessionSummary.complete & sessionSummary.targetIpsi;
        
        sessionSummary.acc(1) = sum(correctTargetIpsi) / sum(completeTargetIpsi);
        sessionSummary.acc(2) = sum(correctTargetContra) / sum(completeTargetContra);
        sessionSummary.acc(3) = sum(sessionSummary.correct) / sum(sessionSummary.complete);
        
        
        
        %center accuracy
        correctCenter2   = sessionSummary.correct & logDataWeek.Center == 2;
        correctCenter3   = sessionSummary.correct & logDataWeek.Center == 4;
        correctCenter4   = sessionSummary.correct & logDataWeek.Center == 8;
        
        completeTargetCenter2 = sessionSummary.complete & logDataWeek.Center == 2;
        completeTargetCenter3   = sessionSummary.complete & logDataWeek.Center == 4;
        completeTargetCenter4   = sessionSummary.complete & logDataWeek.Center == 8;
        sessionSummaryCenter.acc(1) = sum(correctCenter2) / sum(completeTargetCenter2);
        sessionSummaryCenter.acc(2) = sum(correctCenter3) / sum(completeTargetCenter3);
        sessionSummaryCenter.acc(3) = sum(correctCenter4) / sum(completeTargetCenter4);
        
        % accuracy new plots
        AccuracyCenter2(count)=sessionSummaryCenter.acc(1);
        AccuracyCenter3(count)=sessionSummaryCenter.acc(2);
        AccuracyCenter4(count)=sessionSummaryCenter.acc(3);
        
        % new plots for attempts etc.
        ipsiAttempt(count)= sum(sessionSummary.targetIpsi);
        contraAttempt(count)= sum(sessionSummary.targetContra);
        allAttempt(count)= length(sessionSummary.correct);
        
        ipsiComplete(count)= sum(completeTargetIpsi);
        contraComplete(count)= sum(completeTargetContra);
        allComplete(count)= sum(sessionSummary.complete);
        
        ipsiCorrect(count)= sum(correctTargetIpsi);
        contraCorrect(count)= sum(correctTargetContra);
        allCorrect(count)= sum(sessionSummary.correct);
        
        
        
        % accuracy new plots
        ipsiAccuracy(count)=sessionSummary.acc(1);
        contraAccuracy(count)=sessionSummary.acc(2);
        allAccuracy(count)=sessionSummary.acc(3);
        
        
        
        %% Fill in data for each plot into plot matrix
        %new outcomes plots
        plotMatrix = zeros(3, 6);
        % first row - ipsi directed trials; 2nd row - contra directed trials; 3rd
        % row - all trials
        outcomeList = [0,1,3,4,6,5];
        for i_outcome = 1 : 6
            plotMatrix(1, i_outcome) = sum(logDataWeek.outcome == outcomeList(i_outcome) & ...
                sessionSummary.targetIpsi);
            plotMatrix(2, i_outcome) = sum(logDataWeek.outcome == outcomeList(i_outcome) & ...
                sessionSummary.targetContra);
            plotMatrix(3, i_outcome) = sum(logDataWeek.outcome == outcomeList(i_outcome));
        end
        
        plotMatrix(1,:) = plotMatrix(1,:) ./ sum(sessionSummary.targetIpsi);
        correctOutcomeIpsi(count)=plotMatrix(1,1);
        fsOutcomeIpsi(count)=plotMatrix(1,2);
        wsOutcomeIpsi(count)=plotMatrix(1,3);
        lhOutcomeIpsi(count)=plotMatrix(1,4);
        mhOutcomeIpsi(count)=plotMatrix(1,5);
        wrongOutcomeIpsi(count)=plotMatrix(1,6);
        
        
        plotMatrix(2,:) = plotMatrix(2,:) ./ sum(sessionSummary.targetContra);
        correctOutcomeContra(count)=plotMatrix(2,1);
        fsOutcomeContra(count)=plotMatrix(2,2);
        wsOutcomeContra(count)=plotMatrix(2,3);
        lhOutcomeContra(count)=plotMatrix(2,4);
        mhOutcomeContra(count)=plotMatrix(2,5);
        wrongOutcomeContra(count)=plotMatrix(2,6);
        
        plotMatrix(3,:) = plotMatrix(3,:) ./ length(sessionSummary.correct);
        correctOutcomeAll(count)=plotMatrix(3,1);
        fsOutcomeAll(count)=plotMatrix(3,2);
        wsOutcomeAll(count)=plotMatrix(3,3);
        lhOutcomeAll(count)=plotMatrix(3,4);
        mhOutcomeAll(count)=plotMatrix(3,5);
        wrongOutcomeAll(count)=plotMatrix(3,6);
        
        
        
        if count==1
            figure
        end
        sessionSummary.ipsiRT   = logDataWeek.RT(completeTargetIpsi);
        sessionSummary.contraRT = logDataWeek.RT(completeTargetContra);
        sessionSummary.allRT    = logDataWeek.RT(sessionSummary.complete);
        
        %% Start plotting data
        ipsiHist   = histogram(sessionSummary.ipsiRT, RTbins);
        contraHist = histogram(sessionSummary.contraRT, RTbins);
        allHist    = histogram(sessionSummary.allRT, RTbins);
        
        
        
        subplot(3,3,1),plot(RTbins, ipsiHist, 'color', [0 0 0.2*count]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimipsirtTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        ylabel('# Trial','FontSize',fontFigure)
        hold on
        title('completed RT;Ipsi','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,2),plot(RTbins, contraHist, 'color', [0 0.2*count 0]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimcontrartTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        hold on
        title('completed RT; Contra','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,3),plot(RTbins, allHist, 'color', [0.2*count 0 0]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimallrtTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        hold on
        title('completed RT; All','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        
        sessionSummary.ipsiMT   = logDataWeek.MT(completeTargetIpsi);
        sessionSummary.contraMT = logDataWeek.MT(completeTargetContra);
        sessionSummary.allMT    = logDataWeek.MT(sessionSummary.complete);
        
        ipsiHist   = histogram(sessionSummary.ipsiMT, MTbins);
        contraHist = histogram(sessionSummary.contraMT, MTbins);
        allHist    = histogram(sessionSummary.allMT, MTbins);
        
        subplot(3,3,4),plot(MTbins, ipsiHist, 'color', [0 0 0.2*count]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimipsirtTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        ylabel('# Trial','FontSize',fontFigure)
        hold on
        title('completed MT;Ipsi','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,5),plot(MTbins, contraHist, 'color', [0 0.2*count 0]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimcontrartTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        hold on
        title('completed MT; Contra','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,6),plot(MTbins, allHist, 'color', [0.2*count 0 0]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimallrtTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        hold on
        title('completed MT; All','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        sessionSummary.ipsiRTMT   = logDataWeek.MT(completeTargetIpsi) + logDataWeek.RT(completeTargetIpsi);
        sessionSummary.contraRTMT = logDataWeek.MT(completeTargetContra) + logDataWeek.RT(completeTargetContra);
        sessionSummary.allRTMT    = logDataWeek.MT(sessionSummary.complete) + logDataWeek.RT(sessionSummary.complete);
        
        ipsiHist   = histogram(sessionSummary.ipsiRTMT, MTbins);
        contraHist = histogram(sessionSummary.contraRTMT, MTbins);
        allHist    = histogram(sessionSummary.allRTMT, MTbins);
        
        subplot(3,3,7),plot(MTbins, ipsiHist, 'color', [0 0 0.2*count]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimipsirtTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        ylabel('# Trial','FontSize',fontFigure)
        hold on
        title('completed MT+RT;Ipsi','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,8),plot(MTbins, contraHist, 'color', [0 0.2*count 0]);
        set(gca,'FontSize',fontTitle2)
        ylim(ylimcontrartTrial)
        xlabel('Time(s)','FontSize',fontFigure)
        hold on
        title('completed MT+RT; Contra','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        subplot(3,3,9),plot(MTbins, allHist, 'color', [0.2*count 0 0]);
        set(gca,'FontSize',fontTitle2)
        xlabel('Time(s)','FontSize',fontFigure)
        ylim(ylimallrtTrial)
        hold on
        title('completed MT+RT; All','FontSize',fontFigure);
        legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
        
        % Set page properties
        if count==5
            A=cell(1,3);
            A{1,1} = ['Subject: ' logData.subject];
            A{1,2} = ['Date: ' logDataWeek.date];
            A{1,3} = ['Task Level: ' logDataWeek.taskLevel];
            mls = sprintf('%s\n%s\n%s',A{1,1},A{1,2},A{1,3});
            name=fname(1).name ;
            textString{1} = [name(1:5) '(' logDataWeek.combined ')_LogAnalysisRTMT'];
            % inches units
            legend('Day1','Day2','Day3','Day4','Day5','Location','NorthEast');
            textLoc = [];
            set(gcf, 'PaperUnits','inches','PaperPosition', [xMargin yMargin xSize ySize]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
            set(gcf, 'PaperType', 'usletter'); %Keep the same paper size
            figureSize = get(gcf,'Position');
            uicontrol('Style','text',...
                'String',mls,...
                'Units', 'pixels',...
                'Position', [140 2510 1600 150],...
                'BackgroundColor','white','FontSize',fontTitle);
            cd(graphFolder);
            saveas(gcf, textString{1}, 'pdf')
            
            % Plot individual figures and set properties
            figure
            subplot(3,3,1),plot(ipsiAttempt,'color','b')
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            ylim(ylimipsiTrial)
            xlabel('Day','FontUnits','points','FontSize',fontFigure)
            ylabel('# Trials','FontUnits','points','FontSize',fontFigure)
            hold on
            plot(ipsiComplete,'color','g')
            plot(ipsiCorrect,'color','r')
            plotTitle = sprintf('Ipsi Attempt\nComplete, Correct');
            title(plotTitle,'FontUnits','points','FontSize',fontFigure);
            legend('Attempt','Complete','Correct','Location','SouthEast');
            
            subplot(3,3,2),plot(contraAttempt,'color','b')
            set(gca,'FontUnits','points','FontUnits','points','FontSize',fontTitle2)
            ylim(ylimcontraTrial)
            xlabel('Day','FontUnits','points','FontSize',fontFigure)
            hold on
            plot(contraComplete,'color','g')
            plot(contraCorrect,'color','r')
            plotTitle = sprintf('Contra Attempt\nComplete, Correct');
            title(plotTitle,'FontUnits','points','FontSize',fontFigure);
            legend('Attempt','Complete','Correct','Location','SouthEast');
            
            subplot(3,3,3),plot(allAttempt,'color','b')
            set(gca,'FontUnits','points','FontUnits','points','FontSize',fontTitle2)
            xlabel('Day','FontUnits','points','FontSize',fontFigure)
            ylim(ylimallTrial)
            hold on
            plot(allComplete,'color','g')
            plot(allCorrect,'color','r')
            plotTitle = sprintf('All Attempt\nComplete, Correct');
            title(plotTitle,'FontUnits','points','FontSize',fontFigure);
            legend('Attempt','Complete','Correct','Location','SouthEast');
            
            finalMatrixIpsi(:,1)=correctOutcomeIpsi;
            finalMatrixIpsi(:,2)=fsOutcomeIpsi;
            finalMatrixIpsi(:,3)=wsOutcomeIpsi;
            finalMatrixIpsi(:,4)=lhOutcomeIpsi;
            finalMatrixIpsi(:,5)=mhOutcomeIpsi;
            finalMatrixIpsi(:,6)=wrongOutcomeIpsi;
            
            finalMatrixContra(:,1)=correctOutcomeContra;
            finalMatrixContra(:,2)=fsOutcomeContra;
            finalMatrixContra(:,3)=wsOutcomeContra;
            finalMatrixContra(:,4)=lhOutcomeContra;
            finalMatrixContra(:,5)=mhOutcomeContra;
            finalMatrixContra(:,6)=wrongOutcomeContra;
            
            finalMatrixAll(:,1)=correctOutcomeAll;
            finalMatrixAll(:,2)=fsOutcomeAll;
            finalMatrixAll(:,3)=wsOutcomeAll;
            finalMatrixAll(:,4)=lhOutcomeAll;
            finalMatrixAll(:,5)=mhOutcomeAll;
            finalMatrixAll(:,6)=wrongOutcomeAll;
            
            subplot(3,3,4), bar(finalMatrixIpsi, 'stack');
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            title('Ipsi trial outcomes','FontUnits','points','FontSize',fontFigure);
            set(gca,'xticklabel',{'1','2','3','4','5'}, ...
                'ylim',[0 1]);
            xlabel('Day');
            legend('cor','fs','ws','lh','mh','wrong','Location','SouthEast');
            ylabel('% of Trials','FontUnits','points','FontSize',fontFigure)
            
            subplot(3,3,5), bar(finalMatrixContra, 'stack');
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            title('Contra trial outcomes','FontUnits','points','FontSize',fontFigure);
            set(gca,'xticklabel',{'1','2','3','4','5'}, ...
                'ylim',[0 1]);
            xlabel('Day');
            legend('cor','fs','ws','lh','mh','wrong','Location','SouthEast');
            
            subplot(3,3,6), bar(finalMatrixAll, 'stack');
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            title('All trial outcomes','FontUnits','points','FontSize',fontFigure);
            set(gca,'xticklabel',{'1','2','3','4','5'}, ...
                'ylim',[0 1]);
            xlabel('Day');
            legend('cor','fs','ws','lh','mh','wrong','Location','SouthEast');
            
            subplot(3,3,7),plot(ipsiAccuracy,'color','r')
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            ylim(ylimAccuracy)
            xlabel('Day','FontUnits','points','FontSize',fontFigure)
            ylabel('% Accurate','FontUnits','points','FontSize',fontFigure)
            hold on
            plot(contraAccuracy,'color','g')
            plot(allAccuracy,'color','b')
            title('Accuracy','FontUnits','points','FontSize',fontFigure);
            legend('Ipsi','Contra','All','Location','SouthEast');
            
            subplot(3,3,8),plot(AccuracyCenter2,'color','r')
            set(gca,'FontUnits','points','FontSize',fontTitle2)
            ylim(ylimAccuracy)
            xlabel('Day','FontUnits','points','FontSize',fontFigure)
            ylabel('% Accurate','FontUnits','points','FontSize',fontFigure)
            hold on
            plot(AccuracyCenter3,'color','g')
            plot(AccuracyCenter4,'color','b')
            title('Accuracy','FontUnits','points','FontSize',fontFigure);
            legend('Port 2','Port 3','Port 4','Location','SouthEast');
            
            A=cell(1,3);
            A{1,1} = ['Subject: ' logData.subject];
            A{1,2} = ['Date: ' logDataWeek.date];
            A{1,3} = ['Task Level: ' logDataWeek.taskLevel];
            mls = sprintf('%s\n%s\n%s',A{1,1},A{1,2},A{1,3});
            
            textString{1} = [name(1:5) '(' logDataWeek.combined ')_LogAnalysisOutcome'];
            set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [xMargin yMargin xSize ySize]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
            set(gcf, 'PaperType', 'usletter'); %Keep the same paper size
            figureSize = get(gcf,'Position');
            uicontrol('Style','text',...
                'String',mls,...
                'Units','pixels',...
                'Position',[140 2510 1600 150],...
                'BackgroundColor','white','FontUnits','points','FontSize',fontTitle);
            cd(graphFolder);
            %export_fig(textString{1},'-pdf','-q101','-painters', '-nocrop');
            saveas(gcf, textString{1}, 'pdf')
            cd(parentFolder);
            cd(direct(ii).name);
            count=0;
            close all
        end
        cd(parentFolder);
    else
        cd(parentFolder);
        continue;
    end
    cd(parentFolder);
end