function PoleLocTraining

% Trains head-fixed mice to discriminate up to six pole locations through
% whisking. The user is prompted to select one out of three training phases
% before each session.
% - Phase 1: water consumption upon pole presentations at a sigle location.
% - Phase 2: two-location discrimination
% - Phase 3: multiple location test
%
% Necessary hardware:
%
% - Bpod State Machine combined with Bpod Analog Output Module (USB ports
%   COM10 and COM6, respectively): reads task parameters, controls trial
%   loops, sends commands to Zaber actuators, gets mouse responses at the
%   lickometer (beam breaks), activates water valve for rewards (or
%   punishment time outs), provides timestamps to Intan, displays
%   behavioral performance during the session, and saves trial outcomes.
%
% - Zaber X-MCB2 (USB port COM8): responds to inputs from both Bpod devices
%   through triggers configured by a custom script in C#, named
%   PoleLocTriggers.cs (also available in this repository).
%
% TASK DESIGN (GO/NO-GO) __________________________________________________
% - Whisker (pole) stimulation -> Response window -> inter-trial interval
%
% - Up to six types of stimuli: pole locations A, B, C, D, E, F. Phase 1
%   training is restricted to location A only. Phase 2 presents extreme
%   locations A and F for the binary discrimination training.
%
% - Locations A, B, C:    go trials
%       - Trial outcomes: hit (lick) or miss (no lick)
%       - Hit:            water is delivered
%       - Miss:           nothing happens (inter-trial interval)
%
% - Locations D, E, F:    no-go trials
%       - Trial outcomes: false alarm (lick) or corr rejection (no lick)
%       - False alarm:    time-out punishment
%       - Corr rejection: nothing happens (time out is avoided)
%
% - Locations vary at constant distances in the rostral-caudal direction,
%   from A to F.
%
% - Locations B, C, D, E are intermediate, and hypothesized to yield
%   psychometric fits once optimal behavioral performance is achieved.
%
% See the second section of this script ("Sets parameters") for stimulus
% durations, inter-trial intervals, etc.
%
% USAGE ___________________________________________________________________
% Step 1: Load the Zaber Console software, open the X-MCB2 device, and run
% PoleLocTriggers.cs to set the triggers. Check if "completed" appears in
% the Script Output area. Repeat if the device was restarted.
%
% Step 2: Enter "Bpod" in the Command Window, and wait until the Bpod
% Console is ready. Then enter "PoleLocTraining", and respond to the
% training phase prompt. TTLs should be visible in the Intan RHD interface,
% provided that cabling is set up correctly.
%
% LSBuenoJr and MXDing, with inputs from the Sanworks Support Forum _______



%% Sets base path and asks user to specify the training phase.
global BpodSystem;
basepath = cd;
prompt   = ...
    'Which phase: water consumption (w), two locations (t), or multiple locations (m)? ';
prompt   = input(prompt,'s');

%% Configures the Bpod Analog Output Module to trigger intermediate pole
% locations through Zaber. This had to be done given the limited number of
% output channels offered by the Bpod State Machine.
W = BpodWavePlayer('COM6');
W.TriggerMode = 'Normal';
W.TriggerProfileEnable = 'On';
W.TriggerProfiles(1,1:4) = [1 2 2 2]; % TTL-like waveforms out of BNC #1
W.TriggerProfiles(2,1:4) = [2 1 2 2]; %                       ... BNC #2
W.TriggerProfiles(3,1:4) = [2 2 1 2]; %                       ... BNC #3
W.TriggerProfiles(4,1:4) = [2 2 2 1]; %                       ... BNC #4

W.loadWaveform(1,...
    ones(1,W.SamplingRate*0.5)*3); % A square pulse of 0.5 s and 3 V.      
W.loadWaveform(2,...
    zeros(1,W.SamplingRate*0.5));  % Nothing, just flat voltage



%% Sets parameters (e.g., stimulus durations, inter-trial intervals, etc.).
% Some parameters are unused (inherited from MXDing's GoNogo_Piezo), but
% were left for eventual future use.
S.GUI.CurrentBlock       = 1;
S.GUI.RewardAmount       = 5;   % In microliters
S.GUI.TrialLength        = 5;   % In seconds
S.GUI.WaterValveTime     = GetValveTimes(S.GUI.RewardAmount,1);
S.GUI.PreStimPeriod      = 0;   % Suppressed in this task design
S.GUI.RespWindow         = 0.5; % In seconds
S.GUI.PostStimPeriod     = 2.5; % In seconds
S.GUI.PunishmentPeriod   = 10;  % In seconds
S.GUI.Lick_GoNogo        = 2;

S.GUIPanels.Behavior     = {...
    'WaterValveTime',...
    'PreStimPeriod',...
    'RespWindow',...
    'PostStimPeriod',...
    'PunishmentPeriod',...
    'TrialLength'};
S.GUIPanels.Lick_GoNogo  = {'Lick_GoNogo'};

S.GUIMeta.Lick_GoNogo.Style  = 'popupmenu';
S.GUIMeta.Lick_GoNogo.String = {'Licking','GoNogo_PoleLoc'};

S.GUI.MaxSameTrial       = 3;
S.GUI.NoTrialProb        = 0.5;
S.GUI.MinCorrectNogo     = 1;
S.GUI.MaxIncorrectNogo   = 3;
S.GUI.MinCorrectGo       = 1;
S.GUI.MaxIncorrectGo     = 3;
    
S.GUIPanels.TrialSelection = {...
    'MaxSameTrial',...
    'NoTrialProb',...
    'MinCorrectNogo',...
    'MaxIncorrectNogo',...
    'MinCorrectGo',...
    'MaxIncorrectGo'};

BpodParameterGUI('init',S);clear ans



%% Generates the sequence of trials depending on user input.
switch prompt
    case 'w'
        TrialSeq = ones(1,1000);
    case 't' % Limits trial type repetition to three consecutive
        TrialSeq = [zeros(1,5) nan(1,995)]; % Pre-defines five initial trials
        for i    = 6:length(TrialSeq)
            if i > S.GUI.MaxSameTrial
                if sum(TrialSeq((i-S.GUI.MaxSameTrial):(i-1))) == ...
                        0
                    TrialSeq(i) = 1;
                elseif sum(TrialSeq((i-S.GUI.MaxSameTrial):(i-1))) == ...
                        S.GUI.MaxSameTrial
                    TrialSeq(i) = 0;
                else
                    TrialSeq(i) = round(rand(1));
                end
            else
                TrialSeq(i)     = round(rand(1));
            end
        end
        TrialSeq = TrialSeq+1;
    case 'm'
        TrialSeq = [ones(1,5) nan(1,995)]; % Pre-defines five initial trials
        TrialTypes = 1:6;
        for i = 6:length(TrialSeq)
            PickTrialType = randi(length(TrialTypes));
            TrialSeq(i)   = TrialTypes(PickTrialType);
            %TrialSeq = [ones(1,1000)];
        end
end

BpodSystem.Data.TrialSeq      = TrialSeq;
BpodSystem.Data.TrialOutcomes = nan(size(TrialSeq));



%% Configures the outcome plot, which displays the behavioral performance
% during the session.
BpodSystem.ProtocolFigures.GoNogoPerfOutcomePlotFig = figure(...
    'Position',[200 100 1400 200],...
    'name','Outcome plot',...
    'numbertitle','off',...
    'MenuBar', 'none',...
    'Resize', 'off',...
    'Color', [1 1 1]);

BpodSystem.GUIHandles.GoNogoPerfOutcomePlot = axes(...
    'Position',[.2 .2 .75 .7]);

uicontrol(....
    'Style','text',...
    'String','nDisplay',...
    'Position',[10 170 45 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor', [1 1 1]);

BpodSystem.GUIHandles.DisplayNTrials = uicontrol(...
    'Style','edit',...
    'string','90',...
    'Position',[55 170 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Correct % (all): ',...
    'Position',[10 140 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

BpodSystem.GUIHandles.hitpct = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 140 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Correct % (40): ',...
    'Position',[10 120 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

BpodSystem.GUIHandles.hitpctrecent = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 120 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Corr rej %: ',...
    'Position',[10 90 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

BpodSystem.GUIHandles.hitpctnogo = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 90 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Hit % : ',...
    'Position',[10 70 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

BpodSystem.GUIHandles.hitpctgo = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 70 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Trials: ',...
    'Position',[10 40 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor', [1 1 1]);

BpodSystem.GUIHandles.numtrials = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 40 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

uicontrol(...
    'Style','text',...
    'String','Rewards: ',...
    'Position',[10 20 80 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]);

BpodSystem.GUIHandles.numrewards = uicontrol(...
    'Style','text',...
    'string','0',...
    'Position',[95 20 40 15],...
    'HorizontalAlignment','left',...
    'BackgroundColor', [1 1 1]);

BpodSystem.GUIHandles.CxnDisplay = uicontrol(...
    'Style','text',...
    'string','Playing',...
    'Position',[130 90 70 20],...
    'HorizontalAlignment','left',...
    'BackgroundColor', [1 1 1]);

TrialTypeOutcomePlot(BpodSystem.GUIHandles.GoNogoPerfOutcomePlot,...
    'init',BpodSystem.Data.TrialSeq);



%% Main loop
Outcomes = nan(size(TrialSeq));StimType = cell(1);Action = cell(1);
for i = 1:length(TrialSeq)
    
    % Synchronizes with BpodParameterGUI plugin and outcome plot
    S = BpodParameterGUI('sync',S); 
    TrialTypeOutcomePlot(...
        BpodSystem.GUIHandles.GoNogoPerfOutcomePlot,'update',...
        i,BpodSystem.Data.TrialSeq,Outcomes);
    
    % Displays trials on the command window and saves trials settings. For
    % multiple location training, trials are identified from 1 to 6. For
    % two-location training, trials are identified as either 1 or 2. The
    % latter is better than identifying trials 1 or 6, as it results in a
    % nicer-looking outcome plot, i.e., without an empty space between 2
    % and 5 along the Y axis. The "informal" nomenclature of Location A,
    % Location B, etc., is, however, kept consistent across training
    % phases, as well as their corresponding output commands to Zaber and
    % Intan.
    switch prompt
        case 'm'
            if TrialSeq(i)     == 1
                str             = 'Go (Location A)';
                StimType{i}     = 'Location_A';
                Action{i}       = 'Hit_A';
            elseif TrialSeq(i) == 2
                str             = 'Go (Location B)';
                StimType{i}     = 'Location_B';
                Action{i}       = 'Hit_B';
            elseif TrialSeq(i) == 3
                str             = 'Go (Location C)';
                StimType{i}     = 'Location_C';
                Action{i}       = 'Hit_C';
            elseif TrialSeq(i) == 4
                str             = 'Nogo (Location D)';
                StimType{i}     = 'Location_D';
                Action{i}       = 'FalseAlarm_D';
            elseif TrialSeq(i) == 5
                str             = 'Nogo (Location E)';
                StimType{i}     = 'Location_E';
                Action{i}       = 'FalseAlarm_E';
            elseif TrialSeq(i) == 6
                str             = 'Nogo (Location F)';
                StimType{i}     = 'Location_F';
                Action{i}       = 'FalseAlarm_F';
            end
        case 't'
            if TrialSeq(i)     == 1
                str             = 'Go (Location A)';
                StimType{i}     = 'Location_A';
                Action{i}       = 'Hit_A';
            elseif TrialSeq(i) == 2
                str             = 'Nogo (Location F)';
                StimType{i}     = 'Location_F';
                Action{i}       = 'FalseAlarm_F';
            end
        case 'w'
                str             = 'Go (Location A)';
                StimType{i}     = 'Location_A';
                Action{i}       = 'Hit_A';
    end
    
    disp(['Trial number: ',num2str(i),...
        ' Trial type: ' str ' (' num2str(TrialSeq(i)) ')'])
    BpodSystem.Data.TrialSettings(i) = S;
    
    % Sets Bpod state matrix using the locations ("StimType{i}"), and
    % hits or false alarms ("Action{i}") defined above
    sma     = NewStateMatrix();
    sma     = PoleLoc_Matrix(sma,S,Action{i},StimType{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine;
    
    % Allocates trials as states into the "BpodSystem.Data" structure
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        switch prompt
            case 'm'
                if TrialSeq(i)     == 1   % Go trial A
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_A(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 2   % Go trial B
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_B(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 3   % Go trial C
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_C(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 4   % Nogo trial D
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}.States. ...
                            FalseAlarm_D(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ....
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                elseif TrialSeq(i) == 5   % Nogo trial E
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_E(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                elseif TrialSeq(i) == 6   % Nogo trial F
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_F(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                end
            case 't'
                if TrialSeq(i)     == 1   % Go trial A
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_A(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 2   % Nogo trial F
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_F(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                end
            case 'w'
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_A(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
        end
        BpodSystem.Data.TrialOutcomes(i) = Outcomes(i);
        BpodSystem.ProtocolSettings = S;
        
        % Saves trial outcomes and timestamps
        SessionData = BpodSystem.Data; %#ok<NASGU>
        save(fullfile(basepath,'PoleLocSessionData.mat'),'SessionData','-v6');
    end
    
    if BpodSystem.Status.BeingUsed == 0;return;end
    correct          = Outcomes    == 1 | Outcomes == 2;
    hitgo            = Outcomes    == 1;
    hitnogo          = Outcomes    == 2;
    correctpct       = 100.*sum(correct)./i;
    hitpctgo         = 100.*sum(hitgo)./sum(TrialSeq(1:i));
    hitpctnogo       = 100.*sum(hitnogo)./sum(TrialSeq(1:i) == 0);
    inds40           = max(1,i-40+1):i;
    correctpctrecent = 100.*sum(correct(inds40))./numel(inds40);

    set(BpodSystem.GUIHandles.hitpct,...
        'String', num2str(correctpct));
    
    set(BpodSystem.GUIHandles.hitpctrecent,...
        'String', num2str(correctpctrecent));
    
    set(BpodSystem.GUIHandles.hitpctgo,...
        'String', num2str(hitpctgo));
    
    set(BpodSystem.GUIHandles.hitpctnogo,...
        'String', num2str(hitpctnogo));
    
    set(BpodSystem.GUIHandles.numtrials,...
        'String',num2str(i));
    
    set(BpodSystem.GUIHandles.numrewards,...
        'String', num2str(sum(hitgo)));
    
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end



%% Bpod conversation via state matrix
function sma = PoleLoc_Matrix(sma,S,CurrentAction,CurrentStimType)

% Communicates the State Machine with the Analog Output Module via serial
% messages: {'WavePlayer1',1}, {'WavePlayer1',2}, {'WavePlayer1',3}, and
% {'WavePlayer1',4}.
LoadSerialMessages('WavePlayer1',{['P' 0],['P' 1],['P' 2],['P' 3]});

sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.GUI.TrialLength);

sma = AddState(sma,'Name','TrialStart',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup','PreStim'},...
    'OutputActions',{'GlobalTimerTrig',1}); % Used to deliver the trial
                                            % onset cue (light) using
                                            % " 'PWM1',200, " before the
                                            % Global Timer (supppressed in
                                            % this task design).

sma = AddState(sma,'Name','PreStim',...
    'Timer',S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup',CurrentStimType},...
    'OutputActions',{'Wire1',1}); % Trial onset TTL out of wire 1 to Intan

sma = AddState(sma,'Name','Location_A',...
    'Timer',S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1}); % Triggers Zaber, sends TTL to Intan

sma = AddState(sma,'Name','Location_B',...
    'Timer', S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1,'WavePlayer1',1}); % Same as above, but using
                                                  % the Analog Output Module

sma = AddState(sma,'Name','Location_C',...
    'Timer', S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1,'WavePlayer1',2}); % As above

sma = AddState(sma,'Name','Location_D',...
    'Timer', S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1,'WavePlayer1',3}); % As above

sma = AddState(sma,'Name','Location_E',...
    'Timer', S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1,'WavePlayer1',4}); % As above

sma = AddState(sma,'Name','Location_F',...
    'Timer', S.GUI.RespWindow,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'Wire2',1,'Wire3',2}); % As above, but without
                                            % the Analog Output Module

sma = AddState(sma,'Name','ResponseWindow',...
    'Timer',S.GUI.PostStimPeriod,...
    'StateChangeConditions',{'Port1In',CurrentAction,'Tup','TimeOut'},...
    'OutputActions',{'Wire1',1}); % Post-stimulus TTL out of wire 1 to Intan

sma = AddState(sma,'Name','Hit_A',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % Rewarded response and
                                                % TTL out of BNC1 to Intan

sma = AddState(sma,'Name','Hit_B',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % As above

sma = AddState(sma,'Name','Hit_C',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % As above

sma = AddState(sma,'Name','FalseAlarm_D',...
    'Timer',S.GUI.PunishmentPeriod,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_D'},...
    'OutputActions',{'BNC1',1}); % Punished response and TTL out of BNC1

sma = AddState(sma,'Name','FalseAlarm_E',...
    'Timer',S.GUI.PunishmentPeriod,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_E'},...
    'OutputActions',{'BNC1',1}); % As above

sma = AddState(sma,'Name','FalseAlarm_F',...
    'Timer',S.GUI.PunishmentPeriod,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_F'},...
    'OutputActions',{'BNC1',1}); % As above

sma = AddState(sma,'Name','TimeOut',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end



end