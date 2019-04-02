function [ccg,t] = rippleCCG(chan1,chan2,varargin)
% combines bz_FindRipples, CCG, and PlotCCG to create a CCG from 2 channels
%
% Inputs:
%   chan1 - first channel
%   chan2 - second channel
%
%   Optional inputs:
%       'duration' - the duration of each xcorrelation in CCG (in seconds)
%       'binSize' - the bin size in CCG (in seconds)
%       'full' - the 'full' property in PlotCCG (either 'on' or 'off' by
%       default
%       'threshold' - the threshold for bz_FindRipples (default [2 5])
%
% Note: This is the Delenn version
p = inputParser;
addParameter(p,'duration',0.5);
addParameter(p,'binSize',0.01);
addParameter(p,'full','off');
addParameter(p,'threshold',[2 5]);
parse(p,varargin{:})

dur = p.Results.duration;
binsz = p.Results.binSize;
state = p.Results.full;
thresh = p.Results.threshold;

[ripples1] = bz_FindRipples(cd, chan1,'thresholds',thresh,'savemat',true);
chan1TimeData= ripples1.timestamps;
[ripples2] = bz_FindRipples(cd, chan2,'thresholds',thresh,'savemat',true);
chan2TimeData= ripples2.timestamps;
chan1Times = [];
chan2Times = [];

for i=1:length(chan1TimeData)
    chan1Add = [chan1TimeData(i,1) 1];
    chan1Times = [chan1Times;chan1Add];
end
for i=1:length(chan2TimeData)
    chan2Add = [chan2TimeData(i,1) 2];
    chan2Times = [chan2Times;chan2Add];
end

ccgData = [chan1Times;chan2Times];

[ccg,t] = CCG(ccgData(:,1),ccgData(:,2),'duration',dur,'binSize',binsz);
PlotCCG(t,ccg,'full',state)
savefig(['CCGfigure_chans_' num2str(chan1) '_' num2str(chan2) '_thresh_' num2str(thresh(1)) '_' num2str(thresh(2))])
end

% ignore this:
% function [ccg,t] = rippleCCG(basepath,channel)
% rpls = bz_FindRipples(basepath, channel,'savemat',true);
% t = rpls.timestamps(:,1);
% grp = [1:length(t)];
% CCG(t,grp);
% end