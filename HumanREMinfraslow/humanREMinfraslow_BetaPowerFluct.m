function [BetaPowerFluctOutput,Params] = humanREMinfraslow_BetaPowerFluct(RawREMepoch,SamplRateHz,varargin)
%
% [BetaPowerFluctOutput,Params] = humanREMinfraslow_BetaPowerFluct(RawREMepoch,SamplRateHz)
%
% Calculates wavelet spectrogram and temporally smoothed beta power
% fluctuations from a single EEG channel or montage. Unlike another
% function (humanREMinfraslow_ZscSpectrBeta),  this method retains the
% original sampling rate, making it suitable for analyzing infraslow
% periodicity within REM episodes, after resolving sleep architecture.
%
% [BetaPowerFluctOutput,Params] = humanREMinfraslow_BetaPowerFluct(RawREMepoch,SamplRateHz,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   RawREMepoch
%     Numeric vector containing EEG channel or montage from a REM episode.
%     Data can be imported using edfread. User is responsible for REM
%     epoching and artifact/noise removal before calling this function.
%
%   SamplRateHz
%     Sampling rate in Hz.
%
% NAME-VALUE ARGUMENTS:
%   'BetaBandLimHz'      Two-element vector specifying lower and upper
%                        beta-band limits in Hz.
%                        Default: [15 30]
%
%   'FreqBinSizeHz'      Spacing between wavelet frequencies in Hz.
%                        Default: 1
%
%   'NumCycles'          Number of cycles in each Morlet wavelet.
%                        Default: 40
%
%   'RateMovMeanSec'     Moving-average and Gaussian-smoothing window
%                        duration in seconds.
%                        Default: 30
%
% OUTPUTS:
%   OutputData
%     Table containing:
%       beta_power       Vector containing summed and temporally
%                        smoothed beta-band wavelet magnitudes.
%
%   Params
%       Optional structure containing the parameters used.
%
% DEPENDENCIES:
%   MorletWavelet and FConv from buzcode:
%   https://github.com/buzsakilab/buzcode
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

addParameter(p,'WaveletBetaBandLimHz',[15 30],@isnumeric);
addParameter(p,'WaveletFreqBinSizeHz',1,@isnumeric);
addParameter(p,'WaveletNumCycles',40,@isnumeric);
addParameter(p,'WaveletMovMeanSec',30,@isnumeric);

parse(p,varargin{:})

WaveletBetaBandLimHz = p.Results.WaveletBetaBandLimHz;
WaveletFreqBinSizeHz = p.Results.WaveletFreqBinSizeHz;
WaveletNumCycles     = p.Results.NumCycles;
WaveletMovMeanSec    = p.Results.WaveletMovMeanSec;

WaveletMovMeanSampl = round(WaveletMovMeanSec*SamplRateHz);

WaveletFreqList = ...
    (WaveletBetaBandLimHz(1):WaveletFreqBinSizeHz:WaveletBetaBandLimHz(2))';



%% Convert raw signal to column vector if necessary, and make sure it is 
% double precision.
if size(RawREMepoch,2)>size(RawREMepoch,1)
    RawREMepoch = RawREMepoch';
end

RawREMepoch = double(RawREMepoch);



%% Calculate wavelet spectrogram
WavelSpectr = zeros(length(WaveletFreqList),length(RawREMepoch));

for FreqIdx = 1:length(WaveletFreqList)

    TempWavel = MorletWavelet(WaveletFreqList(FreqIdx),WaveletNumCycles,1/SamplRateHz);

    WavelSpectr(FreqIdx,:) = FConv(TempWavel',RawREMepoch);
end

WavelSpectr = abs(WavelSpectr);



%% Calculate beta power by summing wavelet magnitudes across frequencies
BetaPower = sum(WavelSpectr,1);



%% Temporally smooth beta power fluctuations
BetaPower = movmean(BetaPower,WaveletMovMeanSampl);

BetaPower = smoothdata(BetaPower,'gaussian',WaveletMovMeanSampl)';



%% Output table, can be combined with outputs from other functions
BetaPowerFluctOutput = cell2table({BetaPower},'VariableNames',{'beta_power'});



%% Parameters used, optionally returned for traceability
Params.SamplRateHz          = SamplRateHz;
Params.WaveletBetaBandLimHz = WaveletBetaBandLimHz;
Params.WaveletFreqBinSizeHz = WaveletFreqBinSizeHz;
Params.WaveletFreqList      = WaveletFreqList;
Params.WaveletNumCycles     = WaveletNumCycles;
Params.WaveletMovMeanSec    = WaveletMovMeanSec;
Params.WaveletMovMeanSampl  = WaveletMovMeanSampl;

end