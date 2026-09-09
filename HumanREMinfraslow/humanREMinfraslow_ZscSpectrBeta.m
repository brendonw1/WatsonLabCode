function [ZscSpectrBetaOutput,Params] = humanREMinfraslow_ZscSpectrBeta(RawEEG,SamplRateHz,varargin)
%
% [ZscSpectrBetaOutput,Params] = humanREMinfraslow_ZscSpectrBeta(RawEEG,SamplRateHz)
%
% Calculates temporally smoothed, Z-scored spectrogram and beta power
% fluctuations from a single EEG channel or montage. Unlike another
% function (humanREMinfraslow_BetaPowerFluct), this method processes
% overnight data at a lower temporal resolution to facilitate inspection of
% sleep architecture labels before quantifying individual REM episodes.
%
% [ZscSpectrBetaOutput,Params] = humanREMinfraslow_ZscSpectrBeta(RawEEG,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   RawEEG
%     Numeric vector containing EEG channel or montage. Data can be
%     imported using edfread. User is responsible for artifact/noise
%     removal before calling this function.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'SpectrWindowSec'    Spectrogram window duration in seconds.
%                        Default: 2
%
%   'SpectrFreqLimHz'    Two-element vector specifying lower and upper
%                        spectrogram frequency limits in Hz.
%                        Default: [2 51]
%
%   'FreqBinSizeHz'      Spacing between spectrogram frequencies in Hz.
%                        Default: 1
%
%   'TimeSmoothSec'      Temporal moving-average window in seconds. The
%                        requested duration is converted to the nearest
%                        integer number of spectrogram time bins.
%                        Default: 120
%
%   'BetaBandLimHz'      Two-element vector specifying lower and upper
%                        beta-band limits in Hz.
%                        Default: [15 30]
%
%   'BetaBandMarginHz'   Frequency margin added above and below the beta
%                        band during normalization. The margins are
%                        excluded from the final beta-band average.
%                        Default: 10
%
% OUTPUTS:
%   OutputData
%     Table containing:
%       Zscored_spectrogram   Frequency-by-time matrix containing the
%                             normalized and smoothed spectrogram.
%
%       beta_power            Vector containing the mean normalized
%                             beta-band magnitude.
%
%   Params
%       Optional structure containing the parameters used.
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

addParameter(p,'SpectrWindowSec',2,@isnumeric);
addParameter(p,'SpectrFreqLimHz',[2 51],@isnumeric);
addParameter(p,'SpectrFreqBinSizeHz',1,@isnumeric);
addParameter(p,'SpectrTimeSmoothSec',120,@isnumeric);
addParameter(p,'SpectrBetaBandLimHz',[15 30],@isnumeric);
addParameter(p,'SpectrBetaBandMarginHz',10,@isnumeric);

parse(p,varargin{:})

SpectrWindowSec        = p.Results.SpectrWindowSec;
SpectrFreqLimHz        = p.Results.SpectrFreqLimHz;
SpectrFreqBinSizeHz    = p.Results.SpectrFreqBinSizeHz;
SpectrTimeSmoothSec    = p.Results.SpectrTimeSmoothSec;
SpectrBetaBandLimHz    = p.Results.SpectrBetaBandLimHz;
SpectrBetaBandMarginHz = p.Results.SpectrBetaBandMarginHz;

SpectrWindowSampl = round(SpectrWindowSec*SamplRateHz);

SpectrFreqList = ...
    (SpectrFreqLimHz(1):SpectrFreqBinSizeHz:SpectrFreqLimHz(2))';



%% Convert raw signal to column vector if necessary, and make sure it is 
% double precision.
if size(RawEEG,2)>size(RawEEG,1)
    RawEEG = RawEEG';
end

RawEEG = double(RawEEG);



%% Calculate the spectrogram and obtain its time coordinates
[RawSpectr,~,SpectrTimeListSec] = spectrogram(...
    RawEEG,...
    SpectrWindowSampl,...
    [],...
    SpectrFreqList,...
    SamplRateHz);

RawSpectr = abs(RawSpectr);



%% Convert smoothing duration from seconds to spectrogram time bins.
% Use median time step to accommodate small floating-point differences
% between spectrogram time coordinates.
SpectrTimeStepSec = median(diff(SpectrTimeListSec));

SpectrTimeSmoothBins = max(1,round(SpectrTimeSmoothSec/SpectrTimeStepSec));

% Record the smoothing duration represented by the rounded number of bins.
SpectrActualTimeSmoothSec = SpectrTimeSmoothBins*SpectrTimeStepSec;



%% Convert beta-band limits and margins from Hz to frequency-bin indices
BetaMarginLimHz = [...
    SpectrBetaBandLimHz(1)-SpectrBetaBandMarginHz,...
    SpectrBetaBandLimHz(2)+SpectrBetaBandMarginHz];

% Select available frequency bins nearest to requested margin limits.
[~,BetaMarginStartIdx] = min(abs(...
    SpectrFreqList-BetaMarginLimHz(1)));

[~,BetaMarginEndIdx] = min(abs(...
    SpectrFreqList-BetaMarginLimHz(2)));

BetaMarginFreqList = SpectrFreqList(...
    BetaMarginStartIdx:BetaMarginEndIdx);

% Locate beta-band limits within margin-extended frequency range.
[~,BetaStartIdx] = min(abs(...
    BetaMarginFreqList-SpectrBetaBandLimHz(1)));

[~,BetaEndIdx] = min(abs(...
    BetaMarginFreqList-SpectrBetaBandLimHz(2)));



%% Normalize and temporally smooth the spectrogram. First, Z-score each
% time bin across frequencies. Next, Z-score each frequency bin across time.
% Finally, apply temporal smoothing.
ZscSpectr = movmean(zscore(zscore(RawSpectr),0,2),...
    SpectrTimeSmoothBins,2);

% Repeat using only the beta band and its surrounding frequency margins.
% The margins provide frequency context for the first Z-scoring step and
% are excluded from the beta-band average below.
ZscSpectrForBeta = movmean(zscore(zscore(RawSpectr(...
    BetaMarginStartIdx:BetaMarginEndIdx,:)),0,2),...
    SpectrTimeSmoothBins,2);



%% Average spectrogram values across the beta band
BetaPower = mean(ZscSpectrForBeta(BetaStartIdx:BetaEndIdx,:),1)';



%% Output table, can be combined with outputs from other functions
ZscSpectrBetaOutput = cell2table([{ZscSpectr} {BetaPower}],...
    'VariableNames',{'Zscored_spectrogram','beta_power'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz               = SamplRateHz;
Params.SpectrWindowSec           = SpectrWindowSec;
Params.SpectrFreqLimHz           = SpectrFreqLimHz;
Params.SpectrFreqBinSizeHz       = SpectrFreqBinSizeHz;
Params.SpectrFreqList            = SpectrFreqList;
Params.SpectrTimeListSec         = SpectrTimeListSec;
Params.SpectrTimeStepSec         = SpectrTimeStepSec;
Params.SpectrTimeSmoothSec       = SpectrTimeSmoothSec;
Params.SpectrTimeSmoothBins      = SpectrTimeSmoothBins;
Params.SpectrActualTimeSmoothSec = SpectrActualTimeSmoothSec;
Params.SpectrBetaBandLimHz       = SpectrBetaBandLimHz;
Params.SpectrBetaBandMarginHz    = SpectrBetaBandMarginHz;

end