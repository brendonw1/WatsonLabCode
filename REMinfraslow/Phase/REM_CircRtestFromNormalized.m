function [Pval,RadVec] = REM_CircRtestFromNormalized(BinnedIncidence)
%
% Pval = REM_CircRtestFromNormalized(BinnedIncidence,PhaseBinSizeDeg)
%
% Creates a vector of radians from a binned/normalized circular
% distribution, and then runs the circ_rtest from Berens (2009).
% https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics
%
% USAGE
%   - BinnedIncidence: vector of decimals representing the normalized
%                      incidence per phase bin. Bin size is assumed based
%                      on the length of this vector. For example, if vector
%                      length is 36, a 10 degree bin size is determined.
%
% OUTPUTS
%   - Pval:   Rayleigh P value
%   - RadVec: vector of radians for polar plotting (optional)
%                   
% Bueno-Junior et al. (2023)

%%
PhaseBinSize = 360/length(BinnedIncidence);
RadianBins   = num2cell(deg2rad(PhaseBinSize:PhaseBinSize:360)');
RoundIncid   = ceil(BinnedIncidence*100);
for BinIdx   = 1:numel(RoundIncid)
    RadianBins{BinIdx,2} = repmat(...
        RadianBins{BinIdx,1},RoundIncid(BinIdx),1);
end
RadVec = cell2mat(RadianBins(:,2));
Pval   = circ_rtest(RadVec);

end