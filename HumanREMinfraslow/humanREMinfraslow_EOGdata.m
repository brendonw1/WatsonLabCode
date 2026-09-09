function [EOGdataOutputs,Params] = humanREMinfraslow_EOGdata(RawEOG,EligibleSamples,SamplRateHz,varargin)
%
% [EOGdataOutputs,Params] = humanREMinfraslow_EOGdata(RawEOG,EligibleSamples,SamplRateHz)
%
% Calculates the absolute difference between two EOG channels and detects
% eye-movement peaks within user-specified states. To restrict detection to
% REM sleep, EligibleSamples should be true during REM and false during
% WAKE and NREM.
%
% [EOGdataOutputs,Params] = humanREMinfraslow_EOGdata(RawEOG,EligibleSamples,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   RawEOG
%     EOG samples in rows, left-right EOG channels in two columns. Data
%     can be imported using edfread. User is responsible for artifact/noise
%     removal before calling this function.
%
%   EligibleSamples
%     Logical vector containing one element for each sample in RawEOG. True
%     values identify samples eligible for eye-movement detection, e.g.,
%     those during REM, and false values identify samples to exclude, e.g.,
%     WAKE and NREM. The user is responsible for generating this logical
%     vector and aligning it with RawEOG.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'EOGhighPassHz'          High-pass filter cutoff frequency in Hz.
%                            Default: 0.05
%
%   'EOGSmoothSec'           Moving-average window duration in seconds.
%                            Default: 1
%
%   'EOGminPeakProminence'   Minimum prominence required for eye-movement
%                            peaks.
%                            Default: 100
%
% OUTPUTS:
%   EOGdataOutputs
%     Table containing:
%       left_right_difference
%           Vector containing high-pass-filtered, absolute
%           difference between the two EOG channels.
%
%       EOG_peaks_XY
%           Two-column matrix containing detected eye movements. The first
%           column contains sample indices relative to RawEOG, and the
%           second column contains peak amplitudes. Only peaks occurring
%           where EligibleSamples is true are included.
%
%   Params
%     Optional structure containing the parameters used.
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

PositiveScalar = @(x) isnumeric(x) && isscalar(x) &&...
    isreal(x) && isfinite(x) && x>0;

NonnegativeScalar = @(x) isnumeric(x) && isscalar(x) &&...
    isreal(x) && isfinite(x) && x>=0;

addParameter(p,'EOGhighPassHz',0.05,PositiveScalar);
addParameter(p,'EOGSmoothSec',1,PositiveScalar);
addParameter(p,'EOGminPeakProminence',100,NonnegativeScalar);

parse(p,varargin{:})

EOGhighPassHz        = p.Results.EOGhighPassHz;
EOGSmoothSec         = p.Results.EOGSmoothSec;
EOGminPeakProminence = p.Results.EOGminPeakProminence;

if ~PositiveScalar(SamplRateHz)
    error('SamplRateHz must be a positive numeric scalar.')
end

if EOGhighPassHz>=SamplRateHz/2
    error('EOGhighPassHz must be lower than the Nyquist frequency.')
end

EOGSmoothSampl = max(1,round(EOGSmoothSec*SamplRateHz));



%% Convert raw signals to sample-by-channel format and double precision
if ~isnumeric(RawEOG) || ~ismatrix(RawEOG)
    error('RawEOG must be a numeric two-dimensional matrix.')
end

if size(RawEOG,2)>size(RawEOG,1)
    RawEOG = RawEOG';
end

if size(RawEOG,2)~=2
    error('RawEOG must contain exactly two EOG channels.')
end

RawEOG = double(RawEOG);



%% Orient and validate the eligible-sample logical vector
if ~islogical(EligibleSamples) || ~isvector(EligibleSamples)
    error('EligibleSamples must be a logical vector.')
end

EligibleSamples = EligibleSamples(:);

if numel(EligibleSamples)~=size(RawEOG,1)
    error(['EligibleSamples must contain one logical value for each ',...
        'sample in RawEOG.'])
end



%% High-pass filter and temporally smooth both EOG channels
[b,a] = butter(2,EOGhighPassHz/(SamplRateHz/2),'high');

FiltEOG = filtfilt(b,a,RawEOG);
FiltEOG = movmean(FiltEOG,EOGSmoothSampl);



%% Calculate absolute difference between EOG channels
ProcEOG = abs(diff(FiltEOG,1,2));



%% Identify contiguous intervals eligible for eye-movement detection
% Peak detection is performed separately within each contiguous interval
% where EligibleSamples is true.
StateTransitions = diff([false; EligibleSamples; false]);

EligibleStartIdx = find(StateTransitions==1);
EligibleEndIdx   = find(StateTransitions==-1)-1;



%% Detect eye-movement peaks only within eligible intervals (e.g., REM)
EOGpeak_X = zeros(0,1);
EOGpeak_Y = zeros(0,1);

for IntIdx = 1:length(EligibleStartIdx)

    TempStartIdx = EligibleStartIdx(IntIdx);
    TempEndIdx   = EligibleEndIdx(IntIdx);
    TempEOG      = ProcEOG(TempStartIdx:TempEndIdx);

    if length(TempEOG)<3
        continue
    end

    [TempPeakY,TempPeakX] = findpeaks(TempEOG,...
        'MinPeakProminence',EOGminPeakProminence);

    EOGpeak_X = [EOGpeak_X; TempPeakX+TempStartIdx-1];
    EOGpeak_Y = [EOGpeak_Y; TempPeakY];
end



%% Output table, can be combined with outputs from other functions
EOGdataOutputs = cell2table(...
    [{ProcEOG} {[EOGpeak_X EOGpeak_Y]}],...
    'VariableNames',{'left_right_difference','EOG_peaks_XY'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz          = SamplRateHz;
Params.EOGhighPassHz        = EOGhighPassHz;
Params.EOGSmoothSec         = EOGSmoothSec;
Params.EOGSmoothSampl       = EOGSmoothSampl;
Params.EOGminPeakProminence = EOGminPeakProminence;

end