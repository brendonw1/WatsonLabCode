function SpikingAnalysis_REMStartStopLockedSpiking(basename,basepath,episodes,S,Se,Si)

spanhalfsize = 50*10000;%based on minimum REM length of 50s... unless want to make asymmetrical
binwidth = 5*10000;%5sec bins
eventbin = ceil(spanhalfsize/binwidth);
numbins = spanhalfsize/binwidth;
% bins = -endbin:50000:endbin;

for a = 1:length(episodes);
    remstart = Start(subset(episodes{a},2));
    span = intervalSet(remstart-spanhalfsize,remstart+spanhalfsize);
    S2 = Restrict(S,span);
    Se2 = Restrict(Se,span);
    Si2 = Restrict(Si,span);
    REMStartBinCounts(:,:,a) = Data(MakeQfromS(S2,binwidth))';
    REMStartBinCountsNorm(:,:,a) = bwnormalize_array(REMStartBinCounts(:,:,a)')';
    REMStartBinCountsE(:,:,a) = Data(MakeQfromS(Se2,binwidth))';
    REMStartBinCountsNormE(:,:,a) = bwnormalize_array(REMStartBinCountsE(:,:,a)')';
    REMStartBinCountsI(:,:,a) = Data(MakeQfromS(Si2,binwidth))';
    REMStartBinCountsNormI(:,:,a) = bwnormalize_array(REMStartBinCountsI(:,:,a)')';

    remstop = End(subset(episodes{a},2));
    span = intervalSet(remstop-spanhalfsize,remstop+spanhalfsize);
    S2 = Restrict(S,span);
    Se2 = Restrict(Se,span);
    Si2 = Restrict(Si,span);
    REMStopBinCounts(:,:,a) = Data(MakeQfromS(S2,binwidth))';
    REMStopBinCountsNorm(:,:,a) = bwnormalize_array(REMStopBinCounts(:,:,a)')';
    REMStopBinCountsE(:,:,a) = Data(MakeQfromS(Se2,binwidth))';
    REMStopBinCountsNormE(:,:,a) = bwnormalize_array(REMStopBinCountsE(:,:,a)')';
    REMStopBinCountsI(:,:,a) = Data(MakeQfromS(Si2,binwidth))';
    REMStopBinCountsNormI(:,:,a) = bwnormalize_array(REMStopBinCountsI(:,:,a)')';
end

%REM start triggered avg
h = figure;
set(h,'Position',[1100 225 825 750],'name',[basename,'_REMStartTriggeredAvg'])
subplot(3,2,1)
hold on
plot(sum(sum(REMStartBinCounts,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all cells around REM start')
subplot(3,2,2)
hold on
errorbar(mean(sum(REMStartBinCountsNorm,1),3),std(sum(REMStartBinCountsNorm,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all cells around REM start')

subplot(3,2,3)
hold on
plot(sum(sum(REMStartBinCountsE,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all E cells around REM start')
subplot(3,2,4)
hold on
errorbar(mean(sum(REMStartBinCountsNormE,1),3),std(sum(REMStartBinCountsNormE,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all E cells around REM start')

subplot(3,2,5)
hold on
plot(sum(sum(REMStartBinCountsI,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all I cells around REM start')
subplot(3,2,6)
hold on
errorbar(mean(sum(REMStartBinCountsNormI,1),3),std(sum(REMStartBinCountsNormI,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all I cells around REM start')

%REM stop triggered avg
h = figure;
set(h,'Position',[1100 225 825 750],'name',[basename,'_REMStopTriggeredAvg'])
subplot(3,2,1)
hold on
plot(sum(sum(REMStopBinCounts,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all cells around REM stop')
subplot(3,2,2)
hold on
errorbar(mean(sum(REMStopBinCountsNorm,1),3),std(sum(REMStopBinCountsNorm,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all cells around REM stop')

subplot(3,2,3)
hold on
plot(sum(sum(REMStopBinCountsE,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all E cells around REM stop')
subplot(3,2,4)
hold on
errorbar(mean(sum(REMStopBinCountsNormE,1),3),std(sum(REMStopBinCountsNormE,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all E cells around REM stop')

subplot(3,2,5)
hold on
plot(sum(sum(REMStopBinCountsI,1),3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Raw sum of spike rates of all I cells around REM stop')
subplot(3,2,6)
hold on
errorbar(mean(sum(REMStopBinCountsNormI,1),3),std(sum(REMStopBinCountsNormI,1),0,3))
plot([eventbin eventbin],get(gca,'YLim'),'-g')
axis tight
title('Summed normalized spike rates of all I cells around REM stop')



%save figs
if ~exist(fullfile(basepath,'SWSREMSWSEpisodeFigs'),'dir')
    mkdir(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
end
cd(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
saveallfigsas('fig')
cd(basepath)