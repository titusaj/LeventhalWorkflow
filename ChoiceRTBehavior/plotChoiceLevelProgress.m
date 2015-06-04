function plotChoiceLevelProgress(nasPath)

choiceRTdifficulty = cell(1,10);
choiceRTdifficulty{1}  = 'poke any';
choiceRTdifficulty{2}  = 'very easy';
choiceRTdifficulty{3}  = 'easy';
choiceRTdifficulty{4}  = 'standard';
choiceRTdifficulty{5}  = 'advanced';
choiceRTdifficulty{6}  = 'choice VE';
choiceRTdifficulty{7}  = 'choice easy';
choiceRTdifficulty{8}  = 'choice standard';
choiceRTdifficulty{9}  = 'choice advanced';
choiceRTdifficulty{10} = 'testing';

rootdir = fullfile(nasPath,'R00*/*/*/*.log');
logFiles = rdir(rootdir);

%remove old log files, could use regex
logFilenames = {};
jj = 1;
for ii=1:length(logFiles)
    if isempty(strfind(logFiles(ii).name,'_old.log'))
        logFilenames{jj} = logFiles(ii).name;
        jj = jj + 1;
    end
end

currentSubject = '';
nRat = 0;
allSubjects = {};
compiledDays = [];
for ii=1:length(logFilenames)
    logData = readLogData(logFilenames{ii});
    % is this a new subject?
    if ~strcmp(logData.subject,currentSubject)
        % skip logging data if poke any level is not present
        if logData.taskLevel ~= 0
            continue;
        end
        currentSubject = logData.subject;
        currentStartDate = datenum(logData.date,'yyyymmdd');
        currentLevel = 0;
        nRat = nRat + 1;
        compiledDays(nRat,:) = zeros(1,9);
        allSubjects{nRat} = logData.subject;
    end
    % compile to choice advanced
    if logData.taskLevel == currentLevel + 1 && logData.taskLevel < 9
        % enter as taskLevel+1 so level 0 has a zero entry
        compiledDays(nRat,logData.taskLevel+1) = datenum(logData.date,'yyyymmdd') - currentStartDate;
        currentLevel = logData.taskLevel;
    end
end

h = figure('position',[100 100 900 400]);
for ii=1:size(compiledDays,1)
    % skip mishaps
    if ~any(compiledDays(ii,:))
        continue;
    end
    hold on;
    levelRange = compiledDays(ii,2:end) > 0;
    plot(compiledDays(ii,logical([1 levelRange])),'lineWidth',5);
end
for ii=1:9
    hold on;
    set(gca,'XTick',ii,'XTickLabel',choiceRTdifficulty{ii});
end
th = rotateticklabel(h,45);
grid on;
xlim([1 9]);
disp('end');