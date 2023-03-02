function [ProcEOG,EOGenvel] = REM_HumanEOGamplit(TwoChnEOG,SamplFreq,varargin)
%
% [ProcEOG,EOGenvel] = REM_HumanEOGamplit(TwoChnEOG,SamplFreq,varargin)
%
% Human REM electrooculogram is processed into a vector emphasizing
% rapid eye movements as spike-like events.
%
% USAGE
%   - TwoChnEOG: time samples x two EOG channels (int16, double, etc.)
%   - varargin: please see input parser section
%
% OUTPUTS
%   - EOGdata:  column vector, same length as TwoChnEOG. Use this for
%               event thresholding (see REM_FacialMovPhasePref).
%   - EOGenvel: envelope from EOGdata, to be used in distribution analysis
%               (e.g., see REM_DistrHist).
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% To remove slow trends
addParameter(p,'HighPassFilt',0.05,@isnumeric) % Hz
% Envelope parameter
addParameter(p,'EnvelWindowSec',10,@isnumeric) % s

parse(p,varargin{:})
HighPassFilt   = p.Results.HighPass;
EnvelWindowSec = p.Results.EnvelWindowSec;



%% Check size
if size(TwoChnEOG,1) == 1 || size(TwoChnEOG,2) == 1
    error('Input must have two channels (left and right eye)')
elseif size(TwoChnEOG,2) > 2
    TwoChnEOG = TwoChnEOG';
end



%% Filter the two channels
[b,a] = butter(2,HighPassFilt/(SamplFreq/2),'high');
EOGfilt = filtfilt(b,a,double(TwoChnEOG));



%% Left-right difference
ProcEOG = abs(diff(EOGfilt,1,2));



%% Upper envelope
EOGenvel = abs(envelope(ProcEOG,EnvelWindowSec*SamplFreq,'peak'));

end