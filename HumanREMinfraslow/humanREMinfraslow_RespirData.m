function [RespirDataOutputs,Params] = humanREMinfraslow_RespirData(RawRespir,SamplRateHz,varargin)
%
% [RespirDataOutputs,Params] = humanREMinfraslow_RespirData(RawRespir,SamplRateHz)
%
% Detects respiratory peaks and calculates a continuous, temporally
% smoothed estimate of respiratory rate from a single plethysmographic
% channel (e.g., abdomen or chest belt). These estimates may feature
% infraslow fluctuations, which can be quantified using other functions.
%
% [RespirDataOutputs,Params] = humanREMinfraslow_RespirData(RawRespir,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   RawRespir
%     Numeric vector containing respiratory signal samples. Data can be
%     imported using edfread. User is responsible for artifact/noise
%     removal before calling this function.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'RespirPreFindPeakMovMeanSec'
%                          Moving-average window applied before respiratory
%                          peak detection, in seconds. This is to suppress
%                          small noise before peak detection.
%                          Default: 0.1
%
%   'RespirMinPeakProminence'
%                          Minimum prominence required for respiratory
%                          peaks.
%                          Default: 100
%
%   'RespirMinPeakDistanceSec'
%                          Minimum distance between respiratory peaks, in
%                          seconds.
%                          Default: 1
%
%   'RespirPeakBinSizeSec'
%                          Bin duration used to count respiratory peaks, in
%                          seconds.
%                          Default: 1
%
%   'RespirRateMovMeanSec'
%                          Moving-average and Gaussian-smoothing window
%                          applied to respiratory-rate time series, in
%                          seconds.
%                          Default: 30
%
%   'RespirSignFlip'
%                          Logical scalar specifying whether to invert the
%                          respiratory signal before peak detection. This
%                          allows respiratory troughs to be detected as
%                          peaks when appropriate, depending on the
%                          participant. Vsual inspection of the raw
%                          signal may help inform inform this decision.
%                          Default: false
%
% OUTPUTS:
%   RespirDataOutputs
%     Table containing:
%       respir_cycles
%           Vector containing the respiratory signal. The signal is
%           inverted when RespirSignFlip is true.
%
%       respir_peaks_XY
%           Two-column matrix containing detected respiratory peaks. The
%           first column contains sample indices relative to RawRespir, and
%           the second column contains peak amplitudes.
%
%       respir_rate
%           Sample-aligned vector containing the interpolated and
%           temporally smoothed respiratory rate signal. Use this for
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

addParameter(p,'RespirPreFindPeakMovMeanSec',0.1,PositiveScalar);
addParameter(p,'RespirMinPeakProminence',100,NonnegativeScalar);
addParameter(p,'RespirMinPeakDistanceSec',1,PositiveScalar);
addParameter(p,'RespirPeakBinSizeSec',1,PositiveScalar);
addParameter(p,'RespirRateMovMeanSec',30,PositiveScalar);
addParameter(p,'RespirSignFlip',false,LogicalScalar);

parse(p,varargin{:})

RespirPreFindPeakMovMeanSec = p.Results.RespirPreFindPeakMovMeanSec;
RespirMinPeakProminence     = p.Results.RespirMinPeakProminence;
RespirMinPeakDistanceSec    = p.Results.RespirMinPeakDistanceSec;
RespirPeakBinSizeSec        = p.Results.RespirPeakBinSizeSec;
RespirRateMovMeanSec        = p.Results.RespirRateMovMeanSec;
RespirSignFlip              = p.Results.RespirSignFlip;

if ~PositiveScalar(SamplRateHz)
    error('SamplRateHz must be a positive numeric scalar.')
end

RespirPreFindPeakMovMeanSampl = max(1,round(...
    RespirPreFindPeakMovMeanSec*SamplRateHz));

RespirMinPeakDistanceSampl = max(1,round(...
    RespirMinPeakDistanceSec*SamplRateHz));

RespirPeakBinSizeSampl = max(1,round(...
    RespirPeakBinSizeSec*SamplRateHz));

RespirRateMovMeanSampl = max(1,round(...
    RespirRateMovMeanSec*SamplRateHz));



%% Convert raw signal to column vector if necessary, and make sure it is
% double precision.
if ~isnumeric(RawRespir) || ~isvector(RawRespir) || isempty(RawRespir)
    error('RawRespir must be a nonempty numeric vector.')
end

if size(RawRespir,2)>size(RawRespir,1)
    RawRespir = RawRespir';
end

RawRespir = double(RawRespir);

NumSamples = size(RawRespir,1);



%% Invert respiratory signal if requested
% This option allows respiratory troughs to be detected as peaks when the
% signal polarity or waveform shape makes trough detection preferable,
% e.g., in participants with secondary breathing movements acccompanying
% inspiratory peaks.
if RespirSignFlip
    RawRespir = RawRespir*-1;
end



%% Temporally smooth respiratory signal before peak detection
RespirForPeakDetection = movmean(...
    RawRespir,RespirPreFindPeakMovMeanSampl);



%% Detect respiratory peaks
[RespirPeak_Y,RespirPeak_X] = findpeaks(...
    RespirForPeakDetection,...
    'MinPeakProminence',RespirMinPeakProminence,...
    'MinPeakDistance',RespirMinPeakDistanceSampl);



%% Count respiratory peaks within consecutive time bins
RespirPeakBinEdges = 0:RespirPeakBinSizeSampl:NumSamples;

if RespirPeakBinEdges(end)<NumSamples
    RespirPeakBinEdges(end+1) = NumSamples;
end

BinnedRespirPeaks = histcounts(...
    RespirPeak_X,RespirPeakBinEdges)';



%% Interpolate binned respiratory peak counts to the original signal length
if length(BinnedRespirPeaks)==1

    RespirRate = repmat(BinnedRespirPeaks,NumSamples,1);

else

    RespirRate = interp1(...
        (1:length(BinnedRespirPeaks))',...
        BinnedRespirPeaks,...
        linspace(1,length(BinnedRespirPeaks),NumSamples))';
end



%% Temporally smooth respiratory rate
RespirRate = movmean(RespirRate,RespirRateMovMeanSampl);

RespirRate = smoothdata(...
    RespirRate,'gaussian',RespirRateMovMeanSampl);



%% Output table, can be combined with outputs from other functions
RespirDataOutputs = cell2table(...
    [{RawRespir} {[RespirPeak_X RespirPeak_Y]} {RespirRate}],...
    'VariableNames',{'respir_cycles','respir_peaks_XY','respir_rate'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz                      = SamplRateHz;
Params.RespirPreFindPeakMovMeanSec      = RespirPreFindPeakMovMeanSec;
Params.RespirPreFindPeakMovMeanSampl    = RespirPreFindPeakMovMeanSampl;
Params.RespirMinPeakProminence          = RespirMinPeakProminence;
Params.RespirMinPeakDistanceSec         = RespirMinPeakDistanceSec;
Params.RespirMinPeakDistanceSampl       = RespirMinPeakDistanceSampl;
Params.RespirPeakBinSizeSec             = RespirPeakBinSizeSec;
Params.RespirPeakBinSizeSampl           = RespirPeakBinSizeSampl;
Params.RespirRateMovMeanSec             = RespirRateMovMeanSec;
Params.RespirRateMovMeanSampl           = RespirRateMovMeanSampl;
Params.RespirSignFlip                   = RespirSignFlip;

end