function PhysiolData = REM_HumanPhysiolRate(WavelSpectr,Params,varargin)
%
% PhysiolData = REM_HumanPhysiolRate(WavelSpectr,Params,varargin)
%
% Human respiration and heart rate fluctuations from spectrogram ridge.
%
% USAGE
%   - WavelSpectr: from REM_WavelSpectr. For example, 
%                  respiration: 0.1-0.5 Hz, 0.002 Hz bins,
%                  heart:       0.8-1.8 Hz, 0.005 Hz bins
%   - Params: a structure
%       - .FreqList:  list of frequency bins
%       - .SamplFreq: scalar in Hz (e.g., 125)
%   - varargin: please see input parser section
%
% OUTPUT
%   - PhysiolData: a structure
%       - .RidgeFreqs: ridges in frequency values.
%		               Rows: ridges. Columns: time samples.
%       - .RidgeIdx:   as above, but in frequency bin indices
%
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

addParameter(p,'TimeSmoothSec',5,@isnumeric) % s

parse(p,varargin{:})
TimeSmoothSec = p.Results.TimeSmoothSec;



%% Required inputs. Throw error messages if parameters are lacking.
FreqList  = Params.FreqList;
SamplFreq = Params.SamplFreq;



%% Time-frequency ridge (just one ridge, as respiration and heart rate
% spectrograms are assumed to form strong patterns)
[RidgeFreqs,RidgeIdx] = tfridge(WavelSpectr,FreqList);
RidgeFreqs = smoothdata(RidgeFreqs,...
    'gaussian',SamplFreq*TimeSmoothSec)';
RidgeIdx   = smoothdata(RidgeIdx,...
    'gaussian',SamplFreq*TimeSmoothSec)';



%% Output structure
PhysiolData.RidgeFreqs = RidgeFreqs;
PhysiolData.RidgeIdx   = RidgeIdx;

end