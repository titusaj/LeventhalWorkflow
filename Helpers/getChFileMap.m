function fullSevFiles = getChFileMap(sessionPath)
sevFiles = dir(fullfile(sessionPath,'*.sev'));
chFileMap = zeros(length(sevFiles),1);
fullSevFiles = cell(length(sevFiles),1);
for ii=1:length(sevFiles)
    chFileMap(ii) = getSEVChFromFilename(sevFiles(ii).name);
    fullSevFiles{ii} = fullfile(sessionPath,sevFiles(ii).name);
end
fullSevFiles(chFileMap) = fullSevFiles; %remap so they are in order