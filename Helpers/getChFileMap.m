function fullSevFiles = getChFileMap(channelPath)
sevFiles = dir(fullfile(channelPath,'*.sev'));
chFileMap = zeros(length(sevFiles),1);
fullSevFiles = cell(length(sevFiles),1);
for ii=1:length(sevFiles)
    chFileMap(ii) = getSEVChFromFilename(sevFiles(ii).name);
    fullSevFiles{ii} = fullfile(channelPath,sevFiles(ii).name);
end
fullSevFiles(chFileMap) = fullSevFiles; %remap so they are in order