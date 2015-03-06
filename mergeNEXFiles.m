function mergeNEXFiles(nasPath,sessionName)

leventhalPaths = buildLeventhalPaths(nasPath,sessionName);
disp('Making box.nex file...');
TDTtoNex(nasPath,sessionName);
disp('Merging all .nex files...');
combineSessionNex_wf(leventhalPaths.processed);