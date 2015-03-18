function mergeNEXFiles(nasPath,sessionName)

leventhalPaths = buildLeventhalPaths(nasPath,sessionName);
disp('Making box.nex file...');
TDTtoNex(sessionName,'nasPath',nasPath);
disp('Merging all .nex files...');
parts = strsplit(leventhalPaths.processed,filesep);
combineSessionNex_wf(fullfile(parts{1:end-1}));