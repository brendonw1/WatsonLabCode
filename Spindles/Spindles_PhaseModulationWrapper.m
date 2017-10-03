function h = Spindles_PhaseModulationWrapper(basepath,basename)

if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end
cd(basepath)

%% Load Spindles, get starts, stops
t = load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData');
normspindles = t.SpindleData.normspindles;
sp_starts = normspindles(:,1);
sp_stops = normspindles(:,3);
spindleband = t.SpindleData.DetectionParams.spindleband;

%% Load Spikes
t = load([basename '_SStable.mat']);
S = t.S;

numcells = length(S);

%% Cell Rates
Rates = Rate(S);

%% Load LFP
t = load([basename '_BasicMetaData.mat']);
SpindleChannel = t.Spindlechannel;
nChannels = t.Par.nChannels;
lfpFreq = t.Par.lfpSampleRate;

eegname = getSessionEegLfpPath(t);
lfp = LoadBinary(eegname,'nChannels',nChannels,'channels',SpindleChannel,'frequency',lfpFreq);

%% Get & Save spindle phase modulation per cell
[phasedistros,phasebins,phasestats,h] = PhaseModulation(S,lfp,spindleband,[sp_starts sp_stops],lfpFreq,'hilbert',1);
meanphase = phasestats.m;
modsignif = phasestats.p;
phasedistros_rawpersec = phasedistros.*repmat(Rates',180,1);

%% Save basic figs from PhaseModulation.m
dirname = fullfile(basepath,'Spindles','SpindlePhaseModulationFigs');
if ~exist(dirname,'dir')
    mkdir(dirname)
end

cd(dirname)
savefigsasname(h,'fig')

cd(basepath)

close(h)
h = [];
    
%% Cell Spike Features
t = load([basename '_CellClassificationOutput.mat']);
peaktroughtimes = t.CellClassificationOutput.CellClassOutput(:,2);
spikewidthtimes = t.CellClassificationOutput.CellClassOutput(:,3);

%% Cell Classess
t = load([basename '_CellIDs.mat']);
ECells = t.CellIDs.EAll;
ICells = t.CellIDs.IAll;

classVect = zeros(numcells,1);
classVect(ECells) = 1;
classVect(ICells) = -1;

%% Readying for plotting (mcorr)
ERates = Rates(ECells);
Ephasedistros = phasedistros(:,ECells);
Ephasedistros_rawpersec = phasedistros_rawpersec(:,ECells);
Emodsignif = modsignif(ECells);
Emeanphase = meanphase(ECells);
Epeaktroughtimes = peaktroughtimes(ECells);
Espikewidthtimes = spikewidthtimes(ECells);

IRates = Rates(ICells);
Iphasedistros = phasedistros(:,ICells);
Iphasedistros_rawpersec = phasedistros_rawpersec(:,ICells);
Imodsignif = modsignif(ICells);
Imeanphase = meanphase(ICells);
Ipeaktroughtimes = peaktroughtimes(ICells);
Ispikewidthtimes = spikewidthtimes(ICells);

%% Basic stats
texttext = {['N Cells = ' num2str(numcells)];...
    ['Total significant (Rayleigh p<0.05) = ' num2str(sum(modsignif>0.05)) ' (' num2str(100*sum(modsignif>0.05)/length(modsignif)) '%)'];...
    ['All-Cells Mean Phase Mean = ' num2str(mean(meanphase))];...
    [''];...
    ['N E Cells = ' num2str(length(ECells))];...
    ['E Cells significant (Rayleigh p<0.05) = ' num2str(sum(Emodsignif>0.05)) ' (' num2str(100*sum(Emodsignif>0.05)/length(Emodsignif)) '%)'];...
    ['E Cells Mean Phase Mean = ' num2str(mean(Emeanphase))];...
    [''];...
    ['N I Cells = ' num2str(length(ICells))];...
    ['I Cells significant (Rayleigh p<0.05) = ' num2str(sum(Imodsignif>0.05)) ' (' num2str(100*sum(Imodsignif>0.05)/length(Imodsignif)) '%)'];...
    ['I Cells Mean Phase Mean = ' num2str(mean(Imeanphase))];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicModulationStats')

% ps, means

%% Big correlation Figures

h(end+1) = figure;
mcorr_bw(Emodsignif,Emeanphase,ERates,Epeaktroughtimes,Espikewidthtimes)
set(h(end),'name','ECellCorrelationsVsCellFeatures')

if ~isempty(ICells)
    h(end+1) = figure;
    mcorr_bw(Imodsignif,Imeanphase,IRates,Ipeaktroughtimes,Ispikewidthtimes)
    set(h(end),'name','ICellCorrelationsVsCellFeatures')
end

h(end+1) = figure;
mcorr_bw(modsignif,meanphase,classVect,Rates,peaktroughtimes,spikewidthtimes)
set(h(end),'name','AllCellCorrelationsVsCellFeatures')

%% E vs I cell mean phases
h(end+1) = figure;
hax = subplot(1,2,1);
hist(Emeanphase,20)
yl = ylim(gca);
axis tight
hold on
xlim([0 2*pi])
if ~isempty(ICells)
    [counts,bins] = hist(Imeanphase,20);
    plot(bins,counts,'m');
    legend('E','I')    
else
    legend('E')
end
plot([0:0.05:2*pi],cos([0:0.05:2*pi])*0.05*max(yl)+0.9*max(yl),'color',[.7 .7 .7])
xlabel('Mean spindle phase per cell')
ylabel('# Cells')

subplot(1,2,2)
if ~isempty(ICells)
    hax = plot_nanmeanSD_bars(Emeanphase,Imeanphase);
else
    hax = plot_nanmeanSD_bars(Emeanphase,0);
end    
set(hax,'XTick',[1 2])
set(hax,'XTickLabel',{'E';'I'})
ylabel('Mean spindle phase per cell')
title('Histogram of per-cell mean phases')

set(h(end),'name','PerCellMeanPhases')


%% Plot total E cell spikes Vs total I cell spikes
h(end+1) = figure;
bar(phasebins,sum(phasedistros_rawpersec(:,ECells)'));
hold on
if ~isempty(ICells)
    plot(phasebins,sum(phasedistros_rawpersec(:,ICells)'),'m');
    legend('E','I')
else
    legend('E')
end
xlim([0 2*pi])
yl = ylim(gca);
plot([0:0.05:2*pi],cos([0:0.05:2*pi])*0.05*max(yl)+0.9*max(yl),'color',[.7 .7 .7])
xlabel('Phase')
ylabel('Total Spikes/Sec')
title('Total (per second) spike counts across all cells of each type')
set(h(end),'name','TotalEVsISpikesByPhase')

%% Save data
SpindleModulationData = v2struct(spindleband,sp_starts,sp_stops,...
    phasedistros,phasebins,phasestats,...
    meanphase,modsignif,phasedistros_rawpersec,Rates,...
    peaktroughtimes,spikewidthtimes,ECells,ICells,...
    Ephasedistros,Ephasedistros_rawpersec,...
    ERates,Emodsignif,Emeanphase,Epeaktroughtimes,Espikewidthtimes,...
    Iphasedistros, Iphasedistros_rawpersec,...
    IRates,Imodsignif,Imeanphase, Ipeaktroughtimes, Ispikewidthtimes);
save(fullfile(basepath,'Spindles',[basename '_SpindleModulationData.mat']),'SpindleModulationData')

%% Save figures
dirname = fullfile(basepath,'Spindles','SpindlePhaseModulationFigs');
if ~exist(dirname,'dir')
    mkdir(dirname)
end

cd(dirname)
savefigsasname(h,'fig')

cd(basepath)
