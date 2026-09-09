function [CorrelClustOutputs,Params] = humanREMinfraslow_CorrelClust(InData,VariableNames,varargin)
%
% [CorrelClustOutputs,Params] = humanREMinfraslow_CorrelClust(InData,VariableNames)
%
% Calculates correlations among variables and performs hierarchical
% clustering based on similarities in their correlation profiles. This
% approach can identify blocks of intercorrelated variables, such as
% groups of collinear symptom measures.
%
% [CorrelClustOutputs,Params] = humanREMinfraslow_CorrelClust(InData,VariableNames,Name,Value)
%
% Specifies optional parameters using name-value arguments.
%
% INPUTS:
%   InData
%     Numeric matrix containing observations in rows and variables in
%     columns. The input must not contain missing or infinite values, and
%     each variable must have nonzero variance. The user is responsible
%     for data cleaning before calling this function.
%
%   VariableNames
%     Cell array of character vectors or string vector containing one name
%     for each column in InData.
%
% NAME-VALUE ARGUMENTS:
%   'CorrelClustAlpha'
%                          Significance threshold applied after
%                          Benjamini-Hochberg false discovery rate
%                          correction.
%                          Default: 0.05
%
% OUTPUTS:
%   CorrelClustOutputs
%     Table containing:
%       correlation_matrix
%           Spearman correlation matrix reordered according to the
%           hierarchical-clustering leaf order.
%
%       correlation_p_values
%           Uncorrected p-value matrix in the same variable order.
%
%       FDR_adjusted_p_values
%           P-value matrix after Benjamini-Hochberg false discovery rate
%           correction across all unique variable pairs.
%
%       FDR_significance_matrix
%           Logical matrix identifying correlations that remain
%           significant after false discovery rate correction.
%
%       linkage_tree
%           Hierarchical linkage tree generated using average linkage.
%
%       cluster_index
%           Cluster assignment for each variable, presented in the
%           reordered variable order.
%
%       leaf_order
%           Column indices describing the hierarchical-clustering order
%           relative to the original input data.
%
%       variable_names
%           Variable names in hierarchical-clustering order.
%
%   Params
%     Optional structure containing the parameters and derived clustering
%     values used.
%
% DEPENDENCIES:
%   Statistics and Machine Learning Toolbox.
%   Bioinformatics Toolbox.
%
% Lezio S. Bueno-Junior, Brendon O. Watson (2026-7), University of Michigan

%% Parse inputs
p = inputParser;

AlphaValue = @(x) isnumeric(x) && isscalar(x) &&...
    isreal(x) && isfinite(x) && x>0 && x<1;

addParameter(p,'CorrelClustAlpha',0.05,AlphaValue);

parse(p,varargin{:})

CorrelClustAlpha = p.Results.CorrelClustAlpha;



%% Validate input data and variable names
if ~isnumeric(InData) || ~ismatrix(InData) || isempty(InData)
    error('InData must be a nonempty numeric matrix.')
end

InData = double(InData);

if any(~isfinite(InData(:)))
    error('InData must not contain missing or infinite values.')
end

NumVariables = size(InData,2);

if NumVariables<3
    error('InData must contain at least three variables.')
end

if size(InData,1)<3
    error('InData must contain at least three observations.')
end

if any(std(InData,0,1)==0)
    error('Each variable in InData must have nonzero variance.')
end

if isstring(VariableNames)
    VariableNames = cellstr(VariableNames(:));
elseif iscell(VariableNames)
    VariableNames = VariableNames(:);
else
    error(['VariableNames must be a cell array of character vectors or ',...
        'a string vector.'])
end

if numel(VariableNames)~=NumVariables
    error(['VariableNames must contain one name for each column in ',...
        'InData.'])
end

if ~all(cellfun(@(x) ischar(x) && isrow(x),VariableNames))
    error('Each entry in VariableNames must be a character vector.')
end



%% Calculate Spearman correlations among variables
[CorrelationMatrix,PvalueMatrix] = corr(InData,'Type','Spearman');



%% Calculate correlation-based distances among variables
% Absolute correlations are used so that strong positive and negative
% correlations both indicate similar variable relationships.
CorrelDistMatrix = 1-abs(CorrelationMatrix);
CorrelDistMatrix(1:NumVariables+1:end) = 0;
CorrelDistVector = squareform(CorrelDistMatrix,'tovector');



%% Perform hierarchical clustering using average linkage
LinkageTree = linkage(CorrelDistVector,'average');



%% Determine cluster cutoff from the largest increase in linkage distance
% The cutoff is placed halfway between the two consecutive linkage
% distances separated by the largest increase.
LinkageDistanceDifference = diff(LinkageTree(:,3));

[~,LargestDistanceIncreaseIdx] = max(LinkageDistanceDifference);

CorrelClustCutHeight = mean(LinkageTree(...
    LargestDistanceIncreaseIdx:LargestDistanceIncreaseIdx+1,3));

ClusterIndex = cluster(...
    LinkageTree,...
    'Cutoff',CorrelClustCutHeight,...
    'Criterion','distance');



%% Determine leaf order using MATLAB dendrogram ordering
% An invisible temporary figure is used to reproduce the leaf order
% returned by dendrogram without displaying an additional figure.
TempFigure = figure('Visible','off');
TempAxes   = axes('Parent',TempFigure);

set(TempFigure,'CurrentAxes',TempAxes);

[~,~,LeafOrder] = dendrogram(...
    LinkageTree,...
    0,...
    'Orientation','left',...
    'ColorThreshold',CorrelClustCutHeight);

close(TempFigure)



%% Correct correlation p-values for false discovery rate
% Benjamini-Hochberg correction is applied once to the unique variable
% pairs in the upper triangle of the correlation matrix.
UpperTriangle = triu(true(NumVariables),1);
UpperPvalues  = PvalueMatrix(UpperTriangle);

AdjustedPvalues = mafdr(UpperPvalues,'BHFDR',true);

FDRadjPvalueMatrix = zeros(NumVariables);

FDRadjPvalueMatrix(UpperTriangle) = AdjustedPvalues;
FDRadjPvalueMatrix = FDRadjPvalueMatrix + FDRadjPvalueMatrix';

FDRadjPvalueMatrix(1:NumVariables+1:end) = 0;

FDRsignifMatrix = FDRadjPvalueMatrix<=CorrelClustAlpha;



%% Reorder matrices and variables according to hierarchical clustering
CorrelationMatrix = CorrelationMatrix(LeafOrder,LeafOrder);

PvalueMatrix = PvalueMatrix(LeafOrder,LeafOrder);

FDRadjPvalueMatrix = FDRadjPvalueMatrix(LeafOrder,LeafOrder);

FDRsignifMatrix = FDRsignifMatrix(LeafOrder,LeafOrder);

ClusterIndex = ClusterIndex(LeafOrder);
VariableNames = VariableNames(LeafOrder);



%% Output table, can be combined with outputs from other functions
CorrelClustOutputs = cell2table(...
    [{CorrelationMatrix} {PvalueMatrix}...
    {FDRadjPvalueMatrix} {FDRsignifMatrix}...
    {LinkageTree} {ClusterIndex} {LeafOrder} {VariableNames}],...
    'VariableNames',{'correlation_matrix',...
    'correlation_p_values',...
    'FDR_adjusted_p_values',...
    'FDR_significance_matrix',...
    'linkage_tree',...
    'cluster_index',...
    'leaf_order',...
    'variable_names'});



%% Parameters used, optionally returned for traceability
Params.CorrelClustCutHeight = CorrelClustCutHeight;
Params.CorrelClustAlpha     = CorrelClustAlpha;

end