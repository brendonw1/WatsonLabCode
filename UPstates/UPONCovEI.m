function UPONCovEI (basepath,basename)

if  ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);basepath = cd;
end

%% UP states
load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']))
load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsI.mat']))

% Coefficient of variation of E and I populations
PerUPCoVE = nanstd(isse.spkrates,[],2)./nanmean(isse.spkrates,2);
PerUPCoVI = nanstd(issi.spkrates,[],2)./nanmean(issi.spkrates,2);

% EI Ratios: E/sec/event over I/sec/event
updurs = isse.intends-isse.intstarts;
UPer = sum(isse.spkcounts,2);%total e spikes per event
UPer = UPer ./ updurs;

UPir = sum(issi.spkcounts,2);
UPir = UPir ./ updurs;

PerUPEI = UPer./(UPer+UPir);
PerUPEIZ = nanzscore(PerUPEI);

%% ON states
load(fullfile(basepath,'UPstates',[basename '_ONSpikeStatsE.mat']))
load(fullfile(basepath,'UPstates',[basename '_ONSpikeStatsI.mat']))

% Coefficient of variation of E and I populations
PerONCoVE = nanstd(isse.spkrates,[],2)./nanmean(isse.spkrates,2);
PerONCoVI = nanstd(issi.spkrates,[],2)./nanmean(issi.spkrates,2);

% EI Ratios: E/sec/event over I/sec/event
ondurs = isse.intends-isse.intstarts;
ONer = sum(isse.spkcounts,2);%total e spikes per event
ONer = ONer ./ ondurs;

ONir = sum(issi.spkcounts,2);
ONir = ONir ./ ondurs;

PerONEI = ONer./(ONer+ONir);
PerONEIZ = nanzscore(PerONEI);

%% save
UPONCovEI = v2struct(PerUPCoVE,PerUPCoVI,PerUPEI,PerUPEIZ,UPer,UPir,...
    PerONCoVE,PerONCoVI,PerONEI,PerONEIZ,ONer,ONir);
save(fullfile(basepath,'UPstates',[basename '_UPONCovEI']),'UPONCovEI')