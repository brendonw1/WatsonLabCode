function StateIntervals = ConvertStatesVectorToIntervalSets(states,basename)
% Function to take "states" from -states.mat file from StateEditor to 
% convert them to TStoolbox-style interval sets
%
% Input: states: variable stored in basename-states.mat by StateEditor, is
% a vector of the assigned state at each second in the recording
% 
% Output: StateIntervals is a cell array, each element contains the full
% interval set for one of the states (0 through 5) in StateEditor.  As of
% this writing: 
% State 1 = Wake
% State 2 = Drowsy
% State 3 = SWS
% State 4 = Intermediate Sleep
% State 5 = REM
% State 6 = No label
% State 7 = Interval for entire recording
% Brendon Watson January 2014

if ~exist('basename','var')
    basename = [];
end

havestates = 0;
if exist('states','var') 
    if ~isempty(states)
        havestates = 1;
    end
end
if ~havestates
    states = getstateinfo(basename);
    if isempty(states)
        states = getstateinfo(basename);
    end
end
if isstruct(states)
    if isfield(states,'states')
        states = states.states;
    end
end

for a = 1:6; %for each of 6 states in StateEditor
    if a~=6;
        statetype = a;
    else
	    statetype = 0;%no label case
    end
    
	thesestarts = find(diff(states == statetype)>0);%basic function here and next linfunction states = getstateinfo(varargin)
    thesestops = find(diff(states == statetype)<0);
    
    if states(1) == statetype%account for states that begin at start of file
        thesestarts=cat(2,1,thesestarts);
    end
    if states(end) == statetype%account for states that finsh at end of file
        thesestops=cat(2,thesestops,length(states));
    end
    
    StateIntervals{a} = intervalSet(thesestarts*10000,thesestops*10000);%store results
end

StateIntervals{end+1} = intervalSet(0,length(states));


function states = getstateinfo(basename)
% function states = getstateinfo(varargin)

% Loads basename-states.mat in a relatively problem-tolerant way, if
% it's in the current directory

if ~isempty(basename)
      if FileExistsIn([basename, '-states.mat']);
        
        states = load([basename, '-states.mat']);
%         StateInfo = StateInfo.StateInfo;
    end
else
    xmlBase = dir('*xml');
    if length(xmlBase) == 0
        if FileExistsIn('*-states.mat')
            d = dir('*-states.mat');
            states = load(d(1).name);
%             StateInfo = StateInfo.StateInfo;
        else
            warndlg('No ''*xml'' file found. Quitting now. Bye bye.');
            return
        end
    else
        xmlBase = xmlBase(1);
        choice = questdlg(['No basename entered, use ', xmlBase.name(1:(end - 4)), ' as file basename?'],'No Basename','Yes','Cancel','Yes');
        if strmatch(choice,'Cancel')
            return
        elseif strmatch(choice,'Yes')
            basename = xmlBase.name(1:(end - 4));
            states = load([basename, '-states.mat']);
        end
    end
end



function E = FileExistsIn(name)
if length(dir(name)) > 0
    E = 1;
else
    E = 0;
end
