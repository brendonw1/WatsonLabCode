basename = 'Dino_061614';
basepath = '/mnt/brendon6/Dino/Dino_061614';
dropbasepathstr = 'dropbasepath = fullfile(getdropbox,''Data'',''KetamineDataset'',basename);';
eval(dropbasepathstr)
if exist(basepath,'dir')
    cd(basepath)
    tbasepath = basepath;
else
    cd(dropbasepath)
    tbasepath = dropbasepath;
end

%% basic meta data
Par = LoadPar(fullfile(tbasepath,[basename '.xml']));
% voltsperunit = 3.814697265625000e-07;%amplirec
voltsperunit = VoltsPerUnit(basename,basepath);

%% 
BadInterval = [];
BadIntervali = [];
if ~isempty(BadInterval)
    BadIntervali = intervalSet(BadInterval(:,1),BadInterval(:,2));
end

%% channels
% !!! All channels base 1 !!!
goodshanks = [1:12];%% Can code this based on spkgroupnums = matchSpkGroupsToAnatGroups(par)
% goodeegchannel = 46; %base 1
if exist(fullfile(tbasepath,[basename,'_StateScoreMetrics.mat']),'file')
    Thetachannel = load(fullfile(tbasepath,[basename,'_StateScoreMetrics.mat']),'THchannum'); %Good # of units
    goodeegchannel = load(fullfile(tbasepath,[basename,'_StateScoreMetrics.mat']),'SWchannum');
elseif exist(fullfile(tbasepath,[basename,'.eegstates.mat']),'file')
    t  =load(fullfile(tbasepath,[basename,'.eegstates.mat']),'StateInfo'); %Good # of units
    goodeegchannel = t.StateInfo.Chs(1);
    Thetachannel = t.StateInfo.Chs(2);
else
    goodeegchannel = [];
    Thetachannel = [];
end
clear t

UPstatechannel = goodeegchannel; %Good # of units
Spindlechannel = goodeegchannel; %Superficial cortical is best

Ripplechannel = Thetachannel;
RippleNoiseChannel = [];

%% For ketamine analysis
InjectionStartFile = NaN;% could grab from .csv??
InjectionTimestamp = InjectionStartFromDatInfo(tbasepath,basename,InjectionStartFile);
InjectionType = 'ketamine';

%%
SaveBasicMetaData