function PoleLocation

% Trains head-fixed mice to discriminate pole locations through whisking. 
% The user is prompted to select one of two phases before each session.
% Before starting this training, mice should be pre-trained for water
% consumption at the lickometer.
%
% - Phase 1 (string 't'): two-location discrimination training (usually
%   5-10 daily sessions of ~60 min).
%
% - Phase 2 (string 'm'): multiple location test (can be made just once or
%   twice, during post-training neurophysiological recordings).
%
%
%
% NECESSARY HARDWARE ______________________________________________________
% - Bpod State Machine combined with Bpod Analog Output Module: reads task
%   parameters, controls trial loops, sends commands to Zaber actuators,
%   gets mouse responses at the lickometer (beam breaks), activates water
%   valve for rewards (or punishment time outs), provides timestamps to
%   Intan, displays behavioral performance during the session, and saves
%   trial outcomes.
%
% - Zaber X-MCB2: responds to inputs from both Bpod devices through
%   triggers configured by another script in C# (PoleLocTriggers.cs, also
%   available in this repository).
%
%
%
% OPTIONAL HARDWARE _______________________________________________________
% - Intan RHD2000: acquires digital and analog events to be used as
%   timestamps during analysis.
%
% - Whisker imaging camera (Mikrotron, EoSens) and frame grabber
%   (Teledyne Dalsa Xtium): not described here.
%
% - Pupil imaging camera (Flea3) and PCIe card: not described here.
%
%
%
% TASK DESIGN (GO/NO-GO) __________________________________________________
% - Inspired mostly by: - O'Connor et al. (2010) - J Neurosci 30,
%                       - Schriver et al. (2018) - J Neurophysiol 120, and
%                       - lab discussions
%
% - Whisker (pole) stimulation -> response window -> inter-trial interval
%
% - Up to five pole locations along the whisker pad, named according to the
%   anterior-posterior axis as below:
%       - PP: extreme       posterior  (both  't' and  'm' phases)
%       - P : intermediate  posterior  (phase 'm' only)
%       - H : halfway                  (phase 'm' only)
%       - A : intermediate  anterior   (phase 'm' only)
%       - AA: extreme       anterior   (both  't' and  'm' phases)
%
% - Locations PP and P:   go trials
%       - Trial outcomes: hit (lick) or miss (no lick)
%       - Hit:            water is delivered
%       - Miss:           nothing happens (inter-trial interval)
%
% - Locations AA and A:   no-go trials
%       - Trial outcomes: false alarm (lick) or corr rejection (no lick)
%       - False alarm:    punishment (light-cued time out)
%       - Corr rejection: nothing happens (punishment is avoided)
%
% - Halfway:              either go or no-go randomly (50% chance)
%
% - Locations vary at constant distances in the rostral-caudal direction.
%   See PoleLocTriggers.cs for distances along the whisker pad.
%
% - The multiple location test is hypothesized to yield sigmoid
%   psychometric fits.
%
% See the second section of this script ("Sets parameters") for stimulus
% durations, trial length, etc.
%
%
%
% USAGE ___________________________________________________________________
% Step 1: Load the Zaber Console software, open the X-MCB2 device, and run
% PoleLocTriggers.cs. Check if "completed" is displayed in the Script
% Output Area. Still in the Zaber Console, go to the "Simple" tab, and set
% axis 1 position to zero, and axis 2 to the halfway (see
% PoleLocTriggers.cs for the halfway position in microsteps).
%
% Step 2: Go back to Matlab, enter "Bpod" in the Command Window, and wait
% until the Bpod Console is ready. Then enter "PoleLocation", and respond
% to the prompt(s). With appropriate cabling, digital and analog events
% should be visible in the Intan RHD interface.
%
% LSBuenoJr and MXDing, with inputs from the Sanworks Support Forum _______



%% Sets base path, asks user about saving a previous session (if present in
% the working directory), and asks user to specify the training phase.
global BpodSystem;
basepath = cd;

if ~isempty(BpodSystem.Data) || exist('SessionData.mat') %#ok<EXIST>
    prompt = 'Save previous session? (y/n)';
    prompt = input(prompt,'s');
    if strcmp(prompt,'y')
        SessionData = BpodSystem.Data;
        save(fullfile(basepath,...
            'PoleLocPreviousSession.mat'),'SessionData','-v6');
    end
    BpodSystem.Data = [];
end

prompt   = ...
    'Two locations (t), or Multiple locations (m)? ';
prompt   = input(prompt,'s');

%% Configures square pulses to be sent from the Analog Output Module to
% Zaber. They will trigger five different pole location stimuli. This
% had to be done given the limited number of output channels offered by the
% Bpod State Machine.
W = BpodWavePlayer('COM6'); % If not this communication port, go to:
                            % Control Panel -> Devices and Printers, then
                            % left-click X-MCB2 to set properties.
W.TriggerMode = 'Normal';
W.TriggerProfileEnable = 'On';
W.TriggerProfiles(1,1:5) = [1 4 4 4 4]; % Out of BNC #1 (Location PP)
W.TriggerProfiles(2,1:5) = [4 2 4 4 4]; %        ... #2 (Location P)
W.TriggerProfiles(3,1:5) = [4 4 2 4 4]; %        ... #3 (Location A)
W.TriggerProfiles(4,1:5) = [4 4 4 1 4]; %        ... #4 (Location AA)
W.TriggerProfiles(5,1:5) = [4 4 4 4 3]; %        ... #5 (Halfway location)

PoleMovement = 0.8; % Period it takes for the pole to reach the whisker
                    % level. This will be added to a 0.1 s trial onset
                    % digital event for a total of 0.9 s (see the
                    % first use of Bpod AddState function, in the last
                    % section of this script). Durations were defined by
                    % high-speed videography of pole movements.

W.loadWaveform(1,...
    ones(1,W.SamplingRate*PoleMovement)*3); % Locations PP and AA; no
                                            % latency before pole movement
                                            % 3 volts

W.loadWaveform(2,...
    [ones(1,W.SamplingRate*0.1)*0.5 ... % Latency of 0.1 s, 3 volts
    ones(1,W.SamplingRate*(PoleMovement-0.1))*3]); % Locations P and A

W.loadWaveform(3,...
    [ones(1,W.SamplingRate*0.3)*0.5 ... % Latency of 0.3 s, 3 volts
    ones(1,W.SamplingRate*(PoleMovement+1.5))*3]); % Halfway location

W.loadWaveform(4,...
    zeros(1,W.SamplingRate*PoleMovement)); % Nothing, just flat voltage.



%% Sets parameters (e.g., stimulus durations, inter-trial intervals, etc.).
S.GUI.TrialLength_seconds = 6; % In seconds
S.GUI.RewardAmount_mL     = 5; % In microliters
S.GUI.WaterValveTime      = GetValveTimes(S.GUI.RewardAmount_mL,1);
S.GUI.PreStimPeriod       = PoleMovement;
S.GUI.RespPeriod          = 1.5;
S.GUI.PunishmentPeriod    = 9;

S.GUIPanels.Durations_and_RewardAmount     = {...
    'TrialLength_seconds',...    
    'WaterValveTime',...
    'PreStimPeriod',...
    'RespPeriod',...
    'PunishmentPeriod',...
    'RewardAmount_mL',...
    };

BpodParameterGUI('init',S);clear ans



%% Generates the sequence of trials upon user input.
switch prompt
    case 'm'
        TrialSeq = [ones(1,50)+1 nan(1,995)];
%         TrialTypes = 1:6;
%         for i = 6:length(TrialSeq)
%             PickTrialType = randi(length(TrialTypes));
%             TrialSeq(i)   = TrialTypes(PickTrialType);
%         end
    case 't'
        MaxSameTrial = 3; % Limits trial type repetition to three consecutive.
        TrialSeq = [zeros(1,5) nan(1,995)]; % Pre-defines five initial trials.
        for i    = 6:length(TrialSeq)
            if i > MaxSameTrial
                if sum(TrialSeq((i-MaxSameTrial):(i-1))) == ...
                        0
                    TrialSeq(i) = 1;
                elseif sum(TrialSeq((i-MaxSameTrial):(i-1))) == ...
                        MaxSameTrial
                    TrialSeq(i) = 0;
                else
                    TrialSeq(i) = round(rand(1));
                end
            else
                TrialSeq(i)     = round(rand(1));
            end
        end
        TrialSeq = TrialSeq+1;
end

BpodSystem.Data.TrialSeq      = TrialSeq;
BpodSystem.Data.SessionData = nan(size(TrialSeq));



%% Configures the outcome plot to display the behavioral performance
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
    
    % Synchronizes with BpodParameterGUI plugin and outcome plot.
    S = BpodParameterGUI('sync',S); 
    TrialTypeOutcomePlot(...
        BpodSystem.GUIHandles.GoNogoPerfOutcomePlot,'update',...
        i,BpodSystem.Data.TrialSeq,Outcomes);
    
    % Displays trials on the command window and saves trials settings. For
    % multiple pole locations, trials are identified from 1 to 6. For two
    % pole locations, trials are identified as either 1 or 2. This latter
    % avoids an empty space between 1 and 6 on the outcome plot Y axis.
    switch prompt
        case 'm'
            if TrialSeq(i)     == 1
                str             = 'Go (Location PP)';
                StimType{i}     = 'Location_PP';
                Action{i}       = 'Hit_PP'; % Posterior defined as "go"
                                            % based on O'Connor et al.
                                            % (2010) - J Neurosci 30.
            elseif TrialSeq(i) == 2
                str             = 'Go (Location P)';
                StimType{i}     = 'Location_P';
                Action{i}       = 'Hit_P';
            elseif TrialSeq(i) == 3
                str             = 'Go (Halfway)';
                StimType{i}     = 'Go_Halfway';
                Action{i}       = 'Hit_H';
            elseif TrialSeq(i) == 4
                str             = 'Nogo (Halfway)';
                StimType{i}     = 'Nogo_Halfway';
                Action{i}       = 'FalseAlarm_H';
            elseif TrialSeq(i) == 5
                str             = 'Nogo (Location A)';
                StimType{i}     = 'Location_A';
                Action{i}       = 'FalseAlarm_A';
            elseif TrialSeq(i) == 6
                str             = 'Nogo (Location AA)';
                StimType{i}     = 'Location_AA';
                Action{i}       = 'FalseAlarm_AA';
            end
        case 't'
            if TrialSeq(i)     == 1
                str             = 'Go (Location PP)';
                StimType{i}     = 'Location_PP';
                Action{i}       = 'Hit_PP';
            elseif TrialSeq(i) == 2
                str             = 'Nogo (Location AA)';
                StimType{i}     = 'Location_AA';
                Action{i}       = 'FalseAlarm_AA';
            end
    end
    
    disp(['Trial #' num2str(i) ...
        ', ' str ' (' num2str(TrialSeq(i)) ')'])
    BpodSystem.Data.TrialSettings(i) = S;
    
    % Sets Bpod state matrix using the locations ("StimType{i}"), and
    % hits or false alarms ("Action{i}") defined above.
    sma     = NewStateMatrix();
    sma     = PoleLocation_Matrix(sma,S,Action{i},StimType{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine;
    
    % Allocates trials as states into the "BpodSystem.Data" structure.
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        switch prompt
            case 'm'
                if TrialSeq(i)     == 1   % Go trial PP
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_PP(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 2   % Go trial P
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_P(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 3   % Go trial halfway
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_H(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 4   % Nogo trial halfway
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}.States. ...
                            FalseAlarm_H(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ....
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                elseif TrialSeq(i) == 5   % Nogo trial A
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_A(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                elseif TrialSeq(i) == 6   % Nogo trial AA
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_AA(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                end
            case 't'
                if TrialSeq(i)     == 1   % Go trial PP
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.Hit_PP(1))
                        Outcomes(i) = 1;  % Hit
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = -1; % Miss
                    else
                    end
                elseif TrialSeq(i) == 2   % Nogo trial AA
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.FalseAlarm_AA(1))
                        Outcomes(i) = 0;  % False alarm
                    elseif ~isnan(BpodSystem.Data.RawEvents.Trial{i}. ...
                            States.TimeOut(1))
                        Outcomes(i) = 2;  % Correct rejection
                    else
                    end
                end
        end
        BpodSystem.Data.SessionData(i) = Outcomes(i);
        BpodSystem.ProtocolSettings = S;
        
        % Saves trial outcomes and timestamps.
        SessionData = BpodSystem.Data;
        save(fullfile(basepath,'SessionData.mat'),'SessionData','-v6');
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
function sma = PoleLocation_Matrix(sma,S,CurrentAction,CurrentStimType)

% Communicates the State Machine with the Analog Output Module.
LoadSerialMessages('WavePlayer1',{['P' 0],['P' 1],['P' 2],['P' 3],['P' 4]});

% Sets states and their timers, subsequent events, and output actions.
sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.GUI.TrialLength_seconds);

sma = AddState(sma,'Name','TrialStart',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup',CurrentStimType},...
    'OutputActions',{'GlobalTimerTrig',1,'Wire1',1}); % Digital event out
                                                      % of wire #1 to Intan

sma = AddState(sma,'Name','Location_PP',...
    'Timer',S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',1}); % BNC #1 of the Analog Output
                                        % Module controls X-MCB2, and sends
                                        % a copy of the event to Intan.

sma = AddState(sma,'Name','Location_P',...
    'Timer', S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',2}); % As above; BNC #2

sma = AddState(sma,'Name','Location_A',...
    'Timer', S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',3}); % As above; BNC #3

sma = AddState(sma,'Name','Location_AA',...
    'Timer', S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',4}); % As above; BNC #4

sma = AddState(sma,'Name','Nogo_Halfway',...
    'Timer', S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',5}); % As above; BNC #5

sma = AddState(sma,'Name','Go_Halfway',...
    'Timer', S.GUI.PreStimPeriod,...
    'StateChangeConditions',{'Tup','ResponseWindow'},...
    'OutputActions',{'WavePlayer1',5}); % As above; also BNC #5

sma = AddState(sma,'Name','ResponseWindow',...
    'Timer',S.GUI.RespPeriod,...
    'StateChangeConditions',{'Port1In',CurrentAction,'Tup','TimeOut'},...
    'OutputActions',{'Wire1',1,'BNC2',1}); % Response window out of wire #1
                                           % (to Intan) and BNC #2 (for
                                           % triggering the whisker camera)

sma = AddState(sma,'Name','Hit_PP',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % Rewarded response, and  
                                                % corresponding event out
                                                % of the State Machine 
                                                % (BNC #1) to Intan
                                                
sma = AddState(sma,'Name','Hit_P',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % As above

sma = AddState(sma,'Name','Hit_H',...
    'Timer',S.GUI.WaterValveTime,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{'ValveState',1,'BNC1',1}); % As above

sma = AddState(sma,'Name','FalseAlarm_H',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup','FalseAlarm_H_timeout'},...
    'OutputActions',{'BNC1',1,'PWM1',200}); % Onset of punishment time out
                                            % from BNC #1 of State Machine
                                            % to Intan, along with a
                                            % 0.1 s light cue
                                            
sma = AddState(sma,'Name','FalseAlarm_H_timeout',...
    'Timer',S.GUI.PunishmentPeriod-0.1,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_H_timeout'},...
    'OutputActions',{'BNC1',1}); % Remaining time out period

sma = AddState(sma,'Name','FalseAlarm_A',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup','FalseAlarm_A_timeout'},...
    'OutputActions',{'BNC1',1,'PWM1',200}); % As above

sma = AddState(sma,'Name','FalseAlarm_A_timeout',...
    'Timer',S.GUI.PunishmentPeriod-0.1,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_A_timeout'},...
    'OutputActions',{'BNC1',1}); % As above

sma = AddState(sma,'Name','FalseAlarm_AA',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup','FalseAlarm_AA_timeout'},...
    'OutputActions',{'BNC1',1,'PWM1',200}); % As above

sma = AddState(sma,'Name','FalseAlarm_AA_timeout',...
    'Timer',S.GUI.PunishmentPeriod-0.1,...
    'StateChangeConditions',{'Tup','exit','Port1In','FalseAlarm_AA_timeout'},...
    'OutputActions',{'BNC1',1}); % As above

sma = AddState(sma,'Name','TimeOut',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end



end