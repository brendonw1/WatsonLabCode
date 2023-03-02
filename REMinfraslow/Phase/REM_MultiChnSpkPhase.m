function SpkPhase = REM_MultiChnSpkPhase(SpkTimes,EpochInt,FluctPhase,SamplFreq)
%
% SpkPhase = REM_MultiChnSpkPhase(SpkTimes,EpochInt,FluctPhase,SamplFreq)
%
% Infraslow phase values are gathered by epoched spike indices.
%
% USAGE
%   - SpkTimes: 1D cell array from '.spikes.cellinfo.mat'. Each cell
%               contains all spikes from a neuronal unit (user is
%               responsible for re-mapping).
%               IMPORTANT: spike times should be in seconds.
%   - EpochInt: epoch interval in seconds, e.g., [5 35]
%   - FluctPhase: Hilbert transform from infraslow fluctuation
%                 (vector of radians).
%   - SamplFreq: scalar in Hz, e.g., 125
%
% OUTPUT
%   - SpkPhase: 1D cell array, same size as SpkTimes. Each cell contains
%               infraslow phase values in radians.
% 
% Bueno-Junior et al. (2023)

%%
SpkPhase = cell(size(SpkTimes));
for UnitIdx = 1:length(SpkTimes)
    
    SpkEpoch = round((SpkTimes{UnitIdx}(...
        SpkTimes{UnitIdx} >  EpochInt(1) & ...
        SpkTimes{UnitIdx} <= EpochInt(2))-EpochInt(1))*SamplFreq);
    SpkEpoch(SpkEpoch==0) = [];
    SpkPhase{UnitIdx} = FluctPhase(SpkEpoch);
end

end
