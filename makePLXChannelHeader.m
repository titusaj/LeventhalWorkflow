function makePLXChannelHeader(PLXid,sessionConf,tetrodeChannels,tetrodeName)

for ii=1:length(tetrodeChannels)
    chInfo.tetName  = [sessionConf.sessionName,'_',tetrodeName];
    chInfo.wireName = sprintf('%s_W%02d', tetrodeName, ii);
    
    chInfo.wireNum   = ii; %tetrode number
    chInfo.WFRate    = sessionConf.Fs;
    chInfo.SIG       = tetrodeChannels(ii);  %channel number
    chInfo.refWire   = 0;     % not sure exactly what this is; Alex had it set to zero
    chInfo.gain      = 300;
    chInfo.filter    = 0;    % not sure what this is; Alex had it set to zero
    chInfo.thresh    = 0; % does this even matter anywhere?
    chInfo.numUnits  = 0;    % no sorted units
    chInfo.sortWidth = sessionConf.waveLength;
    chInfo.comment   = 'created with Spikey, makePLXChannelHeader';
    
    writePLXChanHeader(PLXid, chInfo);
end