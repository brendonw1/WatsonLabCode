function PlotAll5minSWSSpectra

SWS5MinSpectra = GatherAll5minSWSSpectra;
normidxs = find(SWS5MinSpectra.standardFs>5 & SWS5MinSpectra.standardFs<100);
numfreqs = length(SWS5MinSpectra.standardFs);
numsess = size(SWS5MinSpectra.basepaths,2);
% wspect = zscore(SWS5MinSpectra.wspect')'+100;
% rspect = zscore(SWS5MinSpectra.rspect')'+100;
% sspect = zscore(SWS5MinSpectra.sspect')'+100;
% f5mspect = zscore(SWS5MinSpectra.f5mspect')'+100;
% l5mspect = zscore(SWS5MinSpectra.l5mspect')'+100;
% wspect = SWS5MinSpectra.wspect./repmat(mean(wspect(:,normidxs),2),1,numfreqs);
% rspect = SWS5MinSpectra.rspect./repmat(mean(rspect(:,normidxs),2),1,numfreqs);
% sspect = SWS5MinSpectra.sspect./repmat(mean(sspect(:,normidxs),2),1,numfreqs);
% f5mspect = SWS5MinSpectra.f5mspect./repmat(mean(f5mspect(:,normidxs),2),1,numfreqs);
% l5mspect = SWS5MinSpectra.l5mspect./repmat(mean(l5mspect(:,normidxs),2),1,numfreqs);
wspect = log10(SWS5MinSpectra.wspect);
rspect = log10(SWS5MinSpectra.rspect);
sspect = log10(SWS5MinSpectra.sspect);
prespect = log10(SWS5MinSpectra.prespect);
postspect = log10(SWS5MinSpectra.postspect);
% wspect = zscore(wspect')'+100;
% rspect = zscore(rspect')'+100;
% sspect = zscore(sspect')'+100;
% f5mspect = zscore(f5mspect')'+100;
% l5mspect = zscore(l5mspect')'+100;
% wspect = SWS5MinSpectra.wspect;
% rspect = SWS5MinSpectra.rspect;
% sspect = SWS5MinSpectra.sspect;
% f5mspect = SWS5MinSpectra.f5mspect;
% l5mspect = SWS5MinSpectra.l5mspect;

%Plot raw normalized
% figure;
% loglog(wspect','c')
% hold on;loglog(rspect','k')
% hold on;loglog(sspect','m')

wakeMedian = median(wspect,1);
remMedian = median(rspect,1);
swsMedian = median(sspect,1);
preswsMedian = median(prespect,1);
postswsMedian = median(postspect,1);

wakeVar = nanstd(wspect,1,1);
remVar = nanstd(rspect,1,1);
swsVar = nanstd(sspect,1,1);
f5mswsVar = nanstd(prespect,1,1);
l5mswsVar = nanstd(postspect,1,1);
% wakeVar = nansem(wspect);
% remVar = nansem(rspect);
% swsVar = nansem(sspect);
% f5mswsVar = nansem(f5mspect);
% l5mswsVar = nansem(l5mspect);

plotxmin = 0.5;
plotxmax = 150;
col = RainbowColors(5);

%% all states figure
h = figure('position',[0 0 400 900],'name','All5minSWSSpectra');
subplot(2,1,1)
% semilogx(SWS5MinSpectra.standardFs,1,5,wspect,'k')
semilogx(repmat(SWS5MinSpectra.standardFs,1,numsess),wspect','color',col(1,:))
hold on
semilogx(repmat(SWS5MinSpectra.standardFs,1,numsess),rspect','color',col(2,:))
semilogx(repmat(SWS5MinSpectra.standardFs,1,numsess),sspect','color',col(3,:))
semilogx(repmat(SWS5MinSpectra.standardFs,1,numsess),prespect','color',col(4,:))
semilogx(repmat(SWS5MinSpectra.standardFs,1,numsess),postspect','color',col(5,:))
set(gca,'xlim',[plotxmin plotxmax])
legend({'Wake','REM','SWS','FirstPacket','LastPacket'})

subplot(2,1,2)
boundedline(log10(repmat(SWS5MinSpectra.standardFs,1,5)),...
    (cat(1,wakeMedian,remMedian,swsMedian,preswsMedian,postswsMedian))',...
    (cat(3,wakeVar',remVar',swsVar',f5mswsVar',l5mswsVar')),...
    'cmap',col,'transparency',.5,'alpha');
pause(0.5)
set(gca,'xlim',[log(plotxmin) log10(plotxmax)])
legend({'Wake';'REM';'SWS';'FirstPacket';'LastPacket'})

%% Pre v Post figure
h = figure('position',[0 0 800 900],'name','All5minSWSSpectra');
subplot(2,2,1)


MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Spectra',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Spectra',h,'png')

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/July2015SleepProject/Spectra',SWS5MinSpectra);