function sessionSummary = analyze_choiceRTlogDataAll(implantSide)
parentFolder=pwd;
graphFolder=[parentFolder(1:end-7) 'graphs'];
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

%ylim
ylimAccuracy=[0 1.1];
ylimipsiTrial=[0 100];
ylimcontraTrial=[0 100];
ylimallTrial=[0 200];
ylimallrtTrial=[0 70];
ylimipsirtTrial=[0 40];
ylimcontrartTrial=[0 40];

%paper dimensions # centimeters units
X = 21.0;                  %# A3 paper size
Y = 29.7;                  %# A3 paper size
xMargin = 1;               %# left/right margins from page borders
yMargin = 1;               %# bottom/top margins from page borders
xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

%font
fontTitle=25;
fontFigure=18;

for ii=4:length(direct)
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
    
    logData = readLogData(fname(1).name);
    if length(fieldnames(logData))>=27 && length(logData.Attempt)>20
        count=count+1;
        if count==1
            logDataWeek.date=[logData.date];
            logDataWeek.subject=[logData.subject];
            logDataWeek.startTime=[logData.startTime];
            logDataWeek.taskLevel=[int2str(logData.taskLevel)];
            logDataWeek.combined=[logDataWeek.date];
        
        elseif count==length(direct)-5
           logDataWeek.combined=[logDataWeek.combined '-' logData.date];
           logDataWeek.taskLevel=[logDataWeek.taskLevel,', ',int2str(logData.taskLevel)];
           logDataWeek.date=[logDataWeek.date,', ',logData.date];
           logDataWeek.subject=[logDataWeek.subject,', ',logData.subject];
        else
            
            logDataWeek.taskLevel=[logDataWeek.taskLevel,', ',int2str(logData.taskLevel)];
            logDataWeek.date=[logDataWeek.date,', ',logData.date];
            logDataWeek.subject=[logDataWeek.subject,', ',logData.subject];
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
            
            ipsiHist   = hist(sessionSummary.ipsiRT, RTbins);
            contraHist = hist(sessionSummary.contraRT, RTbins);
            allHist    = hist(sessionSummary.allRT, RTbins);
            
            
            
            subplot(3,3,1),plot(RTbins, ipsiHist, 'color', [0 0 0.05*count]);
            ylim(ylimipsirtTrial)
            xlabel('Time(s)','fontsize',fontFigure) 
            ylabel('# Trial','fontsize',fontFigure)
            hold on
            title('completed RT;Ipsi','fontsize',fontFigure);
            
            
            subplot(3,3,2),plot(RTbins, contraHist, 'color', [0 0.05*count 0]);
            ylim(ylimcontrartTrial)
            xlabel('Time(s)','fontsize',fontFigure)
            hold on
            title('completed RT; Contra','fontsize',fontFigure);
           
            
            subplot(3,3,3),plot(RTbins, allHist, 'color', [0.05*count 0 0]);
            ylim(ylimallrtTrial)
            xlabel('Time(s)','fontsize',fontFigure) 
            hold on
            title('completed RT; All','fontsize',fontFigure);
            
            
            
            sessionSummary.ipsiMT   = logDataWeek.MT(completeTargetIpsi);
            sessionSummary.contraMT = logDataWeek.MT(completeTargetContra);
            sessionSummary.allMT    = logDataWeek.MT(sessionSummary.complete);
            
            ipsiHist   = hist(sessionSummary.ipsiMT, MTbins);
            contraHist = hist(sessionSummary.contraMT, MTbins);
            allHist    = hist(sessionSummary.allMT, MTbins);
            
           subplot(3,3,4),plot(MTbins, ipsiHist, 'color', [0 0 0.05*count]);
           ylim(ylimipsirtTrial)
           xlabel('Time(s)','fontsize',fontFigure) 
           ylabel('# Trial','fontsize',fontFigure)
           hold on
           title('completed MT;Ipsi','fontsize',fontFigure);
           
            
           subplot(3,3,5),plot(MTbins, contraHist, 'color', [0 0.05*count 0]);
           ylim(ylimcontrartTrial)
           xlabel('Time(s)','fontsize',fontFigure) 
           hold on
           title('completed MT; Contra','fontsize',fontFigure);
           
           
           subplot(3,3,6),plot(MTbins, allHist, 'color', [0.05*count 0 0]);
           ylim(ylimallrtTrial)
           xlabel('Time(s)','fontsize',fontFigure) 
           hold on
           title('completed MT; All','fontsize',fontFigure);
          
            
            sessionSummary.ipsiRTMT   = logDataWeek.MT(completeTargetIpsi) + logDataWeek.RT(completeTargetIpsi);
            sessionSummary.contraRTMT = logDataWeek.MT(completeTargetContra) + logDataWeek.RT(completeTargetContra);
            sessionSummary.allRTMT    = logDataWeek.MT(sessionSummary.complete) + logDataWeek.RT(sessionSummary.complete);
            
            ipsiHist   = hist(sessionSummary.ipsiRTMT, MTbins);
            contraHist = hist(sessionSummary.contraRTMT, MTbins);
            allHist    = hist(sessionSummary.allRTMT, MTbins);
            
           subplot(3,3,7),plot(MTbins, ipsiHist, 'color', [0 0 0.05*count]);
           ylim(ylimipsirtTrial)
           xlabel('Time(s)','fontsize',fontFigure) 
           ylabel('# Trial','fontsize',fontFigure)
           hold on
           title('completed MT+RT;Ipsi','fontsize',fontFigure);
          
            
           subplot(3,3,8),plot(MTbins, contraHist, 'color', [0 0.05*count 0]);
           ylim(ylimcontrartTrial)
           xlabel('Time(s)','fontsize',fontFigure) 
           hold on
           title('completed MT+RT; Contra','fontsize',fontFigure);
          
           
           subplot(3,3,9),plot(MTbins, allHist, 'color', [0.05*count 0 0]);
           xlabel('Time(s)','fontsize',fontFigure) 
           ylim(ylimallrtTrial)
           hold on
           title('completed MT+RT; All','fontsize',fontFigure);
           
        
       if count==length(direct)-5
        A=cell(1,3);   
        A{1,1} = ['Subject: ' logData.subject];
        A{1,2} = ['Date: ' logDataWeek.date];
        A{1,3} = ['Task Level: ' logDataWeek.taskLevel];
        mls = sprintf('%s\n%s\n%s',A{1,1},A{1,2},A{1,3});
       name=fname(1).name ;
       textString{1} = [name(1:5) '(' logDataWeek.combined ')_LogAnalysisRTMT'];
       %# centimeters units
       textLoc = [];
       set(gcf, 'PaperPosition', [xMargin yMargin xSize ySize]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
       set(gcf, 'PaperSize', [X Y]); %Keep the same paper size
       figureSize = get(gcf,'Position');
        uicontrol('Style','text',...
                'String',mls,...
                'Position',[140 2510 1600 150],...
                'BackgroundColor','white','fontsize',fontTitle);
            cd(graphFolder);
            saveas(gcf, textString{1}, 'pdf')  
            
        figure
        subplot(3,3,1),plot(ipsiAttempt,'color','b')
        ylim(ylimipsiTrial)
        xlabel('Day','fontsize',fontFigure)
        ylabel('# Trials','fontsize',fontFigure)
        hold on
        plot(ipsiComplete,'color','g')
        plot(ipsiCorrect,'color','r')
        title('Ipsi Attempt,Complete,Correct','fontsize',fontFigure);
        legend('Attempt','Complete','Correct','Location','SouthEast');
        
        subplot(3,3,2),plot(contraAttempt,'color','b')
        ylim(ylimcontraTrial)
        xlabel('Day','fontsize',fontFigure)
        hold on
        plot(contraComplete,'color','g')
        plot(contraCorrect,'color','r')
        title('Contra Attempt,Complete,Correct','fontsize',fontFigure);
        legend('Attempt','Complete','Correct','Location','SouthEast');
        
        subplot(3,3,3),plot(allAttempt,'color','b')
        xlabel('Day','fontsize',fontFigure)
        ylim(ylimallTrial)
        hold on
        plot(allComplete,'color','g')
        plot(allCorrect,'color','r')
        title('All Attempt,Complete,Correct','fontsize',fontFigure);
        legend('Attempt','Complete','Correct','Location','SouthEast');
        

subplot(3,3,4),plot(ipsiAccuracy,'color','r')
       ylim(ylimAccuracy)
       xlabel('Day','fontsize',fontFigure)
       ylabel('% Accurate','fontsize',fontFigure)
       hold on
       plot(contraAccuracy,'color','g')
       plot(allAccuracy,'color','b')
       title('Accuracy','fontsize',fontFigure); 
       legend('Ipsi','Contra','All','Location','SouthEast');

subplot(3,3,5),plot(AccuracyCenter2,'color','r')
       ylim(ylimAccuracy)
       xlabel('Day','fontsize',fontFigure)
       ylabel('% Accurate','fontsize',fontFigure)
       hold on
       plot(AccuracyCenter3,'color','g')
       plot(AccuracyCenter4,'color','b')
       title('Accuracy','fontsize',fontFigure); 
       legend('Port 2','Port 3','Port 4','Location','SouthEast');       
       
A=cell(1,3);   
A{1,1} = ['Subject: ' logData.subject];
A{1,2} = ['Date: ' logDataWeek.date];
A{1,3} = ['Task Level: ' logDataWeek.taskLevel];
mls = sprintf('%s\n%s\n%s',A{1,1},A{1,2},A{1,3});

        textString{1} = [name(1:5) '(' logDataWeek.combined ')_LogAnalysisOutcome'];    
       set(gcf, 'PaperPosition', [xMargin yMargin xSize ySize]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
       set(gcf, 'PaperSize', [X Y]); %Keep the same paper size
       figureSize = get(gcf,'Position');
       uicontrol('Style','text',...
                'String',mls,...
                'Position',[140 2510 1600 150],...
                'BackgroundColor','white','fontsize',fontTitle);
            cd(graphFolder);
            saveas(gcf, textString{1}, 'pdf')
            cd(parentFolder);
            cd(direct(ii).name);
       close all
      end
      cd(parentFolder);      
    else
        cd(parentFolder);
        continue;
    end
    cd(parentFolder);
end