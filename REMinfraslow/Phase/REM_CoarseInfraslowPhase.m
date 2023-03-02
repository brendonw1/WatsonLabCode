function [CoarsePhase,SubEpochs,AngleCategs] = ...
    REM_CoarseInfraslowPhase(RawPhase,AngleBinSize)
%
% [CoarsePhase,SubEpochs,AngleCategs] = REM_CoarseInfraslowPhase(RawPhase,AngleBinSize)
%
% Coarsens a Hilbert transform into a staircase-like curve. Timestamps
% corresponding to each staircase step are provided as outputs in a cell
% array, at the input sampling frequency. Upsampling of these timestamps
% or their conversion to seconds must be done separately.
%
% USAGE
%   - RawPhase:     Hilbert transform of Z scored detrended infraslow
%                   fluctuation (a vector, in radians). See also
%                   REM_FacialMovPhasePref.
%   - AngleBinSize: scalar in degrees (e.g., 45).
%
% OUTPUT
%   - CoarsePhase:  staircase-like transform (in radians)
%   - SubEpochs:    a table (see table headers for explanation)
%   - AngleCategs:  step/bin categories, represented by their central
%                   angle values, in degrees.
%
% Bueno-Junior et al. (2023)

%% Size check
if size(RawPhase,1) > 1 && size(RawPhase,2) > 1
    error('RawPhase must be a column vector')
elseif size(RawPhase,1) == 1 && size(RawPhase,2) > 1
    RawPhase = RawPhase';
end



%% Phase coarsening
AngleBinCenters = linspace(0,2*pi,(360/AngleBinSize)+1);

CoarsePhase = zeros(size(RawPhase));
for SampleIdx = 1:length(RawPhase)
    
    [~,RoundRad] = min(abs(AngleBinCenters-RawPhase(SampleIdx)));
    
    % Merge zero- and 360-attracted into the zero-centered bin
    if RoundRad == 1;RoundRad = 9;end
    
    CoarsePhase(SampleIdx) = AngleBinCenters(RoundRad);
end
AngleCategs = rad2deg(AngleBinCenters(1:end-1))';



%% Phase sub-epochs
SubEpochEdges = find(logical(abs([0;diff(CoarsePhase)])));
SubEpochEdges = [SubEpochEdges;length(CoarsePhase)];

SubEpochs   = cell(numel(SubEpochEdges),2);ii = 0;
for EdgeIdx = 1:numel(SubEpochEdges)
    
    % Step indices
    SubEpochs{EdgeIdx,2} = (ii+1:SubEpochEdges(EdgeIdx))';
    SubEpochs{EdgeIdx,2}(isnan(...
        CoarsePhase(ii+1:SubEpochEdges(EdgeIdx)))) = NaN;
    
    % Sub-epoch lengths
    SubEpochs{EdgeIdx,3} = length(SubEpochs{EdgeIdx,2});
    
    % Angle categories
    if logical(sum(isnan(SubEpochs{EdgeIdx,2})))
        SubEpochs{EdgeIdx,1} = NaN;
    else
        SubEpochs{EdgeIdx,1} = rad2deg(mode(...
            CoarsePhase(ii+1:SubEpochEdges(EdgeIdx))));
    end
    
    if SubEpochs{EdgeIdx,1} == 360
        SubEpochs{EdgeIdx,1} = 0;
    end
    
    ii = SubEpochEdges(EdgeIdx);
end
SubEpochs = cell2table(SubEpochs(~isnan(cell2mat(SubEpochs(:,1))),:),...
    'VariableNames',{'CentralAngles','Timestamps','Length'});

end
