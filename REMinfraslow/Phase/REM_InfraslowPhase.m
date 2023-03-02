function FluctPhase = REM_InfraslowPhase(InfraslFluct)
%
% FluctPhase = REM_InfraslowPhase(InfraslFluct)
%
% Hilbert transform of infraslow fluctuation (e.g., theta frequency).
% Based on bz_PhaseModulation.
%
% USAGE
%   - InfraslFluct: a vector, from Z scored detrended fluctuation.
%
% OUTPUT
%   - FluctPhase: the transform, in radians. Same size as InfraslFluct.
%
% Bueno-Junior et al. (2023)

%%
FluctPhase = mod(angle(hilbert(InfraslFluct)),2*pi);

end