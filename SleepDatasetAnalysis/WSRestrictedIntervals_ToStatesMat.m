function WSRestrictedIntervals_ToStatesMat(basepath,basename)

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
if exist(fullfile(basepath,[basename '-states.mat']),'file')
    load(fullfile(basepath,[basename '-states.mat']))
end
load(fullfile(basepath,[basename '.eegstates.mat']))

len = size(StateInfo.fspec{1}.to,1);
clear StateInfo

statecell{1} = StartEnd(WakeIntervalSetFormat);
statecell{2} = StartEnd(MAIntervalSetFormat);
statecell{3} = StartEnd(SWSPacketIntervalSetFormat);
statecell{5} = StartEnd(REMIntervalSetFormat);
states = INTtoIDX(statecell,len);
states = states';

if exist(fullfile(basepath,[basename '-states.mat']),'file')
    movefile(fullfile(basepath,[basename '-states.mat']),fullfile(basepath,[basename '-states_PrePaper.mat']))
end
    
if exist('events','var')
    save(fullfile(basepath,[basename '-states.mat']),'states','events')
else
    save(fullfile(basepath,[basename '-states.mat']),'states')
end
