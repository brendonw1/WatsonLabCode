function PhasePrefData = ...
    REM_InfraslowPhasePref(InfraslFluct,FacialMov,varargin)
%
% PhasePrefData = REM_InfraslowPhasePref(InfraslFluct,FacialMov,varargin)
%
% Phase relationships between facial movement timestamps and underlying
% infraslow fluctuations.
%
% USAGE
%   - InfraslFluct: a structure
%       - .Data: vector of time samples. Infraslow fluctuation.
%       - .SamplFreq: physiology sampling frequency.
%   - FacialMov: another structure
%       - .Data: vector of time samples. Movement speed (e.g., see
%                REM_EyeDataSingleEpoch) or EOG activity (e.g., see
%                REM_HumanEOGamplit)
%       - .SamplFreq: sampling frequency or video frame rate.
%   - varargin: please see input parser section.
%
% CAUTION: make sure InfraslFluct.Data and FacialMov.Data are from the
%          same epoch.
%
% OUTPUTS:
%   - PhasePrefData: a structure
%       - FluctPhase: Hilbert transform from infraslow fluctuation
%                     (vector of radians, ready for circular statistics).
%       - RawMovPhase: phase values of FluctPhase corresponding to movements
%                      (vector of radians, ready for circular statistics).
%       - NormMovPhase: same as RawMovPhase, but normalized in relation
%                       to FluctPhase (number of samples in raw vs.
%                       normalized may differ, but the circular
%                       distribution is what matters; see
%                       REM_PhasePrefNormalization).
%       - MovTstamps: movement timestamp indices (for illustrative plots).
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

addParameter(p,'NumStdDeviations',2,@isnumeric)
addParameter(p,'AngleBinSize',10,@isnumeric) % degrees

parse(p,varargin{:})
NumStdDeviations = p.Results.NumStdDeviations;
AngleBinSize     = p.Results.AngleBinSize;



%% Check sampling rates, upsample facial movement data if needed
if FacialMov.SamplFreq > InfraslFluct.SamplFreq
    error('Video frame rate should be lower than physiology sampling rate')
elseif FacialMov.SamplFreq < InfraslFluct.SamplFreq % mouse data
    FacialMov.Data = REM_InterpToNewLength(...
        FacialMov.Data,length(InfraslFluct.Data));
else % human PSG, same sampling frequency across channels, do nothing
end



%% Infraslow phases
FluctPhase = REM_InfraslowPhase(InfraslFluct.Data);



%% Timestamps from thresholded movements
StdThresh  = mean(FacialMov.Data)+(std(FacialMov.Data)*NumStdDeviations);
MovTstamps = FacialMov.Data;
MovTstamps(MovTstamps<StdThresh) = 0;
MovTstamps(MovTstamps>0) = 1;
MovTstamps = diff(MovTstamps);
MovTstamps = find(MovTstamps==1)+1; % +1 is to compensate for diff



%% Raw and normalized phase relationships
RawMovPhase  = FluctPhase(MovTstamps);
NormMovPhase = REM_PhasePrefNormalization(...
    FluctPhase,RawMovPhase,AngleBinSize);



%% Output structure
PhasePrefData.FluctPhase   = FluctPhase;
PhasePrefData.RawMovPhase  = RawMovPhase;
PhasePrefData.NormMovPhase = NormMovPhase;
PhasePrefData.MovTstamps   = MovTstamps;

end
