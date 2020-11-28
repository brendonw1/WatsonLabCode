function SpikeTransfer_PlotByStrengthOverSleep

nstrengthdivisions1 = 2;
nstrengthdivisions2 = 3;
nstrengthdivisions3 = 6;

ST = GatherSpikeTransfersPerSleepPortion;
% DecilePerCnxnRatioE = ST.RatioChangeNormPerPortionMedianE;
% DecilePerCnxnRatioI = ST.RatioChangeNormPerPortionMedianI;
% DecilePerCnxnRatioEE = ST.RatioChangeNormPerPortionMedianEE;
% DecilePerCnxnRatioEI = ST.RatioChangeNormPerPortionMedianEI;
% DecilePerCnxnRatioIE = ST.RatioChangeNormPerPortionMedianIE;
% DecilePerCnxnRatioII = ST.RatioChangeNormPerPortionMedianII;
DecilePerCnxnRateDiffE = ST.RateDiffChangeNormPerPortionMedianE;
DecilePerCnxnRateDiffI = ST.RateDiffChangeNormPerPortionMedianI;
DecilePerCnxnRateDiffEE = ST.RateDiffChangeNormPerPortionMedianEE;
DecilePerCnxnRateDiffEI = ST.RateDiffChangeNormPerPortionMedianEI;
DecilePerCnxnRateDiffIE = ST.RateDiffChangeNormPerPortionMedianIE;
DecilePerCnxnRateDiffII = ST.RateDiffChangeNormPerPortionMedianII;

fchunk = 1;
lchunk = size(DecilePerCnxnRateDiffE,1);

%% get activity in a particular state for sorting/ranking
SynapseByStateAll = SpikeTransfer_GatherAllSpikeTransferByState;
% ERatioWakeB = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
% IRatioWakeB = SynapseByStateAll.IRatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
% EERatioWakeB = SynapseByStateAll.EERatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
% EIRatioWakeB = SynapseByStateAll.EIRatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
% IERatioWakeB = SynapseByStateAll.IERatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
% IIRatioWakeB = SynapseByStateAll.IIRatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
ERateDiffWakeB = SynapseByStateAll.EDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
IRateDiffWakeB = SynapseByStateAll.IDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
EERateDiffWakeB = SynapseByStateAll.EEDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
EIRateDiffWakeB = SynapseByStateAll.EIDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
IERateDiffWakeB = SynapseByStateAll.IEDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));
IIRateDiffWakeB = SynapseByStateAll.IIDiffs(:,ismember(SynapseByStateAll.StateNames,'WSWake'));

%% Start plotting
h = [];


% distribution-wide changes 
earlychunks = round(.33*size(DecilePerCnxnRateDiffE,1));
latechunks = round(.67*size(DecilePerCnxnRateDiffE,1));
% earlychunks = fchunk;
% latechunks = lchunk;

EarlySleepE = DecilePerCnxnRateDiffE(earlychunks,:);
LateSleepE = DecilePerCnxnRateDiffE(latechunks,:);
h(end+1) = PrePostBars(EarlySleepE,LateSleepE);
EarlySleepI = DecilePerCnxnRateDiffI(earlychunks,:);
LateSleepI = DecilePerCnxnRateDiffI(latechunks,:);
h(end+1) = PrePostBars(EarlySleepI,LateSleepI);

EarlySleepEE = DecilePerCnxnRateDiffEE(earlychunks,:);
LateSleepEE = DecilePerCnxnRateDiffEE(latechunks,:);
h(end+1) = PrePostBars(EarlySleepEE,LateSleepEE);
EarlySleepEI = DecilePerCnxnRateDiffEI(earlychunks,:);
LateSleepEI = DecilePerCnxnRateDiffEI(latechunks,:);
h(end+1) = PrePostBars(EarlySleepEI,LateSleepEI);

EarlySleepIE = DecilePerCnxnRateDiffIE(earlychunks,:);
LateSleepIE = DecilePerCnxnRateDiffIE(latechunks,:);
h(end+1) = PrePostBars(EarlySleepIE,LateSleepIE);
EarlySleepII = DecilePerCnxnRateDiffII(earlychunks,:);
LateSleepII = DecilePerCnxnRateDiffII(latechunks,:);
h(end+1) = PrePostBars(EarlySleepII,LateSleepII);


% % E & I RATIO
% h(end+1) = figure('position',[2 2 1200 700]);
% subplot(2,4,1)
%     PlotEachRawRatioDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk)
%     title('All-E Cnxns - Log','Fontweight','normal')
% subplot(2,4,5)
%     PlotEachRawRatioDistro(1./DecilePerCnxnRatioI,1./IRatioWakeB,fchunk,lchunk)
%     title('All-I Cnxns - Log','Fontweight','normal')
% subplot(2,4,2)
%     PlotEachRatioDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk,nstrengthdivisions1);
%     title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
% subplot(2,4,6)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioI,1./IRatioWakeB,fchunk,lchunk,nstrengthdivisions1);
% subplot(2,4,3)
%     PlotEachRatioDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk,nstrengthdivisions2);
%     title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
% subplot(2,4,7)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioI,1./IRatioWakeB,fchunk,lchunk,nstrengthdivisions2);
% subplot(2,4,4)
%     PlotEachRatioDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk,nstrengthdivisions3);
%     title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
% subplot(2,4,8)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioI,1./IRatioWakeB,fchunk,lchunk,nstrengthdivisions3);
% AboveTitle('AllE&AllISpikeTransmissionRatioOverSleep')
% set(gcf,'name','AllE&AllISpikeTransmissionRatioOverSleep')
%% E & I RateDiff
h(end+1) = figure('position',[2 2 1200 700]);
subplot(2,4,1)
    PlotEachRawDiffDistro(DecilePerCnxnRateDiffE,ERateDiffWakeB,fchunk,lchunk)
    title('All-E Cnxns - Log','Fontweight','normal')
subplot(2,4,5)
    PlotEachRawDiffDistro(-DecilePerCnxnRateDiffI,-IRateDiffWakeB,fchunk,lchunk)
    title('All-I Cnxns - Log','Fontweight','normal')
subplot(2,4,2)
    PlotEachDiffDistro(DecilePerCnxnRateDiffE,ERateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
    title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
subplot(2,4,6)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffI,-IRateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
subplot(2,4,3)
    PlotEachDiffDistro(DecilePerCnxnRateDiffE,ERateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
    title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
subplot(2,4,7)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffI,-IRateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
subplot(2,4,4)
    PlotEachDiffDistro(DecilePerCnxnRateDiffE,ERateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
    title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
subplot(2,4,8)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffI,-IRateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
AboveTitle('AllE & AllI SpikeTransmissionRateDiffOverSleep')
set(gcf,'name','AllE&AllISpikeTransmissionRateDiffOverSleep')


% % EE & EI RATIO
% h(end+1) = figure('position',[2 2 1200 700]);
% subplot(2,4,1)
%     PlotEachRawRatioDistro(DecilePerCnxnRatioEE,EERatioWakeB,fchunk,lchunk)
%     title('EE Cnxns - Log','Fontweight','normal')
% subplot(2,4,5)
%     PlotEachRawRatioDistro(DecilePerCnxnRatioEI,EIRatioWakeB,fchunk,lchunk)
%     title('EI Cnxns - Log','Fontweight','normal')
% subplot(2,4,2)
%     PlotEachRatioDistro(DecilePerCnxnRatioEE,EERatioWakeB,fchunk,lchunk,nstrengthdivisions1);
%     title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
% subplot(2,4,6)
% 	PlotEachRatioDistro(DecilePerCnxnRatioEI,EIRatioWakeB,fchunk,lchunk,nstrengthdivisions1);
% subplot(2,4,3)
%     PlotEachRatioDistro(DecilePerCnxnRatioEE,EERatioWakeB,fchunk,lchunk,nstrengthdivisions2);
%     title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
% subplot(2,4,7)
% 	PlotEachRatioDistro(DecilePerCnxnRatioEI,EIRatioWakeB,fchunk,lchunk,nstrengthdivisions2);
% subplot(2,4,4)
%     PlotEachRatioDistro(DecilePerCnxnRatioEE,EERatioWakeB,fchunk,lchunk,nstrengthdivisions3);
%     title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
% subplot(2,4,8)
% 	PlotEachRatioDistro(DecilePerCnxnRatioEI,EIRatioWakeB,fchunk,lchunk,nstrengthdivisions3);
% AboveTitle('EEEISpikeTransmissionRatioOverSleep')
% set(gcf,'name','EEEISpikeTransmissionRatioOverSleep')
%% EE & EI RateDiff
h(end+1) = figure('position',[2 2 1200 700]);
subplot(2,4,1)
    PlotEachRawDiffDistro(DecilePerCnxnRateDiffEE,EERateDiffWakeB,fchunk,lchunk)
    title('EE Cnxns - Log','Fontweight','normal')
subplot(2,4,5)
    PlotEachRawDiffDistro(DecilePerCnxnRateDiffEI,EIRateDiffWakeB,fchunk,lchunk)
    title('EI Cnxns - Log','Fontweight','normal')
subplot(2,4,2)
    PlotEachDiffDistro(DecilePerCnxnRateDiffEE,EERateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
    title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
subplot(2,4,6)
	PlotEachDiffDistro(DecilePerCnxnRateDiffEI,EIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
subplot(2,4,3)
    PlotEachDiffDistro(DecilePerCnxnRateDiffEE,EERateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
    title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
subplot(2,4,7)
	PlotEachDiffDistro(DecilePerCnxnRateDiffEI,EIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
subplot(2,4,4)
    PlotEachDiffDistro(DecilePerCnxnRateDiffEE,EERateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
    title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
subplot(2,4,8)
	PlotEachDiffDistro(DecilePerCnxnRateDiffEI,EIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
AboveTitle('EE & EISpikeTransmissionRateDiffOverSleep')
set(gcf,'name','EEEISpikeTransmissionRateDiffOverSleep')    

% % IE & II RATIO
% h(end+1) = figure('position',[2 2 1200 700]);
% subplot(2,4,1)
%     PlotEachRawRatioDistro(1./DecilePerCnxnRatioIE,1./IERatioWakeB,fchunk,lchunk)
%     title('IE Cnxns - Log','Fontweight','normal')
% subplot(2,4,5)
%     PlotEachRawRatioDistro(1./DecilePerCnxnRatioII,1./IIRatioWakeB,fchunk,lchunk)
%     title('II Cnxns - Log','Fontweight','normal')
% subplot(2,4,2)
%     PlotEachRatioDistro(1./DecilePerCnxnRatioIE,1./IERatioWakeB,fchunk,lchunk,nstrengthdivisions1);
%     title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
% subplot(2,4,6)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioII,1./IIRatioWakeB,fchunk,lchunk,nstrengthdivisions1);
% subplot(2,4,3)
%     PlotEachRatioDistro(1./DecilePerCnxnRatioIE,1./IERatioWakeB,fchunk,lchunk,nstrengthdivisions2);
%     title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
% subplot(2,4,7)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioII,1./IIRatioWakeB,fchunk,lchunk,nstrengthdivisions2);
% subplot(2,4,4)
%     PlotEachRatioDistro(1./DecilePerCnxnRatioIE,1./IERatioWakeB,fchunk,lchunk,nstrengthdivisions3);
%     title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
% subplot(2,4,8)
% 	PlotEachRatioDistro(1./DecilePerCnxnRatioII,1./IIRatioWakeB,fchunk,lchunk,nstrengthdivisions3);
% AboveTitle('IEIISpikeTransmissionRatioOverSleep')
% set(gcf,'name','IEIISpikeTransmissionRatioOverSleep')
%% E & I RateDiff
h(end+1) = figure('position',[2 2 1200 700]);
subplot(2,4,1)
    PlotEachRawDiffDistro(-DecilePerCnxnRateDiffIE,-IERateDiffWakeB,fchunk,lchunk)
    title('IE Cnxns - Log','Fontweight','normal')
subplot(2,4,5)
    PlotEachRawDiffDistro(-DecilePerCnxnRateDiffII,-IIRateDiffWakeB,fchunk,lchunk)
    title('II Cnxns - Log','Fontweight','normal')
subplot(2,4,2)
    PlotEachDiffDistro(-DecilePerCnxnRateDiffIE,-IERateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
    title([num2str(nstrengthdivisions1) ' Groups'],'Fontweight','normal')
subplot(2,4,6)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffII,-IIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions1);
subplot(2,4,3)
    PlotEachDiffDistro(-DecilePerCnxnRateDiffIE,-IERateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
    title([num2str(nstrengthdivisions2) ' Groups'],'Fontweight','normal')
subplot(2,4,7)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffII,-IIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions2);
subplot(2,4,4)
    PlotEachDiffDistro(-DecilePerCnxnRateDiffIE,-IERateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
    title([num2str(nstrengthdivisions3) ' Groups'],'Fontweight','normal')
subplot(2,4,8)
	PlotEachDiffDistro(-DecilePerCnxnRateDiffII,-IIRateDiffWakeB,fchunk,lchunk,nstrengthdivisions3);
AboveTitle('IE & IISpikeTransmissionRateDiffOverSleep')
set(gcf,'name','IEIISpikeTransmissionRateDiffOverSleep')    

MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/OverSleepPortions',h)
MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/OverSleepPortions',h,'png')
1;


function PlotEachDiffDistro(Data,RankingParam,fchunk,lchunk,nstrengthdivisions)
d = Data(:);
Data(Data == Inf) = max(d(d<Inf));
Data(Data == -Inf) = min(d(d>-Inf));
Geodata = Data;
Geodata(Geodata<=0) = min(d(d>0));
% Data = abs(log10(Data));
StrengthGroups = GetQuartilesByRank(RankingParam,nstrengthdivisions);%ie quartiles or hexiles
for a = 1:nstrengthdivisions
    RatioStrengthsByGroupE(:,a) = abs(nangeomean(Geodata(:,StrengthGroups==a),2));
end
cols = RainbowColors(nstrengthdivisions);
for a = 1:nstrengthdivisions
    semilogy(RatioStrengthsByGroupE(:,a),'color',cols(a,:),'LineWidth',2,'marker','.','markersize',10);
    hold on;
end
axis tight
xlabel('Division')
ylabel('Hz Difference')

function PlotEachRatioDistro(Data,RankingParam,fchunk,lchunk,nstrengthdivisions)
d = Data(:);
Data(Data == Inf) = max(d(d<Inf));
Data(Data <= 0) = nan;
% Data = abs(log10(Data));
StrengthGroups = GetQuartilesByRank(RankingParam,nstrengthdivisions);%ie quartiles or hexiles
for a = 1:nstrengthdivisions
    RatioStrengthsByGroupE(:,a) = nangeomean(Data(:,StrengthGroups==a),2);
end
cols = RainbowColors(nstrengthdivisions);
for a = 1:nstrengthdivisions
    semilogy(RatioStrengthsByGroupE(:,a),'color',cols(a,:),'LineWidth',2,'marker','.','markersize',10);
    hold on;
end
axis tight
xlabel('Division')
ylabel('Ratio')

function PlotEachRawDiffDistro(Data,RankingParam,fchunk,lchunk)
d = Data(:);
Data(Data == Inf) = max(d(d<Inf));
Data(Data == -Inf) = min(d(d>-Inf));
Data = abs(log10(Data));
[~,i] = sort(RankingParam);
Data = Data(:,flipud(i));
imagesc(Data');colormap jet

function PlotEachRawRatioDistro(Data,RankingParam,fchunk,lchunk)
d = Data(:);
Data(Data == Inf) = max(d(d<Inf));
Data(Data <= 0) = nan;
Data = abs(log10(Data));
[~,i] = sort(RankingParam);
Data = Data(:,flipud(i));
% imagesc(nanzscore(Data'));colormap jet
imagesc(Data');colormap jet
