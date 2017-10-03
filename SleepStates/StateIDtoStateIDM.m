function StateIDtoStateIDM(basepath,basename)


if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

%correct length of states vectors
tid = load(fullfile(basepath,[basename, '_StateIDA.mat']));
load(fullfile(basepath,[basename, '.eegstates.mat']));
x{1} = tid.stateidx(:)';
x{2} = tid.episodeidx(:)';

for a = 1:length(x)
    if length(StateInfo.motion) > length(x{a})
        lv = x{a}(end);
        ld = length(StateInfo.motion) - length(x{a});
        x{a} = cat(2,x{a},lv*ones(1,ld));
    elseif length(StateInfo.motion) < length(x{a})
       ld = length(x{a}) - length(StateInfo.motion);
       x{a} = x{a}(1:end-(ld));
    end
end

%WS Episode detect and save as StateEditor Events
ints = tid.episodeintervals;
ints{5}=ints{3};
ints{3}=ints{2};
ints{2}=[];
ints{1}=intervalSet(ints{1}(:,1)*10000,ints{1}(:,2)*10000);
ints{2}=intervalSet([],[]);
ints{3}=intervalSet(ints{3}(:,1)*10000,ints{3}(:,2)*10000);
ints{4}=intervalSet([],[]);
ints{5}=intervalSet(ints{5}(:,1)*10000,ints{5}(:,2)*10000);
load(fullfile(basepath,[basename, '_GoodSleepInterval.mat']));
WS = DefineWakeSleepWakeEpisodes(basepath,basename,ints,GoodSleepInterval);

%save episode scoring
states = x{2};
states(states==3) = 5;
states(states==2) = 3;
states(x{1}==3) = 2;
states(x{1}==5) = 4;

events = [];
for a = 1:length(WS.WSEpisodes)
    se = StartEnd(WS.WSEpisodes{a},'s');
%     WStart(a) = se(1,1);
%     WEnd(a) = se(1,2);
%     SStart(a) = se(2,1);
%     SEnd(a) = se(2,2);
    Evts = [a*ones(4,1) [se(1,1);se(1,2);se(2,1);se(2,2)]];
    events = cat(1,events,Evts);
end


%% save out
save(fullfile(basepath,[basename, '_ReviewEpStates.mat']),'states','events');


% 
% %save state scoring
% states = x{1};
% if isfield(ts,'events');
%     events = ts.events;
%     save(fullfile(basepath,[basename, '_StateIDM.mat']),'states','events');
% else
%     save(fullfile(basepath,[basename, '_StateIDM.mat']),'states');
% end
% %save episode scoring
% states = x{2};
% states(states==3) = 5;
% states(states==2) = 3;
% if isfield(ts,'events');
%     events = ts.events;
%     save(fullfile(basepath,[basename, '_EpisodeIDM.mat']),'states','events');
% else
%     save(fullfile(basepath,[basename, '_EpisodeIDM.mat']),'states');
% end
    


% tid = load(fullfile(basepath,[basename, '_StateID.mat']));
% load(fullfile(basepath,[basename, '.eegstates.mat']));
% 
% if length(StateInfo.motion) > length(tid.states)
%     lv = tid.states(end);
%     ld = length(StateInfo.motion) - length(tid.states);
%     tid.states = cat(2,tid.states,lv*ones(1,ld));
% elseif length(StateInfo.motion) < length(tid.states)
%    ld = length(tid.states) - length(StateInfo.motion);
%    tid.states = tid.states(1:end-(ld));
% end
%     
% states = tid.states;
% % stateintervals = tid.stateintervals;
% if isfield(ts,'events');
%     events = ts.events;
%     save(fullfile(basepath,[basename, '_StateIDM.mat']),'states','events');
% else
%     save(fullfile(basepath,[basename, '_StateIDM.mat']),'states');
% end
%     
% 
