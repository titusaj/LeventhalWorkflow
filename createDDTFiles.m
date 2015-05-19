function createDDTFiles(sessionConf)

leventhalPaths = buildLeventhalPaths(sessionConf);
fullSevFiles = getChFileMap(leventhalPaths.channels);
validChannelMatrix = sessionConf.chMap(:,2:end).*sessionConf.validMasks;
channelsToConvert = sort(validChannelMatrix(validChannelMatrix(:)>0));

for iCh = 1:length(channelsToConvert)
    disp(['Converting ch',num2str(channelsToConvert(iCh)),'...']);
    [sev,header] = read_tdt_sev(fullSevFiles{channelsToConvert(iCh)});
    sev = wavefilter(sev,6);
    sev = artifactThresh(sev,1,600);
    ddt_write_v([fullSevFiles{channelsToConvert(iCh)},'.ddt'],1,length(sev),header.Fs,sev/1000);
end