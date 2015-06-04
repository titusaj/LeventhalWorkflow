function tsCell = leventhalNexTs(filename)
oldFs = 24414;
newFs = 24414.0625;

[nvar, names, types] = nex_info(filename);
tsCell = cellstr(names);

for ii=1:size(tsCell,1)
    [n, ts] = nex_ts(filename,tsCell{ii});
    ts = adjustTs(ts,oldFs,newFs);
    tsCell{ii,2} = ts;
end