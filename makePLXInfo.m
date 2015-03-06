function PLXid = makePLXInfo(PLXfn,sessionConf,tetrodeChannels,dataLength)

sessionDateStr = sessionConf.sessionName(7:14);
sessionDateVec = datevec(sessionDateStr, 'yyyymmdd');

plxInfo.comment    = '';
plxInfo.ADFs       = sessionConf.Fs; % record the upsampled Fs as the AD freq for timestamps
plxInfo.numWires   = length(tetrodeChannels);
plxInfo.numEvents  = 0;
plxInfo.numSlows   = 0;
plxInfo.waveLength = sessionConf.waveLength;
plxInfo.peakLoc    = sessionConf.peakLoc;

plxInfo.year  = sessionDateVec(1);
plxInfo.month = sessionDateVec(2);
plxInfo.day   = sessionDateVec(3);

timeVector = datevec('12:00','HH:MM');
plxInfo.hour       = timeVector(4);
plxInfo.minute     = timeVector(5);
plxInfo.second     = 0;
plxInfo.waveFs     = sessionConf.Fs; % record the upsampled Fs as the waveform sampling frequency
plxInfo.dataLength = dataLength;

plxInfo.Trodalness     = length(tetrodeChannels); %Trodalness - 0,1 = single electrode, 2 = stereotrode, 4 = tetrode
plxInfo.dataTrodalness = 0; %this is set to 0 in the Plexon tetrode sample file

plxInfo.bitsPerSpikeSample = 16;
plxInfo.bitsPerSlowSample  = 16;

plxInfo.SpikeMaxMagnitudeMV = 10000;
plxInfo.SlowMaxMagnitudeMV  = 10000;

plxInfo.SpikePreAmpGain = 1; % gain before final amplification stage

PLXid = fopen(PLXfn, 'w');
disp('PLX file opened...')
writePLXheader(PLXid, plxInfo);