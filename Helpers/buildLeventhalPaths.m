function leventhalPaths = buildLeventhalPaths(sessionConf,varargin)

leventhalPaths = {};
ratID = sessionConf.sessionName(1:5);
leventhalPaths.rawdata = fullfile(sessionConf.nasPath,ratID,[ratID,'-rawdata'],sessionConf.sessionName);
leventhalPaths.processed = fullfile(sessionConf.nasPath,ratID,[ratID,'-processed'],sessionConf.sessionName);
leventhalPaths.graphs = fullfile(sessionConf.nasPath,ratID,[ratID,'-graphs'],sessionConf.sessionName);
leventhalPaths.channels = fullfile(leventhalPaths.rawdata,sessionConf.sessionName);

% pass in makeFolders (ie. {'rawData'})
if nargin == 2
    makeFolders = varargin{1};
    allFields = fieldnames(leventhalPaths);
    for ii=1:length(makeFolders)
        if ismember(makeFolders{ii},allFields)
            if ~exist(leventhalPaths.(makeFolders{ii}),'dir')
                mkdir(leventhalPaths.(makeFolders{ii}));
            end
        end
    end
end