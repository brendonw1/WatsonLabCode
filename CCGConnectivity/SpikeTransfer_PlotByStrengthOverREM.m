function SpikeTransfer_PlotByStrengthOverREM

nstrengthdivisions1 = 2;
nstrengthdivisions2 = 3;
nstrengthdivisions3 = 6;

ST = GatherSpikeTransfersPerREMPortion;
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

%% handle cases where there was no REM, get rid of pair measures in Wake based on those which have no REM
ERateDiffWakeB = RmvNonValidSessions(ERateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numep);
IRateDiffWakeB = RmvNonValidSessions(IRateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numip);
EERateDiffWakeB = RmvNonValidSessions(EERateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numeep);
EIRateDiffWakeB = RmvNonValidSessions(EIRateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numeip);
IERateDiffWakeB = RmvNonValidSessions(IERateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numiep);
IIRateDiffWakeB = RmvNonValidSessions(IIRateDiffWakeB,ST.GoodSessions,SynapseByStateAll.numiip);

%% Start plotting
h = [];

% distribution-wide changes 
EarlyREME = DecilePerCnxnRateDiffE(fchunk,:);
LateREME = DecilePerCnxnRateDiffE(lchunk,:);
h(end+1) = PrePostBars(EarlyREME,LateREME);
EarlyREMI = DecilePerCnxnRateDiffI(fchunk,:);
LateREMI = DecilePerCnxnRateDiffI(lchunk,:);
h(end+1) = PrePostBars(EarlyREMI,LateREMI);

EarlyREMEE = DecilePerCnxnRateDiffEE(fchunk,:);
LateREMEE = DecilePerCnxnRateDiffEE(lchunk,:);
h(end+1) = PrePostBars(EarlyREMEE,LateREMEE);
EarlyREMEI = DecilePerCnxnRateDiffEI(fchunk,:);
LateREMEI = DecilePerCnxnRateDiffEI(lchunk,:);
h(end+1) = PrePostBars(EarlyREMEI,LateREMEI);

EarlyREMIE = DecilePerCnxnRateDiffIE(fchunk,:);
LateREMIE = DecilePerCnxnRateDiffIE(lchunk,:);
h(end+1) = PrePostBars(EarlyREMIE,LateREMIE);
EarlyREMII = DecilePerCnxnRateDiffII(fchunk,:);
LateREMII = DecilePerCnxnRateDiffII(lchunk,:);
h(end+1) = PrePostBars(EarlyREMII,LateREMII);


% E & I RATIO
% h(end+1) = figure('position',[2 2 1200 700]);
% subplot(2,4,1)
%     PlotEachRawRatioDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk)
%     title('AllE Cnxns - Log','Fontweight','normal')
% subplot(2,4,5)
%     PlotEachRawRatioDistro(1./DecilePerCnxnRatioI,1./IRatioWakeB,fchunk,lchunk)
%     title('AllI Cnxns - Log','Fontweight','normal')
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
% AboveTitle('AllE&AllISpikeTransmissionRatioOverREM')
% set(gcf,'name','AllE&AllISpikeTransmissionRatioOverREM')
%% E & I RateDiff
h(end+1) = figure('position',[2 2 1200 700]);
subplot(2,4,1)
    PlotEachRawDiffDistro(DecilePerCnxnRateDiffE,ERateDiffWakeB,fchunk,lchunk)
    title('AllE Cnxns - Log','Fontweight','normal')
subplot(2,4,5)
    PlotEachRawDiffDistro(-DecilePerCnxnRateDiffI,-IRateDiffWakeB,fchunk,lchunk)
    title('AllI Cnxns - Log','Fontweight','normal')
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
AboveTitle('AllE & AllI SpikeTransmissionRateDiffOverREM')
set(gcf,'name','AllE&AllISpikeTransmissionRateDiffOverREM')


% EE & EI RATIO
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
% AboveTitle('EEEISpikeTransmissionRatioOverREM')
% set(gcf,'name','EEEISpikeTransmissionRatioOverREM')
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
AboveTitle('EE & EISpikeTransmissionRateDiffOverREM')
set(gcf,'name','EEEISpikeTransmissionRateDiffOverREM')    

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
% AboveTitle('IEIISpikeTransmissionRatioOverREM')
% set(gcf,'name','IEIISpikeTransmissionRatioOverREM')
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
AboveTitle('IE & IISpikeTransmissionRateDiffOverREM')
set(gcf,'name','IEIISpikeTransmissionRateDiffOverREM')    

MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/OverREMPortions',h)
MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/OverREMPortions',h,'png')
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

function Rates = RmvNonValidSessions(Rates,GoodSessions,NumPairsPerSession)
badsess = find(GoodSessions==0);
endidxs=cumsum(NumPairsPerSession);
startidxs = cat(2,0,endidxs(1:end-1))+1;
rmv = startidxs(badsess):endidxs(badsess);
Rates(rmv) = [];

