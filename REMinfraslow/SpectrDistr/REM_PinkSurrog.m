function PinkSurrog = REM_PinkSurrog(EpochDurSec,SamplFreq,varargin)
%
% PinkSurrog = REM_PinkSurrog(EpochDurSec,SamplFreq,varargin)
%
% Pink noise surrogate to simulate infraslow fluctuations. Based on
% Mike X. Cohen's course (https://www.udemy.com/course/suv-data-mxc/).
%
% USAGE
%   - EpochDurSec: epoch duration in seconds.
%   - SamplFreq:   in Hz
%   - varargin:    please, see Input parser section
%
% OUTPUT
%   - PinkSurrog:  the signal. Can be analyzed using REM_InfraslowPSD.
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

addParameter(p,'FreqLims',[0 0.15],@isnumeric) % Hz
addParameter(p,'FreqBinSize',0.001,@isnumeric) % Hz

% C variable to control amplitude. Values lower than 1 give more weight
% to higher frequencies. Values between 1 and 3 given more weight to
% lower frequencies.
addParameter(p,'Cvariable',0.7,@isnumeric) % 

parse(p,varargin{:})
FreqLims    = p.Results.FreqLims;
FreqBinSize = p.Results.FreqBinSize;
Cvariable   = p.Results.Cvariable;



%% Time and frequencies
TimeAxis = 1/SamplFreq:1/SamplFreq:EpochDurSec;
FreqList = FreqLims(1)+FreqBinSize:FreqBinSize:FreqLims(2);



%% Pink noise (from Mike X. Cohen's course)
PinkSurrog  = zeros(size(TimeAxis));
for FreqIdx = 1:length(FreqList)
    
    Amplit  = 1/FreqList(FreqIdx)^Cvariable;
    
    PinkSurrog = PinkSurrog+Amplit*sin(...
        2*pi*FreqList(FreqIdx)*...
        TimeAxis + rand*2*pi);
end

end