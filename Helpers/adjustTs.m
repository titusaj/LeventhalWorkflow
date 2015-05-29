function ts = adjustTs(ts,oldFs,newFs)
% ts
% old is 24414
% new is 24414.0625

samples = ts * oldFs;
ts = samples / newFs;