function PulsePalControl_md
% load('ParameterMatrix1.mat');
% PulsePal;
%% Chirp stimulation (linear)
% MinFreq = 1;
% MaxFreq = 100;
% Duration = 10;
% SampleRate = 500; % ???
% MaxVoltage = 3; % ??
% ChirpVoltage = MaxVoltage * chirp([0:1/SampleRate:Duration],MinFreq,Duration,MaxFreq);
% SendCustomWaveform(1,1/SampleRate,ChirpVoltage(1:end-1));
% TriggerPulsePal(1);


%% ascending and descending steps
Phase1Duration = 0.300;
InterPhaseInterval = 2.000;
CycleTime = Phase1Duration + InterPhaseInterval;

Voltages = [0.5:0.25:1.5 1.25:-0.25:0.5];

PulseTimes = [0:CycleTime:((length(Voltages)-1)*CycleTime)];

SendCustomPulseTrain(1, PulseTimes, Voltages); 

ProgramPulsePalParam(1, 14, 1); % Sets output channel 1 to use custom train 1

ProgramPulsePalParam(1, 4, Phase1Duration); 
for i = 1:100
    TriggerPulsePal(1);
    pause(60);
end
end
