function ChorSol = ChoristerSoloist(basepath,basename)
% Brendon function calling Dan L's SpkTrigPopRate to evaluate
% chorister/solist-ness of each cell.  Based on Okun et al 2015.  

%% defaults
binseconds = 0.05;
% states = [1,3,5];

%% Prep/loading
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
% 
% load(fullfile(basepath,[basename '_SStable.mat']))
% load(fullfile(basepath,[basename '_Intervals.mat']))
% load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))

%% Calculation
% Overall... could restrict to each pre-wake
for each cell
    get S
    oneSeries(S(allbut thiscell))
    ccg = ccg(s,otherS,1000ms)
    
end

%% Calculate per timebin
bins = every300 sec

SpikeTransferPerPacketPortion




% [ZeroLagCorrelation, CorrelationVects, VectBinTimes] = SpkTrigPopRate( spkObject,intervals,states,binseconds,GoodSleepInterval );
% 
% ChorSol = v2struct(ZeroLagCorrelation,CorrelationVects,VectBinTimes);
% 
% save(fullfile(basepath,[basename '_ChorSol.mat'],'ChorSol')