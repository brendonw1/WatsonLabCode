function DropPredictionByWakeSleepEpoch

% Calculate Synapse strengths across various timepoints
% WSSnippets_SpikeRates_all('WakeB')
% WSSnippets_SpikeRates_all('wssleep')
% WSSnippets_SpikeRates_all('WakeA')
% WSSnippets_SpikeRates_all('wssws')
% WSSnippets_SpikeRates_all('wsrem')
% WSSnippets_SpikeRates_all('WakeB1quarter')
% WSSnippets_SpikeRates_all('WakeB2quarter')
% WSSnippets_SpikeRates_all('WakeB3quarter')
% WSSnippets_SpikeRates_all('WakeB4quarter')
% WSSnippets_SpikeRates_all('wssws1quartersleep')
% WSSnippets_SpikeRates_all('wssws2quartersleep')
% WSSnippets_SpikeRates_all('wssws3quartersleep')
% WSSnippets_SpikeRates_all('wssws4quartersleep')
% WSSnippets_SpikeRates_all('wsrem1quartersleep')
% WSSnippets_SpikeRates_all('wsrem2quartersleep')
% WSSnippets_SpikeRates_all('wsrem3quartersleep')
% WSSnippets_SpikeRates_all('wsrem4quartersleep')
% WSSnippets_SpikeRates_all('WakeA1quarter')
% WSSnippets_SpikeRates_all('WakeA2quarter')
% WSSnippets_SpikeRates_all('WakeA3quarter')
% WSSnippets_SpikeRates_all('WakeA4quarter')

%% Gather synapse strengths
warning off

Slopes = GatherWSSpikeSlopes;
% SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians('FLSWS');
% ESpikeRateEarly = SpikeWSSnippets.medianRatePreSpikesE;
% ESpikeRateLate = SpikeWSSnippets.medianRatePostSpikesE;
% ISpikeRateEarly = SpikeWSSnippets.medianRatePreSpikesI;
% ISpikeRateLate = SpikeWSSnippets.medianRatePostSpikesI;
pppE = Slopes.MedianOfNormE;

SynWSSnippets_WakeB = WSSnippets_GatherAllSpikeMedians('WakeB');
SynWSSnippets_WSSleep = WSSnippets_GatherAllSpikeMedians('wssleep');
SynWSSnippets_WakeA = WSSnippets_GatherAllSpikeMedians('WakeA');

SynWSSnippets_WSSWS = WSSnippets_GatherAllSpikeMedians('wssws');
SynWSSnippets_WSREM = WSSnippets_GatherAllSpikeMedians('wsrem');

SynWSSnippets_WakeB1quarter = WSSnippets_GatherAllSpikeMedians('WakeB1quarter');
SynWSSnippets_WakeB2quarter = WSSnippets_GatherAllSpikeMedians('WakeB2quarter');
SynWSSnippets_WakeB3quarter = WSSnippets_GatherAllSpikeMedians('WakeB3quarter');
SynWSSnippets_WakeB4quarter = WSSnippets_GatherAllSpikeMedians('WakeB4quarter');
SynWSSnippets_WSSWS1QuarterSleep = WSSnippets_GatherAllSpikeMedians('wssws1quartersleep');
SynWSSnippets_WSSWS2QuarterSleep = WSSnippets_GatherAllSpikeMedians('wssws2quartersleep');
SynWSSnippets_WSSWS3QuarterSleep = WSSnippets_GatherAllSpikeMedians('wssws3quartersleep');
SynWSSnippets_WSSWS4QuarterSleep = WSSnippets_GatherAllSpikeMedians('wssws4quartersleep');
SynWSSnippets_WSREM1QuarterSleep = WSSnippets_GatherAllSpikeMedians('wsrem1quartersleep');
SynWSSnippets_WSREM2QuarterSleep = WSSnippets_GatherAllSpikeMedians('wsrem2quartersleep');
SynWSSnippets_WSREM3QuarterSleep = WSSnippets_GatherAllSpikeMedians('wsrem3quartersleep');
SynWSSnippets_WSREM4QuarterSleep = WSSnippets_GatherAllSpikeMedians('wsrem4quartersleep');
SynWSSnippets_WakeA1quarter = WSSnippets_GatherAllSpikeMedians('WakeA1quarter');
SynWSSnippets_WakeA2quarter = WSSnippets_GatherAllSpikeMedians('WakeA2quarter');
SynWSSnippets_WakeA3quarter = WSSnippets_GatherAllSpikeMedians('WakeA3quarter');
SynWSSnippets_WakeA4quarter = WSSnippets_GatherAllSpikeMedians('WakeA4quarter');

%extract
wakebe = SynWSSnippets_WakeB.medianRatePreSpikesE;
wssleepe = SynWSSnippets_WSSleep.medianRatePreSpikesE;
wakeae = SynWSSnippets_WakeA.medianRatePreSpikesE;

wsswse = SynWSSnippets_WSSWS.medianRatePreSpikesE;
wsreme = SynWSSnippets_WSREM.medianRatePreSpikesE;

wakeb1qe = SynWSSnippets_WakeB1quarter.medianRatePreSpikesE;
wakeb2qe = SynWSSnippets_WakeB2quarter.medianRatePreSpikesE;
wakeb3qe = SynWSSnippets_WakeB3quarter.medianRatePreSpikesE;
wakeb4qe = SynWSSnippets_WakeB4quarter.medianRatePreSpikesE;
wssws1qe = SynWSSnippets_WSSWS1QuarterSleep.medianRatePreSpikesE;
wssws2qe = SynWSSnippets_WSSWS2QuarterSleep.medianRatePreSpikesE;
wssws3qe = SynWSSnippets_WSSWS3QuarterSleep.medianRatePreSpikesE;
wssws4qe = SynWSSnippets_WSSWS4QuarterSleep.medianRatePreSpikesE;
wsrem1qe = SynWSSnippets_WSREM1QuarterSleep.medianRatePreSpikesE;
wsrem2qe = SynWSSnippets_WSREM2QuarterSleep.medianRatePreSpikesE;
wsrem3qe = SynWSSnippets_WSREM3QuarterSleep.medianRatePreSpikesE;
wsrem4qe = SynWSSnippets_WSREM4QuarterSleep.medianRatePreSpikesE;
wakea1qe = SynWSSnippets_WakeA1quarter.medianRatePreSpikesE;
wakea2qe = SynWSSnippets_WakeA2quarter.medianRatePreSpikesE;
wakea3qe = SynWSSnippets_WakeA3quarter.medianRatePreSpikesE;
wakea4qe = SynWSSnippets_WakeA4quarter.medianRatePreSpikesE;


%% Plot individual correlations and calculate correlation stats.

figure('position',[2 0 900 600]);%plot Wake,Sleep,Wake and SWS,REM under
subplot(2,6,1:2)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(wakebe,pppE,'loglog','max','none');
title('Wake Before')
subplot(2,6,3:4)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(wssleepe,pppE,'loglog','max','none');
title('Sleep')
subplot(2,6,5:6)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(wakeae,pppE,'loglog','max','none');
title('Wake After')
subplot(2,6,8:9)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(wsswse,pppE,'loglog','max','none');
title('SWS')
subplot(2,6,10:11)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(wsreme,pppE,'loglog','max','none');
title('REM')


figure('position',[2 0 1200 900]);%plot Wake,Sleep,Wake and SWS,REM under
subplot(4,4,1)
    [p_wakeb1qe,r,slope_wakeb1qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb1qe,pppE,'loglog','max','none');
    title('Wake Before Q1')
subplot(4,4,2)
    [p_wakeb2qe,r,slope_wakeb2qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb2qe,pppE,'loglog','max','none');
    title('Wake Before Q2')
subplot(4,4,3)
    [p_wakeb3qe,r,slope_wakeb3qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb3qe,pppE,'loglog','max','none');
    title('Wake Before Q3')
subplot(4,4,4)
    [p_wakeb4qe,r,slope_wakeb4qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb4qe,pppE,'loglog','max','none');
    title('Wake Before Q4')

subplot(4,4,5)
    [p_wssws1qe,r,slope_wssws1qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws1qe,pppE,'loglog','max','none');
    title('SWS Q1')
subplot(4,4,6)
    [p_wssws2qe,r,slope_wssws2qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws2qe,pppE,'loglog','max','none');
    title('SWS Q2')
subplot(4,4,7)
    [p_wssws3qe,r,slope_wssws3qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws3qe,pppE,'loglog','max','none');
    title('SWS Q3')
subplot(4,4,8)
    [p_wssws4qe,r,slope_wssws4qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws4qe,pppE,'loglog','max','none');
    title('SWS Q4')

subplot(4,4,9)
    [p_wsrem1qe,r,slope_wsrem1qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem1qe,pppE,'loglog','max','none');
    title('REM Q1')
subplot(4,4,10)
    [p_wsrem2qe,r,slope_wsrem2qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem2qe,pppE,'loglog','max','none');
    title('REM Q2')
subplot(4,4,11)
    [p_wsrem3qe,r,slope_wsrem3qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem3qe,pppE,'loglog','max','none');
    title('REM Q3')
subplot(4,4,12)
    [p_wsrem4qe,r,slope_wsrem4qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem4qe,pppE,'loglog','max','none');
    title('REM Q4')

subplot(4,4,13)
    [p_wakea1qe,r,slope_wakea1qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea1qe,pppE,'loglog','max','none');
    title('Wake After Q1')
subplot(4,4,14)
    [p_wakea2qe,r,slope_wakea2qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea2qe,pppE,'loglog','max','none');
    title('Wake After Q2')
subplot(4,4,15)
    [p_wakea3qe,r,slope_wakea3qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea3qe,pppE,'loglog','max','none');
    title('Wake After Q3')
subplot(4,4,16)
    [p_wakea4qe,r,slope_wakea4qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea4qe,pppE,'loglog','max','none');
    title('Wake After Q4')

1;    
figure('position',[2 200 560 100])
axes
hold on
patch([0 0 1 1],[0 1 1 0],val2col(slope_wakeb1qe));
    if p_wakeb1qe < 0.05;plot(.5,.5,'*k');end
patch([1 1 2 2],[0 1 1 0],val2col(slope_wakeb2qe));
    if p_wakeb2qe < 0.05;plot(1.5,.5,'*k');end
patch([2 2 3 3],[0 1 1 0],val2col(slope_wakeb3qe));
    if p_wakeb3qe < 0.05;plot(2.5,.5,'*k');end
patch([3 3 4 4],[0 1 1 0],val2col(slope_wakeb4qe));
    if p_wakeb4qe < 0.05;plot(3.5,.5,'*k');end
patch([4 4 5 5],[0 1 1 0],val2col(slope_wssws1qe));
    if p_wssws1qe < 0.05;plot(4.5,.5,'*k');end
patch([5 5 6 6],[0 1 1 0],val2col(slope_wssws2qe));
    if p_wssws2qe < 0.05;plot(5.5,.5,'*k');end
patch([6 6 7 7],[0 1 1 0],val2col(slope_wssws3qe));
    if p_wssws3qe < 0.05;plot(6.5,.5,'*k');end
patch([7 7 8 8],[0 1 1 0],val2col(slope_wssws4qe));
    if p_wssws4qe < 0.05;plot(7.5,.5,'*k');end
patch([8 8 9 9],[0 1 1 0],val2col(slope_wsrem1qe));
    if p_wsrem1qe < 0.05;plot(8.5,.5,'*k');end
patch([9 9 10 10],[0 1 1 0],val2col(slope_wsrem2qe));
    if p_wsrem2qe < 0.05;plot(9.5,.5,'*k');end
patch([10 10 11 11],[0 1 1 0],val2col(slope_wsrem3qe));
    if p_wsrem3qe < 0.05;plot(10.5,.5,'*k');end
patch([11 11 12 12],[0 1 1 0],val2col(slope_wsrem4qe));
    if p_wsrem4qe < 0.05;plot(11.5,.5,'*k');end
patch([12 12 13 13],[0 1 1 0],val2col(slope_wakea1qe));
    if p_wakea2qe < 0.05;plot(12.5,.5,'*k');end
patch([13 13 14 14],[0 1 1 0],val2col(slope_wakea2qe));
    if p_wakea3qe < 0.05;plot(13.5,.5,'*k');end
patch([14 14 15 15],[0 1 1 0],val2col(slope_wakea3qe));
    if p_wakea3qe < 0.05;plot(14.5,.5,'*k');end
patch([15 15 16 16],[0 1 1 0],val2col(slope_wakea4qe));
    if p_wakea4qe < 0.05;plot(15.5,.5,'*k');end
patch([3.9 3.9 4.1 4.1],[0 1 1 0],'k');
patch([7.9 7.9 8.1 8.1],[0 1 1 0],'k');
patch([11.9 11.9 12.1 12.1],[0 1 1 0],'k');
title('WakeBs         SWSs         REMs         WakeAs')

figure('position',[2 200 560 100])
axes
hold on
patch([0 0 1 1],[0 1 1 0],val2col(slope_wakeb1qe));
    if p_wakeb1qe < 0.05;plot(.5,.5,'*k');end
patch([1 1 2 2],[0 1 1 0],val2col(slope_wakeb2qe));
    if p_wakeb2qe < 0.05;plot(1.5,.5,'*k');end
patch([2 2 3 3],[0 1 1 0],val2col(slope_wakeb3qe));
    if p_wakeb3qe < 0.05;plot(2.5,.5,'*k');end
patch([3 3 4 4],[0 1 1 0],val2col(slope_wakeb4qe));
    if p_wakeb4qe < 0.05;plot(3.5,.5,'*k');end
patch([4 4 5 5],[0 1 1 0],val2col(slope_wssws1qe));
    if p_wssws1qe < 0.05;plot(4.5,.5,'*k');end
patch([5 5 6 6],[0 1 1 0],val2col(slope_wssws2qe));
    if p_wssws2qe < 0.05;plot(5.5,.5,'*k');end
patch([6 6 7 7],[0 1 1 0],val2col(slope_wssws3qe));
    if p_wssws3qe < 0.05;plot(6.5,.5,'*k');end
patch([7 7 8 8],[0 1 1 0],val2col(slope_wssws4qe));
    if p_wssws4qe < 0.05;plot(7.5,.5,'*k');end
patch([8 8 9 9],[0 1 1 0],val2col(slope_wakea1qe));
    if p_wakea1qe < 0.05;plot(8.5,.5,'*k');end
patch([9 9 10 10],[0 1 1 0],val2col(slope_wakea2qe));
    if p_wakea2qe < 0.05;plot(9.5,.5,'*k');end
patch([10 10 11 11],[0 1 1 0],val2col(slope_wakea3qe));
    if p_wakea3qe < 0.05;plot(10.5,.5,'*k');end
patch([11 11 12 12],[0 1 1 0],val2col(slope_wakea4qe));
    if p_wakea4qe < 0.05;plot(11.5,.5,'*k');end
patch([3.9 3.9 4.1 4.1],[0 1 1 0],'k');
patch([7.9 7.9 8.1 8.1],[0 1 1 0],'k');
title('WakeBs                SWSs                 WakeAs')

% Get slopes, forget plotting fcn, just get basic slopes
% make plot of 16 blocks
% wb1,wb2,wb3,wb4,sws1,rem1,sws2,rem2,sws3,rem3,sws4,rem4,wa1,wa2,wa3,wa4
% 
% color each block
% -1 makes red
% 1 makes blue
%put solid vertical lines where sleep starts
%put text labels on each block
%^star if slope is diff from one

1;

function col = val2col(val)
if val<0
    col = [1 1+2*val 1];
else
    col = [1-10*val 1 1];
end
col(col<0) = 0;
col(col>1) = 1;

