function PlotAll5minSWSSpectra(ep1name)

if ~exist('ep1name','var')
    ep1name = 'flsws';
end

SWSSpectra = GatherAll5minSWSSpectra(ep1name);
% normidxs = find(SWS5MinSpectra.standardFs>5 & SWS5MinSpectra.standardFs<100);
% numfreqs = length(SWS5MinSpectra.standardFs);
numsess = size(SWSSpectra.basepaths,2);
numsleeps = size(SWSSpectra.wspect,1);
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
wspect = log10(SWSSpectra.wspect);
rspect = log10(SWSSpectra.rspect);
sspect = log10(SWSSpectra.sspect);
prespect = log10(SWSSpectra.prespect);
postspect = log10(SWSSpectra.postspect);
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
preswsVar = nanstd(prespect,1,1);
postswsVar = nanstd(postspect,1,1);
% wakeVar = nansem(wspect);
% remVar = nansem(rspect);
% swsVar = nansem(sspect);
% f5mswsVar = nansem(f5mspect);
% l5mswsVar = nansem(l5mspect);

plotxmin = 0.5;
plotxmax = 150;
col = RainbowColors(5);

%% all states figure
h = figure('position',[0 0 400 800],'name',['All' ep1name 'Spectra_AllStates']);
subplot(2,1,1)
    % semilogx(SWS5MinSpectra.standardFs,1,5,wspect,'k')
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),wspect','color',col(1,:))
    hold on
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),rspect','color',col(2,:))
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),sspect','color',col(3,:))
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),prespect','color',col(4,:))
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),postspect','color',col(5,:))
    set(gca,'xlim',[plotxmin plotxmax])
    legend({'Wake','REM','SWS','FirstPacket','LastPacket'})
    axis square
subplot(2,1,2)
    boundedline(log10(repmat(SWSSpectra.standardFs,1,5)),...
        (cat(1,wakeMedian,remMedian,swsMedian,preswsMedian,postswsMedian))',...
        (cat(3,wakeVar',remVar',swsVar',preswsVar',postswsVar')),...
        'cmap',col,'transparency',.5,'alpha');
    pause(0.5)
    set(gca,'xlim',[log(plotxmin) log10(plotxmax)])
    legend({'Wake';'REM';'SWS';'FirstPacket';'LastPacket'})
    axis square

%% Pre v Post figure
h = figure('position',[0 0 800 900],'name',[ep1name '_Spectra_PreVPost']);
subplot(2,2,1) %plot raw spectra
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),prespect','color',col(4,:))
    hold
    semilogx(repmat(SWSSpectra.standardFs,1,numsleeps),postspect','color',col(5,:))
    set(gca,'xlim',[plotxmin plotxmax])
    legend({'FirstPacket','LastPacket'})
    axis square
subplot(2,2,2) %plot boundedline
    boundedline(log10(repmat(SWSSpectra.standardFs,1,2)),...
        (cat(1,preswsMedian,postswsMedian))',...
        (cat(3,preswsVar',postswsVar')),...
        'cmap',col(4:5,:),'transparency',.5,'alpha');
    pause(0.5)
    set(gca,'xlim',[log(plotxmin) log10(plotxmax)])
    legend({'FirstPacket Median+SD';'LastPacket Median+SD'})
    axis square
subplot(2,2,3) %plot just medians
    semilogx(SWSSpectra.standardFs,preswsMedian,'color',col(4,:))
    hold on
    semilogx(SWSSpectra.standardFs,postswsMedian,'color',col(5,:))
    set(gca,'xlim',[plotxmin plotxmax])
    legend({'FirstPacket Median';'LastPacket Median'})
    axis square
subplot(2,2,4) %plot subtraction
    d = postswsMedian - preswsMedian;
    boundedline(log10(SWSSpectra.standardFs),...
        (median(postspect - prespect))',...
        (nanstd(postspect - prespect))',...
        'cmap','m','transparency',.5,'alpha');
    hold on
    plot([log(plotxmin) log10(plotxmax)],[0 0],'color',[.5 .5 .5])
    set(gca,'xlim',[log(plotxmin) log10(plotxmax)])
    legend({'Post-Pre per session+SD'})

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Spectra',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Spectra',h,'png')

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Spectra',SWSSpectra);