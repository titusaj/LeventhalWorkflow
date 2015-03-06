function filePath=exportSessionConf(sessionName,saveDir)
% This function exports a configuration file for a session so
% that processing can be offloaded to a non-networked machine.
% INPUTS:
%   sessionName : ex. R0036_20150225a
%   saveDir: where you want this config file save, right now the
%   extractSpikesTDT script prompts for the location of this file

sessionConf = struct;
sessionConf.sessionName = sessionName;
[~,sessionConf.ratID] = sql_getSubjectFromSession(sessionName);
chMap = sql_getChannelMap(sessionConf.ratID);
sessionConf.chMap = chMap.chMap;
sessionConf.validMasks = sql_getAllTetChannels(sessionConf.sessionName);
sessionConf.tetrodeNames = chMap.tetNames;

% get this from file or DB
sessionConf.Fs = 2.441406250000000e+04;
sessionConf.waveLength = 24;
sessionConf.peakLoc = 8;
sessionConf.deadTime = round(sessionConf.Fs/1000); %see getSpikeLocations.m

filename = ['session_conf_',sessionName,'.mat'];
filePath = fullfile(saveDir,filename);
save(filePath,'sessionConf');