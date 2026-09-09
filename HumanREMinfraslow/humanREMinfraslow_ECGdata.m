function [ECGdataOutputs,Params] = humanREMinfraslow_ECGdata(RawECG,SamplRateHz,varargin)
%
% [ECGdataOutputs,Params] = humanREMinfraslow_ECGdata(RawECG,SamplRateHz)
%
% Detects heartbeat peaks and calculates a continuous, temporally smoothed
% estimate of cardiac rate from ECG channel. These estimates may feature
% infraslow fluctuations, which can be quantified using other functions.
%
% [ECGdataOutputs,Params] = humanREMinfraslow_ECGdata(RawECG,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   RawECG
%     Numeric vector containing ECG signal samples. Data can be imported
%     using edfread. User is responsible for artifact/noise removal before
%     calling this function.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'ECGminPeakProminence'
%                          Minimum prominence required for heartbeats.
%                          Default: 300
%
%   'ECGminPeakDistanceSec'
%                          Minimum distance between heartbeats, in
%                          seconds.
%                          Default: 0.5
%
%   'ECGpeakBinSizeSec'
%                          Bin duration used to count heartbeats, in
%                          seconds.
%                          Default: 1
%
%   'ECGrateMovMeanSec'
%                          Moving-average and Gaussian-smoothing window
%                          applied to heart-rate time series, in seconds.
%                          Default: 30
%
%   'ECGsignFlip'
%                          Logical scalar specifying whether to invert the
%                          ECG signal before peak detection. This allows
%                          downward cardiac deflections to be detected as
%                          peaks when appropriate. Visual inspection of the
%                          raw signal may help inform this decision.
%                          Default: false
%
% OUTPUTS:
%   ECGdataOutputs
%     Table containing:
%       heart_beats
%           Vector containing the ECG signal. The signal is inverted when
%           ECGsignFlip is true.
%
%       beat_peaks_XY
%           Two-column matrix containing detected cardiac peaks. The first
%           column contains sample indices relative to RawECG, and the
%           second column contains peak amplitudes.
%
%       heart_rate
%           Sample-aligned vector containing the interpolated and
%           temporally smoothed cardiac rate signal. Use this for
%           infraslow periodicity analysis using other functions.
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

LogicalScalar = @(x) islogical(x) && isscalar(x);

addParameter(p,'ECGminPeakProminence',300,NonnegativeScalar);
addParameter(p,'ECGminPeakDistanceSec',0.5,PositiveScalar);
addParameter(p,'ECGpeakBinSizeSec',1,PositiveScalar);
addParameter(p,'ECGrateMovMeanSec',30,PositiveScalar);
addParameter(p,'ECGsignFlip',false,LogicalScalar);

parse(p,varargin{:})

ECGminPeakProminence  = p.Results.ECGminPeakProminence;
ECGminPeakDistanceSec = p.Results.ECGminPeakDistanceSec;
ECGpeakBinSizeSec     = p.Results.ECGpeakBinSizeSec;
ECGrateMovMeanSec     = p.Results.ECGrateMovMeanSec;
ECGsignFlip           = p.Results.ECGsignFlip;

if ~PositiveScalar(SamplRateHz)
    error('SamplRateHz must be a positive numeric scalar.')
end

ECGminPeakDistanceSampl = max(1,round(...
    ECGminPeakDistanceSec*SamplRateHz));

ECGpeakBinSizeSampl = max(1,round(...
    ECGpeakBinSizeSec*SamplRateHz));

ECGrateMovMeanSampl = max(1,round(...
    ECGrateMovMeanSec*SamplRateHz));



%% Convert raw signal to column vector if necessary, and make sure it is
% double precision.
if ~isnumeric(RawECG) || ~isvector(RawECG) || isempty(RawECG)
    error('RawECG must be a nonempty numeric vector.')
end

if size(RawECG,2)>size(RawECG,1)
    RawECG = RawECG';
end

RawECG = double(RawECG);

NumSamples = size(RawECG,1);



%% Invert ECG signal if requested
% This option allows downward cardiac deflections to be detected as peaks
% when inverted signal polarity is preferable depending on the ECG signal.
if ECGsignFlip
    RawECG = RawECG*-1;
end



%% Detect cardiac peaks
[HeartPeak_Y,HeartPeak_X] = findpeaks(...
    RawECG,...
    'MinPeakProminence',ECGminPeakProminence,...
    'MinPeakDistance',ECGminPeakDistanceSampl);



%% Count cardiac peaks within consecutive time bins
HeartPeakBinEdges = 0:ECGpeakBinSizeSampl:NumSamples;

if HeartPeakBinEdges(end)<NumSamples
    HeartPeakBinEdges(end+1) = NumSamples;
end

BinnedHeartPeaks = histcounts(...
    HeartPeak_X,HeartPeakBinEdges)';



%% Interpolate binned heartbeat counts to the original signal length
if length(BinnedHeartPeaks)==1

    HeartRate = repmat(BinnedHeartPeaks,NumSamples,1);

else

    HeartRate = interp1(...
        (1:length(BinnedHeartPeaks))',...
        BinnedHeartPeaks,...
        linspace(1,length(BinnedHeartPeaks),NumSamples))';
end



%% Temporally smooth heart rate
HeartRate = movmean(HeartRate,ECGrateMovMeanSampl);

HeartRate = smoothdata(...
    HeartRate,'gaussian',ECGrateMovMeanSampl);



%% Output table, can be combined with outputs from other functions
ECGdataOutputs = cell2table(...
    [{RawECG} {[HeartPeak_X HeartPeak_Y]} {HeartRate}],...
    'VariableNames',{'heart_beats','beat_peaks_XY','heart_rate'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz                = SamplRateHz;
Params.ECGminPeakProminence       = ECGminPeakProminence;
Params.ECGminPeakDistanceSec      = ECGminPeakDistanceSec;
Params.ECGminPeakDistanceSampl    = ECGminPeakDistanceSampl;
Params.ECGpeakBinSizeSec          = ECGpeakBinSizeSec;
Params.ECGpeakBinSizeSampl        = ECGpeakBinSizeSampl;
Params.ECGrateMovMeanSec          = ECGrateMovMeanSec;
Params.ECGrateMovMeanSampl        = ECGrateMovMeanSampl;
Params.ECGsignFlip                = ECGsignFlip;

end