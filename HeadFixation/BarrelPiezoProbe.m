function BarrelPiezoProbe

% Piezoelectric whisker stimulation under anesthesia to evoke cortical
% laminar firing from S1 barrels (using linear-probe recordings).
%
%
%
% NECESSARY HARDWARE ______________________________________________________
% - Bpod State Machine combined with Bpod Analog Output Module: reads
%   stimulation parameters, sends waveforms to both the Dagan Biphasic
%   Stimulus Isolator, and Intan RHD2000.
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
% - Piezo waveform: sinusoidal, 10 V amplitude (+/- 5 V), 10 Hz, 4 s
%   duration.
%
%
%
% USAGE ___________________________________________________________________
% Step 1: Load RHD2000 interface, set channels, recording parameters, 
% save-to folder, etc.
%
% Step 2: Run Bpod then BarrelPiezoProbe.
%
% Step 3: Run RasterPiezo for analysis.
%
% LSBuenoJr _______________________________________________________________



%% Configures the Bpod Analog Output Module to send waveforms to Dagan
% (adapted from MXDing's GoNogo_piezo).
global BpodSystem;

W = BpodWavePlayer('COM6');
W.TriggerMode = 'Normal';
W.TriggerProfileEnable = 'On';
W.TriggerProfiles(1,1:8) = [zeros(1,6) 1 2]; % Out of BNCs #7 and #8
                                             % PoleLocation trigger profiles)

MaxMinVolt = 5;   % +/- volts
Freq       = 10;  % Hz
StimDur    = 4;   % 4 sec stimulation

W.loadWaveform(1,sin(Freq*2*pi/W.SamplingRate:Freq*2*pi/W.SamplingRate:...
    Freq*2*pi*StimDur)+1);                        % to Intan (3.3 V)
W.loadWaveform(2,MaxMinVolt*sin(Freq*2*pi/W.SamplingRate:...
    Freq*2*pi/W.SamplingRate:Freq*2*pi*StimDur)); % to Dagan (5 V)



%% Sets Bpod parameters
numSweeps        = 20;
S.SweepLength    = 8;       % In seconds
S.StimPeriod     = StimDur; % See section above



%% Stimulation loop
Stimulus = cell(1);Action = cell(1);
for i = 1:numSweeps

    Stimulus{i} = 'Piezo';
    Action{i}   = 'None';
    
    disp(['Piezo #' num2str(i)])
    
    % Sets Bpod state matrix
    sma     = NewStateMatrix();
    sma     = BarrelPiezo_Matrix(sma,S,Action{i},Stimulus{i});
    SendStateMachine(sma);
    RawEvents = RunStateMachine; %#ok<NASGU>
    
    if BpodSystem.Status.BeingUsed == 0;return;end 
end



%% Bpod conversation via state matrix
function sma = BarrelPiezo_Matrix(sma,S,~,CurrStim)

LoadSerialMessages('WavePlayer1',{['P' 0]});

sma = SetGlobalTimer(sma,...
    'TimerID',1,...
    'Duration',S.SweepLength);

sma = AddState(sma,'Name','SweepStart',...
    'Timer',0,...
    'StateChangeConditions',{'Tup',CurrStim},...
    'OutputActions',{'GlobalTimerTrig',1});

sma = AddState(sma,'Name','Piezo',...
    'Timer',S.StimPeriod,...
    'StateChangeConditions',{'Tup','SweepEnd'},...
    'OutputActions',{'BNC2',1,'WavePlayer1',1});
                                                % Stamps piezo stimuli with
                                                % square pulses from BNC #2
                                                % of State Machine, and
                                                % sends piezo waveforms
                                                % from the Analog Output
                                                % Module to Intan and Dagan.

sma = AddState(sma,'Name','SweepEnd',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end

end