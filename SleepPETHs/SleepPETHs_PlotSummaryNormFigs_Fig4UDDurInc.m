function SleepPETHs_PlotSummaryNormFigs_Fig4UDDurInc
PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

%need rates!

load(fullfile(PF,'UPs','UPIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPDursIntsOverSleepInts.mat'))

load(fullfile(PF,'UPs','DNIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','DNDursIntsOverSleepInts.mat'))

statenames = {'SWSPackets','SWSEpisodes','SWSSleep'};
numhorizplots = 2;
%% for tstate = 1:length(statenames);
h = [];
h(end+1) = figure('name','ForFig4_UPDNDurInc','position',[2 2 1200 800]);
for a = 1:3;
    tstate = 4-a;

    
    ax = subplot(length(statenames),numhorizplots,a*numhorizplots-1);
        t = UPIncidenceOverSleepInts;
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
        t = t.AllEpAlignedI;
        valsa = nanmean(t{stateidx}.align_norm,2);
        timesa = t{stateidx}.t_norm;

        t = DNIncidenceOverSleepInts;
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
        t = t.AllEpAlignedI;
        valsb = nanmean(t{stateidx}.align_norm,2);
        timesb = t{stateidx}.t_norm;

        xl = [-0.1 1.1];
        [hax] = plotyy(timesa,valsa,timesb,valsb);
        set(hax,'xlim',xl)
        ylabel(hax(1),'Hz')
        ylabel(hax(2),'Hz')
        legend('UPIncidence','DOWNIncidence')
        title(['UP/DOWN Incidence across ' statenames{tstate}],'fontweight','normal','fontsize',10)

    ax = subplot(length(statenames),numhorizplots,a*numhorizplots);
        t = UPDursIntsOverSleepInts;
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
        t = t.AllEpAlignedD;
        valsa = nanmean(t{stateidx}.align_norm,2);
        timesa = t{stateidx}.t_norm;

        t = DNDursIntsOverSleepInts;
        stateidx = find(strcmp(t.statenames,statenames{tstate}));
        t = t.AllEpAlignedD;
        valsb = nanmean(t{stateidx}.align_norm,2);
        timesb = t{stateidx}.t_norm;

        xl = [-0.1 1.1];
        [hax] = plotyy(timesa,valsa,timesb,valsb);
        set(hax,'xlim',xl)
        ylabel(hax(1),'s')
        ylabel(hax(2),'s')
        legend('UPDuration','DOWNDuration')
        title(['UP/DOWN Duration across ' statenames{tstate}],'fontweight','normal','fontsize',10)
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/SuperSummaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/SuperSummaries/',h,'svg')
