function ManualToFinalStateID(basepath,basename)
% Uses a -states.mat (with history saved) to create _StateIDM (manual) from
% _StateIDA.
% After _StateIDA (auto) has been generated, user reviews with stateeditor
% after using StateIDtoStateIDM to create _ReviewEpStates.mat.
% (StateEditor opens _ReviewEpStates to get "states out".  Any new changes
% made in state editor will be saved as history events so HISTORY MUST BE
% SAVED with state editor for this to work properly (because states 2 and 4
% are used improperly here).
% Brendon Watson

% stateidxs: 1 = wake, 2 = drowsy(unused), 3=SWS, 4=Intermediate(unused), 5=REM
% episodeidxs 1 = Wake Episode, 2 = SWS Episode, 3 = REM Episode

if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

load(fullfile(basepath, [basename '_StateIDA.mat']));
load(fullfile(basepath, [basename '_GoodSleepInterval.mat']),'GoodSleepInterval');

if exist(fullfile(basepath, [basename '-states.mat']));
    if strcmp(basename(1:5),'Rizzo')%special case of very HVS-y state
        load(fullfile(basepath, [basename '-states.mat']),'states');
        episodeidx = ManualStateIdxToEpisodeIdx(states);
        stateidx = states;
    else
        load(fullfile(basepath, [basename '-states.mat']),'history');
        episodeidx(episodeidx==3) = 5;%temporarily convert so same code as states.mat
        episodeidx(episodeidx==2) = 3;
        episodeidx(episodeidx==4) = [];%prob unnecesssary
        episodeidx(episodeidx==2) = [];%prob unnecesssary
        for a = 1:length(history.newStates)%go in temporal order of when state changes were made, so overwrites will happen properly 
            newvals = history.newStates{a}.state;
            start = history.newStates{a}.location;
            dur = length(history.newStates{a}.state);
            stateidx(start:start+dur-1) = newvals;
            episodeidx(start:start+dur-1) = newvals;
        end
        episodeidx(episodeidx==4) = 3;%prob unnecesssary
        episodeidx(episodeidx==2) = 1;%prob unnecesssary
        episodeidx(episodeidx==3) = 2;
        episodeidx(episodeidx==5) = 3;
    end
end


% convert episodeidx and stateidx to intervals with tsds.
% Make INT2TSDIDX

stateintervals = IDXtoTSDINT(stateidx);
episodeintervals = IDXtoTSDINT(episodeidx);

s = stateidx;
s(s~=3) = 0;
minPACKdur = 20;
packetintervals = IDXtoTSDINT(s);
packetintervals{1} = dropShortIntervals(packetintervals{1},minPACKdur*10000);

% 
stateidx = stateidx(:);
episodeidx = episodeidx(:);

%%
ei{5} = episodeintervals{3};
ei{4} = intervalSet([],[]);
ei{3} = episodeintervals{2};
ei{2} = intervalSet([],[]);
ei{1} = episodeintervals{1};

si{5} = stateintervals{3};
si{4} = intervalSet([],[]);
si{3} = stateintervals{2};
si{2} = intervalSet([],[]);
si{1} = stateintervals{1};

if strcmp(basename(1:10),'BWRat17')%
    WS = DefineWakeSleepWakeEpisodes(basepath,basename,si,GoodSleepInterval);
else
    WS = DefineWakeSleepWakeEpisodes(basepath,basename,ei,GoodSleepInterval);
end
WakeSleep = WS.WSEpisodes;
if isempty(WakeSleep)
    disp('WS Empty')
end

%%
save(fullfile(basepath,[basename '_StateIDM.mat']),'stateidx','stateintervals','episodeidx','episodeintervals','packetintervals','WakeSleep')


function episodeidx = ManualStateIdxToEpisodeIdx(stateidx)

stateidx(stateidx==4) = 3;%convert from stateeditor scoring (Degade drowsy to wake and Intermediate to REM)
stateidx(stateidx==2) = 1;
stateidx(stateidx==3) = 2;%SWS to 2 (wake already 1)
stateidx(stateidx==5) = 3;%REM to 3

% stateintervals = IDXtoINT(stateidx);
stateintervals = IDXtoTSDINT(stateidx);

WAKEints = stateintervals{1};
SWSints = stateintervals{2};
REMints = stateintervals{3};

minintdur = 40;
minWAKEdur = 20;
% [episodeints{1}] = idstateepisode(WAKEints,minintdur,minWAKEdur);
[episodeints{1}] = mergeCloseIntervals(WAKEints,minintdur*10000);
[episodeints{1}] = dropShortIntervals(episodeints{1},minWAKEdur*10000);

minintdur = 40;
minSWSdur = 20;
% [episodeints{2}] = idstateepisode(SWSints,minintdur,minSWSdur);
[episodeints{2}] = mergeCloseIntervals(SWSints,minintdur*10000);
[episodeints{2}] = dropShortIntervals(episodeints{2},minSWSdur*10000);

minintdur = 40;
minREMdur = 20;
% [episodeints{3}] = idstateepisode(REMints,minintdur,minREMdur);
[episodeints{3}] = mergeCloseIntervals(REMints,minintdur*10000);
[episodeints{3}] = dropShortIntervals(episodeints{3},minREMdur*10000);

episodeints{1} = StartEnd(episodeints{1},'s');
episodeints{2} = StartEnd(episodeints{2},'s');
episodeints{3} = StartEnd(episodeints{3},'s');
episodeidx = INTtoIDX(episodeints,length(stateidx));
