function [cellStateRates,modulations] = StateModulationIndices(S,intervals,plotting)
% remswsmodulationindex = remrate/swsrate;

if ~exist('plotting','var')
    plotting = 0;
end

%% Get REM episode rates
allremcellrates = zeros(length(length(intervals{5})),size(S,1));
for a = 1:size(S,1)
    allremcellrates(:,a) = Data(intervalRate(S{a},intervals{5}));
end
meanremcellrates = mean(allremcellrates,1);%average across REM episodes

%% Get SWS episode rates
allswscellrates = zeros(length(length(intervals{3})),size(S,1));
for a = 1:size(S,1)
    allswscellrates(:,a) = Data(intervalRate(S{a},intervals{3}));
end
meanswscellrates = mean(allswscellrates,1);%average across REM episodes

%% Get Wake episode rates
allwakecellrates = zeros(length(length(intervals{1})),size(S,1));
for a = 1:size(S,1)
    allwakecellrates(:,a) = Data(intervalRate(S{a},intervals{1}));
end
meanwakecellrates = mean(allwakecellrates,1);%average across REM episodes

totalrates = Rate(S);

%% Save episode rates and mean rates
cellStateRates = v2struct(totalrates,allwakecellrates, meanwakecellrates, allswscellrates, meanswscellrates, allremcellrates, meanremcellrates);

%% Save mean modulation indices
remswsmodulationindex = meanremcellrates./meanswscellrates;
wakeswsmodulationindex = meanwakecellrates./meanswscellrates;
remwakemodulationindex = meanremcellrates./meanwakecellrates;

modulations = v2struct(remswsmodulationindex,wakeswsmodulationindex,remwakemodulationindex);

%% 

%% plotting
if plotting
    figure
    plot(allwakecellrates,wakeswsmodulationindex,'.')
    xlabel('Cell Firing Rate')
    ylabel('Wake-SWS Modulation')
end