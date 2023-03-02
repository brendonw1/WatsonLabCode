function SpkCircStats = REM_MultiChnSpkCirc(SpkPhase)
%
% SpkCirc = REM_MultiChnSpkCirc(SpkPhase)
%
% Circular stats from spike-indexed infraslow phases.
%
% USAGE
%   - SpkPhase: from REM_MultiChnSpkPhase. It can be a m x n cell array,
%               where m are concatenated epochs and n are the neuronal
%               units (user is responsible for re-mapping). It also
%               works without epoch concatenation, i.e., 1 x n cell array.
%
% OUTPUT
%   - SpkCircStats: 3 x n matrix, where n are the neuronal units, same
%                   mapping as input. The three rows are as follows:
%       - mean direction
%       - mean resultant length
%       - Rayleigh test
% 
% Bueno-Junior et al. (2023)

%%
SpkCircStats = zeros(3,size(SpkPhase,2));
for UnitIdx = 1:size(SpkPhase,2)
    
    ConcatUnit = cell2mat(SpkPhase(:,UnitIdx));
    if ~isempty(ConcatUnit)
        SpkCircStats(1,UnitIdx) = circ_mean(ConcatUnit);
        SpkCircStats(2,UnitIdx) = circ_r(ConcatUnit);
        SpkCircStats(3,UnitIdx) = circ_rtest(ConcatUnit);
    else
        SpkCircStats(1:3,UnitIdx) = NaN;
    end
end

end
