function BarrelPiezoCamera

% Piezoelectric whisker stimulation under anesthesia for intrinsic imaging
% of S1 barrels using high-power LED illumination, and skull transparency
% procedures.
%
%
%
% NECESSARY HARDWARE ______________________________________________________
% - Bpod State Machine combined with Bpod Analog Output Module: reads
%   stimulation parameters, sends waveforms to the Dagan Biphasic Stimulus
%   Isolator, and triggers the Photon Focus Camera.
%
% - Dagan Biphasic Stimulus Isolator: vibrates the glass capillary based on
%   inputs from Bpod Analog Output Module, i.e., the waveforms to be
%   piezoelectrically converted.
%
% - Photon Focus Camera (MV1-D1024E-80-G2-12) and lenses: acquires images
%   from above the mouse head in response to triggers from Bpod State
%   Machine (via BNC). Must be connected to a properly
%   configured network adapter, via ethernet (for guidelines, see
%   http://www.photonfocus.com/fileadmin/web/manuals/MAN063_e_V1_0_MV1_D1024E_G2.pdf).
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
% Step 1: Connect the PF_GEVPlayer to the camera; in Device Control, set
% imaging parameters (e.g., ROI, exposure, black level, gain), turn on the
% Trigger Mode, and set Burst Trigger methods (40 frames at 10 Hz,
% alternating between piezo stimulation and inter-stimulus interval).
%
% Step 2: Still in the PF_GEVPlayer, set the folder to store frames
% (Tools -> Save Images...).
%
% Step 3: Run Bpod then BarrelPiezoCamera to start triggering both the
% camera and the piezo stimuli.
%
% Step 4: Run BarrelAveraging for analysis.
%
% LSBuenoJr _______________________________________________________________



%% Configures the Bpod Analog Output Module to send waveforms to Dagan
% (adapted from MXDing's GoNogo_piezo).
global BpodSystem;

W = BpodWavePlayer('COM6');
W.TriggerMode = 'Normal';
W.TriggerProfileEnable = 'On';
W.TriggerProfiles(1,1:8) = [zeros(1,7) 1]; % Out of BNC #8 (separate from
                                           % PoleLocation trigger profiles)

MaxMinVolt = 5;   % +/- volts
Freq       = 10;  % Hz
StimDur    = 4;   % 4 sec stimulation        
                                
W.loadWaveform(1,MaxMinVolt*sin(Freq*2*pi/W.SamplingRate:...
    Freq*2*pi/W.SamplingRate:Freq*2*pi*StimDur));



%% Sets Bpod parameters
numSweeps        = 20;
S.SweepLength    = 16;      % In seconds
S.StimPeriod     = StimDur; % See section above
S.RecoveryPeriod = 7;



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
    'StateChangeConditions',{'Tup','PreTriggerISI'},...
    'OutputActions',{'BNC2',1,'WavePlayer1',1}); % Triggers camera from
                                                 % BNC #2 of State Machine,
                                                 % and piezo from BNC #8 of
                                                 % the Analog Output Module

sma = AddState(sma,'Name','PreTriggerISI',...
    'Timer',S.RecoveryPeriod,...
    'StateChangeConditions',{'Tup','ISItrigger'},...
    'OutputActions',{});

sma = AddState(sma,'Name','ISItrigger',...
    'Timer',1,...
    'StateChangeConditions',{'Tup','SweepEnd'},...
    'OutputActions',{'BNC2',1});                 % Triggers camera from
                                                 % BNC #2 of State Machine
                                                 % (inter-stimulus frames)

sma = AddState(sma,'Name','SweepEnd',...
    'Timer',10,...
    'StateChangeConditions',{'GlobalTimer1_End','exit'},...
    'OutputActions',{});
end

end