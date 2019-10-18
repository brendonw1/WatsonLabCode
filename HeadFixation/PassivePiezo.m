function PassivePiezo

% Piezoelectric whisker stimulation of awake, head-fixed mouse. Passive
% stimuli (i.e., without a Go/No-go schedule) are delivered along with
% sham trials randomly.
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
% Step 2: Run Bpod then PassivePiezo.
%
% LSBuenoJr _______________________________________________________________



%% Configures the Bpod Analog Output Module to send waveforms to Dagan.
global BpodSystem
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



%% Sets Bpod parameters and the sequence of trials
S.SweepLength = 6;       % In seconds
S.StimPeriod  = StimDur; % See section above
TrialSeq      = randi([0 2],1,660);
TrialSeq(TrialSeq==2) = 10;TrialSeq(TrialSeq==1) = 4;



%% Stimulation loop
StimType = cell(1);Action = cell(1);
for i = 1:length(TrialSeq)

    % Displays trials on the command window and saves trial settings.
    if TrialSeq(i)     == 10
        str             = '10 Hz passive piezo';
        StimType{i}     = 'Piezo10Hz';
        Action{i}       = 'Piezo10Hz_noAction';
    elseif TrialSeq(i) == 4
        str             = '4 Hz passive piezo';
        StimType{i}     = 'Piezo4Hz';
        Action{i}       = 'Piezo4Hz_noAction';
    elseif TrialSeq(i) == 0
        str             = 'No stimulus (sham)';
        StimType{i}     = 'Sham';
        Action{i}       = 'Sham_noAction';
    end
    
    disp(['Trial #' num2str(i) ...
        ', ' str ' (' num2str(TrialSeq(i)) ')'])
    BpodSystem.Data.TrialSettings(i) = S;
    
    % Sets Bpod state matrix
    sma     = NewStateMatrix();
    sma     = PassivePiezo_Matrix(sma,S,Action{i},StimType{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine; %#ok<NASGU>
    
    if BpodSystem.Status.BeingUsed == 0;return;end 
end



%% Bpod conversation via state matrix
function sma = PassivePiezo_Matrix(sma,S,~,CurrStim)

LoadSerialMessages('WavePlayer1',{['P' 0],['P' 1]});

sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.SweepLength);

sma = AddState(sma,'Name','SweepStart',...
    'Timer',0,...
    'StateChangeConditions',{'Tup',CurrStim},...
    'OutputActions',{'GlobalTimerTrig',1});

sma = AddState(sma,'Name','Piezo10Hz',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','SweepEnd'},...
    'OutputActions',{'WavePlayer1',1,'Wire1',1}); % Waveform to Dagan,
                                                  % piezo timestamp to Intan
                                                  
sma = AddState(sma,'Name','Piezo4Hz',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','SweepEnd'},...
    'OutputActions',{'WavePlayer1',2,'Wire2',1}); % "

sma = AddState(sma,'Name','Sham',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','SweepEnd'},...
    'OutputActions',{'Wire3',1}); % Sham timestamp to Intan
                                     
sma = AddState(sma,'Name','SweepEnd',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end

end