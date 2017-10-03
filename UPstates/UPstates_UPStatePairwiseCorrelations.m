function h = UPstates_UPStatePairwiseCorrelations(basepath,basename)


%% Meta info
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
cd(basepath)
% bmd = load([basename '_BasicMetaData.mat']);
% numchans = bmd.Par.nChannels;

%% Load UP state data (assuming it was done as part of _BigScript_Sleep
t = load([basename, '_UPDOWNIntervals']);
UPInts = t.UPInts;

%% Extract basic UP info
UPstarts = Start(UPInts);
% UPpeaks = 10000*normspindles(:,2);%... may later redefine this based on moment of max firing
UPstops = End(UPInts);

durs = UPstops - UPstarts;
% amps = SpindleData.data.peakAmplitude;
% freqs = SpindleData.data.peakFrequency;

%% Extract spike features of each spindle
filename = fullfile('UPstates',[basename '_UPSpikeStatsE.mat']);
load(filename);%brings in isse

%% Find times with at least 5min of waking beween SWS Epochs
t = load([basename,'_Intervals.mat']);
intervals = t.intervals;

sleepborders = mergeCloseIntervals(intervals{3},300*10000);
sleepbordertimes = Start(sleepborders);
SleepStartTimes = Start(sleepborders); 
SleepStopTimes = End(sleepborders);

for a = 1:length(SleepStartTimes);
    staidx = find(UPstarts>SleepStartTimes(a),1,'first');
    stoidx = find(UPstops<SleepStopTimes(a),1,'last');

    SleepStartIdxs(a) = staidx;
    SleepStopIdxs(a) = stoidx;
end

%%
disp([basename ': Starting meanspktsfromstart_capped: 1 of 6'])
[pairwiseR_meanVpeak_capped,pairwiseP_meanVpeak_capped] = TimingVectorCorrs(isse.meanspktsfrompeak_capped);
disp([basename ': Starting meanspktsfromstart_capped: 2 of 6'])
[pairwiseR_meanVstart_capped,pairwiseP_meanVstart_capped] = TimingVectorCorrs(isse.meanspktsfromstart_capped);
disp([basename ': Starting meanspktsfromstart: 3 of 6'])
[pairwiseR_meanVstart,pairwiseP_meanVstart] = TimingVectorCorrs(isse.meanspktsfromstart);
disp([basename ': Starting meanspktsfrompeak: 4 of 6'])
[pairwiseR_meanVpeak,pairwiseP_meanVpeak] = TimingVectorCorrs(isse.meanspktsfrompeak);
disp([basename ': Starting firstspktsfromstart: 5 of 6'])
[pairwiseR_firstVstart,pairwiseP_firstVstart] = TimingVectorCorrs(isse.firstspktsfromstart);
disp([basename ': Starting firstspktsfrompeak: 6 of 6'])
[pairwiseR_firstVpeak,pairwiseP_firstVpeak] = TimingVectorCorrs(isse.firstspktsfrompeak);

% PairwiseUPstateRsAndPs = v2struct(pairwiseR_meanVstart_capped, pairwiseP_meanVstart_capped,...
%     pairwiseR_meanVstart, pairwiseP_meanVstart, pairwiseR_meanVpeak, pairwiseP_meanVpeak,...
%     pairwiseR_firstVstart, pairwiseP_firstVstart, pairwiseR_firstVpeak, pairwiseP_firstVpeak);
% 
% PairwiseUPstateRsAndPs = v2struct(pairwiseR_meanVstart_capped,...
%     pairwiseR_meanVstart, pairwiseR_meanVpeak,...
%     pairwiseR_firstVstart, pairwiseR_firstVpeak);

cd(fullfile(basepath,'UPstates'))
if ~exist('PairwiseCorrelations','dir')
    mkdir('PairwiseCorrelations');
end
cd ('PairwiseCorrelations')

save([basename '_PairwiseUPstateRs_meanVpeak_Capped.mat'],'pairwiseR_meanVpeak_capped')
save([basename '_PairwiseUPstateRs_meanVstart_Capped.mat'],'pairwiseR_meanVstart_capped')
save([basename '_PairwiseUPstateRs_meanVstart.mat'],'pairwiseR_meanVstart')
save([basename '_PairwiseUPstateRs_meanVpeak.mat'],'pairwiseR_meanVpeak')
save([basename '_PairwiseUPstateRs_firstVstart.mat'],'pairwiseR_firstVstart')
save([basename '_PairwiseUPstateRs_firstVpeak.mat'],'pairwiseR_firstVpeak')

save([basename '_PairwiseUPstatePs_meanVpeak_Capped.mat'],'pairwiseP_meanVpeak_capped')
save([basename '_PairwiseUPstatePs_meanVstart_Capped.mat'],'pairwiseP_meanVstart_capped')
save([basename '_PairwiseUPstatePs_meanVstart.mat'],'pairwiseP_meanVstart')
save([basename '_PairwiseUPstatePs_meanVpeak.mat'],'pairwiseP_meanVpeak')
save([basename '_PairwiseUPstatePs_firstVstart.mat'],'pairwiseP_firstVstart')
save([basename '_PairwiseUPstatePs_firstVpeak.mat'],'pairwiseP_firstVpeak')

cd(basepath)
%%
h = [];
