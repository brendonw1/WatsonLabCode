function SleepDivisions = GatherSleepDivisionIntervals(basepath,basename,NumSleepDivisions)
% Returns intervalSets for common states for a given recording.
% Brendon Watson 2015


%% Set costants
if ~exist('NumSleepDivisions','var')
    NumSleepDivisions= 4;
end

%% Manage inputs
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
% 
% if ~exist('RestrictInterval','var')
%     %     RestrictInterval = intervalSet(0,Inf);
%     t = load([fullfile(basepath,basename) '_GoodSleepInterval.mat']);
%     RestrictInterval = t.GoodSleepInterval;
% end

%% Load everything we'll need
t = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
WakeInts = t.WakeInts;

%% Getting Sleep, SW Sleep and REM Sleep 
for a = 1:length(length(WakeInts))
    portions = regIntervals(subset(WakeInts,a),NumSleepDivisions);
    for b = 1:NumSleepDivisions
        SleepDivisions{a,b} = portions{b};
        SWSDivisions{a,b} = intersect(portions{b},WakeInts{3});
        REMDivisions{a,b} = intersect(portions{b},WakeInts{5});
    end
end

%% Storage
SleepDivisions = v2struct(SleepDivisions,SWSDivisions,REMDivisions,NumSleepDivisions);

savematname = fullfile(basepath,[basename '_SleepDivisions' num2str(NumSleepDivisions) '.mat']);
save(savematname,'SleepDivisions')