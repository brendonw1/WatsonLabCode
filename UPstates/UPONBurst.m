function UPONBurst(basepath,basename)

if  ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);basepath = cd;
end

burstcutoff = 0.015;%15ms

%% UP states
load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']))
load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsI.mat']))

% Coefficient of variation of E and I populations
Se = isse.S;
Si = issi.S;
ints = isse.ints;
bincentertimes = mean(StartEnd(ints,'s'),2);
for a = 1:length(length(ints))
    thisSe = Restrict(Se,subset(ints,a));
    UBIE(a,:) = BurstIndex_TsdArray(thisSe,burstcutoff);
    thisSi = Restrict(Si,subset(ints,a));
    UBII(a,:) = BurstIndex_TsdArray(thisSi,burstcutoff);
%     if rem(a,100)==0
%         disp(a)
%     end
end
UMBIE = nanmean(UBIE,2);%mean of BI for E cells for each timebin
UMBII = nanmean(UBII,2);%mean of BI for E cells for each timebin


%% ON states
load(fullfile(basepath,'UPstates',[basename '_ONSpikeStatsE.mat']))
load(fullfile(basepath,'UPstates',[basename '_ONSpikeStatsI.mat']))

% Coefficient of variation of E and I populations
Se = isse.S;
Si = issi.S;
ints = isse.ints;
bincentertimes = mean(StartEnd(ints,'s'),2);
for a = 1:length(length(ints))
    thisSe = Restrict(Se,subset(ints,a));
    OBIE(a,:) = BurstIndex_TsdArray(thisSe,burstcutoff);
    thisSi = Restrict(Si,subset(ints,a));
    OBII(a,:) = BurstIndex_TsdArray(thisSi,burstcutoff);
%     if rem(a,100)==0
%         disp(a)
%     end
end
OMBIE = nanmean(OBIE,2);%mean of BI for E cells for each timebin
OMBII = nanmean(OBII,2);%mean of BI for E cells for each timebin


%% save
UPONBurst = v2struct(UBIE,UBII,UMBIE,UMBII,OBIE,OBII,OMBIE,OMBII,bincentertimes);
save(fullfile(basepath,'UPstates',[basename '_UPONBurst']),'UPONBurst')