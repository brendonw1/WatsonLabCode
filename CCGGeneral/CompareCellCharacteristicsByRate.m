function CompareCellCharacteristicsByRate
warning off

%% Basic setup
[names,dirs] = GetDefaultDataset;

Ept = [];
Ewd = [];
Ewvs = [];
Eacgs10 = [];
Eacgs30 = [];
Eacgs100 = [];
Eacgs300 = [];
Eacgs1000 = [];
Eacgs3000 = [];
Ipt = [];
Iwd = [];
Iwvs = [];
Iacgs10 = [];
Iacgs30 = [];
Iacgs100 = [];
Iacgs300 = [];
Iacgs1000 = [];
Iacgs3000 = [];

numratedivisions = 6;

% [ISpFast,ISpSlow] = ICellsBySpindleRate(1);%find I cells faster/slower than 1Hz during spindles


%% Gather info
for a = 1:length(dirs);
    basepath = dirs{a};
    basename = names{a};
    cd(basepath)
    
    %waveforms
    wv = load(fullfile(basepath,[basename,'_MeanWaveforms.mat']));
    
    %ACGs
%     if ~exist(fullfile(basepath,[basename, '_ACGData']),'file')
%         GatherCellACGs(basepath,basename)
%     end
%     acg = load(fullfile(basepath,[basename, '_ACGData']));
    t = load(fullfile(basepath,[basename '_ACGCCGsAll.mat']));
    acg10 = t.ACGCCGsAll.ACGs{1};
    acg30 = t.ACGCCGsAll.ACGs{2};
    acg100 = t.ACGCCGsAll.ACGs{3};
    acg300 = t.ACGCCGsAll.ACGs{4};
    acg1000 = t.ACGCCGsAll.ACGs{5};
    acg3000 = t.ACGCCGsAll.ACGs{6};

    if a == 1;
        acgtimes = t.ACGCCGsAll.Times;
    end
    
    %waveform metrics
    c = load(fullfile(basepath,[basename, '_CellClassificationOutput.mat']));
    pt = c.CellClassificationOutput.CellClassOutput(:,2);    
    wd = c.CellClassificationOutput.CellClassOutput(:,3);
    
    c = load(fullfile(basepath,[basename, '_CellIDs']));
    e = c.CellIDs.EAll;
    i = c.CellIDs.IAll;
    
    numcellsA = size(acg10,2);
    numcellsWv = size(wv.MeanWaveforms.MaxWaves,2);
    
%     if (length(e)+length(i))~=numcellsA || numcellsA~=numcellsWv
%         error('unequal number of cells in loaded matrices')
%     end
    
    Ept = cat(1,Ept,pt(e));
    Ewd = cat(1,Ewd,wd(e));
    Ewvs = cat(2,Ewvs,wv.MeanWaveforms.MaxWaves(:,e));
    Eacgs10 = cat(2,Eacgs10,acg10(:,e));
    Eacgs30 = cat(2,Eacgs30,acg30(:,e));
    Eacgs100 = cat(2,Eacgs100,acg100(:,e));
    Eacgs300 = cat(2,Eacgs300,acg300(:,e));
    Eacgs1000 = cat(2,Eacgs1000,acg1000(:,e));
    Eacgs3000 = cat(2,Eacgs3000,acg3000(:,e));
 
    Ipt = cat(1,Ipt,pt(i));
    Iwd = cat(1,Iwd,wd(i));
    Iwvs = cat(2,Iwvs,wv.MeanWaveforms.MaxWaves(:,i));
    Iacgs10 = cat(2,Iacgs10,acg10(:,i));
    Iacgs30 = cat(2,Iacgs30,acg30(:,i));
    Iacgs100 = cat(2,Iacgs100,acg100(:,i));
    Iacgs300 = cat(2,Iacgs300,acg300(:,i));
    Iacgs1000 = cat(2,Iacgs1000,acg1000(:,i));
    Iacgs3000 = cat(2,Iacgs3000,acg3000(:,i));
    
    ne(a) = length(e);
    ni(a) = length(i);
end

s = SpikingAnalysis_GatherAllStateRates;

%% Normalize waves
[em,emi] = min(Ewvs,[],1);
[im,imi]= min(Iwvs,[],1);

ew = [];
for a = 1:length(emi)
    if emi(a)>16.5
        ew(:,a) = Ewvs(2:32,a);
    elseif emi(a)<16.5
        ew(:,a) = Ewvs(1:31,a);
    end
end
iw = [];
for a = 1:length(imi)
    if imi(a)>16.5
        iw(:,a) = Iwvs(2:32,a);
    elseif imi(a)<16.5
        iw(:,a) = Iwvs(1:31,a);
    end
end

Ewvs = ew./repmat(-em,31,1);
Iwvs = iw./repmat(-im,31,1);

% IspFwvs = Iwvs(:,ISpFast);
% IspSwvs = Iwvs(:,ISpSlow);

%% Manual review if you want
figure;imagesc(Ewvs)
figure;imagesc(Iwvs)
    

%% Plot waveforms by rate/class
colors = RainbowColors(numratedivisions);

[~,sidx] = sort(s.EWSWakeRates);
ne = length(sidx);
edivs = round(linspace(1,ne,numratedivisions+1));
estarts = edivs(1:numratedivisions);
eends = edivs(2:numratedivisions+1);

h = figure('name','Waveforms By ECell Rates vs ICells','position',[0 2 560 900]);
subplot(2,1,1)
hold on
for a = 1:numratedivisions
    tidx = estarts(a):eends(a);
    twvs = Ewvs(:,sidx(tidx));
%     pstart = (a-1)*41;
%     plot(pstart+1:pstart+31,mean(twvs,2)')
    tmean = mean(twvs,2)';
    tmean = -tmean/min(tmean);
    plot(tmean,'color',colors(a,:),'LineWidth',2)
    if a == 1
        labelcell{a} = [num2str(a) ' Low FR'];
    elseif a == numratedivisions
        labelcell{a} = [num2str(a) ' High FR'];
    else
        labelcell{a} = num2str(a);
    end
end
labelcell{end+1} = 'ICells';


imean = mean(Iwvs,2)';
imean = -imean/min(imean);
plot(imean,'color','k','LineWidth',4)

legend(labelcell,'Location','SouthWest')
axis tight

subplot(2,1,2)
hold on
for a = 1:numratedivisions
    tidx = estarts(a):eends(a);
    twvs = Ewvs(:,sidx(tidx));
%     pstart = (a-1)*41;
%     plot(pstart+1:pstart+31,mean(twvs,2)')
    tmean = mean(twvs,2)';
%     tmean = -tmean/min(tmean);
    plot(tmean,'color',colors(a,:),'LineWidth',2)
end

imean = mean(Iwvs,2)';
% imean = -imean/min(imean);
plot(imean,'color','k','LineWidth',4)

legend(labelcell,'Location','SouthWest')
axis tight



%% Regressions of spike features vs rate
[perspikemin,minloc] = min(Ewvs(12:20,:));
minloc = minloc+11;
for a = 1:size(Ewvs,2);
    [premax(a),premaxloc(a)] = max(Ewvs(1:minloc(a)-1,a));
    [postmax(a),postmaxloc(a)] = max(Ewvs(minloc(a)+1:end,a));
end
postmaxloc = postmaxloc+minloc;
minpostmaxslope = [perspikemin-postmax]./[minloc-postmaxloc];
minpremaxslope = [perspikemin-premax]./[minloc-premaxloc];

h(2) = figure('position',[0 2 560 900],'name','Rate vs Waveform Characteristics');
subplot(4,2,1);
plot(s.EWSWakeRates,premax,'k.');%amp of premax
set(get(gca,'ylabel'),'String','amp of premax')
subplot(4,2,2);
plot(s.EWSWakeRates,postmax,'k.');%amp of postmax
set(get(gca,'ylabel'),'String','amp of postmax')
% hold on
% for a = 1:numratedivisions
%     tidx = estarts(a):eends(a);
%     tpms = mean(postmax(sidx(tidx)));
%     trates = mean(s.EWSWakeRates(sidx(tidx)));
%     plot(trates,tpms,'color',colors(a,:),'marker','.','markersize',50)
% end
    
    
subplot(4,2,3);
plot(s.EWSWakeRates,premaxloc,'k.');%location of premax
set(get(gca,'ylabel'),'String','location of premax')
subplot(4,2,4);
plot(s.EWSWakeRates,postmaxloc,'k.');%location of postmax
set(get(gca,'ylabel'),'String','location of postmax')

subplot(4,2,5);
plot(s.EWSWakeRates,minpostmaxslope,'k.');%slope min to premax
set(get(gca,'ylabel'),'String','Slope from min to premax')
subplot(4,2,6);
plot(s.EWSWakeRates,minpostmaxslope,'k.');%slope min to postmax
set(get(gca,'ylabel'),'String','Slope from min to postmax')

subplot(4,2,7);
plot(s.EWSWakeRates,Ewd,'k.');
set(get(gca,'ylabel'),'String','Spike Width')
subplot(4,2,8);
plot(s.EWSWakeRates,Ept,'k.');
set(get(gca,'ylabel'),'String','Trough-Peak ms')

AboveTitle('All vs Wake Rate')
1;

%% Another figure of some other exploratory correlations
h(end+1) = figure('position',[0 2 560 900],'name','WaveformPropertyCorrelations');
vp = 3;
hp = 2;

subplot(vp,hp,1)
plot(postmaxloc,postmax,'.k')
xlabel('Postmax delay (samples after trough)')
ylabel('Postmax amplitude')

subplot(vp,hp,2)
plot(premaxloc,premax,'.k')
xlabel('Premax delay (samples after trough)')
ylabel('Premax amplitude')

subplot(vp,hp,3)
plot(Ewd,postmax,'k.')
xlabel('Spike Width')
ylabel('Post max amplitude')

subplot(vp,hp,4)
plot(Ept,postmax,'k.')
xlabel('Trough-Peak ms')
ylabel('Post max amplitude')

subplot(vp,hp,5)
plot(Ewd,premax,'k.')
xlabel('Spike Width')
ylabel('Pre max amplitude')

subplot(vp,hp,6)
plot(Ept,premax,'k.')
xlabel('Trough-Peak ms')
ylabel('Pre max amplitude')

AboveTitle('Basic correlations of waveform measures')
1;

%% Normalize acgs
nEacgs10 = Eacgs10./repmat(max(Eacgs10,[],1),size(Eacgs10,1),1);
nIacgs10 = Iacgs10./repmat(max(Iacgs10,[],1),size(Iacgs10,1),1);
nEacgs30 = Eacgs30./repmat(max(Eacgs30,[],1),size(Eacgs30,1),1);
nIacgs30 = Iacgs30./repmat(max(Iacgs30,[],1),size(Iacgs30,1),1);
nEacgs100 = Eacgs100./repmat(max(Eacgs100,[],1),size(Eacgs100,1),1);
nIacgs100 = Iacgs100./repmat(max(Iacgs100,[],1),size(Iacgs100,1),1);
nEacgs300 = Eacgs300./repmat(max(Eacgs300,[],1),size(Eacgs300,1),1);
nIacgs300 = Iacgs300./repmat(max(Iacgs300,[],1),size(Iacgs300,1),1);
nEacgs1000 = Eacgs1000./repmat(max(Eacgs1000,[],1),size(Eacgs1000,1),1);
nIacgs1000 = Iacgs1000./repmat(max(Iacgs1000,[],1),size(Iacgs1000,1),1);
nEacgs3000 = Eacgs3000./repmat(max(Eacgs3000,[],1),size(Eacgs3000,1),1);
nIacgs3000 = Iacgs3000./repmat(max(Iacgs3000,[],1),size(Iacgs3000,1),1);

%% ACGs plots of E vs I
h(end+1:end+2) = ACGPlot(Eacgs10,Iacgs10,nEacgs10,nIacgs10,acgtimes{1},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'10ms'])
set(h(end),'name',[get(h(end),'name'),'10ms'])

h(end+1:end+2) = ACGPlot(Eacgs30,Iacgs30,nEacgs30,nIacgs30,acgtimes{2},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'30ms'])
set(h(end),'name',[get(h(end),'name'),'30ms'])

h(end+1:end+2) = ACGPlot(Eacgs100,Iacgs100,nEacgs100,nIacgs100,acgtimes{3},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'100ms'])
set(h(end),'name',[get(h(end),'name'),'100ms'])

h(end+1:end+2) = ACGPlot(Eacgs300,Iacgs300,nEacgs300,nIacgs300,acgtimes{4},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'300ms'])
set(h(end),'name',[get(h(end),'name'),'300ms'])

h(end+1:end+2) = ACGPlot(Eacgs1000,Iacgs1000,nEacgs1000,nIacgs1000,acgtimes{5},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'1000ms'])
set(h(end),'name',[get(h(end),'name'),'1000ms'])

h(end+1:end+2) = ACGPlot(Eacgs3000,Iacgs3000,nEacgs3000,nIacgs3000,acgtimes{6},numratedivisions,sidx,labelcell);
set(h(end-1),'name',[get(h(end-1),'name'),'3000ms'])
set(h(end),'name',[get(h(end),'name'),'300s0ms'])

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/CellSpikesACGs',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/CellSpikesACGs',h,'png')

1;


function h = ACGPlot(Eacgs,Iacgs,nEacgs,nIacgs,acgtimes,numratedivisions,sidx,labelcell)
warning off

colors = RainbowColors(numratedivisions);

ne = length(sidx);
edivs = round(linspace(1,ne,numratedivisions+1));
estarts = edivs(1:numratedivisions);
eends = edivs(2:numratedivisions+1);


h(1) = figure('position',[0 2 600 800],'name','BasicACGOverlays');
vp = 3;
hp = 2;
% raw overlay plot
% subplot(vp,hp,1)
% plot(Eacgs);
% axis tight
% subplot(vp,hp,2)
% plot(Iacgs);
% axis tight
% log overlay plot
subplot(vp,hp,1)
semilogy(Eacgs);
axis tight
title('semilogy of E')
subplot(vp,hp,2)
semilogy(Iacgs)
axis tight
title('semilogy of I')
% normalized
subplot(vp,hp,3);
imagesc(nEacgs');
axis tight
title('Zscored E')
subplot(vp,hp,4);
imagesc(nIacgs');
axis tight
title('Zscored I')
% Boundedline
subplot(vp,hp,5);
boundedline(acgtimes,nanmean(nIacgs,2),nanstd(nIacgs,[],2),'cmap',[1 0 0])
hold on
boundedline(acgtimes,nanmean(nEacgs,2),nanstd(nEacgs,[],2),'cmap',[0 1 0])
axis tight
title('E-mean Green, I-mean Red')
AboveTitle('ACG overlays by Cell Class')

% ACGs by decile
h(2) = figure('position',[0 2 500 800],'name','ACGsByDecile');
subplot(2,1,1)% decile means renormalized for plot here
hold on
for a = 1:numratedivisions
    tidx = estarts(a):eends(a);
    tacgs = nEacgs(:,sidx(tidx));
    tacgs(tacgs==Inf) = 1;
    tacgs(tacgs==-Inf) = 0;
%     pstart = (a-1)*41;
%     plot(pstart+1:pstart+31,mean(twvs,2)')
    tmean = nanmean(tacgs,2)';
    tmean = tmean/max(tmean);
    plot(acgtimes,tmean,'color',colors(a,:),'LineWidth',2)
end

imean = nanmean(nIacgs,2)';
imean = imean/max(imean);
plot(acgtimes,imean,'color','k','LineWidth',4)

legend(labelcell,'Location','SouthWest')
axis tight
title('Renormalized')

% non-renormalized decile means
subplot(2,1,2)
hold on
for a = 1:numratedivisions
    tidx = estarts(a):eends(a);
    tacgs = nEacgs(:,sidx(tidx));
    tacgs(tacgs==Inf) = 1;
    tacgs(tacgs==-Inf) = 0;
%     pstart = (a-1)*41;
%     plot(pstart+1:pstart+31,mean(twvs,2)')
    tmean = nanmean(tacgs,2)';
%     tmean = tmean/max(tmean);
    plot(acgtimes,tmean,'color',colors(a,:),'LineWidth',2)
end

imean = nanmean(nIacgs,2)';
% imean = imean/max(imean);
plot(acgtimes,imean,'color','k','LineWidth',4)

legend(labelcell,'Location','SouthWest')
axis tight
title('Non-Renormalized')
AboveTitle('ACGs by E cell Decile VS Icells')

