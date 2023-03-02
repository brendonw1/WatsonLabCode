function [PSDcurve,FreqList] = REM_InfraslowPSD(DataVector,Params,varargin)
%
% PSDcurve = REM_InfraslowPSD(DataVector,Params,varargin)
%
% Infraslow power spectral density from physiological fluctuations.
%
% USAGE
%   - DataVector: vector of time samples
%       - RECOMMENDED: detrending and z scoring or normalization of
%                      DataVector within epoch pairs. See
%	  	       REM_JointZscNorm.
%   - Params: a structure
%       - .WindowSec: scalar in seconds (e.g., 60, 180)
%       - .SamplFreq: scalar in Hz (e.g., 125)
%   - varargin: please see input parser section
%
% OUTPUT
%   - PSDcurve
%   - FreqList: list of frequency bins
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% pwelch parameters
addParameter(p,'FreqLims',[0 0.15],@isnumeric) % Hz
addParameter(p,'FreqBinSize',0.001,@isnumeric) % Hz

parse(p,varargin{:})
FreqLims    = p.Results.FreqLims;
FreqBinSize = p.Results.FreqBinSize;



%% Required inputs. Throw error messages if parameters are lacking.
WindowSec = Params.WindowSec;
SamplFreq = Params.SamplFreq;



%% Frequency list and window
FreqList     = FreqLims(1)+FreqBinSize:FreqBinSize:FreqLims(2);
PwelchWindow = floor(WindowSec*SamplFreq);



%% PSD curve
PSDcurve = pwelch(DataVector,PwelchWindow,[],FreqList,SamplFreq);

end
