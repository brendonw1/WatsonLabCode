function PavlovianPiezo(Counterbalancing)

% Piezoelectric whisker stimulation of awake, head-fixed mouse. Two piezo
% frequencies (4 Hz and 10 Hz) are randomly presented, with or without
% water (the water-paired frequency can be counterbalanced across subjects
% depending on subsequent Go/No-go training). Water is delivered regardless
% of mouse responses for classical conditioning. This can be either a
% self-contained experiment or a pre-training step before operant
% Go/No-go discrimination.
%
%
%
% NECESSARY HARDWARE ______________________________________________________
% - Bpod State Machine combined with Bpod Analog Output Module: reads
%   stimulation parameters, sends waveforms to the Dagan Biphasic
%   Stimulus Isolator, and corresponding timestamps to Intan RHD2000.
%
% - Dagan Biphasic Stimulus Isolator: vibrates the glass capillary based on
%   inputs from Bpod Analog Output Module, i.e., the waveforms to be
%   piezoelectrically converted.
%
% - Intan RHD2000: acquires neural signals aligned with piezoelectric
%   waveforms.
%
%
%
% STIMULATION _____________________________________________________________
% - Piezo waveform -> Inter-stimulus interval (ISI) -> Piezo waveform -> ...
% - Piezo waveform: sinusoidal, 10 V amplitude (+/- 5 V), 1 s duration,
%   either 4 or 10 Hz.
%
%
%
% USAGE ___________________________________________________________________
% Step 1: Load RHD2000 interface, set channels, recording parameters, 
% save-to folder, etc.
%
% Step 2: Run Bpod then PavlovianPiezo.
%
% Inputs: Counterbalancing can be either 4 or 10 to define the "Go" piezo
% frequency (Hz) in subsequent training.
%
% LSBuenoJr _______________________________________________________________



%% Sets base path, asks user about saving a previous session (if present in
% the working directory).
global BpodSystem
basepath   = cd;

if ~isempty(BpodSystem.Data) || exist('SessionData.mat') %#ok<EXIST>
    prompt = 'Save previous session? (y/n)';
    prompt = input(prompt,'s');
    if strcmp(prompt,'y')
        SessionData = BpodSystem.Data;
        save(fullfile(basepath,...
            'PavlovPiezoPrevSession.mat'),'SessionData','-v6');
    end
    BpodSystem.Data = [];
end



%% Configures the Bpod Analog Output Module to send waveforms to Dagan.
W                        = BpodWavePlayer('COM6');
W.TriggerMode            = 'Normal';
W.TriggerProfileEnable   = 'On';
W.TriggerProfiles(1,1:8) = [zeros(1,7) 10]; % Out of BNC #8, both profiles
W.TriggerProfiles(2,1:8) = [zeros(1,7) 4];  % Out of BNC #8, both profiles
MaxMinVolt               = 5;  % +/- volts
StimDur                  = 1;  % stimulus duration in seconds

W.loadWaveform(10,MaxMinVolt*sin(10*2*pi/W.SamplingRate:...
    10*2*pi/W.SamplingRate:10*2*pi*StimDur)); % 10 Hz waveform to Dagan

W.loadWaveform(4,MaxMinVolt*sin(4*2*pi/W.SamplingRate:...
    4*2*pi/W.SamplingRate:4*2*pi*StimDur));   % 4 Hz waveform to Dagan



%% Sets parameters (e.g., stimulus durations, inter-trial intervals, etc.).
S.TrialLength         = 6; % In seconds
S.RewardAmount_mL     = 5; % In microliters
S.WaterValveTime      = GetValveTimes(S.RewardAmount_mL,1);
S.StimPeriod          = StimDur;



%% Randomizes the sequence of trials.
MaxSameTrial = 3; % Limits trial type repetition to three consecutive.
TrialSeq     = nan(1,995);
for i        = 1:length(TrialSeq)
    if i > MaxSameTrial
        if sum(TrialSeq((i-MaxSameTrial):(i-1))) == 0
            TrialSeq(i) = 1;
        elseif sum(TrialSeq((i-MaxSameTrial):(i-1))) == MaxSameTrial
            TrialSeq(i) = 0;
        else
            TrialSeq(i) = round(rand(1));
        end
    else
        TrialSeq(i)     = round(rand(1));
    end
end
TrialSeq(TrialSeq==1)   = 10;
TrialSeq(TrialSeq==0)   = 4;

switch Counterbalancing
    case 10
        TrialSeq  = [zeros(1,5)+10.1 TrialSeq+0.1]; % Pre-defines initial five
        SerialMsg = 1:2;
    case 4
        TrialSeq  = [zeros(1,5)+4 TrialSeq];        % Pre-defines initial five
        SerialMsg = 2:-1:1;
end

BpodSystem.Data.TrialSeq    = TrialSeq;
BpodSystem.Data.SessionData = nan(size(TrialSeq));



%% Stimulation loop
StimType = cell(1);Action = cell(1);
for i = 1:length(TrialSeq)

    % Displays trials on the command window and saves trial settings.
    if TrialSeq(i)     == 10.1
        str             = 'Water-paired 10 Hz piezo';
        StimType{i}     = 'WaterPaired_piezo';
        Action{i}       = 'WaterPaired_piezo_noAction';
    elseif TrialSeq(i) == 4.1
        str             = 'No-water 4 Hz piezo';
        StimType{i}     = 'NoWater_piezo';
        Action{i}       = 'NoWater_piezo_noAction';
    elseif TrialSeq(i) == 10
        str             = 'No-water 10 Hz piezo';
        StimType{i}     = 'NoWater_piezo';
        Action{i}       = 'NoWater_piezo_noAction';
    elseif TrialSeq(i) == 4
        str             = 'Water-paired 4 Hz piezo';
        StimType{i}     = 'WaterPaired_piezo';
        Action{i}       = 'WaterPaired_piezo_noAction';
    end
    
    disp(['Trial #' num2str(i) ', ' str])
    BpodSystem.Data.TrialSettings(i) = S;
    
    % Sets Bpod state matrix
    sma     = NewStateMatrix();
    sma     = PavlovianPiezo_Matrix(sma,S,Action{i},StimType{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine;
    
    % Allocates trials as states into the "BpodSystem.Data" structure.
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        BpodSystem.ProtocolSettings = S;
        
        % Saves trial outcomes and timestamps.
        SessionData = BpodSystem.Data;
        save(fullfile(basepath,'SessionData.mat'),'SessionData','-v6');
    end
    
    if BpodSystem.Status.BeingUsed == 0;return;end 
end



%% Bpod conversation via state matrix
function sma = PavlovianPiezo_Matrix(sma,S,~,CurrStim)

% Communicates the State Machine with the Analog Output Module.
LoadSerialMessages('WavePlayer1',{['P' 0],['P' 1]});

sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.TrialLength);

sma = AddState(sma,'Name','TrialStart',...
    'Timer',0,...
    'StateChangeConditions',{'Tup',CurrStim},...
    'OutputActions',{'GlobalTimerTrig',1});

sma = AddState(sma,'Name','WaterPaired_piezo',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','PavlovWater'},...
    'OutputActions',{'WavePlayer1',SerialMsg(1),'Wire1',1});

sma = AddState(sma,'Name','NoWater_piezo',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','TrialEnd'},...
    'OutputActions',{'WavePlayer1',SerialMsg(2),'Wire2',1});
                                                  
sma = AddState(sma,'Name','PavlovWater',...
    'Timer',S.WaterValveTime,...
    'StateChangeConditions',{'Tup','TrialEnd'},...
    'OutputActions',{'ValveState',1});
                                     
sma = AddState(sma,'Name','TrialEnd',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end

end