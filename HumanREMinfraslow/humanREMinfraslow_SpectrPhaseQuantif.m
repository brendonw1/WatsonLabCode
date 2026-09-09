function [InfraslowOutputs,Params] = humanREMinfraslow_SpectrPhaseQuantif(InSignal,InTstamps,SamplRateHz,varargin)
%
% [InfraslowOutputs,Params] = humanREMinfraslow_SpectrPhaseQuantif(InSignal,InTstamps,SamplRateHz)
%
% Detrends and Z-scores a physiological time series (e.g., respiratory rate
% fluctuations), calculates its infraslow power spectral density as well as
% phase for circular statistics, and extracts phase values at user-specified
% timestamps (e.g., rapid eye movements). This function can be applied to
% respiratory rate, cardiac rate, beta power, etc.
%
% [InfraslowOutputs,Params] = humanREMinfraslow_SpectrPhaseQuantif(InSignal,InTstamps,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   InSignal
%     Numeric vector containing a continuous physiological time series.
%     The signal should represent a single REM episode or another interval
%     of interest. User is responsible for epoching and artifact/noise
%     removal before calling this function.
%
%   InTstamps
%     Numeric vector containing sample indices at which infraslow phase
%     values will be extracted, e.g., eye-movement peak indices. Indices
%     must be positive integers aligned with InSignal. An empty vector can
%     be provided when timestamp-specific phase values are not required.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'InfraslowFreqLimHz'
%                          Two-element vector specifying lower and upper
%                          frequency limits for power spectral density
%                          estimation, in Hz.
%                          Default: [0 0.05]
%
%   'InfraslowFreqBinSizeHz'
%                          Spacing between frequencies used for power
%                          spectral density estimation, in Hz.
%                          Default: 0.00005
%
%   'InfraslowPwelchWindowMin'
%                          Welch window duration in minutes. If the
%                          requested window exceeds the signal duration,
%                          the full signal length is used.
%                          Default: 10
%
%   'InfraslowDetrendMovMeanMin'
%                          Moving-average window used to estimate and
%                          subtract the slow baseline, in minutes.
%                          Default: 5
%
% OUTPUTS:
%   InfraslowOutputs
%     Table containing:
%       detrended_signal
%           Sample-aligned vector after subtraction of the moving-average
%           baseline.
%
%       zscored_signal
%           Sample-aligned vector containing the detrended signal Z-scored
%           within the input interval.
%
%       infraslow_PSD
%           Power spectral density of the detrended, Z-scored signal.
%
%       infraslow_phase
%           Sample-aligned Hilbert phase of the detrended, Z-scored signal,
%           expressed from 0 to 2*pi radians.
%
%       timestamp_phase_preference
%           Infraslow phase values at the sample indices provided in
%           InTstamps.
%
%       PSD_frequency_axis
%           Frequency values in Hz corresponding to infraslow_PSD.
%
%   Params
%     Optional structure containing the parameters used.
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

PositiveScalar = @(x) isnumeric(x) && isscalar(x) &&...
    isreal(x) && isfinite(x) && x>0;

FrequencyLimits = @(x) isnumeric(x) && isvector(x) &&...
    numel(x)==2 && all(isreal(x)) && all(isfinite(x)) &&...
    x(1)>=0 && x(1)<x(2);

addParameter(p,'InfraslowFreqLimHz',[0 0.05],FrequencyLimits);
addParameter(p,'InfraslowFreqBinSizeHz',0.00005,PositiveScalar);
addParameter(p,'InfraslowPwelchWindowMin',10,PositiveScalar);
addParameter(p,'InfraslowDetrendMovMeanMin',5,PositiveScalar);

parse(p,varargin{:})

InfraslowFreqLimHz         = p.Results.InfraslowFreqLimHz;
InfraslowFreqBinSizeHz     = p.Results.InfraslowFreqBinSizeHz;
InfraslowPwelchWindowMin   = p.Results.InfraslowPwelchWindowMin;
InfraslowDetrendMovMeanMin = p.Results.InfraslowDetrendMovMeanMin;

if ~PositiveScalar(SamplRateHz)
    error('SamplRateHz must be a positive numeric scalar.')
end

if InfraslowFreqLimHz(2)>=SamplRateHz/2
    error(['The upper value in InfraslowFreqLimHz must be lower than ',...
        'the Nyquist frequency.'])
end

InfraslowDetrendMovMeanSampl = max(1,round(...
    InfraslowDetrendMovMeanMin*60*SamplRateHz));

RequestedPwelchWindowSampl = max(1,floor(...
    InfraslowPwelchWindowMin*60*SamplRateHz));

InfraslowFreqList = (...
    InfraslowFreqLimHz(1)+InfraslowFreqBinSizeHz:...
    InfraslowFreqBinSizeHz:InfraslowFreqLimHz(2))';



%% Convert input signal to column vector if necessary, and make sure it is
% double precision.
if ~isnumeric(InSignal) || ~isvector(InSignal) || isempty(InSignal)
    error('InSignal must be a nonempty numeric vector.')
end

if size(InSignal,2)>size(InSignal,1)
    InSignal = InSignal';
end

InSignal = double(InSignal);

if any(~isfinite(InSignal))
    error('InSignal must contain only finite numeric values.')
end

NumSamples = size(InSignal,1);

InfraslowPwelchWindowSampl = min(...
    RequestedPwelchWindowSampl,NumSamples);

InfraslowActualPwelchWindowMin = ...
    InfraslowPwelchWindowSampl/(60*SamplRateHz);



%% Orient and validate input timestamps
if ~isnumeric(InTstamps) || ~(isvector(InTstamps) || isempty(InTstamps))
    error('InTstamps must be a numeric vector or an empty vector.')
end

InTstamps = InTstamps(:);

if any(~isfinite(InTstamps)) || any(InTstamps~=round(InTstamps)) ||...
        any(InTstamps<1) || any(InTstamps>NumSamples)
    error(['InTstamps must contain positive integer sample indices ',...
        'within the bounds of InSignal.'])
end



%% Detrend signal by subtracting its moving-average baseline
DetrSignal = InSignal-movmean(InSignal,InfraslowDetrendMovMeanSampl);



%% Z-score detrended signal within the input interval
ZscSignal = zscore(DetrSignal);



%% Calculate infraslow power spectral density
InfraslowPSD = pwelch(...
    ZscSignal,...
    InfraslowPwelchWindowSampl,...
    [],...
    InfraslowFreqList,...
    SamplRateHz);



%% Calculate infraslow phase
InfraslowPhase = mod(angle(hilbert(ZscSignal)),2*pi);



%% Extract infraslow phase values at input timestamps
TimestampPhasePreference = InfraslowPhase(InTstamps);



%% Output table, can be combined with outputs from other functions
InfraslowOutputs = cell2table(...
    [{DetrSignal} {ZscSignal} {InfraslowPSD} {InfraslowPhase}...
    {TimestampPhasePreference} {InfraslowFreqList}],...
    'VariableNames',{'detrended_signal','zscored_signal',...
    'infraslow_PSD','infraslow_phase',...
    'timestamp_phase_preference','PSD_frequency_axis'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz                       = SamplRateHz;
Params.InfraslowFreqLimHz                = InfraslowFreqLimHz;
Params.InfraslowFreqBinSizeHz            = InfraslowFreqBinSizeHz;
Params.InfraslowFreqList                 = InfraslowFreqList;
Params.InfraslowPwelchWindowMin          = InfraslowPwelchWindowMin;
Params.InfraslowPwelchWindowSampl        = InfraslowPwelchWindowSampl;
Params.InfraslowActualPwelchWindowMin    = InfraslowActualPwelchWindowMin;
Params.InfraslowDetrendMovMeanMin        = InfraslowDetrendMovMeanMin;
Params.InfraslowDetrendMovMeanSampl      = InfraslowDetrendMovMeanSampl;

end