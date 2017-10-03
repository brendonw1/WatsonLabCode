function SleepPETHs_PlotSummaryNormFigs_UPDOWNRoleInSpiking

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

%need rates!
load(fullfile(PF,'PopRate','PopRateOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPRatesOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPDursIntsOverSleepInts.mat'))

load(fullfile(PF,'CoeffVar','CoeffVarOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPEICoVOverSleepInts.mat'))
load(fullfile(PF,'UPs','DNIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','DNDursIntsOverSleepInts.mat'))

load(fullfile(PF,'BurstIndex','MeanBurstIndexOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPEIBurstIndexOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPDNRatioOverSleepInts.mat'))

load(fullfile(PF,'EIRatio','EIRatioOverSleepInts.mat'))
load(fullfile(PF,'Spindles','SpindleIncidenceOverSleepInts.mat'))
load(fullfile(PF,'Spindles','SpindleDursIntsOverSleepInts.mat'))

statenames = {'SWSPackets','SWSEpisodes','Sleep'};

%% for tstate = 1:length(statenames);
for a = 1:3;
    tstate = 4-a;

    h(end+1) = figure('name',['UPVsSpkIn' statenames{tstate}],'position',[2 2 1200 800]);
    
    ax = subplot(4,4,1);
    t = PopRateOverSleepInts;
    if strcmp(statenames{tstate},'Sleep')
        stateidx = find(strcmp(t.statenames,'SWSSleep'));
    else
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
    end
    t = t.AllEpAlignedE;
    [~,r1,r2] = PlotPETHNormAxesData(t{stateidx});
    title ('E SpkRates','fontweight','normal','fontsize',10)

    ax = subplot(4,4,2);
    t = UPRatesOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedE;
    [~,ur1,ur2] = PlotPETHNormAxesData(t{stateidx});
    title ('E SpkRates in UPs','fontweight','normal','fontsize',10)

    ax = subplot(4,4,3);
    t = UPIncidenceOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedI;
    [~,ui1,ui2] = PlotPETHNormAxesData(t{stateidx});
    title ('UP Incidence','fontweight','normal','fontsize',10)
    
    ax = subplot(4,4,4);
    t = UPDursIntsOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedD;
    [~,ud1,ud2] = PlotPETHNormAxesData(t{stateidx});
    title ('UP Duration','fontweight','normal','fontsize',10)

    ax = subplot(4,4,5);
    t = CoeffVarOverSleepInts;
    if strcmp(statenames{tstate},'Sleep')
        stateidx = find(strcmp(t.statenames,'SWSSleep'));
    else
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
    end
    t = t.AllEpAlignedE;
    [~,cv1,cv2] = PlotPETHNormAxesData(t{stateidx});
    title ('CoeffVar','fontweight','normal','fontsize',10)
    
    ax = subplot(4,4,6);
    t = UPEICoVOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedCoVE;
    [~,uc1,uc2] = PlotPETHNormAxesData(t{stateidx});
    title ('UP CoeffVar','fontweight','normal','fontsize',10)

    ax = subplot(4,4,7);
    t = DNIncidenceOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedI;
    [~,di1,di2] = PlotPETHNormAxesData(t{stateidx});
    title ('DN Incidence','fontweight','normal','fontsize',10)
    
    ax = subplot(4,4,8);
    t = DNDursIntsOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedD;
    [~,dd1,dd2] = PlotPETHNormAxesData(t{stateidx});
    title ('DN Duration','fontweight','normal','fontsize',10)

    ax = subplot(4,4,9);
    t = MeanBurstIndexOverSleepInts;
    if strcmp(statenames{tstate},'Sleep')
        stateidx = find(strcmp(t.statenames,'SWSSleep'));
    else
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
    end
    t = t.AllEpAlignedE;
    [~,bu1,bu2] = PlotPETHNormAxesData(t{stateidx});
    title ('BurstIdx','fontweight','normal','fontsize',10)

    ax = subplot(4,4,10);
    t = UPEIBurstIndexOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedE;
    [~,ub1,ub2] = PlotPETHNormAxesData(t{stateidx});
    title ('UP BurstIdx','fontweight','normal','fontsize',10)

    ax = subplot(4,4,11);
    tt = UPDNRatioOverSleepInts;
    stateidx = find(strcmp(tt.statenames,statenames{tstate}));
    t = tt.AllEpAlignedU;
    [~,up1,up2] = PlotPETHNormAxesData(t{stateidx},ax,'g');
    t = tt.AllEpAlignedD;
    [~,dp1,dp2] = PlotPETHNormAxesData(t{stateidx},ax,'r');
    t = tt.AllEpAlignedNoUD;
    [~,nudp1,nudp2] = PlotPETHNormAxesData(t{stateidx},ax,'k');
    title (['% in UP,DN,Neither'],'fontweight','normal')
    set(up1,'String',strcat('UP:',get(up1,'String')),'position',[.01 .55 0])
    set(up2,'String',strcat('UP:',get(up2,'String')),'position',[.01 .475 0])
    set(dp1,'String',strcat('DN:',get(dp1,'String')),'position',[.01 .15 0])
    set(dp2,'String',strcat('DN:',get(dp2,'String')),'position',[.01 .075 0])
    set(nudp1,'String',strcat('NoUD:',get(nudp1,'String')),'position',[.01 .95 0])
    set(nudp2,'String',strcat('NoUD:',get(nudp2,'String')),'position',[.01 .875 0])

    ax = subplot(4,4,13);
    t = EIRatioOverSleepInts;
    if strcmp(statenames{tstate},'Sleep')
        stateidx = find(strcmp(t.statenames,'SWSSleep'));
    else
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
    end
    t = t.AllEpAligned;
    [~,ei1,ei2] = PlotPETHNormAxesData(t{stateidx});
    title ('EIRatio','fontweight','normal','fontsize',10)
    
    ax = subplot(4,4,14);
    t = UPEICoVOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedEIR;
    [~,uc1,uc2] = PlotPETHNormAxesData(t{stateidx});
    title ('UP EIRatio','fontweight','normal','fontsize',10)

    ax = subplot(4,4,15);
    t = SpindleIncidenceOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedI;
    [~,uc1,uc2] = PlotPETHNormAxesData(t{stateidx});
    title ('Spindle Incidence','fontweight','normal','fontsize',10)

    ax = subplot(4,4,16);
    t = SpindleDursIntsOverSleepInts;
    stateidx = find(strcmp(t.statenames,statenames{tstate}));
    t = t.AllEpAlignedD;
    [~,uc1,uc2] = PlotPETHNormAxesData(t{stateidx});
    title ('Spindle Duration','fontweight','normal','fontsize',10)

%% Duplicate figure to have just stats on it     
%     h(end+1) = copyobj(h(end),0);
%     delete(findall(h(end),'type','line'));%delete lines from 2nd fig
% %     delete(findall(h(end),'type','legend'));%delete lines from 2nd fig
%     set(h(end),'name',['UPVsSpkIn' statenames{tstate} '-Stats'])
% 
%     delete(findall(h(end-1),'tag','ptext'));%delete text from orig fig
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/SuperSummaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/SuperSummaries/',h,'png')
