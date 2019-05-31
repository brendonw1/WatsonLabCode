% Figures from individual whisker chunks. The user can choose which whisker
% to analyze, as well as two channel groups putatively representing
% intermediate and deep layers, and four individual channels.
%
%
%
% USAGE ___________________________________________________________________
% - Load workspace containing outputs from PiezoERPandMUAdata.m.
%
% - Respond to prompts.
%
%
%
% LSBuenoJr _______________________________________________________________



%% Figure 1
% Just a representative piezo waveform. This is also how piezo waveforms
% are designed for Bpod.
represPiezo = [NaN(1,params.befPiezo/20) ...
    sin(params.stimFreq*2*pi/(params.samplFreq/20):...
    params.stimFreq*2*pi/(params.samplFreq/20):...
    params.stimFreq*2*pi*params.stimDur)*2 ...
    NaN(1,params.aftPiezo/20)];

% Asks to select the whisker
whichWhisker    = 'Which whisker (e.g., D2)? ';
whichWhisker    = input(whichWhisker,'s');
whichRow        = cell(length(stackedChannels),1);
for i           = 1:length(whichRow)
    whichRow{i} = strcmp(stackedChannels(i).whiskerID,whichWhisker);
end;whichRow    = cell2mat(whichRow);
whichRow        = find(whichRow==1);
clear i whichWhisker

figure('name','Stacked-channels (merged sweeps)')
% Top left
img1 = subplot('position',[0.05 0.35 0.25 0.60]);
imagesc(stackedChannels(whichRow).ERP);hold on
plot((1:4000),represPiezo+62,'color',[0.466 0.674 0.188],'linewidth',2)
colormap(img1,redblue);title('Event-related potentials');caxis([-0.5 0.5])
ylabel('Channels across S1 layers');xticklabels([])
c = colorbar('position',[0.31 0.52 0.005 0.30]);
c.Label.String   = 'Millivolts';
c.Label.FontSize = 12;

% Top center
img2 = subplot('position',[0.40 0.35 0.25 0.60]);
imagesc(~stackedChannels(whichRow).binaryRaster);hold on
plot((1:4000),represPiezo+62,'color',[0.466 0.674 0.188],'linewidth',2)
colormap(img2,gray);title('Binary MUA raster')
yticklabels([]);xticklabels([])

% Top right
img3 = subplot('position',[0.70 0.35 0.25 0.60]);
imagesc(stackedChannels(whichRow).ZscoredRaster);hold on
plot((1:4000),represPiezo+62,'color',[0.466 0.674 0.188],'linewidth',2)
colormap(img3,redblue);title('Z scored MUA raster');caxis([-2 2])
yticklabels([]);xticklabels([])
c = colorbar('position',[0.96 0.52 0.005 0.30]);
c.Label.String   = 'Z score';
c.Label.FontSize = 12;
clear c img1 img2 img3

disp('Select channel ranges that potentially represent...')
middChn = input('...middle layers (e.g. 15:25): ');
deepChn = input('...deep layers (e.g. 45:55): ');

% Bottom left
subplot('position',[0.05 0.10 0.25 0.20]);
plot(mean(stackedChannels(whichRow). ...
    ERP(middChn,:)),'k','LineWidth',2);hold on
plot(mean(stackedChannels(whichRow). ...
    ERP(deepChn,:)),'color',[0.466 0.674 0.188],'LineWidt',2)
legend(...
    ['Chn ' num2str(middChn(1)) ':' num2str(middChn(length(middChn)))],...
    ['Chn ' num2str(deepChn(1)) ':' num2str(deepChn(length(deepChn)))])
ylabel('Mean (mV)');
xticks(0:length(represPiezo)/8:length(represPiezo))
xticklabels(-1:0.5:4);

% Bottom center
subplot('position',[0.40 0.10 0.25 0.20])
bar(sum(stackedChannels(whichRow). ...
    spkCount(middChn,:)),1,'FaceColor','k');hold on
b = bar(sum(stackedChannels(whichRow). ...
    spkCount(deepChn,:)),1,'FaceColor',[0.466 0.674 0.188]);
b.FaceAlpha = 0.5;
ylabel('Spike count (1 ms bins)')
xticks(0:length(represPiezo)/8:length(represPiezo))
xticklabels(-1:0.5:4);xlabel('Perievent time (s)')

% Bottom right
subplot('position',[0.70 0.10 0.25 0.20]);
plot(mean(stackedChannels(whichRow). ...
    ZscoredRaster(middChn,:)),'k','LineWidth',2);hold on
plot(mean(stackedChannels(whichRow). ...
    ZscoredRaster(deepChn,:)),'color',[0.466 0.674 0.188],'LineWidth',2)
ylabel('Mean (Z score)')
xticks(0:length(represPiezo)/8:length(represPiezo))
xticklabels(-1:0.5:4)



%% Figure 2. Difficult to set different colormaps by subplotting within
% loops. Hence subplots were written one by one.
represPiezoRastWholeEpoch = [NaN(1,params.befPiezo/200) ...
    sin(params.stimFreq*2*pi/(params.samplFreq/200):...
    params.stimFreq*2*pi/(params.samplFreq/200):...
    params.stimFreq*2*pi*params.stimDur)*2 ...
    NaN(1,params.aftPiezo/200)];

represPiezoRastZoomEpoch = [NaN(1,params.befPiezo/40) ...
    sin(params.stimFreq*2*pi/(params.samplFreq/40):...
    params.stimFreq*2*pi/(params.samplFreq/40):...
    params.stimFreq*2*pi*params.stimDur)*2 ...
    NaN(1,params.aftPiezo/40)];

% Asks to select four illustrative channels
whichChannels   = input('Four representative channels (e.g. [15 25 45 55]): ');

figure('name','Stacked-sweep ERP and MUA; representative channels')

% Left column _____________________________________________________________
axesColumn1 = zeros(8,1);

% Channel #1 among selected
img = subplot('position',[0.04 0.83 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(1)});
colormap(img,redblue);hold on
plot((1:4000),represPiezo+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(1) = subplot('position',[0.04 0.76 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(1)}),'k','linewidth',2);xticks([])
text(50,double(max(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(1)})))*0.85,...
    ['Chn ' num2str(whichChannels(1))])

img = subplot('position',[0.26 0.83 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(1)});
colormap(img,redblue);hold on
plot(represPiezo(1001:2000)+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(2) = subplot('position',[0.26 0.76 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPzoomEpoch{whichChannels(1)}),'k','linewidth',2);xticks([])





% Channel #2 among selected
img = subplot('position',[0.04 0.60 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(2)});
colormap(img,redblue);hold on
plot((1:4000),represPiezo+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(3) = subplot('position',[0.04 0.53 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(2)}),'k','linewidth',2);xticks([])
text(50,double(max(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(2)})))*0.85,...
    ['Chn ' num2str(whichChannels(2))])

img = subplot('position',[0.26 0.60 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(2)});
colormap(img,redblue);hold on
plot(represPiezo(1001:2000)+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(4) = subplot('position',[0.26 0.53 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPzoomEpoch{whichChannels(2)}),'k','linewidth',2);xticks([])





% Channel #3 among selected
img = subplot('position',[0.04 0.37 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(3)});
colormap(img,redblue);hold on
plot((1:4000),represPiezo+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(5) = subplot('position',[0.04 0.30 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(3)}),'k','linewidth',2);xticks([])
text(50,double(max(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(3)})))*0.85,...
    ['Chn ' num2str(whichChannels(3))])

img = subplot('position',[0.26 0.37 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(3)});
colormap(img,redblue);hold on
plot(represPiezo(1001:2000)+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(6) = subplot('position',[0.26 0.30 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPzoomEpoch{whichChannels(3)}),'k','linewidth',2);xticks([])





% Channel #4 among selected
img = subplot('position',[0.04 0.14 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(4)});
colormap(img,redblue);hold on
plot((1:4000),represPiezo+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
ylabel([num2str(size(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(4)},1)) ' sweeps'])
axesColumn1(7) = subplot('position',[0.04 0.07 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(4)}),'k','linewidth',2)
xticks(0:...
    length(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(4)})/8:...
    length(stackedSweeps(whichRow).ERPwholeEpoch{whichChannels(4)}))
ylabel('Mean (mV)');xticklabels(-1:0.5:4);xlabel('Perievent time (s)')
text(50,double(max(mean(stackedSweeps(whichRow). ...
    ERPwholeEpoch{whichChannels(4)})))*0.85,...
    ['Chn ' num2str(whichChannels(4))])

img = subplot('position',[0.26 0.14 0.20 0.14]);
imagesc(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(4)});
colormap(img,redblue);hold on
plot(represPiezo(1001:2000)+47,'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([]);caxis([-0.5 0.5])
axesColumn1(8) = subplot('position',[0.26 0.07 0.20 0.07]);
plot(mean(stackedSweeps(whichRow). ...
    ERPzoomEpoch{whichChannels(4)}),'k','linewidth',2)
xticks(0:...
    length(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(4)})/8:...
    length(stackedSweeps(whichRow).ERPzoomEpoch{whichChannels(4)}))
xticklabels(-1:0.5:4);

linkaxes(axesColumn1,'y')





% Right column ____________________________________________________________
axesColumn2 = zeros(8,1);

% Channel #1 among selected
img = subplot('position',[0.56 0.83 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastWholeEpoch{whichChannels(1)});
colormap(img,gray);hold on
plot((1:400),represPiezoRastWholeEpoch+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(1) = subplot('position',[0.56 0.76 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(1)},...
    'barwidth',1,'facecolor','k');xticks([])
text(10,double(max(stackedSweeps(whichRow). ...
    spkCountWholeEpoch{whichChannels(1)}))*0.85,...
    ['Chn ' num2str(whichChannels(1))])

img = subplot('position',[0.78 0.83 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastZoomEpoch{whichChannels(1)});
colormap(img,gray);hold on
plot(represPiezoRastZoomEpoch(501:1000)+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(2) = subplot('position',[0.78 0.76 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(1)},...
    'barwidth',1,'facecolor','k');xticks([])





% Channel #2 among selected
img = subplot('position',[0.56 0.60 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastWholeEpoch{whichChannels(2)});
colormap(img,gray);hold on
plot((1:400),represPiezoRastWholeEpoch+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(3) = subplot('position',[0.56 0.53 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(2)},...
    'barwidth',1,'facecolor','k');xticks([])
text(10,double(max(stackedSweeps(whichRow). ...
    spkCountWholeEpoch{whichChannels(2)}))*0.85,...
    ['Chn ' num2str(whichChannels(2))])

img = subplot('position',[0.78 0.60 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastZoomEpoch{whichChannels(2)});
colormap(img,gray);hold on
plot(represPiezoRastZoomEpoch(501:1000)+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(4) = subplot('position',[0.78 0.53 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(2)},...
    'barwidth',1,'facecolor','k');xticks([])





% Channel #3 among selected
img = subplot('position',[0.56 0.37 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastWholeEpoch{whichChannels(3)});
colormap(img,gray);hold on
plot((1:400),represPiezoRastWholeEpoch+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(5) = subplot('position',[0.56 0.30 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(3)},...
    'barwidth',1,'facecolor','k');xticks([])
text(10,double(max(stackedSweeps(whichRow). ...
    spkCountWholeEpoch{whichChannels(3)}))*0.85,...
    ['Chn ' num2str(whichChannels(3))])

img = subplot('position',[0.78 0.37 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastZoomEpoch{whichChannels(3)});
colormap(img,gray);hold on
plot(represPiezoRastZoomEpoch(501:1000)+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(6) = subplot('position',[0.78 0.30 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(3)},...
    'barwidth',1,'facecolor','k');xticks([])





% Channel #4 among selected
img = subplot('position',[0.56 0.14 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastWholeEpoch{whichChannels(4)});
colormap(img,gray);hold on
plot((1:400),represPiezoRastWholeEpoch+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
ylabel([num2str(size(stackedSweeps(whichRow). ...
    binaryRastWholeEpoch{whichChannels(4)},1)) ' sweeps'])
axesColumn2(7) = subplot('position',[0.56 0.07 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(4)},...
    'barwidth',1,'facecolor','k')
xticks(0:...
    length(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(4)})/8:...
    length(stackedSweeps(whichRow).spkCountWholeEpoch{whichChannels(4)}))
ylabel('Count (10 ms bins)');xticklabels(-1:0.5:4);xlabel('Perievent time (s)')
text(10,double(max(stackedSweeps(whichRow). ...
    spkCountWholeEpoch{whichChannels(4)}))*0.85,...
    ['Chn ' num2str(whichChannels(4))])

img = subplot('position',[0.78 0.14 0.20 0.14]);
imagesc(~stackedSweeps(whichRow).binaryRastZoomEpoch{whichChannels(4)});
colormap(img,gray);hold on
plot(represPiezoRastZoomEpoch(501:1000)+47,...
    'color',[0.466 0.674 0.188],'linewidth',2)
xticks([]);yticks([])
axesColumn2(8) = subplot('position',[0.78 0.07 0.20 0.07]);
bar(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(4)},...
    'barwidth',1,'facecolor','k')
xticks(0:...
    length(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(4)})/8:...
    length(stackedSweeps(whichRow).spkCountZoomEpoch{whichChannels(4)}))
ylabel('Count (10 ms bins)');xticklabels(-1:0.5:4);xlabel('Perievent time (s)')

linkaxes(axesColumn2,'y')

clear axesColumn1 axesColumn2 b deepChn i img j k middChn represPiezo...
    represPiezoRastWholeEpoch represPiezoRastZoomEpoch whichChannels whichRow