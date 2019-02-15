function BarrelPiezo

% Intermittently stimulates a whisker of the anesthetized mouse through
% piezoelectric vibration, assuming that the whisker is in a glass
% capillary. The aim is to "highlight" the corresponding somatosensory
% barrel using appropriate illumination, camera imaging, and skull
% transparency procedures (not described here).
%
%
%
% NECESSARY HARDWARE ______________________________________________________
% - Bpod State Machine combined with Bpod Analog Output Module (USB ports
%   COM10 and COM6, respectively): reads stimulation parameters, and sends
%   waveforms to the Dagan Biphasic Stimulus Isolator.
%
% - Dagan Biphasic Stimulus Isolator: vibrates the glass capillary based on
%   inputs from Bpod Analog Output Module, i.e., the waveforms to be
%   piezoelectrically converted.
%
%
%
% OPTIONAL HARDWARE _______________________________________________________
% - Barrel imaging camera (PhotonFocus MV1) and gigabit ethernet interface
%   card: not described here.
%
%
%
% STIMULATION PATTERN _____________________________________________________
% - Waveform -> Inter-stimulus interval (ISI) -> Waveform -> ... and so on.
% - Waveform: sinusoidal, 10 V amplitude (+/- 5 V), 20 Hz, 0.5 s duration
% - ISI     : 3.5 s
%
%
%
% USAGE ___________________________________________________________________
% Enter "Bpod" in the Command Window, and wait until the Bpod Console is
% ready. Then enter "BarrelPiezo", and check if the glass capillary
% vibrates. Stimulus-onset timestamps are sent out of Bpod, as well as 
% waveforms themselves. They are readable by Intan provided that cabling is
% set up correctly. Monitoring stimuli through Intan may be useful for
% video frame synchronization, especially if strobe TTLs from the barrel
% imaging camera are co-acquired.
%
% LSBuenoJr, with inputs from the Sanworks Support Forum __________________



%% Configures the Bpod Analog Output Module to send waveforms to both
% Dagan and Intan (adapted from MXDing's GoNogo_piezo).
global BpodSystem;

W = BpodWavePlayer('COM6');
W.TriggerMode = 'Normal';
W.TriggerProfileEnable = 'On';
W.TriggerProfiles(1,1:2) = 1:2; % BNC #1 sends +/- 5V waveforms to Dagan
                                % BNC #2 gives Intan-friendly waveforms
                                
DagVolt = 5;  % +/- to Dagan
Freq    = 20; % Hz
StimDur = 0.5;  % 1 sec stimulation        
                                
W.loadWaveform(1,DagVolt*sin(Freq*2*pi/W.SamplingRate:...
    Freq*2*pi/W.SamplingRate:Freq*2*pi*StimDur));   % to Dagan
W.loadWaveform(2,sin(Freq*2*pi/W.SamplingRate:...
    Freq*2*pi/W.SamplingRate:Freq*2*pi*StimDur)+1); % to Intan, which is
                                                    % limited to 3.3 V



%% Sets parameters.
S.SweepLength        = 4; % In seconds
S.NoAction           = 0;
S.PreStimPeriod      = 0;
S.StimWindow         = StimDur;
S.PostStimPeriod     = 2.5;



%% Main loop
StimType = cell(1);Action = cell(1);
for i = 1:1000 % Just an arbitrary number of stimuli

    StimType{i} = 'Piezo';
    Action{i}   = 'None';
    
    % Sets Bpod state matrix
    sma     = NewStateMatrix();
    sma     = BarrelPiezo_Matrix(sma,S,Action{i},StimType{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine; %#ok<NASGU>
    
    if BpodSystem.Status.BeingUsed == 0;return;end
end



%% Bpod conversation via state matrix
function sma = BarrelPiezo_Matrix(sma,S,CurrentAction,CurrentStimType)

LoadSerialMessages('WavePlayer1',{['P' 0]});

sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.SweepLength);

sma = AddState(sma,'Name','SweepStart',...
    'Timer',0.1,...
    'StateChangeConditions',{'Tup','PreStim'},...
    'OutputActions',{'GlobalTimerTrig',1});

sma = AddState(sma,'Name','PreStim',...
    'Timer',S.PreStimPeriod,...
    'StateChangeConditions',{'Tup',CurrentStimType},...
    'OutputActions',{'BNC1',1}); % Sweep onset TTL out of BNC #1. This can
                                 % be used to trigger the camera.

sma = AddState(sma,'Name','Piezo',...
    'Timer',S.StimWindow,...
    'StateChangeConditions',{'Tup','PostStim'},...
    'OutputActions',{'WavePlayer1',1}); % Analog Output Module waveforms

sma = AddState(sma,'Name','PostStim',...
    'Timer',S.PostStimPeriod,...
    'StateChangeConditions',{'Port1In',CurrentAction,'Tup','TimeOut'},...
    'OutputActions',{});

sma = AddState(sma,'Name','None',...
    'Timer',S.NoAction,...
    'StateChangeConditions',{'Tup','TimeOut'},...
    'OutputActions',{});

sma = AddState(sma,'Name','TimeOut',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end



end