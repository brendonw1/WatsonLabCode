function SleepPETHs_PlotSummaryNormFigs_UPDNRatio

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','UPDNRatioOverSleepInts.mat'))
statenames = UPDNRatioOverSleepInts.statenames;

%% for tstate = 1:length(statenames);
h(end+1) = figure('name','UPDNRatios','position',[2 2 400 800]);
for a = 1:3;
    tstate = 4-a;
    
    ax = subplot(3,2,a*2-1);
    t = UPDNRatioOverSleepInts.AllEpAlignedU;
    [~,ut1,ut2] = PlotPETHNormAxesData(t{tstate},ax,'g');
    
    t = UPDNRatioOverSleepInts.AllEpAlignedD;
    [~,dt1,dt2] = PlotPETHNormAxesData(t{tstate},ax,'r');

    t = UPDNRatioOverSleepInts.AllEpAlignedNoUD;
    [~,nudt1,nudt2] = PlotPETHNormAxesData(t{tstate},ax,'k');

    title (['UP,DN,Neither in ' statenames{tstate}],'fontweight','normal')
    ylabel('% time')
    if a == 3
        tl = findall(ax,'type','line','marker','.');
        legend(tl,'NonDetect','OFF','ON')
    end
    
    ax = subplot(3,2,a*2);
    t = UPDNRatioOverSleepInts.AllEpAlignedN;
    [~,nt1,nt2] = PlotPETHNormAxesData(t{tstate},ax,'g');
    t = UPDNRatioOverSleepInts.AllEpAlignedF;
    [~,ft1,ft2] = PlotPETHNormAxesData(t{tstate},ax,'r');
    t = UPDNRatioOverSleepInts.AllEpAlignedNoNF;
    [ax,nnft1,nnft2] = PlotPETHNormAxesData(t{tstate},ax,'k');
    title (['ON,OFF,Neither in ' statenames{tstate}],'fontweight','normal')
    ylabel('% time')
    if a == 3
        tl = findall(ax,'type','line','marker','.');
        legend(tl,'NonDetect','OFF','ON')
    end
    
    set(ut1,'String',strcat('UP:',get(ut1,'String')),'position',[.01 .95 0])
    set(ut2,'String',strcat('UP:',get(ut2,'String')),'position',[.01 .875 0])
    set(dt1,'String',strcat('DN:',get(dt1,'String')),'position',[.01 .55 0])
    set(dt2,'String',strcat('DN:',get(dt2,'String')),'position',[.01 .475 0])
    set(nudt1,'String',strcat('NoUD:',get(nudt1,'String')),'position',[.01 .15 0])
    set(nudt2,'String',strcat('NoUD:',get(nudt2,'String')),'position',[.01 .075 0])

    set(nt1,'String',strcat('ON:',get(nt1,'String')),'position',[.01 .95 0])
    set(nt2,'String',strcat('ON:',get(nt2,'String')),'position',[.01 .875 0])
    set(ft1,'String',strcat('OFF:',get(ft1,'String')),'position',[.01 .55 0])
    set(ft2,'String',strcat('OFF:',get(ft2,'String')),'position',[.01 .475 0])
    set(nnft1,'String',strcat('NoNF:',get(nnft1,'String')),'position',[.01 .15 0])
    set(nnft2,'String',strcat('NoNF:',get(nnft2,'String')),'position',[.01 .075 0])
end

    
h(end+1) = copyobj(h(end),0);
delete(findall(h(end),'type','line'));%delete lines from 2nd fig
delete(findall(h(end),'type','legend'));%delete lines from 2nd fig
set(h(end),'position',[402 2 400 800],'name','UPDNRatios-Stats')

delete(findall(h(end-1),'tag','ptext'));%delete text from orig fig

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
