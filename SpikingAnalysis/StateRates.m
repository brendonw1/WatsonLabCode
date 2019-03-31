function StateRates = StateRates(basepath,basename)
% Gets and stores simple spike rates for each cell in a number of states.
% Note this is based on  GatherStateIntervalsets.m, which restricts to
% GoodSleepIntervals.
% Brendon Watson July 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_SStable.mat']));
if isfield(t,'S_TsdArrayFormat');
    S = t.S_TsdArrayFormat;
else
    S = t.S;
end

t = load(fullfile(basepath,[basename '_SSubtypes.mat']));
if isfield(t,'Se_TsdArrayFormat');
    Se = t.Se_TsdArrayFormat;
    Si = t.Si_TsdArrayFormat;
else
    Se = t.Se;
    Si = t.Si;
end

AllAllRates = Rate(S);
EAllRates = Rate(Se);
IAllRates = Rate(Si);

if exist(fullfile(basepath,[basename '-states.mat']),'file')
    t = load(fullfile(basepath,[basename '-states.mat']));%from GatherStateIntervalSets.m
    StateIntervals = IDXtoINT(t.states);
    for a = 1:5;
        if length(StateIntervals)>=a
            StateIntervals{a} = intervalSet(StateIntervals{a}(:,1),StateIntervals{a}(:,2));
        else
            StateIntervals{a} = intervalSet([],[]);
        end
    end
    
%     AllWakeSleepRates = Rate(S,StateIntervals.WakeSleepCycles);
%     AllWSWakeRates = Rate(S,StateIntervals{1});
%     AllWSSleepRates = Rate(S,union(StateIntervals{2},StateIntervals{3},StateIntervals{4},StateIntervals{5}));
    AllWakeRates = Rate(S,StateIntervals{1});    
    AllREMRates = Rate(S,StateIntervals{5});
    AllSWSRates = Rate(S,StateIntervals{3});
    AllMARates = Rate(S,StateIntervals{2});
    % AllMWakeRates = Rate(S,StateIntervals.MWake);
    % AllNMWakeRates = Rate(S,StateIntervals.NMWake);

%     EWSWakeRates = Rate(Se,StateIntervals{1});
%     EWSSleepRates = Rate(Se,union(StateIntervals{2},StateIntervals{3},StateIntervals{4},StateIntervals{5}));
    EWakeRates = Rate(Se,StateIntervals{1});
    EREMRates = Rate(Se,StateIntervals{5});
    ESWSRates = Rate(Se,StateIntervals{3});
    EMARates = Rate(Se,StateIntervals{2});

    if prod(size(Si))>0
        IAllRates = Rate(Si);
        if isempty(IAllRates)
            IAllRates = 0;
        end
%         IWSWakeRates = Rate(Si,StateIntervals{1});
%         IWSSleepRates = Rate(Si,union(StateIntervals{2},StateIntervals{3},StateIntervals{4},StateIntervals{5}));
        IWakeRates = Rate(Si,StateIntervals{1});
        IREMRates = Rate(Si,StateIntervals{5});
        ISWSRates = Rate(Si,StateIntervals{3});
        IMARates = Rate(Si,StateIntervals{2});
    else
        IAllRates = [];
%         IWSWakeRates = [];
%         IWSSleepRates = [];
        IWakeRates = [];
        IREMRates = [];
        ISWSRates = [];
        IMARates = [];
    %     IMWakeRates = [];
    %     INMWakeRates = [];
    end    

%     %% Spindles & UPs
%     AllUPRates = Rate(S,StateIntervals.UPstates);
%     EUPRates = Rate(Se,StateIntervals.UPstates);
%     IUPRates = Rate(Si,StateIntervals.UPstates);
% 
%     AllSpindleRates = Rate(S,StateIntervals.Spindles);
%     ESpindleRates = Rate(Se,StateIntervals.Spindles);
%     ISpindleRates = Rate(Si,StateIntervals.Spindles);
% 
%     % AllNDSpRates = Rate(S,StateIntervals.NDSpindles);
%     % ENDSpRates = Rate(Se,StateIntervals.NDSpindles);
%     % INDSpRates = Rate(Si,StateIntervals.NDSpindles);
% 
%     %% First/last SWS of sleep episodes
%     AllFSWSRates = Rate(S,StateIntervals.FSWS);
%     EFSWSRates = Rate(Se,StateIntervals.FSWS);
%     IFSWSRates = Rate(Si,StateIntervals.FSWS);
% 
%     AllLSWSRates = Rate(S,StateIntervals.LSWS);
%     ELSWSRates = Rate(Se,StateIntervals.LSWS);
%     ILSWSRates = Rate(Si,StateIntervals.LSWS);

    % StateRates = v2struct(EWakeRates,IWakeRates,EREMRates,IREMRates,...
%     ESWSRates,ISWSRates,...
%     EMWakeRates,IMWakeRates,ENMWakeRates,INMWakeRates,...
%     EUPRates,IUPRates,ESpindleRates,ISpindleRates);
StateRates = v2struct(AllAllRates,EAllRates,IAllRates,...
    AllWakeRates,EWakeRates,IWakeRates,...
    AllREMRates,EREMRates,IREMRates,...
    AllSWSRates,ESWSRates,ISWSRates,...
    AllMARates,EMARates,IMARates);
%     AllWakeSleepRates,EWakeSleepRates,IWakeSleepRates,...
%     AllWSWakeRates,EWSWakeRates,IWSWakeRates,...
%     AllWakeARates,EWakeARates,IWakeARates,...
%     AllWSSleepRates,EWSSleepRates,IWSSleepRates,...
%     AllUPRates,EUPRates,IUPRates,...
%     AllSpindleRates,ESpindleRates,ISpindleRates,...
%     AllFSWSRates,EFSWSRates,IFSWSRates,...
%     AllLSWSRates,ELSWSRates,ILSWSRates);
%     AllMWakeRates,EMWakeRates,IMWakeRates,...
%     AllNMWakeRates,ENMWakeRates,INMWakeRates,...

elseif exist(fullfile(basepath,[basename '_StateIntervals.mat']),'file')
    t = load(fullfile(basepath,[basename '_StateIntervals.mat']));%from GatherStateIntervalSets.m
    % t = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
    StateIntervals = t.StateIntervals;

    AllWakeSleepRates = Rate(S,StateIntervals.WakeSleepCycles);
    AllWSWakeRates = Rate(S,StateIntervals.WSWake);
    AllWakeARates = Rate(S,StateIntervals.wakea);
    AllWSSleepRates = Rate(S,StateIntervals.WSSleep);
    AllREMRates = Rate(S,StateIntervals.REM);
    AllSWSRates = Rate(S,StateIntervals.SWS);
    % AllMWakeRates = Rate(S,StateIntervals.MWake);
    % AllNMWakeRates = Rate(S,StateIntervals.NMWake);

    % EAllWakeRates = Rate(Se,interasect(
    EWakeSleepRates = Rate(Se,StateIntervals.WakeSleepCycles);
    EWSWakeRates = Rate(Se,StateIntervals.WSWake);
    EWakeARates = Rate(Se,StateIntervals.wakea);
    EWSSleepRates = Rate(Se,StateIntervals.WSSleep);
    EREMRates = Rate(Se,StateIntervals.REM);
    ESWSRates = Rate(Se,StateIntervals.SWS);
    % EMWakeRates = Rate(Se,StateIntervals.MWake);
    % ENMWakeRates = Rate(Se,StateIntervals.NMWake);

    if prod(size(Si))>0
        IAllRates = Rate(Si);
        if isempty(IAllRates)
            IAllRates = 0;
        end
        IWakeSleepRates = Rate(Si,StateIntervals.WakeSleepCycles);
        IWSWakeRates = Rate(Si,StateIntervals.WSWake);
        IWakeARates = Rate(Si,StateIntervals.wakea);
        IWSSleepRates = Rate(Si,StateIntervals.WSSleep);
        IREMRates = Rate(Si,StateIntervals.REM);
        ISWSRates = Rate(Si,StateIntervals.SWS);
    %     IMWakeRates = Rate(Si,StateIntervals.MWake);
    %     INMWakeRates = Rate(Si,StateIntervals.NMWake);
    else
        IAllRates = [];
        IWakeSleepRates = [];
        IWSWakeRates = [];
        IWakeARates = [];
        IWSSleepRates = [];
        IREMRates = [];
        ISWSRates = [];
    %     IMWakeRates = [];
    %     INMWakeRates = [];
    end    

    %% Spindles & UPs
    AllUPRates = Rate(S,StateIntervals.UPstates);
    EUPRates = Rate(Se,StateIntervals.UPstates);
    IUPRates = Rate(Si,StateIntervals.UPstates);

    AllSpindleRates = Rate(S,StateIntervals.Spindles);
    ESpindleRates = Rate(Se,StateIntervals.Spindles);
    ISpindleRates = Rate(Si,StateIntervals.Spindles);

    % AllNDSpRates = Rate(S,StateIntervals.NDSpindles);
    % ENDSpRates = Rate(Se,StateIntervals.NDSpindles);
    % INDSpRates = Rate(Si,StateIntervals.NDSpindles);

    %% First/last SWS of sleep episodes
    AllFSWSRates = Rate(S,StateIntervals.FSWS);
    EFSWSRates = Rate(Se,StateIntervals.FSWS);
    IFSWSRates = Rate(Si,StateIntervals.FSWS);

    AllLSWSRates = Rate(S,StateIntervals.LSWS);
    ELSWSRates = Rate(Se,StateIntervals.LSWS);
    ILSWSRates = Rate(Si,StateIntervals.LSWS);

    % StateRates = v2struct(EWakeRates,IWakeRates,EREMRates,IREMRates,...
%     ESWSRates,ISWSRates,...
%     EMWakeRates,IMWakeRates,ENMWakeRates,INMWakeRates,...
%     EUPRates,IUPRates,ESpindleRates,ISpindleRates);
    StateRates = v2struct(AllAllRates,EAllRates,IAllRates,...
        AllWakeSleepRates,EWakeSleepRates,IWakeSleepRates,...
        AllWSWakeRates,EWSWakeRates,IWSWakeRates,...
        AllWakeARates,EWakeARates,IWakeARates,...
        AllWSSleepRates,EWSSleepRates,IWSSleepRates,...
        AllREMRates,EREMRates,IREMRates,...
        AllSWSRates,ESWSRates,ISWSRates,...
        AllUPRates,EUPRates,IUPRates,...
        AllSpindleRates,ESpindleRates,ISpindleRates,...
        AllFSWSRates,EFSWSRates,IFSWSRates,...
        AllLSWSRates,ELSWSRates,ILSWSRates);
    %     AllMWakeRates,EMWakeRates,IMWakeRates,...
    %     AllNMWakeRates,ENMWakeRates,INMWakeRates,...
elseif exist(fullfile(basepath,[basename '_SleepScoreManualReviewed.mat']),'file') || exist(fullfile(basepath,[basename '_SleepScore.mat']),'file')
    if exist(fullfile(basepath,[basename '_SleepScoreManualReviewed.mat']),'file')
        tpath = fullfile(basepath,[basename '_SleepScoreManualReviewed.mat']);
    else
        tpath = fullfile(basepath,[basename '_SleepScore.mat']);
    end
    load(tpath)
    t = intervalSet(StateIntervals.WAKEeposode(:,1),StateIntervals.WAKEeposode(:,2));
    AllWakeRates = Rate(S,t);
    EWakeRates = Rate(Se,t);
    IWakeRates = Rate(Se,t);
    
    t = intervalSet(StateIntervals.NREMpacket(:,1),StateIntervals.NREMpacket(:,2));
    AllNREMRates = Rate(S,t);
    ENREMRates = Rate(Se,t);
    INREMRates = Rate(Se,t);

    t = intervalSet(StateIntervals.REMepisode(:,1),StateIntervals.REMepisode(:,2));
    AllREMRates = Rate(S,t);
    EREMRates = Rate(Se,t);
    IREMRates = Rate(Se,t);

    StateRates = v2struct(AllAllRates,EAllRates,IAllRates,...
        AllWakeRates,EWakeRates,IWakeRates,...
        AllNREMRates,ENREMRates,INREMRates,...
        AllREMRates,EREMRates,IREMRates);

end
save(fullfile(basepath,[basename,'_StateRates.mat']),'StateRates')
