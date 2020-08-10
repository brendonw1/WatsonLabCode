function BWRippleModulation(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'ripplechannel',[],@isvector);
addParameter(p,'noisechannel',[],@isvector);
addParameter(p,'wakeonly',false,@islogical);
addParameter(p,'rippleregionname','HPC',@isstr);
addParameter(p,'modulatedregionname','S1',@isstr);

% addParameter(p,'eventCategory','timestamps',@isstr);
% addParameter(p,'eventNumber',1,@isvector);
% addParameter(p,'secondsBefore',0.5,@isvector);
% addParameter(p,'secondsAfter',1,@isvector);
% addParameter(p,'binWidth',0.1,@isvector);
% addParameter(p,'plotting',0.1,@isvector);

parse(p,varargin{:})

basepath = p.Results.basepath;
ripplechannel = p.Results.ripplechannel;
noisechannel = p.Results.noisechannel;
wakeonly = p.Results.wakeonly;
rippleregionname = p.Results.rippleregionname;
modulatedregionname = p.Results.modulatedregionname;

% 
% eventCategory = p.Results.eventCategory;
% eventNumber = p.Results.eventNumber;
% secondsBefore = p.Results.secondsBefore;
% secondsAfter = p.Results.secondsAfter;
% binWidth = p.Results.binWidth;
% plotting = p.Results.plotting;
% saveMat = p.Results.saveMat;

basename = bz_BasenameFromBasepath(basepath);


if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

RipplesFilePath = fullfile(basepath,[basename '.ripples.events.mat']);
if ~exist(RipplesFilePath,'file')
    if wakeonly %if recording without sleep (pretty much)
        ripples = bz_FindRipples(cd,ripplechannel,'saveMat',true,'noise',noisechannel,'thresholds',[2.5 4],'show','on');
    else % if recording with wake and sleep
        ripples = bz_FindRipples(cd,ripplechannel,'saveMat',true,'noise',noisechannel,'thresholds',[1.5 3],'show','on');   
    end
    EventExplorer(cd,'ripples')
else
    load(RipplesFilePath)
end

PETHSpikesFilePath = fullfile(basepath,[basename '.PETHSpikesTrigByripples_1s.mat']);
if ~exist(PETHSpikesFilePath,'file')
    PETHSpikes = bz_PETH_Spikes('ripples','basepath',basepath,'eventCategory','peaks','secondsBefore',2,'secondsAfter',2,'binWidth',0.01,'saveMat',true);
else
    load(PETHSpikesFilePath);
end

spikes = bz_GetSpikes('basepath',basepath);
% load(PETHSpikesFilePath);
sessionInfo = bz_getSessionInfo(basepath);


%now find units in each region group based on max channel - and sort by
%depth
sortedUnitsByGroup = SortUnitsByDepthPerRegion(spikes,sessionInfo);
% S1channels = sessionInfo.spikeGroups.groups{1};
% hpcchannels = sessionInfo.spikeGroups.groups{2};
% Alternative method:
% hpcchannels = find(strcmp(sessionInfo.region,'HPC'));%or spike group2
% s1channels = strcmp(sessionInfo.region,'S1');%or spike group1

%% ripple modulation per region
S1_PETHsSorted = PETHSpikes.counts(:,:,(sortedUnitsByGroup{1}));
HPC_PETHsSorted = PETHSpikes.counts(:,:,(sortedUnitsByGroup{2}));


%% plot S1 and HPC responsiveness
figure('position', [680 8 560 1052],'name','S1CellsRippleModulation');
subplot(2,1,1)
imagesc(zscore(squeeze(sum(S1_PETHsSorted,1)))')
title('S1: Ripple Modulation Per Cell')
ylabel('Cell number: Superficial on top, Deep on bottom')
ticksandline(gca,PETHSpikes.parameters)
%
subplot(2,1,2)
plot(sum(sum(S1_PETHsSorted(:,:,:),3),1))
title('S1: Ripple Modulation over Population')
xlabel('Seconds from RipplePeaks')
ylabel('Average of per-cell averages')
ticksandline(gca,PETHSpikes.parameters)


figure('position', [680 8 560 1052],'name','HPCCellsRippleModulation');
subplot(2,1,1)
imagesc(zscore(squeeze(sum(HPC_PETHsSorted,1)))')
title('HPC: Ripple Modulation Per Cell')
ylabel('Cell number: Superficial on top, Deep on bottom')
ticksandline(gca,PETHSpikes.parameters)
%
subplot(2,1,2)
plot(sum(sum(HPC_PETHsSorted(:,:,:),3),1))
title('HPC: Ripple Modulation over Population')
xlabel('Seconds from RipplePeaks')
ylabel('Average of per-cell averages')
ticksandline(gca,PETHSpikes.parameters)


%% Modulation per cell
% edgebins = [1:10,31:40];%arbitrary
% centerbins = [17:23];%arbitrary
edgebins = [1:75,126:200];%arbitrary
centerbins = [76:125];%arbitrary

S1_PETHsSorted_PerCell = squeeze(sum(S1_PETHsSorted,1));
edgespercell = mean(S1_PETHsSorted_PerCell(edgebins,:));
centerspercell = mean(S1_PETHsSorted_PerCell(centerbins,:));
modulationpercell = centerspercell./edgespercell;
[modssorted,modidx] = sort(modulationpercell);
modulationRanked_PETHPerCell_S1 = S1_PETHsSorted_PerCell(:,modidx);
figure('name','RippleSpikePETHS_RankedByCellModulation_S1');
subplot(2,2,1)
imagesc(zscore(modulationRanked_PETHPerCell_S1)')
subplot(2,2,2)
plot(modulationRanked_PETHPerCell_S1(:,end))
subplot(2,2,3)
plot(modulationRanked_PETHPerCell_S1(:,end-1))
subplot(2,2,4)
plot(modulationRanked_PETHPerCell_S1(:,end-2))


HPC_PETHsSorted_PerCell = squeeze(sum(HPC_PETHsSorted,1));
edgespercell = mean(HPC_PETHsSorted_PerCell(edgebins,:));
centerspercell = mean(HPC_PETHsSorted_PerCell(centerbins,:));
modulationpercell = centerspercell./edgespercell;
[modssorted,modidx] = sort(modulationpercell);
modulationRanked_PETHPerCell_HPC = HPC_PETHsSorted_PerCell(:,modidx);
figure('name','RippleSpikePETHS_RankedByCellModulation_HPC');
subplot(2,2,1)
imagesc(zscore(modulationRanked_PETHPerCell_HPC)')
subplot(2,2,2)
plot(modulationRanked_PETHPerCell_HPC(:,end))
subplot(2,2,3)
try
    plot(modulationRanked_PETHPerCell_HPC(:,end-1))
end
subplot(2,2,4)
try
    plot(modulationRanked_PETHPerCell_HPC(:,end-2))
end

%display spike rate
% load('LB_13_400102.MergePoints.events.mat')
% TotalSeconds = sum(MergePoints.filesizes.amplifier)/20000/67/2;
% SpikeRatesPerCell = cellfun(@length,spikes.times)/TotalSeconds;
% figure('name','SpikeRatesHistogram');
% hist(SpikeRatesPerCell);
% title('Spike Rates of Cells')

function ticksandline(ax,parameters)
v2struct(parameters)%extract some variables for plotting

%set ticks
tickplaces = get(gca,'XTick');
secondticks = tickplaces*binWidth-secondsBefore;
ticktext = cellstr(num2str(secondticks'));
set(gca,'XTickLabel',ticktext)
%put line on middle
hold on
yl = ylim;
zx = find(secondticks==0);%where zero is
zx = tickplaces(zx);
if ~isempty(zx)
    plot([zx zx],yl,'k')
end