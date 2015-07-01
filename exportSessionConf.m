function sessionConf = exportSessionConf(sessionName,varargin)
% This function exports a configuration file for a session so
% that processing can be offloaded to a non-networked machine.
% INPUTS:
%   sessionName : ex. R0036_20150225a
%   varargin, saveDir: where you want this config file save, right now the
%   extractSpikesTDT script prompts for the location of this file

% 7/1/15 Fred Edits for 50micron analysis. Simplify and Take out sql shit
%
%


for iarg = 1 : 2 : nargin - 1
    switch varargin{iarg}
        case 'sessionConfPath'
            sessionConfPath = varargin{iarg + 1};
        case 'nasPath'
            nasPath = varargin{iarg + 1};
    end
end

%set up fields of struct
sessionConf = struct;
sessionConf.sessionName = sessionName;
sessionConf.ratID = input('What is ratID?','s')
sessionConf.nasPath = uigetdir



%[~,sessionConf.ratID] = sql_getSubjectFromSession(sessionName);
%chMap = sql_getChannelMap(sessionConf.ratID);
%sessionConf.chMap = chMap.chMap;
%sessionConf.tetrodeNames = chMap.tetNames;
%try
%    sessionConf.validMasks = sql_getAllTetChannels(sessionConf.sessionName);
%    sessionConf.lfpChannels = sql_getLFPChannels(sessionConf.sessionName);
%catch
%    disp('No tetrode session found: validMasks and lfpChannels not valid');
%end

% if exist('nasPath','var')
%     sessionConf.nasPath = nasPath;
% else
%     sessionConf.nasPath = sql_findNASpath(sessionConf.ratID);
% end

leventhalPaths = buildLeventhalPaths(sessionConf);
sevFiles = dir(fullfile(leventhalPaths.channels,'*.sev'));
if isempty(sevFiles)
    disp('No SEV files found');
    sessionConf.Fs = 0;
else
    header = getSEVHeader(fullfile(leventhalPaths.channels,sevFiles(1).name));
    sessionConf.Fs = header.Fs;
end

sessionConf.waveLength = 48;
sessionConf.peakLoc = 16;
sessionConf.deadTime = round(sessionConf.Fs/1000); %see getSpikeLocations.m

if exist('sessionConfPath','var')
    filename = ['session_conf_',sessionName,'.mat'];
    filePath = fullfile(sessionConfPath,filename);
    save(filePath,'sessionConf');
    sessionConf.file = filePath;
end
