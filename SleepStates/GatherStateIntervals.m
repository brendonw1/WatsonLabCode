function StateIntervals = GatherStateIntervals(basepath,basename,RestrictInterval)
% makes rate matrices for cell x timebin for wake, rem, moving wake,
% non-moving wake at the specified seconds per bin.  For UP states,
% SpindleUPstates, Spindles and No-DOWN Spindles the entire event is taken
% as a rate bin.  Default time bin duration = 1sec

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

% Spindles
t = load(fullfile(basepath,'Spindles',['SpindleData']));%load spindles with no DOWN states
SpindleData = t.SpindleData;
spindleInts = intervalSet(SpindleData.normspindles(:,1)*10000,SpindleData.normspindles(:,3)*10000);
if exist('RestrictInterval','var')
    spindleInts = intersect(spindleInts,RestrictInterval);
end


% NoDOWNSpindles
t = load(fullfile(basepath,'Spindles',['SpindleDataNoDOWN.mat']));%load spindles with no DOWN states
SpindleData = t.SpindleData;
ndSpindleInts = intervalSet(SpindleData.normspindles(:,1)*10000,SpindleData.normspindles(:,3)*10000);
if exist('RestrictInterval','var')
    ndSpindleInts = intersect(ndSpindleInts,RestrictInterval);
end


% UPstates
t = load(fullfile(basepath,[basename '_UPDOWNIntervals']));
UPintsOrig = t.UPInts;
UPInts = UPintsOrig;
if exist('RestrictInterval','var')
    UPInts = intersect(UPInts,RestrictInterval);
end


% SpindleUPstates
t = load(fullfile(basepath,'UPstates',[basename '_SpindleUPEvents']));
SpindleUPEvents = t.SpindleUPEvents;
spindleUPInts = subset(UPintsOrig,SpindleUPEvents.SpindleUPs);
if exist('RestrictInterval','var')
    spindleUPInts = intersect(spindleUPInts,RestrictInterval);
end


% NonSpindleUPstates
nonSpindleUPInts = subset(UPintsOrig,SpindleUPEvents.NoSpindleUPs);
if exist('RestrictInterval','var')
    nonSpindleUPInts = intersect(nonSpindleUPInts,RestrictInterval);
end


intervals = load(fullfile(basepath,[basename '_Intervals']));

% Wake
wakeInts = intervals.intervals{1};
if exist('RestrictInterval','var')
    wakeInt = intersect(wakeInts,RestrictInterval);
end

wakesecs = [Start(wakeInts,'s') End(wakeInts,'s')];%for motion later
% Moving Wake
t = load(fullfile(basepath,[basename '_Motion.mat']));
wakesecs = inttobool(wakesecs,length(t.motiondata.thresholdedsecs));
movewake = wakesecs.*t.motiondata.thresholdedsecs';
movewake2 = booltoint(movewake);
moveWakeInts = intervalSet(movewake2(:,1)*10000,movewake2(:,2)*10000);

% Non-moving Wake
nonmovewake = ~movewake;
nonmovewake = nonmovewake .* wakesecs;%Have to take times that are both (notmoving) and (yeswake)
nonmovewake2 = booltoint(nonmovewake);
nonMoveWakeInts = intervalSet(nonmovewake2(:,1)*10000,nonmovewake2(:,2)*10000);

% REM
REMInts = intervals.intervals{5};
if exist('RestrictInterval','var')
    REMInts = intersect(REMInts,RestrictInterval);
end


%% Save out
StateIntervals = v2struct(spindleInts,ndSpindleInts,...
    UPInts,spindleUPInts,nonSpindleUPInts,...
    wakeInts,moveWakeInts,nonMoveWakeInts,...
    REMInts);
