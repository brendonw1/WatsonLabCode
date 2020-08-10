%    merge the below structures together for quintile_newDI5sp to run.
%    For more info go to trisecFiringFunc.m.
%    (run from parant folder)
%    sleep-basics     -basic cell and channel info
%    sleep-behavior     -sleep state epoch
%    sleep-onOff     -UP and DN state epoch
%    sleep-spikes     -spike time for individual cell
%    sleep-stableSleep     -stable sleep epoch
%    sleep-stateChange     -different state transition
%    sleep-timeNormFR     -Different states has their intrinsic mean
%    periods, thus firing rates need to be normalized.
%    sleep-trisecFiring     -trisection firing rate
%    sleep-trisecFiringSp     -trisect firing rate without DN state spikes
% Written by Tangyu Liu, 2020
directory=getDirectory(pwd,'sleep-newDI5sp.mat');
idx = find(cellfun(@(x) strcmp(x,'/analysis/tangyuli/pooled_withCohEMG'), directory, 'UniformOutput', 1)==1);
directory(idx)=[];
idx = find(cellfun(@(x) strcmp(x,pwd), directory, 'UniformOutput', 1)==1);
directory(idx)=[];
coreName='sleep';
varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HL'
    ...'HLwavelet'
    ...'MA'
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'firing'
    ...'eventRate'
    'stableSleep'
    ...'stableWake'
    'stateChange'
    'trisecFiring'
    'trisecFiringSp'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    ...'pairCorr'
    ...'pairCorrHIGH'
    'timeNormFR'
    ...'timeNormFRsp'
    }';
for i=1:numel(directory)
cd(directory{i});
baseDir=[pwd filesep];
fname=bz_BasenameFromBasepath(pwd);

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end
basicsa.(fname)=basics.(fname);
behaviora.(fname)=behavior.(fname);
spikesa.(fname)=spikes.(fname);
stableSleepa.(fname)=stableSleep.(fname);
stateChangea.(fname)=stateChange.(fname);
trisecFiringa.(fname)=trisecFiring.(fname);
trisecFiringSpa.(fname)=trisecFiringSp.(fname);
timeNormFRa.(fname)=timeNormFR.(fname);
end
eval('cd ..');
baseDir=[pwd filesep];
basics=basicsa;
behavior=behaviora;
spikes=spikesa;
stableSleep=stableSleepa;
stateChange=stateChangea;
trisecFiring=trisecFiringa;
trisecFiringSp=trisecFiringSpa;
timeNormFR=timeNormFRa;
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end