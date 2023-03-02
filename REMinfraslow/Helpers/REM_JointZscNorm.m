function [OutDataA,OutDataB] = REM_JointZscNorm(InDataA,InDataB,WitchType)
%
% [OutDataA,OutDataB] = REM_JointZscNorm(InDataA,InDataB,WhichType)
%
% For joint Z scoring or normalization (0-1 rescaling) within epoch pair.
%
% USAGE
%   - InDataA: matrix (e.g., frequency x time spectrogram) or column vector
%                      e.g., time samples).
%   - InDataB: same as above.
%   - WhichType: 'z' for zscore, 'r' for rescale
%
% If zscoring/rescaling spectrograms, they are jointly zscored/rescaled
% along dimension 1 (e.g., frequency bins).
%
% Bueno-Junior et al. (2023)

%% Check sizes
if ~isequal(size(InDataA),size(InDataB))
    error('DataA and DataB must have same sizes')
end



%% Concatenate. If specrograms, they are stacked for vertical
% zscoring/rescaling, along frequencies in dimension 1. If curves,
% they are combined into a single column vector for zscoring/rescaling
% across time samples.
ConcatData = [InDataA;InDataB];



%% Joint Z scoring or rescaling
switch WitchType
    case 'z'
        ConcatData = zscore(ConcatData);
    case 'r'
        for ColIdx = 1:size(ConcatData,2) % flexible: spectrograms or curves
            ConcatData(:,ColIdx) = rescale(ConcatData(:,ColIdx));
        end
end



%% Deconcatenate
OutDataA = ConcatData(1:size(ConcatData,1)/2,:);
OutDataB = ConcatData((size(ConcatData,1)/2)+1:end,:);

end
