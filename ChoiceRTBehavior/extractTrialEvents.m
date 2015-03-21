function trialEvents = extractTrialEvents( events, trialInterval)
%
% usage: trialEvents = extractTrialEvents( events, trialInterval)
%
% function to find all events that occurred between the start of the
% current trial and the start of the next trial.
%
% INPUTS:
%   events - events structure from a nex data structure
%   trialInterval - 2-element vector containing the start and end times for
%       the individual trial. If this is the last trial, trialInterval(2)
%       should be set to zero
%
% OUTPUT:
%   trialEvents - structure identical to events, but contains only
%       timestamps from the current trial

numEvents = length(events);
trialEvents = cell(1, numEvents);

for iEvent = 1 : numEvents
    
    trialEvents{iEvent}.name = events{iEvent}.name;
    eventTS = events{iEvent}.timestamps;
    if trialInterval(2) == 0
        trialEvents{iEvent}.timestamps = eventTS(eventTS > trialInterval(1));
    else
        trialEvents{iEvent}.timestamps = eventTS(eventTS > trialInterval(1) & ...
                                         eventTS < trialInterval(2));
    end
                                         
end