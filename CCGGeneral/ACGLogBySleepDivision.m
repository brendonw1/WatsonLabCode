function ACGLogBySleepDiv = ACGLogBySleepDivision(basepath,basename,NumSleepDivisions)
% Gets and saves CCGs, ACGs, ISIHistos for all cells across states
% specified in basename_StateIntervals.mat (which is from
% GatherStateIntervalSets.m)
% Brendon Watson 2015
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
if ~exist('NumSleepDivisions','var')
    NumSleepDivisions= 4;
end

load(fullfile(basepath,[basename '_SStable.mat']));
load(fullfile(basepath,[basename '_SleepDivisions' num2str(NumSleepDivisions) '.mat']));

%% Parameters
%Static
HalfWidthsinMs = [10 30 100 300 1000 3000];
numHalfBins = [50 60 50 60 50 60];%static
SampleRate = 10000;%%Based on usual TSD object sample rate<< NEED TO GENERALIZE THIS, HAVEN'T FIGURED OUT HOW YET

%Calculated
msBinSizes = (HalfWidthsinMs./numHalfBins);
numSampsBinSizes = msBinSizes*SampleRate/1000;
HalfWidthInS = HalfWidthsinMs/1000;
BinSizeInS = HalfWidthsinMs./numHalfBins/1000;

for a = 1:length(HalfWidthsinMs)
    thismax = HalfWidthsinMs(a)/1000;
    Times{a} = logspace(log10(thismax/10),log10(thismax),numHalfBins(a));
end
%% Get division-wise acgs
NumWS = size(SleepDivisions.SleepDivisions,1);
NumSleepDiv = SleepDivisions.NumSleepDivisions;
slnames = {'Sleep';'SWS';'REM'};
ACGLogBySleepDiv = v2struct(slnames,NumSleepDiv,NumWS,HalfWidthsinMs,numHalfBins);
for sl = 1:length(slnames)
    for a = 1:NumSleepDiv;
        for b = 1:NumWS%Make combined intervalSet for this quartile across all WSEpisodes
            if b == 1
                eval([slnames{sl} 'Ints{a} = SleepDivisions.SleepDivisions{b,a};'])
            else
                eval([slnames{sl} 'Ints{a} = cat(' slnames{sl} 'Ints{a},SleepDivisions.' slnames{sl} 'Divisions{b,a});'])
            end
        end
        eval(['thisS = Restrict(S,' slnames{sl} 'Ints{a});'])
        for b = 1:length(HalfWidthsinMs)
            ACGs{a,b} = ACGByBins(thisS,Times{b});
            ISIH{a,b} = ISIHistogramByBins(thisS,Times{b});
        end
        BurstIndex{a} = BurstIndex_TsdArray(thisS,0.015);
        BurstMaxPoint{a} = 1;
        
        
        eval(['ACGLogBySleepDiv.' slnames{sl} 'CCGs = CCGs;'])
        eval(['ACGLogBySleepDiv.' slnames{sl} 'ACGs = ACGs;'])
        eval(['ACGLogBySleepDiv.' slnames{sl} 'ISIHs = ISIH;'])
    end
end



%% save
ACGLogBySleepDiv.Times = Times;
save(fullfile(basepath,[basename '_ACGLogBySleepDiv' num2str(NumSleepDivisions) '.mat']),'ACGLogBySleepDiv')
1;