function PlotMRLSummary_HighPower(freqlist,PhstPS,jitmeanMRL,zthreshold,CellIDs,pvalues,yscaler)

%PhstPS:Phasestats by power and states

% NumRow = round(length(fieldnames(jitmeanMRL))/3);
NumRow = 5;
% if isempty(find(~isnan(PhstPS.REMphst.r),1))
%     NumRow = NumRow-1;
% end
% if isempty(find(~isnan(PhstPS.MAphst.r),1))
%     NumRow = NumRow-1;
% end

EE = CellIDs.EAll;
II = CellIDs.IAll;
% EAll = zeros(size(PhstPS.phst.r));
% IAll = zeros(size(PhstPS.phst.r));
% EAll(CellIDs.EAll,:) = 1;
% IAll(CellIDs.IAll,:) = 1;


figure;
ax = [];
yl = [];
fig = gcf;
fig.Position = [1 1 350 920];
xt = [1 2 4 7 10 20 40 70 100 200 400 700];
xx = log10(freqlist);
colors = [0 1 0;1 0 0;0 0 1; 0.5 0 0.5];
% ax(end+1) = subplot(NumRow,4,1);
% boundedline(log10(freqlist),nanmean(PhstPS.phst.r(EE,:)),nanstd(PhstPS.phst.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.phst.r(II,:)),nanstd(PhstPS.phst.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.all(EE,:)),nanstd(jitmeanMRL.all(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.all(II,:)),nanstd(jitmeanMRL.all(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% title('All Power');
% ylabel('All States');
%
% ax(end+1) = subplot(NumRow,4,2);
% boundedline(log10(freqlist),nanmean(PhstPS.phstL.r(EE,:)),nanstd(PhstPS.phstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.phstL.r(II,:)),nanstd(PhstPS.phstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.L(EE,:)),nanstd(jitmeanMRL.L(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.L(II,:)),nanstd(jitmeanMRL.L(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% title(['Low Power (-' num2str(zthreshold) ')']);
%
% ax(end+1) = subplot(NumRow,4,3);
% boundedline(log10(freqlist),nanmean(PhstPS.phstH.r(EE,:)),nanstd(PhstPS.phstH.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.phstH.r(II,:)),nanstd(PhstPS.phstH.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.H(EE,:)),nanstd(jitmeanMRL.H(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.H(II,:)),nanstd(jitmeanMRL.H(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% title(['High Power (' num2str(zthreshold) ')']);
%
% ax(end+1) = subplot(NumRow,4,4);
% boundedline(log10(freqlist),nanmean(PhstPS.phstH.r(EE,:)-PhstPS.phstL.r(EE,:)),nanstd(PhstPS.phstH.r(EE,:)-PhstPS.phstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.phstH.r(II,:)-PhstPS.phstL.r(II,:)),nanstd(PhstPS.phstH.r(II,:)-PhstPS.phstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.H(EE,:)-jitmeanMRL.L(EE,:)),nanstd(jitmeanMRL.H(EE,:)-jitmeanMRL.L(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.H(II,:)-jitmeanMRL.L(II,:)),nanstd(jitmeanMRL.H(II,:)-jitmeanMRL.L(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% title('High Power - Low Power');
%
%
% ax(end+1) = subplot(NumRow,4,5);
% boundedline(log10(freqlist),nanmean(PhstPS.WAKEphst.r(EE,:)),nanstd(PhstPS.WAKEphst.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.WAKEphst.r(II,:)),nanstd(PhstPS.WAKEphst.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKE(EE,:)),nanstd(jitmeanMRL.WAKE(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKE(II,:)),nanstd(jitmeanMRL.WAKE(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% ylabel('WAKE');
%
% ax(end+1) = subplot(NumRow,4,6);
% boundedline(log10(freqlist),nanmean(PhstPS.WAKEphstL.r(EE,:)),nanstd(PhstPS.WAKEphstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.WAKEphstL.r(II,:)),nanstd(PhstPS.WAKEphstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEL(EE,:)),nanstd(jitmeanMRL.WAKEL(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEL(II,:)),nanstd(jitmeanMRL.WAKEL(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
% ax(end+1) = subplot(NumRow,4,7);
% boundedline(log10(freqlist),nanmean(PhstPS.WAKEphstH.r(EE,:)),nanstd(PhstPS.WAKEphstH.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.WAKEphstH.r(II,:)),nanstd(PhstPS.WAKEphstH.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEH(EE,:)),nanstd(jitmeanMRL.WAKEH(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEH(II,:)),nanstd(jitmeanMRL.WAKEH(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
% ax(end+1) = subplot(NumRow,4,8);
% boundedline(log10(freqlist),nanmean(PhstPS.WAKEphstH.r(EE,:)-PhstPS.WAKEphstL.r(EE,:)),nanstd(PhstPS.WAKEphstH.r(EE,:)-PhstPS.WAKEphstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.WAKEphstH.r(II,:)-PhstPS.WAKEphstL.r(II,:)),nanstd(PhstPS.WAKEphstH.r(II,:)-PhstPS.WAKEphstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEH(EE,:)-jitmeanMRL.WAKEL(EE,:)),nanstd(jitmeanMRL.WAKEH(EE,:)-jitmeanMRL.WAKEL(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.WAKEH(II,:)-jitmeanMRL.WAKEL(II,:)),nanstd(jitmeanMRL.WAKEH(II,:)-jitmeanMRL.WAKEL(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
%
% ax(end+1) = subplot(NumRow,4,9);
% boundedline(log10(freqlist),nanmean(PhstPS.NREMphst.r(EE,:)),nanstd(PhstPS.NREMphst.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.NREMphst.r(II,:)),nanstd(PhstPS.NREMphst.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREM(EE,:)),nanstd(jitmeanMRL.NREM(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREM(II,:)),nanstd(jitmeanMRL.NREM(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% ylabel('NREM');
%
% ax(end+1) = subplot(NumRow,4,10);
% boundedline(log10(freqlist),nanmean(PhstPS.NREMphstL.r(EE,:)),nanstd(PhstPS.NREMphstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.NREMphstL.r(II,:)),nanstd(PhstPS.NREMphstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREML(EE,:)),nanstd(jitmeanMRL.NREML(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREML(II,:)),nanstd(jitmeanMRL.NREML(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
% ax(end+1) = subplot(NumRow,4,11);
% boundedline(log10(freqlist),nanmean(PhstPS.NREMphstH.r(EE,:)),nanstd(PhstPS.NREMphstH.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.NREMphstH.r(II,:)),nanstd(PhstPS.NREMphstH.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREMH(EE,:)),nanstd(jitmeanMRL.NREMH(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREMH(II,:)),nanstd(jitmeanMRL.NREMH(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
% ax(end+1) = subplot(NumRow,4,12);
% boundedline(log10(freqlist),nanmean(PhstPS.NREMphstH.r(EE,:)-PhstPS.NREMphstL.r(EE,:)),nanstd(PhstPS.NREMphstH.r(EE,:)-PhstPS.NREMphstL.r(EE,:)),...
%     log10(freqlist),nanmean(PhstPS.NREMphstH.r(II,:)-PhstPS.NREMphstL.r(II,:)),nanstd(PhstPS.NREMphstH.r(II,:)-PhstPS.NREMphstL.r(II,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREMH(EE,:)-jitmeanMRL.NREML(EE,:)),nanstd(jitmeanMRL.NREMH(EE,:)-jitmeanMRL.NREML(EE,:)),...
%     log10(freqlist),nanmean(jitmeanMRL.NREMH(II,:)-jitmeanMRL.NREML(II,:)),nanstd(jitmeanMRL.NREMH(II,:)-jitmeanMRL.NREML(II,:)),'cmap',RainbowColors(4),'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
%
% if ~isempty(PhstPS.REMphst)
%     ax(end+1) = subplot(NumRow,4,13);
%     boundedline(log10(freqlist),nanmean(PhstPS.REMphst.r(EE,:)),nanstd(PhstPS.REMphst.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.REMphst.r(II,:)),nanstd(PhstPS.REMphst.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REM(EE,:)),nanstd(jitmeanMRL.REM(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REM(II,:)),nanstd(jitmeanMRL.REM(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     ylabel('REM');
%
%     ax(end+1) = subplot(NumRow,4,14);
%     boundedline(log10(freqlist),nanmean(PhstPS.REMphstL.r(EE,:)),nanstd(PhstPS.REMphstL.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.REMphstL.r(II,:)),nanstd(PhstPS.REMphstL.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REML(EE,:)),nanstd(jitmeanMRL.REML(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REML(II,:)),nanstd(jitmeanMRL.REML(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%
%     ax(end+1) = subplot(NumRow,4,15);
%     boundedline(log10(freqlist),nanmean(PhstPS.REMphstH.r(EE,:)),nanstd(PhstPS.REMphstH.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.REMphstH.r(II,:)),nanstd(PhstPS.REMphstH.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REMH(EE,:)),nanstd(jitmeanMRL.REMH(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REMH(II,:)),nanstd(jitmeanMRL.REMH(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%
%     ax(end+1) = subplot(NumRow,4,16);
%     boundedline(log10(freqlist),nanmean(PhstPS.REMphstH.r(EE,:)-PhstPS.REMphstL.r(EE,:)),nanstd(PhstPS.REMphstH.r(EE,:)-PhstPS.REMphstL.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.REMphstH.r(II,:)-PhstPS.REMphstL.r(II,:)),nanstd(PhstPS.REMphstH.r(II,:)-PhstPS.REMphstL.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REMH(EE,:)-jitmeanMRL.REML(EE,:)),nanstd(jitmeanMRL.REMH(EE,:)-jitmeanMRL.REML(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.REMH(II,:)-jitmeanMRL.REML(II,:)),nanstd(jitmeanMRL.REMH(II,:)-jitmeanMRL.REML(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
% end
%
% if ~isempty(PhstPS.MAphst)
%     ax(end+1) = subplot(NumRow,4,4*NumRow-3);
%     boundedline(log10(freqlist),nanmean(PhstPS.MAphst.r(EE,:)),nanstd(PhstPS.MAphst.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.MAphst.r(II,:)),nanstd(PhstPS.MAphst.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MA(EE,:)),nanstd(jitmeanMRL.MA(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MA(II,:)),nanstd(jitmeanMRL.MA(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     ylabel('MA');
%
%     ax(end+1) = subplot(NumRow,4,4*NumRow-2);
%     boundedline(log10(freqlist),nanmean(PhstPS.MAphstL.r(EE,:)),nanstd(PhstPS.MAphstL.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.MAphstL.r(II,:)),nanstd(PhstPS.MAphstL.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAL(EE,:)),nanstd(jitmeanMRL.MAL(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAL(II,:)),nanstd(jitmeanMRL.MAL(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%
%     ax(end+1) = subplot(NumRow,4,4*NumRow-1);
%     boundedline(log10(freqlist),nanmean(PhstPS.MAphstH.r(EE,:)),nanstd(PhstPS.MAphstH.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.MAphstH.r(II,:)),nanstd(PhstPS.MAphstH.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAH(EE,:)),nanstd(jitmeanMRL.MAH(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAH(II,:)),nanstd(jitmeanMRL.MAH(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%
%     ax(end+1) = subplot(NumRow,4,4*NumRow);
%     boundedline(log10(freqlist),nanmean(PhstPS.MAphstH.r(EE,:)-PhstPS.MAphstL.r(EE,:)),nanstd(PhstPS.MAphstH.r(EE,:)-PhstPS.MAphstL.r(EE,:)),...
%         log10(freqlist),nanmean(PhstPS.MAphstH.r(II,:)-PhstPS.MAphstL.r(II,:)),nanstd(PhstPS.MAphstH.r(II,:)-PhstPS.MAphstL.r(II,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAH(EE,:)-jitmeanMRL.MAL(EE,:)),nanstd(jitmeanMRL.MAH(EE,:)-jitmeanMRL.MAL(EE,:)),...
%         log10(freqlist),nanmean(jitmeanMRL.MAH(II,:)-jitmeanMRL.MAL(II,:)),nanstd(jitmeanMRL.MAH(II,:)-jitmeanMRL.MAL(II,:)),'cmap',RainbowColors(4),'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
% end

% ax(end+1) = subplot(NumRow,4,1);
% PhstPS.phst.r(isnan(jitmeanMRL.all)) = nan;
% jitmeanMRL.all(isnan(PhstPS.phst.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.phst.r(EE,:)),nanstd(PhstPS.phst.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.phst.r(II,:)),nanstd(PhstPS.phst.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.all(EE,:)),nanstd(jitmeanMRL.all(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.all(II,:)),nanstd(jitmeanMRL.all(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;
% title('All Power');
% ylabel('All States');

% ax(end+1) = subplot(NumRow,4,2);
% PhstPS.phstL.r(isnan(jitmeanMRL.L)) = nan;
% jitmeanMRL.L(isnan(PhstPS.phstL.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.phstL.r(EE,:)),nanstd(PhstPS.phstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.phstL.r(II,:)),nanstd(PhstPS.phstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.L(EE,:)),nanstd(jitmeanMRL.L(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.L(II,:)),nanstd(jitmeanMRL.L(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;
% title(['Low Power (-' num2str(zthreshold) ')']);

ax(end+1) = subplot(NumRow,1,1);
PhstPS.phstH.r(isnan(jitmeanMRL.H)) = nan;
jitmeanMRL.H(isnan(PhstPS.phstH.r)) = nan;
boundedline(log10(freqlist),nanmedian(PhstPS.phstH.r(EE,:)),nanstd(PhstPS.phstH.r(EE,:)),...
    log10(freqlist),nanmedian(PhstPS.phstH.r(II,:)),nanstd(PhstPS.phstH.r(II,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.H(EE,:)),nanstd(jitmeanMRL.H(EE,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.H(II,:)),nanstd(jitmeanMRL.H(II,:)),'cmap',colors,'alpha');
axis tight;
yl(end+1,:) = get(gca,'ylim');
hold on;
title(['High Power (' num2str(zthreshold) ')']);
ylabel('All States');

% ax(end+1) = subplot(NumRow,4,4);
% boundedline(log10(freqlist),nanmedian(PhstPS.phstH.r(EE,:)-PhstPS.phstL.r(EE,:)),nanstd(PhstPS.phstH.r(EE,:)-PhstPS.phstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.phstH.r(II,:)-PhstPS.phstL.r(II,:)),nanstd(PhstPS.phstH.r(II,:)-PhstPS.phstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.H(EE,:)-jitmeanMRL.L(EE,:)),nanstd(jitmeanMRL.H(EE,:)-jitmeanMRL.L(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.H(II,:)-jitmeanMRL.L(II,:)),nanstd(jitmeanMRL.H(II,:)-jitmeanMRL.L(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;
% title('High Power - Low Power');


% ax(end+1) = subplot(NumRow,4,5);
% PhstPS.WAKEphst.r(isnan(jitmeanMRL.WAKE)) = nan;
% jitmeanMRL.WAKE(isnan(PhstPS.WAKEphst.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.WAKEphst.r(EE,:)),nanstd(PhstPS.WAKEphst.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.WAKEphst.r(II,:)),nanstd(PhstPS.WAKEphst.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKE(EE,:)),nanstd(jitmeanMRL.WAKE(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKE(II,:)),nanstd(jitmeanMRL.WAKE(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;
% ylabel('WAKE');
% 
% ax(end+1) = subplot(NumRow,4,6);
% PhstPS.WAKEphstL.r(isnan(jitmeanMRL.WAKEL)) = nan;
% jitmeanMRL.WAKEL(isnan(PhstPS.WAKEphstL.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.WAKEphstL.r(EE,:)),nanstd(PhstPS.WAKEphstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.WAKEphstL.r(II,:)),nanstd(PhstPS.WAKEphstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKEL(EE,:)),nanstd(jitmeanMRL.WAKEL(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKEL(II,:)),nanstd(jitmeanMRL.WAKEL(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;

ax(end+1) = subplot(NumRow,1,2);
PhstPS.WAKEphstH.r(isnan(jitmeanMRL.WAKEH)) = nan;
jitmeanMRL.WAKEH(isnan(PhstPS.WAKEphstH.r)) = nan;
boundedline(log10(freqlist),nanmedian(PhstPS.WAKEphstH.r(EE,:)),nanstd(PhstPS.WAKEphstH.r(EE,:)),...
    log10(freqlist),nanmedian(PhstPS.WAKEphstH.r(II,:)),nanstd(PhstPS.WAKEphstH.r(II,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.WAKEH(EE,:)),nanstd(jitmeanMRL.WAKEH(EE,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.WAKEH(II,:)),nanstd(jitmeanMRL.WAKEH(II,:)),'cmap',colors,'alpha');
axis tight;
yl(end+1,:) = get(gca,'ylim');
ylabel('WAKE');
hold on;

% ax(end+1) = subplot(NumRow,4,8);
% boundedline(log10(freqlist),nanmedian(PhstPS.WAKEphstH.r(EE,:)-PhstPS.WAKEphstL.r(EE,:)),nanstd(PhstPS.WAKEphstH.r(EE,:)-PhstPS.WAKEphstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.WAKEphstH.r(II,:)-PhstPS.WAKEphstL.r(II,:)),nanstd(PhstPS.WAKEphstH.r(II,:)-PhstPS.WAKEphstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKEH(EE,:)-jitmeanMRL.WAKEL(EE,:)),nanstd(jitmeanMRL.WAKEH(EE,:)-jitmeanMRL.WAKEL(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.WAKEH(II,:)-jitmeanMRL.WAKEL(II,:)),nanstd(jitmeanMRL.WAKEH(II,:)-jitmeanMRL.WAKEL(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;


% ax(end+1) = subplot(NumRow,4,9);
% PhstPS.NREMphst.r(isnan(jitmeanMRL.NREM)) = nan;
% jitmeanMRL.NREM(isnan(PhstPS.NREMphst.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.NREMphst.r(EE,:)),nanstd(PhstPS.NREMphst.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.NREMphst.r(II,:)),nanstd(PhstPS.NREMphst.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREM(EE,:)),nanstd(jitmeanMRL.NREM(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREM(II,:)),nanstd(jitmeanMRL.NREM(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;
% ylabel('NREM');
% 
% ax(end+1) = subplot(NumRow,4,10);
% PhstPS.NREMphstL.r(isnan(jitmeanMRL.NREML)) = nan;
% jitmeanMRL.NREML(isnan(PhstPS.NREMphstL.r)) = nan;
% boundedline(log10(freqlist),nanmedian(PhstPS.NREMphstL.r(EE,:)),nanstd(PhstPS.NREMphstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.NREMphstL.r(II,:)),nanstd(PhstPS.NREMphstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREML(EE,:)),nanstd(jitmeanMRL.NREML(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREML(II,:)),nanstd(jitmeanMRL.NREML(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;

ax(end+1) = subplot(NumRow,1,3);
PhstPS.NREMphstH.r(isnan(jitmeanMRL.NREMH)) = nan;
jitmeanMRL.NREMH(isnan(PhstPS.NREMphstH.r)) = nan;
boundedline(log10(freqlist),nanmedian(PhstPS.NREMphstH.r(EE,:)),nanstd(PhstPS.NREMphstH.r(EE,:)),...
    log10(freqlist),nanmedian(PhstPS.NREMphstH.r(II,:)),nanstd(PhstPS.NREMphstH.r(II,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.NREMH(EE,:)),nanstd(jitmeanMRL.NREMH(EE,:)),...
    log10(freqlist),nanmedian(jitmeanMRL.NREMH(II,:)),nanstd(jitmeanMRL.NREMH(II,:)),'cmap',colors,'alpha');
axis tight;
yl(end+1,:) = get(gca,'ylim');
ylabel('NREM');
hold on;

% ax(end+1) = subplot(NumRow,4,12);
% boundedline(log10(freqlist),nanmedian(PhstPS.NREMphstH.r(EE,:)-PhstPS.NREMphstL.r(EE,:)),nanstd(PhstPS.NREMphstH.r(EE,:)-PhstPS.NREMphstL.r(EE,:)),...
%     log10(freqlist),nanmedian(PhstPS.NREMphstH.r(II,:)-PhstPS.NREMphstL.r(II,:)),nanstd(PhstPS.NREMphstH.r(II,:)-PhstPS.NREMphstL.r(II,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREMH(EE,:)-jitmeanMRL.NREML(EE,:)),nanstd(jitmeanMRL.NREMH(EE,:)-jitmeanMRL.NREML(EE,:)),...
%     log10(freqlist),nanmedian(jitmeanMRL.NREMH(II,:)-jitmeanMRL.NREML(II,:)),nanstd(jitmeanMRL.NREMH(II,:)-jitmeanMRL.NREML(II,:)),'cmap',colors,'alpha');
% axis tight;
% yl(end+1,:) = get(gca,'ylim');
% hold on;

if ~isempty(PhstPS.REMphstH)
%     ax(end+1) = subplot(NumRow,4,13);
%     PhstPS.REMphst.r(isnan(jitmeanMRL.REM)) = nan;
%     jitmeanMRL.REM(isnan(PhstPS.REMphst.r)) = nan;
%     boundedline(log10(freqlist),nanmedian(PhstPS.REMphst.r(EE,:)),nanstd(PhstPS.REMphst.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.REMphst.r(II,:)),nanstd(PhstPS.REMphst.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REM(EE,:)),nanstd(jitmeanMRL.REM(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REM(II,:)),nanstd(jitmeanMRL.REM(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     hold on;
%     ylabel('REM');
%     
%     ax(end+1) = subplot(NumRow,4,14);
%     PhstPS.REMphstL.r(isnan(jitmeanMRL.REML)) = nan;
%     jitmeanMRL.REML(isnan(PhstPS.REMphstL.r)) = nan;
%     boundedline(log10(freqlist),nanmedian(PhstPS.REMphstL.r(EE,:)),nanstd(PhstPS.REMphstL.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.REMphstL.r(II,:)),nanstd(PhstPS.REMphstL.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REML(EE,:)),nanstd(jitmeanMRL.REML(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REML(II,:)),nanstd(jitmeanMRL.REML(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
    
    ax(end+1) = subplot(NumRow,1,4);
    PhstPS.REMphstH.r(isnan(jitmeanMRL.REMH)) = nan;
    jitmeanMRL.REMH(isnan(PhstPS.REMphstH.r)) = nan;
    boundedline(log10(freqlist),nanmedian(PhstPS.REMphstH.r(EE,:)),nanstd(PhstPS.REMphstH.r(EE,:)),...
        log10(freqlist),nanmedian(PhstPS.REMphstH.r(II,:)),nanstd(PhstPS.REMphstH.r(II,:)),...
        log10(freqlist),nanmedian(jitmeanMRL.REMH(EE,:)),nanstd(jitmeanMRL.REMH(EE,:)),...
        log10(freqlist),nanmedian(jitmeanMRL.REMH(II,:)),nanstd(jitmeanMRL.REMH(II,:)),'cmap',colors,'alpha');
    axis tight;
    yl(end+1,:) = get(gca,'ylim');
    ylabel('REM');
    hold on;
    
%     ax(end+1) = subplot(NumRow,4,16);
%     boundedline(log10(freqlist),nanmedian(PhstPS.REMphstH.r(EE,:)-PhstPS.REMphstL.r(EE,:)),nanstd(PhstPS.REMphstH.r(EE,:)-PhstPS.REMphstL.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.REMphstH.r(II,:)-PhstPS.REMphstL.r(II,:)),nanstd(PhstPS.REMphstH.r(II,:)-PhstPS.REMphstL.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REMH(EE,:)-jitmeanMRL.REML(EE,:)),nanstd(jitmeanMRL.REMH(EE,:)-jitmeanMRL.REML(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.REMH(II,:)-jitmeanMRL.REML(II,:)),nanstd(jitmeanMRL.REMH(II,:)-jitmeanMRL.REML(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     hold on;
end

if ~isempty(PhstPS.MAphstH)
%     ax(end+1) = subplot(NumRow,4,4*NumRow-3);
%     PhstPS.MAphst.r(isnan(jitmeanMRL.MA)) = nan;
%     jitmeanMRL.MA(isnan(PhstPS.MAphst.r)) = nan;
%     boundedline(log10(freqlist),nanmedian(PhstPS.MAphst.r(EE,:)),nanstd(PhstPS.MAphst.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.MAphst.r(II,:)),nanstd(PhstPS.MAphst.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MA(EE,:)),nanstd(jitmeanMRL.MA(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MA(II,:)),nanstd(jitmeanMRL.MA(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     hold on;
%     ylabel('MA');
%     
%     ax(end+1) = subplot(NumRow,4,4*NumRow-2);
%     PhstPS.MAphstL.r(isnan(jitmeanMRL.MAL)) = nan;
%     jitmeanMRL.MAL(isnan(PhstPS.MAphstL.r)) = nan;
%     boundedline(log10(freqlist),nanmedian(PhstPS.MAphstL.r(EE,:)),nanstd(PhstPS.MAphstL.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.MAphstL.r(II,:)),nanstd(PhstPS.MAphstL.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MAL(EE,:)),nanstd(jitmeanMRL.MAL(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MAL(II,:)),nanstd(jitmeanMRL.MAL(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     hold on;
    
    
    ax(end+1) = subplot(NumRow,1,NumRow);
    PhstPS.MAphstH.r(isnan(jitmeanMRL.MAH)) = nan;
    jitmeanMRL.MAH(isnan(PhstPS.MAphstH.r)) = nan;
    boundedline(log10(freqlist),nanmedian(PhstPS.MAphstH.r(EE,:)),nanstd(PhstPS.MAphstH.r(EE,:)),...
        log10(freqlist),nanmedian(PhstPS.MAphstH.r(II,:)),nanstd(PhstPS.MAphstH.r(II,:)),...
        log10(freqlist),nanmedian(jitmeanMRL.MAH(EE,:)),nanstd(jitmeanMRL.MAH(EE,:)),...
        log10(freqlist),nanmedian(jitmeanMRL.MAH(II,:)),nanstd(jitmeanMRL.MAH(II,:)),'cmap',colors,'alpha');
    axis tight;
    yl(end+1,:) = get(gca,'ylim');
    ylabel('MA');
    hold on;
    
%     ax(end+1) = subplot(NumRow,4,4*NumRow);
%     boundedline(log10(freqlist),nanmedian(PhstPS.MAphstH.r(EE,:)-PhstPS.MAphstL.r(EE,:)),nanstd(PhstPS.MAphstH.r(EE,:)-PhstPS.MAphstL.r(EE,:)),...
%         log10(freqlist),nanmedian(PhstPS.MAphstH.r(II,:)-PhstPS.MAphstL.r(II,:)),nanstd(PhstPS.MAphstH.r(II,:)-PhstPS.MAphstL.r(II,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MAH(EE,:)-jitmeanMRL.MAL(EE,:)),nanstd(jitmeanMRL.MAH(EE,:)-jitmeanMRL.MAL(EE,:)),...
%         log10(freqlist),nanmedian(jitmeanMRL.MAH(II,:)-jitmeanMRL.MAL(II,:)),nanstd(jitmeanMRL.MAH(II,:)-jitmeanMRL.MAL(II,:)),'cmap',colors,'alpha');
%     axis tight;
%     yl(end+1,:) = get(gca,'ylim');
%     hold on;
end
% scalingax = setdiff(1:NumRow*4,(1:NumRow)*4);
% yl_all = [min(yl(scalingax,1)) max(yl(scalingax,2))];
yl_all = [min(yl(:,1)) max(yl(:,2))];
if yscaler
    for ii = 1:NumRow
        yl(ii,:) = yl_all;
    end
    yl(:,2) = 1.09*yl(:,2)-0.09*(yl(:,1));
    for ii = 1:NumRow
        set(ax(ii),'ylim',yl(ii,:));
    end
    Ey = 0.92;
    Iy = 0.98;
else
    Ey = 1.03;
    Iy = 1.1;
end



%% plot significance according to yscaler


% 
% if find(pvalues.E.all<0.01,1)
%     plot(ax(1),xx(pvalues.E.all<0.01),ones(length(find(pvalues.E.all<0.01)),1)*(Ey*yl(1,2)-(Ey-1)*yl(1,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.all<0.01,1)
%     plot(ax(1),xx(pvalues.I.all<0.01),ones(length(find(pvalues.I.all<0.01)),1)*(Iy*yl(1,2)-(Iy-1)*yl(1,1)),'*r','MarkerSize',2.5);
% end
% 
% if find(pvalues.E.L<0.01,1)
%     plot(ax(2),xx(pvalues.E.L<0.01),ones(length(find(pvalues.E.L<0.01)),1)*(Ey*yl(2,2)-(Ey-1)*yl(2,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.L<0.01,1)
%     plot(ax(2),xx(pvalues.I.L<0.01),ones(length(find(pvalues.I.L<0.01)),1)*(Iy*yl(2,2)-(Iy-1)*yl(2,1)),'*r','MarkerSize',2.5);
% end
% 
if find(pvalues.E.H<0.01,1)
    plot(ax(1),xx(pvalues.E.H<0.01),ones(length(find(pvalues.E.H<0.01)),1)*(Ey*yl(1,2)-(Ey-1)*yl(1,1)),'*g','MarkerSize',2.5);
end
if find(pvalues.I.H<0.01,1)
    plot(ax(1),xx(pvalues.I.H<0.01),ones(length(find(pvalues.I.H<0.01)),1)*(Iy*yl(1,2)-(Iy-1)*yl(1,1)),'*r','MarkerSize',2.5);
end
% 
% if find(pvalues.E.HmL<0.01,1)
%     plot(ax(4),xx(pvalues.E.HmL<0.01),ones(length(find(pvalues.E.HmL<0.01)),1)*(Ey*yl(4,2)-(Ey-1)*yl(4,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.HmL<0.01,1)
%     plot(ax(4),xx(pvalues.I.HmL<0.01),ones(length(find(pvalues.I.HmL<0.01)),1)*(Iy*yl(4,2)-(Iy-1)*yl(4,1)),'*r','MarkerSize',2.5);
% end
% 
% if find(pvalues.E.WAKE<0.01,1)
%     plot(ax(5),xx(pvalues.E.WAKE<0.01),ones(length(find(pvalues.E.WAKE<0.01)),1)*(Ey*yl(5,2)-(Ey-1)*yl(5,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.WAKE<0.01,1)
%     plot(ax(5),xx(pvalues.I.WAKE<0.01),ones(length(find(pvalues.I.WAKE<0.01)),1)*(Iy*yl(5,2)-(Iy-1)*yl(5,1)),'*r','MarkerSize',2.5);
% end
% 
% if find(pvalues.E.WAKEL<0.01,1)
%     plot(ax(6),xx(pvalues.E.WAKEL<0.01),ones(length(find(pvalues.E.WAKEL<0.01)),1)*(Ey*yl(6,2)-(Ey-1)*yl(6,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.WAKEL<0.01,1)
%     plot(ax(6),xx(pvalues.I.WAKEL<0.01),ones(length(find(pvalues.I.WAKEL<0.01)),1)*(Iy*yl(6,2)-(Iy-1)*yl(6,1)),'*r','MarkerSize',2.5);
% end
% 
if find(pvalues.E.WAKEH<0.01,1)
    plot(ax(2),xx(pvalues.E.WAKEH<0.01),ones(length(find(pvalues.E.WAKEH<0.01)),1)*(Ey*yl(2,2)-(Ey-1)*yl(2,1)),'*g','MarkerSize',2.5);
end
if find(pvalues.I.WAKEH<0.01,1)
    plot(ax(2),xx(pvalues.I.WAKEH<0.01),ones(length(find(pvalues.I.WAKEH<0.01)),1)*(Iy*yl(2,2)-(Iy-1)*yl(2,1)),'*r','MarkerSize',2.5);
end
% 
% if find(pvalues.E.WAKEHmL<0.01,1)
%     plot(ax(8),xx(pvalues.E.WAKEHmL<0.01),ones(length(find(pvalues.E.WAKEHmL<0.01)),1)*(Ey*yl(8,2)-(Ey-1)*yl(8,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.WAKEHmL<0.01,1)
%     plot(ax(8),xx(pvalues.I.WAKEHmL<0.01),ones(length(find(pvalues.I.WAKEHmL<0.01)),1)*(Iy*yl(8,2)-(Iy-1)*yl(8,1)),'*r','MarkerSize',2.5);
% end
% 
% if find(pvalues.E.NREM<0.01,1)
%     plot(ax(9),xx(pvalues.E.NREM<0.01),ones(length(find(pvalues.E.NREM<0.01)),1)*(Ey*yl(9,2)-(Ey-1)*yl(9,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.NREM<0.01,1)
%     plot(ax(9),xx(pvalues.I.NREM<0.01),ones(length(find(pvalues.I.NREM<0.01)),1)*(Iy*yl(9,2)-(Iy-1)*yl(9,1)),'*r','MarkerSize',2.5);
% end
% 
% if find(pvalues.E.NREML<0.01,1)
%     plot(ax(10),xx(pvalues.E.NREML<0.01),ones(length(find(pvalues.E.NREML<0.01)),1)*(Ey*yl(10,2)-(Ey-1)*yl(10,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.NREML<0.01,1)
%     plot(ax(10),xx(pvalues.I.NREML<0.01),ones(length(find(pvalues.I.NREML<0.01)),1)*(Iy*yl(10,2)-(Iy-1)*yl(10,1)),'*r','MarkerSize',2.5);
% end
% 
if find(pvalues.E.NREMH<0.01,1)
    plot(ax(3),xx(pvalues.E.NREMH<0.01),ones(length(find(pvalues.E.NREMH<0.01)),1)*(Ey*yl(3,2)-(Ey-1)*yl(3,1)),'*g','MarkerSize',2.5);
end
if find(pvalues.I.NREMH<0.01,1)
    plot(ax(3),xx(pvalues.I.NREMH<0.01),ones(length(find(pvalues.I.NREMH<0.01)),1)*(Iy*yl(3,2)-(Iy-1)*yl(3,1)),'*r','MarkerSize',2.5);
end
% 
% if find(pvalues.E.NREMHmL<0.01,1)
%     plot(ax(12),xx(pvalues.E.NREMHmL<0.01),ones(length(find(pvalues.E.NREMHmL<0.01)),1)*(Ey*yl(12,2)-(Ey-1)*yl(12,1)),'*g','MarkerSize',2.5);
% end
% if find(pvalues.I.NREMHmL<0.01,1)
%     plot(ax(12),xx(pvalues.I.NREMHmL<0.01),ones(length(find(pvalues.I.NREMHmL<0.01)),1)*(Iy*yl(12,2)-(Iy-1)*yl(12,1)),'*r','MarkerSize',2.5);
% end
% 
% if ~isempty(PhstPS.REMphst)
%     if find(pvalues.E.REM<0.01,1)
%         plot(ax(13),xx(pvalues.E.REM<0.01),ones(length(find(pvalues.E.REM<0.01)),1)*(Ey*yl(13,2)-(Ey-1)*yl(13,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.REM<0.01,1)
%         plot(ax(13),xx(pvalues.I.REM<0.01),ones(length(find(pvalues.I.REM<0.01)),1)*(Iy*yl(13,2)-(Iy-1)*yl(13,1)),'*r','MarkerSize',2.5);
%     end
%     
%     if find(pvalues.E.REML<0.01,1)
%         plot(ax(14),xx(pvalues.E.REML<0.01),ones(length(find(pvalues.E.REML<0.01)),1)*(Ey*yl(14,2)-(Ey-1)*yl(14,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.REML<0.01,1)
%         plot(ax(14),xx(pvalues.I.REML<0.01),ones(length(find(pvalues.I.REML<0.01)),1)*(Iy*yl(14,2)-(Iy-1)*yl(14,1)),'*r','MarkerSize',2.5);
%     end
% 
    if find(pvalues.E.REMH<0.01,1)
        plot(ax(4),xx(pvalues.E.REMH<0.01),ones(length(find(pvalues.E.REMH<0.01)),1)*(Ey*yl(4,2)-(Ey-1)*yl(4,1)),'*g','MarkerSize',2.5);
    end
    if find(pvalues.I.REMH<0.01,1)
        plot(ax(4),xx(pvalues.I.REMH<0.01),ones(length(find(pvalues.I.REMH<0.01)),1)*(Iy*yl(4,2)-(Iy-1)*yl(4,1)),'*r','MarkerSize',2.5);
    end
% 
%     if find(pvalues.E.REMHmL<0.01,1)
%         plot(ax(16),xx(pvalues.E.REMHmL<0.01),ones(length(find(pvalues.E.REMHmL<0.01)),1)*(Ey*yl(16,2)-(Ey-1)*yl(16,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.REMHmL<0.01,1)
%         plot(ax(16),xx(pvalues.I.REMHmL<0.01),ones(length(find(pvalues.I.REMHmL<0.01)),1)*(Iy*yl(16,2)-(Iy-1)*yl(16,1)),'*r','MarkerSize',2.5);
%     end
% end
% 
% if ~isempty(PhstPS.MAphst)
%     if find(pvalues.E.MA<0.01,1)
%         plot(ax(4*NumRow-3),xx(pvalues.E.MA<0.01),ones(length(find(pvalues.E.MA<0.01)),1)*(Ey*yl(4*NumRow-3,2)-(Ey-1)*yl(4*NumRow-3,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.MA<0.01,1)
%         plot(ax(4*NumRow-3),xx(pvalues.I.MA<0.01),ones(length(find(pvalues.I.MA<0.01)),1)*(Iy*yl(4*NumRow-3,2)-(Iy-1)*yl(4*NumRow-3,1)),'*r','MarkerSize',2.5);
%     end
% 
%     if find(pvalues.E.MAL<0.01,1)
%         plot(ax(4*NumRow-2),xx(pvalues.E.MAL<0.01),ones(length(find(pvalues.E.MAL<0.01)),1)*(Ey*yl(4*NumRow-2,2)-(Ey-1)*yl(4*NumRow-2,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.MAL<0.01,1)
%         plot(ax(4*NumRow-2),xx(pvalues.I.MAL<0.01),ones(length(find(pvalues.I.MAL<0.01)),1)*(Iy*yl(4*NumRow-2,2)-(Iy-1)*yl(4*NumRow-2,1)),'*r','MarkerSize',2.5);
%     end
% 
    if find(pvalues.E.MAH<0.01,1)
        plot(ax(NumRow),xx(pvalues.E.MAH<0.01),ones(length(find(pvalues.E.MAH<0.01)),1)*(Ey*yl(NumRow,2)-(Ey-1)*yl(NumRow,1)),'*g','MarkerSize',2.5);
    end
    if find(pvalues.I.MAH<0.01,1)
        plot(ax(NumRow),xx(pvalues.I.MAH<0.01),ones(length(find(pvalues.I.MAH<0.01)),1)*(Iy*yl(NumRow,2)-(Iy-1)*yl(NumRow,1)),'*r','MarkerSize',2.5);
    end
% 
%     if find(pvalues.E.MAHmL<0.01,1)
%         plot(ax(4*NumRow),xx(pvalues.E.MAHmL<0.01),ones(length(find(pvalues.E.MAHmL<0.01)),1)*(Ey*yl(4*NumRow,2)-(Ey-1)*yl(4*NumRow,1)),'*g','MarkerSize',2.5);
%     end
%     if find(pvalues.I.MAHmL<0.01,1)
%         plot(ax(4*NumRow),xx(pvalues.I.MAHmL<0.01),ones(length(find(pvalues.I.MAHmL<0.01)),1)*(Iy*yl(4*NumRow,2)-(Iy-1)*yl(4*NumRow,1)),'*r','MarkerSize',2.5);
%     end
% end

legend(['E Cells ';'I Cells ';'E Jitter';'I Jitter']);
set(ax,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
end
