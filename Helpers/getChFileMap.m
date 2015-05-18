function fullSevFiles = getChFileMap(channelPath)
% Function that returns a of SEV files within a channel path

%Look for all .SEV files within the path that was input
sevFiles = dir(fullfile(channelPath,'*.sev'));
chFileMap = zeros(length(sevFiles),1);
fullSevFiles = cell(length(sevFiles),1);

%Loop through each SEV file and get the ch value and put the file into
%the map
for ii=1:length(sevFiles)
    chFileMap(ii) = getSEVChFromFilename(sevFiles(ii).name);
    fullSevFiles{ii} = fullfile(channelPath,sevFiles(ii).name);
end
fullSevFiles(chFileMap) = fullSevFiles; %remap so they are in order