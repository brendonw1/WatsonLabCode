function DropSpikeTransferPredictionByWakeSleepEpoch


%% Gather synapse strengths
warning off

ST = GatherSpikeTransfersPerSleepPortion;
SlopesRatioE = ST.RatioChangeNormSlopeE;
SlopesRatioI = ST.RatioChangeNormSlopeI;

SynapseByStateAll = SpikeTransfer_GatherAllSpikeTransferByState;
%extract

ERatioWSSleep = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'WSSleep'));
ERatioWakeB = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
ERatioWakeA = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'wakea'));
ERatioFSWS = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'FSWS'));
ERatioLSWS = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'LSWS'));

ERatioWakeB3Q = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'wakeb3quarter'));
ERatioWakeA3Q = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'wakea3quarter'));
ERatioSWS3Q = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'sws3quarter'));
ERatioREM3Q = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'rem3quarter'));

IRatioWSSleep = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'WSSleep'));
IRatioWakeB = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
IRatioFSWS = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'FSWS'));
IRatioLSWS = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'LSWS'));
IRatioWakeB3Q = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'wakeb3quarter'));
IRatioWakeA3Q = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'wakea3quarter'));

%% Plot individual correlations and calculate correlation stats.

figure('position',[2 0 900 600]);%plot Wake,Sleep,Wake and SWS,REM under
axis tight
subplot(3,3,1)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioWakeB,SlopesRatioE,'loglog','max','none');
title('WakeB')
axis tight
subplot(3,3,2)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioWSSleep,SlopesRatioE,'loglog','max','none');
title('Sleep')
axis tight
subplot(3,3,3)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioWakeA,SlopesRatioE,'loglog','max','none');
title('WakeA')
axis tight
subplot(3,3,4)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioFSWS,SlopesRatioE,'loglog','max','none');
title('FirstSWS')
axis tight
subplot(3,3,7)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioLSWS,SlopesRatioE,'loglog','max','none');
title('LastSWS')
axis tight
subplot(3,3,5)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioWakeB3Q,SlopesRatioE,'loglog','max','none');
title('WakeB3Q')
axis tight
subplot(3,3,8)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioWakeA3Q,SlopesRatioE,'loglog','max','none');
title('WakeA3Q')
axis tight
subplot(3,3,6)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioSWS3Q,SlopesRatioE,'loglog','max','none');
title('SWS3Q')
axis tight
subplot(3,3,9)
[p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(ERatioREM3Q,SlopesRatioE,'loglog','max','none');
title('REM3Q')
axis tight
AboveTitle('ECnxns')

% figure('position',[2 0 900 600]);%plot Wake,Sleep,Wake and SWS,REM under
% subplot(2,2,1)
% [p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(IRatioWakeB,SlopesRatioI,'loglog','max','none');
% title('Wake')
% subplot(2,2,2)
% [p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(IRatioWSSleep,SlopesRatioI,'loglog','max','none');
% title('Sleep')
% subplot(2,2,3)
% [p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(IRatioFSWS,SlopesRatioI,'loglog','max','none');
% title('FirstSWS')
% subplot(2,2,4)
% [p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(IRatioLSWS,SlopesRatioI,'loglog','max','none');
% title('LastSWS')
% AboveTitle('ICnxns')
% 1;

% 
% figure('position',[2 0 1200 900]);%plot Wake,Sleep,Wake and SWS,REM under
% subplot(4,4,1)
%     [p_wakeb1qe,r,slope_wakeb1qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb1qe,SlopesRatioE,'loglog','max','none');
%     title('Wake Before Q1')
% subplot(4,4,2)
%     [p_wakeb2qe,r,slope_wakeb2qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb2qe,SlopesRatioE,'loglog','max','none');
%     title('Wake Before Q2')
% subplot(4,4,3)
%     [p_wakeb3qe,r,slope_wakeb3qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb3qe,SlopesRatioE,'loglog','max','none');
%     title('Wake Before Q3')
% subplot(4,4,4)
%     [p_wakeb4qe,r,slope_wakeb4qe,SlopeCI, intercept, yfit] = ScatterWStats(wakeb4qe,SlopesRatioE,'loglog','max','none');
%     title('Wake Before Q4')
% 
% subplot(4,4,5)
%     [p_wssws1qe,r,slope_wssws1qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws1qe,SlopesRatioE,'loglog','max','none');
%     title('SWS Q1')
% subplot(4,4,6)
%     [p_wssws2qe,r,slope_wssws2qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws2qe,SlopesRatioE,'loglog','max','none');
%     title('SWS Q2')
% subplot(4,4,7)
%     [p_wssws3qe,r,slope_wssws3qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws3qe,SlopesRatioE,'loglog','max','none');
%     title('SWS Q3')
% subplot(4,4,8)
%     [p_wssws4qe,r,slope_wssws4qe,SlopeCI, intercept, yfit] = ScatterWStats(wssws4qe,SlopesRatioE,'loglog','max','none');
%     title('SWS Q4')
% 
% subplot(4,4,9)
%     [p_wsrem1qe,r,slope_wsrem1qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem1qe,SlopesRatioE,'loglog','max','none');
%     title('REM Q1')
% subplot(4,4,10)
%     [p_wsrem2qe,r,slope_wsrem2qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem2qe,SlopesRatioE,'loglog','max','none');
%     title('REM Q2')
% subplot(4,4,11)
%     [p_wsrem3qe,r,slope_wsrem3qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem3qe,SlopesRatioE,'loglog','max','none');
%     title('REM Q3')
% subplot(4,4,12)
%     [p_wsrem4qe,r,slope_wsrem4qe,SlopeCI, intercept, yfit] = ScatterWStats(wsrem4qe,SlopesRatioE,'loglog','max','none');
%     title('REM Q4')
% 
% subplot(4,4,13)
%     [p_wakea1qe,r,slope_wakea1qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea1qe,SlopesRatioE,'loglog','max','none');
%     title('Wake After Q1')
% subplot(4,4,14)
%     [p_wakea2qe,r,slope_wakea2qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea2qe,SlopesRatioE,'loglog','max','none');
%     title('Wake After Q2')
% subplot(4,4,15)
%     [p_wakea3qe,r,slope_wakea3qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea3qe,SlopesRatioE,'loglog','max','none');
%     title('Wake After Q3')
% subplot(4,4,16)
%     [p_wakea4qe,r,slope_wakea4qe,SlopeCI, intercept, yfit] = ScatterWStats(wakea4qe,SlopesRatioE,'loglog','max','none');
%     title('Wake After Q4')
% 
% 1;    
% figure('position',[2 200 560 100])
% axes
% hold on
% patch([0 0 1 1],[0 1 1 0],val2col(slope_wakeb1qe));
%     if p_wakeb1qe < 0.05;plot(.5,.5,'*k');end
% patch([1 1 2 2],[0 1 1 0],val2col(slope_wakeb2qe));
%     if p_wakeb2qe < 0.05;plot(1.5,.5,'*k');end
% patch([2 2 3 3],[0 1 1 0],val2col(slope_wakeb3qe));
%     if p_wakeb3qe < 0.05;plot(2.5,.5,'*k');end
% patch([3 3 4 4],[0 1 1 0],val2col(slope_wakeb4qe));
%     if p_wakeb4qe < 0.05;plot(3.5,.5,'*k');end
% patch([4 4 5 5],[0 1 1 0],val2col(slope_wssws1qe));
%     if p_wssws1qe < 0.05;plot(4.5,.5,'*k');end
% patch([5 5 6 6],[0 1 1 0],val2col(slope_wssws2qe));
%     if p_wssws2qe < 0.05;plot(5.5,.5,'*k');end
% patch([6 6 7 7],[0 1 1 0],val2col(slope_wssws3qe));
%     if p_wssws3qe < 0.05;plot(6.5,.5,'*k');end
% patch([7 7 8 8],[0 1 1 0],val2col(slope_wssws4qe));
%     if p_wssws4qe < 0.05;plot(7.5,.5,'*k');end
% patch([8 8 9 9],[0 1 1 0],val2col(slope_wsrem1qe));
%     if p_wsrem1qe < 0.05;plot(8.5,.5,'*k');end
% patch([9 9 10 10],[0 1 1 0],val2col(slope_wsrem2qe));
%     if p_wsrem2qe < 0.05;plot(9.5,.5,'*k');end
% patch([10 10 11 11],[0 1 1 0],val2col(slope_wsrem3qe));
%     if p_wsrem3qe < 0.05;plot(10.5,.5,'*k');end
% patch([11 11 12 12],[0 1 1 0],val2col(slope_wsrem4qe));
%     if p_wsrem4qe < 0.05;plot(11.5,.5,'*k');end
% patch([12 12 13 13],[0 1 1 0],val2col(slope_wakea1qe));
%     if p_wakea2qe < 0.05;plot(12.5,.5,'*k');end
% patch([13 13 14 14],[0 1 1 0],val2col(slope_wakea2qe));
%     if p_wakea3qe < 0.05;plot(13.5,.5,'*k');end
% patch([14 14 15 15],[0 1 1 0],val2col(slope_wakea3qe));
%     if p_wakea3qe < 0.05;plot(14.5,.5,'*k');end
% patch([15 15 16 16],[0 1 1 0],val2col(slope_wakea4qe));
%     if p_wakea4qe < 0.05;plot(15.5,.5,'*k');end
% patch([3.9 3.9 4.1 4.1],[0 1 1 0],'k');
% patch([7.9 7.9 8.1 8.1],[0 1 1 0],'k');
% patch([11.9 11.9 12.1 12.1],[0 1 1 0],'k');
% title('WakeBs         SWSs         REMs         WakeAs')
% 
% figure('position',[2 200 560 100])
% axes
% hold on
% patch([0 0 1 1],[0 1 1 0],val2col(slope_wakeb1qe));
%     if p_wakeb1qe < 0.05;plot(.5,.5,'*k');end
% patch([1 1 2 2],[0 1 1 0],val2col(slope_wakeb2qe));
%     if p_wakeb2qe < 0.05;plot(1.5,.5,'*k');end
% patch([2 2 3 3],[0 1 1 0],val2col(slope_wakeb3qe));
%     if p_wakeb3qe < 0.05;plot(2.5,.5,'*k');end
% patch([3 3 4 4],[0 1 1 0],val2col(slope_wakeb4qe));
%     if p_wakeb4qe < 0.05;plot(3.5,.5,'*k');end
% patch([4 4 5 5],[0 1 1 0],val2col(slope_wssws1qe));
%     if p_wssws1qe < 0.05;plot(4.5,.5,'*k');end
% patch([5 5 6 6],[0 1 1 0],val2col(slope_wssws2qe));
%     if p_wssws2qe < 0.05;plot(5.5,.5,'*k');end
% patch([6 6 7 7],[0 1 1 0],val2col(slope_wssws3qe));
%     if p_wssws3qe < 0.05;plot(6.5,.5,'*k');end
% patch([7 7 8 8],[0 1 1 0],val2col(slope_wssws4qe));
%     if p_wssws4qe < 0.05;plot(7.5,.5,'*k');end
% patch([8 8 9 9],[0 1 1 0],val2col(slope_wakea1qe));
%     if p_wakea1qe < 0.05;plot(8.5,.5,'*k');end
% patch([9 9 10 10],[0 1 1 0],val2col(slope_wakea2qe));
%     if p_wakea2qe < 0.05;plot(9.5,.5,'*k');end
% patch([10 10 11 11],[0 1 1 0],val2col(slope_wakea3qe));
%     if p_wakea3qe < 0.05;plot(10.5,.5,'*k');end
% patch([11 11 12 12],[0 1 1 0],val2col(slope_wakea4qe));
%     if p_wakea4qe < 0.05;plot(11.5,.5,'*k');end
% patch([3.9 3.9 4.1 4.1],[0 1 1 0],'k');
% patch([7.9 7.9 8.1 8.1],[0 1 1 0],'k');
% title('WakeBs                SWSs                 WakeAs')

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

