function ThetaData = REM_ThetaFreqAndPower(ThetaSpectr,Params,varargin)
%
% ThetaData = REM_ThetaFreqAndPower(ThetaSpectr,Params,varargin)
%
% Theta frequency fluctuations (from spectrogram ridges) and
% theta power fluctuations (from averaged frequency bins).
%
% USAGE (recommended usage; see REM_WavelSpectr)
%   - ThetaSpectr: theta-band spectrogram
%                  (recommended 5-10 Hz, 0.05 Hz bins)
%   - Params: a structure
%       - .FreqList:  list of frequency bins
%       - .SamplFreq: scalar in Hz (e.g., 125)
%   - varargin: please see input parser section
%
% OUTPUT
%   - ThetaData: a structure
%       - .RidgeFreqs: ridges in frequency values.
%		               Rows: ridges. Columns: time samples.
%       - .RidgeIdx:   as above, but in frequency bin indices
%       - .RidgeVar:   ridge variance, all dimensions
%       - .MeanPower:  band power (average across frequency bins)
%
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

% tfridge parameters
addParameter(p,'RidgePenalty',1,@isnumeric)
addParameter(p,'NumRidges',10,@isnumeric)
addParameter(p,'NumBins',1,@isnumeric)
% Smoothing parameter
addParameter(p,'TimeSmoothSec',5,@isnumeric) % s

parse(p,varargin{:})
RidgePenalty  = p.Results.RidgePenalty;
NumRidges     = p.Results.NumRidges;
NumBins       = p.Results.NumBins;
TimeSmoothSec = p.Results.TimeSmoothSec;



%% Required inputs. Throw error messages if parameters are lacking.
FreqList  = Params.FreqList;
SamplFreq = Params.SamplFreq;



%% Time-frequency ridge
[RidgeFreqs,RidgeIdx] = tfridge(ThetaSpectr,FreqList,RidgePenalty,...
    'NumRidges',NumRidges,'NumFrequencyBins',NumBins);
RidgeFreqs = smoothdata(RidgeFreqs,...
    1,'gaussian',SamplFreq*TimeSmoothSec)';
RidgeIdx   = smoothdata(RidgeIdx,...
    1,'gaussian',SamplFreq*TimeSmoothSec)';
RidgeVar   = var(RidgeFreqs,0,'all');



%% Theta power
MeanPower = smoothdata(mean(ThetaSpectr),...
    1,'gaussian',SamplFreq*TimeSmoothSec);



%% Output structure
ThetaData.RidgeFreqs = RidgeFreqs;
ThetaData.RidgeIdx   = RidgeIdx;
ThetaData.RidgeVar   = RidgeVar;
ThetaData.MeanPower  = MeanPower;

end
