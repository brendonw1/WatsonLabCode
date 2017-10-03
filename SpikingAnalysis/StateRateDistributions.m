function StateRateDistributions

warning off
StateRates = SpikingAnalysis_GatherAllStateRates;
% EAll = StateRates.EAllRates;
% IAll = StateRates.IAllRates;
EWSWake = StateRates.EWSWakeRates;
IWSWake = StateRates.IWSWakeRates;
EWSSleep = StateRates.EWSWakeRates;
IWSSleep = StateRates.IWSWakeRates;
ESWS = StateRates.ESWSRates;
ISWS = StateRates.ISWSRates;
EREM = StateRates.EREMRates;
IREM = StateRates.IREMRates;
EUPs = StateRates.EUPRates;
IUPs = StateRates.IUPRates;
ESpindle = StateRates.ESpindleRates;
ISpindle = StateRates.ISpindleRates;
EFSWS = StateRates.EFSWSRates;
ELSWS = StateRates.ELSWSRates;
ILSWS = StateRates.ILSWSRates;
IFSWS = StateRates.IFSWSRates;


% EMWake = StateRates.EMWakeRates;
% IMWake = StateRates.IMWakeRates;
% ENMWake = StateRates.ENMWakeRates;
% INMWake = StateRates.INMWakeRates;
% EMovMod = EMWake./ENMWake;
% IMovMod = IMWake./INMWake;

% warning on

h = [];

%%
h(end+1) = figure('name','EStateRatesBars');
subplot(1,2,1)
hax = plot_stats_bars(EWSWake,ESWS,EUPs,ESpindle,EREM,'central','median','variance''sd');
subplot(1,2,2)
bplot(cat(2,EWSWake,ESWS,EUPs,ESpindle,EREM));

h(end+1) = figure('name','IStateRatesBars');
subplot(1,2,1)
plot_stats_bars(IWSWake,ISWS,IUPs,ISpindle,IREM,'central','median','variance''sd');
subplot(1,2,2)
bplot(cat(2,IWSWake,ISWS,IUPs,ISpindle,IREM));

h(end+1) = figure('name','EStateRatesScatters');
mcorr_bw(EWSWake,ESWS,EUPs,ESpindle,EREM,'plotlogmode','loglog');
h(end+1) = figure('name','IStateRatesScatters');
mcorr_bw(IWSWake,ISWS,IUPs,ISpindle,IREM,'plotlogmode','loglog');

%% just a few specific correlations
eic = EIColors;
h(end+1) = figure('name','WakeVsREMSWS','position',[2 2 1000 400]);
subplot(1,2,1);
ScatterWStats(EWSWake,ESWS,'loglog','max','loglog',eic(1,:));
hold on;
ScatterWStats(IWSWake,ISWS,'loglog','max','loglog',eic(2,:));

subplot(1,2,2)
ScatterWStats(EWSWake,EREM,'loglog','max','loglog',eic(1,:));
hold on;
ScatterWStats(IWSWake,IREM,'loglog','max','loglog',eic(2,:));

1;
%% Plot rate distributions for all states
Enumbins = 30;
Enumsmoothing = 5;
[EWcenters,EWvals]=semilogxhist(EWSWake,Enumbins,0);
[ESlcenters,ESlvals]=semilogxhist(EWSSleep,Enumbins,0);
[EScenters,ESvals]=semilogxhist(ESWS,Enumbins,0);
[EUcenters,EUvals]=semilogxhist(EUPs,Enumbins,0);
[ESpcenters,ESpvals]=semilogxhist(ESpindle,Enumbins,0);
[ERcenters,ERvals]=semilogxhist(EREM,Enumbins,0);
EWvalsS = smooth(EWvals,Enumsmoothing);
ESlvalsS = smooth(ESlvals,Enumsmoothing);
ESvalsS = smooth(ESvals,Enumsmoothing);
EUvalsS = smooth(EUvals,Enumsmoothing);
ESpvalsS = smooth(ESpvals,Enumsmoothing);
ERvalsS = smooth(ERvals,Enumsmoothing);

Inumbins = 30;
Inumsmoothing = 5;
[IWcenters,IWvals]=semilogxhist(IWSWake,Inumbins,0);
[ISlcenters,ISlvals]=semilogxhist(IWSSleep,Inumbins,0);
[IScenters,ISvals]=semilogxhist(ISWS,Inumbins,0);
[IUcenters,IUvals]=semilogxhist(IUPs,Inumbins,0);
[ISpcenters,ISpvals]=semilogxhist(ISpindle,Inumbins,0);
[IRcenters,IRvals]=semilogxhist(IREM,Inumbins,0);
IWvalsS = smooth(IWvals,Inumsmoothing);
ISlvalsS = smooth(ISlvals,Inumsmoothing);
ISvalsS = smooth(ISvals,Inumsmoothing);
IUvalsS = smooth(IUvals,Inumsmoothing);
ISpvalsS = smooth(ISpvals,Inumsmoothing);
IRvalsS = smooth(IRvals,Inumsmoothing);

colors3 = StateColors;
colors5 = RedPurpleColors(5);
% 
% h(end+1) = figure('position',[2 2 800 800],'name',['StateDistributionCurves_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
% subplot(2,1,1)
%     hold on;
%     semilogx(EWcenters,EWvalsS,'color',colors5(1,:),'LineWidth',2)
%     semilogx(EScenters,ESvalsS,'color',colors5(2,:),'LineWidth',2)
%     semilogx(EUcenters,EUvalsS,'color',colors5(3,:),'LineWidth',2)
%     semilogx(ESpcenters,ESpvalsS,'color',colors5(4,:),'LineWidth',2)
%     semilogx(ERcenters,ERvalsS,'color',colors5(5,:),'LineWidth',2)
%     semilogx(EWcenters,EWvals,'.','MarkerSize',5,'color',colors5(1,:))
%     semilogx(EScenters,ESvals,'.','MarkerSize',5,'color',colors5(2,:))
%     semilogx(EUcenters,EUvals,'.','MarkerSize',5,'color',colors5(3,:))
%     semilogx(ESpcenters,ESpvals,'.','MarkerSize',5,'color',colors5(4,:))
%     semilogx(ERcenters,ERvals,'.','MarkerSize',5,'color',colors5(5,:))
% 
%     set(gca,'XScale','log')
%     xlabel('Rate(hz)')
%     ylabel('# Units')
%     legend({'EWake';'ESWS';'EUPs';'ESpindles';'EREM'},'location','NorthWest')

% subplot(2,1,2)
%     hold on;
%     semilogx(IWcenters,IWvalsS,'color',colors5(1,:),'LineWidth',2)
%     semilogx(IScenters,ISvalsS,'color',colors5(2,:),'LineWidth',2)
%     semilogx(IUcenters,IUvalsS,'color',colors5(3,:),'LineWidth',2)
%     semilogx(ISpcenters,ISpvalsS,'color',colors5(4,:),'LineWidth',2)
%     semilogx(IRcenters,IRvalsS,'color',colors5(5,:),'LineWidth',2)
%     semilogx(IWcenters,IWvals,'.','MarkerSize',5,'color',colors5(1,:))
%     semilogx(IScenters,ISvals,'.','MarkerSize',5,'color',colors5(2,:))
%     semilogx(IUcenters,IUvals,'.','MarkerSize',5,'color',colors5(3,:))
%     semilogx(ISpcenters,ISpvals,'.','MarkerSize',5,'color',colors5(4,:))
%     semilogx(IRcenters,IRvals,'.','MarkerSize',5,'color',colors5(5,:))
%     set(gca,'XScale','log')
%     xlabel('Rate(hz)')
%     ylabel('# Units')
%     legend({'IWake';'ISWS';'IUPs';'ISpindles';'IREM'},'location','NorthWest')


%% replot only Wake, SWS, REM
h(end+1) = figure('position',[2 2 800 800],'name',['StateDistributionCurvesWSROnly_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
subplot(2,1,1)
    hold on;
    semilogx(EWcenters,EWvalsS,'color',colors3(1,:),'LineWidth',2)
    semilogx(EScenters,ESvalsS,'color',colors3(2,:),'LineWidth',2)
    semilogx(ERcenters,ERvalsS,'color',colors3(3,:),'LineWidth',2)
    semilogx(EWcenters,EWvals,'.','MarkerSize',5,'color',colors3(1,:))
    semilogx(EScenters,ESvals,'.','MarkerSize',5,'color',colors3(2,:))
    semilogx(ERcenters,ERvals,'.','MarkerSize',5,'color',colors3(3,:))

    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'EWake';'ESWS';'EREM'},'location','NorthWest')
subplot(2,1,2)
    hold on;
    semilogx(IWcenters,IWvalsS,'color',colors3(1,:),'LineWidth',2)
    semilogx(IScenters,ISvalsS,'color',colors3(2,:),'LineWidth',2)
    semilogx(IRcenters,IRvalsS,'color',colors3(3,:),'LineWidth',2)
    semilogx(IWcenters,IWvals,'.','MarkerSize',5,'color',colors3(1,:))
    semilogx(IScenters,ISvals,'.','MarkerSize',5,'color',colors3(2,:))
    semilogx(IRcenters,IRvals,'.','MarkerSize',5,'color',colors3(3,:))
    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'IWake';'ISWS';'IREM'},'location','NorthWest')
    
%% replot only Wake, SWS, REM cumdist
h(end+1) = figure('position',[2 2 800 800],'name',['StateDistributionCurvesWSRCumSum_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
subplot(2,1,1)
    hold on;
%     semilogx(EWcenters,cumsum(EWvalsS),'color',colors3(1,:),'LineWidth',2)
%     semilogx(EScenters,cumsum(ESvalsS),'color',colors3(2,:),'LineWidth',2)
%     semilogx(ERcenters,cumsum(ERvalsS),'color',colors3(3,:),'LineWidth',2)
%     semilogx(EWcenters,cumsum(EWvals),'.','MarkerSize',5,'color',colors3(1,:))
%     semilogx(EScenters,cumsum(ESvals),'.','MarkerSize',5,'color',colors3(2,:))
%     semilogx(ERcenters,cumsum(ERvals),'.','MarkerSize',5,'color',colors3(3,:))
    semilogx(EWcenters,cumsum(EWvals),'color',colors3(1,:),'LineWidth',2)
    semilogx(EScenters,cumsum(ESvals),'color',colors3(2,:),'LineWidth',2)
    semilogx(ERcenters,cumsum(ERvals),'color',colors3(3,:),'LineWidth',2)
    t = sort(EWSWake);
    xlines = t(round((1:6)*(length(t)/6)));
    yl = ylim;
    for a = 1:5;
        plot([xlines(a) xlines(a)],yl,'color',[.5 .5 .5])
    end

    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'EWake';'ESWS';'EREM'},'location','NorthWest')
subplot(2,1,2)
    hold on;
%     semilogx(IWcenters,cumsum(IWvalsS),'color',colors3(1,:),'LineWidth',2)
%     semilogx(IScenters,cumsum(ISvalsS),'color',colors3(2,:),'LineWidth',2)
%     semilogx(IRcenters,cumsum(IRvalsS),'color',colors3(3,:),'LineWidth',2)
%     semilogx(IWcenters,cumsum(IWvals),'.','MarkerSize',5,'color',colors3(1,:))
%     semilogx(IScenters,cumsum(ISvals),'.','MarkerSize',5,'color',colors3(2,:))
%     semilogx(IRcenters,cumsum(IRvals),'.','MarkerSize',5,'color',colors3(3,:))
    semilogx(IWcenters,cumsum(IWvals),'color',colors3(1,:),'LineWidth',2)
    semilogx(IScenters,cumsum(ISvals),'color',colors3(2,:),'LineWidth',2)
    semilogx(IRcenters,cumsum(IRvals),'color',colors3(3,:),'LineWidth',2)
    t = sort(IWSWake);
    xlines = t(round((1:6)*(length(t)/6)));
    yl = ylim;
    for a = 1:5;
        plot([xlines(a) xlines(a)],yl,'color',[.5 .5 .5])
    end
    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'IWake';'ISWS';'IREM'},'location','NorthWest')

%% replot only WSSleep
h(end+1) = figure('position',[2 2 800 800],'name',['StateDistributionCurvesWSSleep_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
subplot(2,1,1)
    hold on;
    semilogx(EWcenters,ESlvalsS,'color',colors3(1,:),'LineWidth',2)
    semilogx(EWcenters,ESlvals,'.','MarkerSize',5,'color',colors3(1,:))

    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'ESleep'},'location','NorthWest')
%     t = sort(EWSWake);
%     xlines = t(round((1:6)*(length(t)/6)));
%     yl = ylim;
%     for a = 1:5;
%         plot([xlines(a) xlines(a)],yl,'color',[.5 .5 .5])
%     end
subplot(2,1,2)
    hold on;
    semilogx(ISlcenters,ISlvalsS,'color',colors3(1,:),'LineWidth',2)
    semilogx(ISlcenters,ISlvals,'.','MarkerSize',5,'color',colors3(1,:))
    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'IWake'},'location','NorthWest')
%     t = sort(IWSSleep);
%     xlines = t(round((1:6)*(length(t)/6)));
%     yl = ylim;
%     for a = 1:5;
%         plot([xlines(a) xlines(a)],yl,'color',[.5 .5 .5])
%     end


%% plot linear for reference
h(end+1) = figure('position',[2 2 800 800],'name',['LinearStateDistributionCurvesWSROnly_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
subplot(2,1,1)
    hold on;
    plot(EWcenters,EWvalsS,'color',colors3(1,:),'LineWidth',2)
    plot(EScenters,ESvalsS,'color',colors3(2,:),'LineWidth',2)
    plot(ERcenters,ERvalsS,'color',colors3(3,:),'LineWidth',2)
    plot(EWcenters,EWvals,'.','MarkerSize',5,'color',colors3(1,:))
    plot(EScenters,ESvals,'.','MarkerSize',5,'color',colors3(2,:))
    plot(ERcenters,ERvals,'.','MarkerSize',5,'color',colors3(3,:))
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'EWake';'ESWS';'EREM'},'location','NorthWest')
subplot(2,1,2)
    hold on;
    plot(IWcenters,IWvalsS,'color',colors3(1,:),'LineWidth',2)
    plot(IScenters,ISvalsS,'color',colors3(2,:),'LineWidth',2)
    plot(IRcenters,IRvalsS,'color',colors3(3,:),'LineWidth',2)
    plot(IWcenters,IWvals,'.','MarkerSize',5,'color',colors3(1,:))
    plot(IScenters,ISvals,'.','MarkerSize',5,'color',colors3(2,:))
    plot(IRcenters,IRvals,'.','MarkerSize',5,'color',colors3(3,:))
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'IWake';'ISWS';'IREM'},'location','NorthWest')

h(end+1) = figure('position',[2 2 800 800],'name',['StateDistributionCurvesSUSpOnly_nBins' num2str(Enumbins) '_nSmooth' num2str(Enumsmoothing)]);
subplot(2,1,1)
    hold on;
    semilogx(EScenters,ESvalsS,'color',colors5(2,:),'LineWidth',2)
    semilogx(EUcenters,EUvalsS,'color',colors5(3,:),'LineWidth',2)
    semilogx(ESpcenters,ESpvalsS,'color',colors5(4,:),'LineWidth',2)
    semilogx(EScenters,ESvals,'.','MarkerSize',5,'color',colors5(2,:))
    semilogx(EUcenters,EUvals,'.','MarkerSize',5,'color',colors5(3,:))
    semilogx(ESpcenters,ESpvals,'.','MarkerSize',5,'color',colors5(4,:))

    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'ESWS';'EUPs';'ESpindles'},'location','NorthWest')

subplot(2,1,2)
    hold on;
    semilogx(IScenters,ISvalsS,'color',colors5(2,:),'LineWidth',2)
    semilogx(IUcenters,IUvalsS,'color',colors5(3,:),'LineWidth',2)
    semilogx(ISpcenters,ISpvalsS,'color',colors5(4,:),'LineWidth',2)
    semilogx(IScenters,ISvals,'.','MarkerSize',5,'color',colors5(2,:))
    semilogx(IUcenters,IUvals,'.','MarkerSize',5,'color',colors5(3,:))
    semilogx(ISpcenters,ISpvals,'.','MarkerSize',5,'color',colors5(4,:))
    set(gca,'XScale','log')
    xlabel('Rate(hz)')
    ylabel('# Units')
    legend({'ISWS';'IUPs';'ISpindles'},'location','NorthWest')
    
%% Examine slope of Wake vs First SWS and Wake vs Last SWS
h(end+1) = figure('name','WakeVsFirstSWSVsLastSWSE','position',[200 100 700 700]);
    subplot(2,2,1)
    [~,~,Fslope,FslopeCI, Fintercept, Fyfit]=ScatterWStats(EWSWake,EFSWS,'loglog');
    subplot(2,2,2)
    [~,~,Lslope,LslopeCI, Lintercept, Lyfit]=ScatterWStats(EWSWake,ELSWS,'loglog');
    
    subplot(2,5,6:9)
    plotx = [min(EWSWake(EWSWake>0)) max(EWSWake)];
    plotx = log10(plotx);
    plotyF = plotx*Fslope+Fintercept;
    plotyFu = plotx*FslopeCI(2,1)+Fintercept;
    plotyFbu = plotyFu - plotyF;
    plotyFbl = plotyFu - plotyF;
        
    plotyL = plotx*Lslope+Lintercept;
    plotyLu = plotx*LslopeCI(2,1)+Lintercept;
    plotyLbu = plotyLu - plotyL;
    plotyLbl = plotyLu - plotyL;

    fboundmtx = cat(2,plotyFbu',plotyFbl');
    lboundmtx = cat(2,plotyLbu',plotyLbl');
    boundmtx = cat(3,fboundmtx,lboundmtx);
    plot(plotx,plotx,'color',[.7 .7 .7])
    hold on
    boundedline([plotx' plotx'],[plotyF' plotyL'],boundmtx)
    axis tight
    xlabel('Log Rate in Wake')
    ylabel('Log Rate in First or Last SWS')
    legend('null','Wake vs First SWS','Wake vs Last SWS','location','eastoutside')
    AboveTitle('E Cells')

h(end+1) = figure('name','WakeVsFirstSWSVsLastSWSI','position',[200 100 700 700]);
    subplot(2,2,1)
    [~,~,Fslope,FslopeCI, Fintercept, Fyfit]=ScatterWStats(IWSWake,IFSWS,'loglog');
    subplot(2,2,2)
    [~,~,Lslope,LslopeCI, Lintercept, Lyfit]=ScatterWStats(IWSWake,ILSWS,'loglog');
    
    subplot(2,5,6:9)
    plotx = log10([min(IWSWake) max(IWSWake)]);
    plotyF = plotx*Fslope+Fintercept;
    plotyFu = plotx*FslopeCI(2,1)+Fintercept;
    plotyFbu = plotyFu - plotyF;
    plotyFbl = plotyFu - plotyF;
        
    plotyL = plotx*Lslope+Lintercept;
    plotyLu = plotx*LslopeCI(2,1)+Lintercept;
    plotyLbu = plotyLu - plotyL;
    plotyLbl = plotyLu - plotyL;

    fboundmtx = cat(2,plotyFbu',plotyFbl');
    lboundmtx = cat(2,plotyLbu',plotyLbl');
    boundmtx = cat(3,fboundmtx,lboundmtx);
    plot(plotx,plotx,'color',[.7 .7 .7])
    hold on
    boundedline([plotx' plotx'],[plotyF' plotyL'],boundmtx)
    axis tight
    xlabel('Log Rate in Wake')
    ylabel('Log Rate in First or Last SWS')
    legend('null','Wake vs First SWS','Wake vs Last SWS','location','eastoutside')
    AboveTitle('I Cells')

%% Save
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/StateRates',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/StateRates',h,'svg')


1;