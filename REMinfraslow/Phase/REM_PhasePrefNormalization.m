function NormMovPhase = ...
    REM_PhasePrefNormalization(FluctPhase,MovPhase,AngleBinSize)
%
% NormMovPhase = REM_PhasePrefNormalization(FluctPhase,MovPhase,AngleBinSize)
%
% Normalizes circular distribution from movement-indexed phases in relation
% to the circular distribution of the underlying infraslow fluctuation.
%
% USAGE
%   - FluctPhase: Hilbert transform from infraslow fluctuation
%                 (vector of radians).
%   - MovPhase: phase values of FluctPhase corresponding to the movements
%               (vector of radians).
%   - AngleBinSize: scalar in degrees (e.g., 10)
%
% OUTPUT (ready for polar histograms and circular statistics):
%   - NormMovPhase: vector of radians. Number of samples in raw vs.
%                   normalized may differ, but without affecting the
%	            distribution.
%
% Bueno-Junior et al. (2023)

%% Bin edges in radians
BinEdges = deg2rad(0:AngleBinSize:360);



%% Normalize within distributions separately
FluctPhaseHist = histcounts(FluctPhase,BinEdges,...
    'normalization','probability');
[MovPhaseHist,~,MovPhaseBins] = histcounts(MovPhase,BinEdges,...
    'normalization','probability');



%% Normalize between distributions
NormMovPhaseHist = rescale(MovPhaseHist./FluctPhaseHist,...
    min(MovPhaseHist),max(MovPhaseHist));



%% Calculate proportional number of samples in the normalized distribution
BinEdges     = BinEdges(2:end);
NormMovPhase = cell(numel(BinEdges),1);
for BinIdx   = 1:numel(BinEdges)
    
    RawProbab      = MovPhaseHist(BinIdx);
    RawNumSamples  = sum(MovPhaseBins==BinIdx);
    NormProbab     = NormMovPhaseHist(BinIdx);
    
    % Rule of three
    NormNumSamples = round((RawNumSamples*NormProbab)/RawProbab);
    if isnan(NormNumSamples);NormNumSamples = 0;end
    
    % Populate each bin with the new samples
    NormMovPhase{BinIdx} = repmat(BinEdges(BinIdx),NormNumSamples,1);
end



%% New vector of radians
NormMovPhase = cell2mat(NormMovPhase);

end
