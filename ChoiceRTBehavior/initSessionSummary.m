function sessionSummary = initSessionSummary()
%
% usage: 
%
% INPUTS:
%   none
%
% OUTPUTS:
%   sessionSummary - sessionSummary structure as output by analyze_choiceRTlogDataDaily

sessionSummary.correct      = 0;
sessionSummary.wrongMove    = 0;
sessionSummary.complete     = 0;
sessionSummary.falseStart   = 0;
sessionSummary.wrongStart   = 0;
sessionSummary.targetRight  = 0;
sessionSummary.moveRight    = 0;
sessionSummary.ftr          = 0;
sessionSummary.LHviol       = 0;
sessionSummary.MHviol       = 0;

sessionSummary.targetContra = 0;
sessionSummary.targetIpsi   = 0;

sessionSummary.moveContra   = 0;
sessionSummary.moveIpsi     = 0;

correctTargetContra = 0;
correctTargetIpsi   = 0;

completeTargetContra = 0;
completeTargetIpsi   = 0;

sessionSummary.acc = zeros(1,3);

sessionSummary.ipsiRT   = 0;
sessionSummary.contraRT = 0;
sessionSummary.allRT    = 0;

sessionSummary.ipsiMT   = 0;
sessionSummary.contraMT = 0;
sessionSummary.allMT    = 0;

sessionSummary.ipsiRTMT   = 0;
sessionSummary.contraRTMT = 0;
sessionSummary.allRTMT    = 0;