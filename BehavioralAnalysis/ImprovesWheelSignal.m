function output = ImprovesWheelSignal(data,f,varargin)

% output = ImprovesWheelSignal(data,f)
%
% Improves wheel running signal collected as voltage samples from the
% absolute encoder to Intan (Board ADC). Explanation: once the mouse
% completes forward or backward cycles on the running wheel, the voltage
% signal undergoes sudden drops or rises, respectively. This function is an
% attempt to correct them. The output should be a crescent stair-like curve,
% ready for downsampling and further analysis. 
%
% USAGE ___________________________________________________________________
% data -> vector with raw wheel data, i.e., a continuous voltage signal.
% Can be single- or double-precision.
%
% f -> Optional sampling frequency. If this is informed, the script shows
% a quality control figure in addition to the output vector.
%
% LSBuenoJr _______________________________________________________________

%% Defines boundaries between forward and backward wheel cycles.
FrwdCyclBounds = ([0 find(diff(data)<(100*std(diff(data)))*-1)])+1;
BkwdCyclBounds = ([0 find(diff(data)>(100*std(diff(data))))])+1;

%% Reorganizes data into segments (cells). Each segment is then leveled in
% relation to its preceding one.
% Forward turns
FrwdTurns = cell(1,length(FrwdCyclBounds));
for i     = 1:length(FrwdTurns)-1
    FrwdTurns{i} = ...
        data(FrwdCyclBounds(i):FrwdCyclBounds(i+1)-1);
end;FrwdTurns{length(FrwdTurns)} = ...
        data(FrwdCyclBounds(length(FrwdCyclBounds))+1:end);

for i = 2:length(FrwdTurns)
    FrwdTurns{i} = ...
        FrwdTurns{i}+max(FrwdTurns{i-1});
end;FrwdData = cell2mat(FrwdTurns);

% Backward turns
BkwdTurns = cell(1,length(BkwdCyclBounds));
for i = 1:length(BkwdTurns)-1
    BkwdTurns{i} = ...
        FrwdData(BkwdCyclBounds(i):BkwdCyclBounds(i+1)-1);
end;BkwdTurns{length(BkwdTurns)} = ...
        FrwdData(BkwdCyclBounds(length(BkwdCyclBounds))+1:end);

for i = 2:length(BkwdTurns)
    jump = BkwdTurns{i}(1)-max(BkwdTurns{i-1});
    BkwdTurns{i} = BkwdTurns{i}-jump;
end

%% Provides the output, and optionally a quality control figure
output = cell2mat(BkwdTurns);

if nargin > 1
    figure;plot(data);hold on;plot(output);xlim([1 length(data)])
    legend('Raw','Improved');ylabel('Wheel activity');xlabel('Time (min)')
    xticks(0:length(data)/5:length(data))
    xticklabels(0:round(((length(data)/f)/60)/5):round((length(data)/f)/60))
else
end
end