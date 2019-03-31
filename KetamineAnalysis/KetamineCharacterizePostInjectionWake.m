function KetamineCharacterizePostInjectionWake(basepath,basename)
% Grab and quantify post injection wakes.  Everything at 1sec resolution
%     - duration
%     - powers in frequency bands
%     - E Rate
%     - I rate
%     - EI ratio
%     - CoV
%     - HR/LR
%  NOTE vectors are not necessarily same precise timebase (ie E and I cell
%  firing are based on firing start and stop times)
%
% Brendon Watson 10/2016
    
if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end

%% Basic interval
try
    [PostInjTiming,NonInjTiming] = KetamineGetPostInjectionWake(basepath,basename);%is in iS format because of badInterval handling in gathering
catch
    return
end
v2struct(PostInjTiming);%unpacks:postinjwake_IS,postinjwake_se,postinjwake_vect
v2struct(NonInjTiming);%unpacks:noninjwake_IS,noninjwake_se,noninjwake_vect

Duration = LastTime(postinjwake_IS) - FirstTime(postinjwake_IS);

%% Locomotion
load(fullfile(basepath,[basename '.eegstates.mat']))
motion = zscore(StateInfo.motion);
motionvect = motion(postinjwake_vect);
motionnoninjvect = motion(noninjwake_vect);

MotionStats = BasicStatsOnVectsIn(motionvect,motionnoninjvect);

%% Oscillatory bands
%... for now just use channels in state editor

BandsData.delta.bandfreqlims = [0 4];
BandsData.theta.bandfreqlims = [5 10];
BandsData.sigma.bandfreqlims = [11 15];
BandsData.beta.bandfreqlims = [18 25];
BandsData.lowgamma.bandfreqlims = [30 40];
BandsData.midgamma.bandfreqlims = [40 58];
BandsData.highgamma.bandfreqlims = [62 130];
BandsData.ripple.bandfreqlims = [135 175];
fn = fieldnames(BandsData);%for each band

for c = 1:length(StateInfo.Chs)%for each channel
    ChannelNum = StateInfo.Chs(c);

    flist = StateInfo.fspec{c}.fo;
    pispec = StateInfo.fspec{c}.spec(postinjwake_vect,:);
    niwspec = StateInfo.fspec{c}.spec(noninjwake_vect,:);%noninjection wake
    
    for a = 1:length(fn)
        tn = fn{a};
        bandfreqlims = getfield(BandsData,tn);
        bandfreqlims = bandfreqlims.bandfreqlims;
        
        sf = bandfreqlims(1);%get indices for frequency band
        ef = bandfreqlims(2);
        sfi = find(flist>=sf,1,'first');
        efi = find(flist<ef,1,'last');

        specblock = pispec(:,sfi:efi);
        rawbandpower = nansum(specblock,2);
        noArtifactbandpower = rawbandpower;
        %exclude seconds of instantaneous high power surrounded by lower
        %power
        zp = zscore(rawbandpower);
        [bads] = continuousabove2(zp,6,1,10);
        for b = 1:size(bads,1)
            noArtifactbandpower(bads(b,1):bads(b,2)) = nan;
        end
        
        niwspecblock = niwspec(:,sfi:efi);
        niwrawbandpower = nansum(niwspecblock,2);
        niwNoArtifactbandpower = niwrawbandpower;
        %exclude seconds of instantaneous high power surrounded by lower
        %power
        niwzp = zscore(niwrawbandpower);
        [bads] = continuousabove2(niwzp,6,1,10);
        for b = 1:size(bads,1)
            niwNoArtifactbandpower(bads(b,1):bads(b,2)) = nan;
        end
        
        ChannelStats = BasicStatsOnVectsIn(noArtifactbandpower,niwNoArtifactbandpower);
        eval(['BandsData.' tn '(c).ChannelStats=ChannelStats;'])

%         bandmean = nanmean(noArtifactbandpower);
%         bandmedian = nanmedian(noArtifactbandpower);
%         bandSD = nanstd(noArtifactbandpower);
%         bandsum = nansum(noArtifactbandpower);
%         bandmax = nanmax(noArtifactbandpower);
%         bandmin = nanmin(noArtifactbandpower);
%         bandz2 = nanmedian(noArtifactbandpower) + 2*nanstd(noArtifactbandpower);
%         
%         noninjbandmean = nanmean(niwNoArtifactbandpower);
%         noninjbandmedian = nanmedian(niwNoArtifactbandpower);
%         injnoninjmeanbandratio = bandmean/noninjbandmean;
%         injnoninjmedianbandratio = bandmedian/noninjbandmedian;
% 
%         eval(['BandsData.' tn '(c).ChannelNumB1 = ChannelNum;']);
%         eval(['BandsData.' tn '(c).ChannelNumB0 = ChannelNum-1;']);
%         eval(['BandsData.' tn '(c).noArtifactbandpower = noArtifactbandpower;']);
%         eval(['BandsData.' tn '(c).rawbandpower = rawbandpower;']);
%         eval(['BandsData.' tn '(c).bandmean = bandmean;']);
%         eval(['BandsData.' tn '(c).bandmedian = bandmedian;']);
%         eval(['BandsData.' tn '(c).bandSD = bandSD;']);
%         eval(['BandsData.' tn '(c).bandsum = bandsum;']);
%         eval(['BandsData.' tn '(c).bandmax = bandmax;']);
%         eval(['BandsData.' tn '(c).bandmin = bandmin;']);
%         eval(['BandsData.' tn '(c).bandz2 = bandz2;']);
%         eval(['BandsData.' tn '(c).noninjbandmean = noninjbandmean;']);
%         eval(['BandsData.' tn '(c).noninjbandmedian = noninjbandmedian;']);
    end
end    

%% E rates
ERateStats = [];
IRateStats = [];
if exist((fullfile(basepath,[basename '_SSubtypes.mat'])),'file')
    load(fullfile(basepath,[basename '_SSubtypes.mat']),'Se')
    numEcells = length(Se);
    Se = oneSeries(Se);
    SePI = Restrict(Se,postinjwake_IS);
    SeNI = Restrict(Se,noninjwake_IS);
    SePIvect = Data(MakeQfromTsd(SePI,1))/numEcells;
    SeNIvect = Data(MakeQfromTsd(SeNI,1))/numEcells;

    ERateStats = BasicStatsOnVectsIn(SePIvect,SeNIvect);

%% I rates
    load(fullfile(basepath,[basename '_SSubtypes.mat']),'Si')
    numIcells = length(Si);
    Si = oneSeries(Si);
    SiPI = Restrict(Si,postinjwake_IS);
    SiNI = Restrict(Si,noninjwake_IS);
    SiPIvect = Data(MakeQfromTsd(SiPI,1))/numIcells;
    SiNIvect = Data(MakeQfromTsd(SiNI,1))/numIcells;

    IRateStats = BasicStatsOnVectsIn(SiPIvect,SiNIvect);
end

%% EIRatio
EIRatioStats = [];
if exist((fullfile(basepath,[basename '_EIRatio.mat'])),'file')
    load(fullfile(basepath,[basename '_EIRatio.mat']))
    EIR = tsd(EIRatioData.bincentertimes,EIRatioData.ZPCEI);
    EIRPIvect = Data(Restrict(EIR,postinjwake_IS));
    EIRNIvect = Data(Restrict(EIR,noninjwake_IS));

    EIRatioStats = BasicStatsOnVectsIn(EIRPIvect,EIRNIvect);
end

%% E Cell Bursts
EBurstStats = [];
if exist((fullfile(basepath,[basename '_BurstPerBinData.mat'])),'file')
    load(fullfile(basepath,[basename '_BurstPerBinData.mat']))
    EBurst = tsd(BurstPerBinData.bincentertimes,BurstPerBinData.MBIE);
    EBurstPIvect = Data(Restrict(EBurst,postinjwake_IS));
    EBurstNIvect = Data(Restrict(EBurst,noninjwake_IS));

    EBurstStats = BasicStatsOnVectsIn(EBurstPIvect,EBurstNIvect);
end

%% CoV
ECoVStats = [];
if exist((fullfile(basepath,[basename '_SpikingCoeffVaration.mat'])),'file')
    load(fullfile(basepath,[basename '_SpikingCoeffVaration.mat']))
    ECoV = tsd(SpikingCoeffVarationData.bincentertimes,SpikingCoeffVarationData.CoVE);
    ECoVPIvect = Data(Restrict(ECoV,postinjwake_IS));
    ECoVNIvect = Data(Restrict(ECoV,noninjwake_IS));

    ECoVStats = BasicStatsOnVectsIn(ECoVPIvect,ECoVNIvect);
end

%% High FR Population Rates
HRRStats = [];
LRRStats = [];
HRLRRStats = [];

if exist((fullfile(basepath,[basename '_HighLowFRRatio.mat'])),'file')
    load(fullfile(basepath,[basename '_HighLowFRRatio.mat']))
    HRR = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.hr);
    HRRPIvect = Data(Restrict(HRR,postinjwake_IS));
    HRRNIvect = Data(Restrict(HRR,noninjwake_IS));

    HRRStats = BasicStatsOnVectsIn(HRRPIvect,HRRNIvect);

    %% Low FR Population Rates
    LRR = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.lr);
    LRRPIvect = Data(Restrict(LRR,postinjwake_IS));
    LRRNIvect = Data(Restrict(LRR,noninjwake_IS));

    LRRStats = BasicStatsOnVectsIn(LRRPIvect,LRRNIvect);

    %% High/Low FR Population Rates
    HRLRR = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.hrlr);
    HRLRRPIvect = Data(Restrict(HRLRR,postinjwake_IS));
    HRLRRNIvect = Data(Restrict(HRLRR,noninjwake_IS));

    HRLRRStats = BasicStatsOnVectsIn(LRRPIvect,LRRNIvect);
end
%%
KetaminePostInjectionWakeData = v2struct(PostInjTiming,NonInjTiming,Duration,...
    MotionStats,BandsData,ERateStats,IRateStats,EIRatioStats,EBurstStats,...
    ECoVStats,HRRStats,LRRStats,HRLRRStats);

save(fullfile(basepath,[basename '_KetaminePostInjectionWake.mat']),'KetaminePostInjectionWakeData')

1;



function stats = BasicStatsOnVectsIn(InjVect,NoninjVect)

TotalInj = nansum(InjVect);
MeanInj = nanmean(InjVect);
MedianInj = nanmedian(InjVect);
SDInj = nanstd(InjVect);
MaxInj = nanmax(InjVect);
MinInj = nanmin(InjVect);
Z2Inj = nanmean(InjVect)+2*nanstd(InjVect);%sort of odd due to zscoring, tho zscoring was done on more than this vector

MeanNoninj = nanmean(NoninjVect);
MedianNoninj = nanmedian(NoninjVect);

InjNoninjMeanRatio = MeanInj/MeanNoninj;
InjNoninjMedianRatio = MedianInj/MedianNoninj;

stats = v2struct(TotalInj,MeanInj,MedianInj,SDInj,MaxInj,MinInj,Z2Inj,...
    MeanNoninj,MedianNoninj,InjNoninjMeanRatio,InjNoninjMedianRatio);
