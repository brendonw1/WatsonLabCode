function PredictedOutput = LearnMotivStudy_StateClassif(InputTable,varargin)

%
% PredictedOutput = LearnMotivStudy_StateClassif(InputTable,varargin)
%
% Within-mouse state prediction using decision trees.
%
% USAGE
%   - InputTable: task trials in rows, predictors in columns. Add a final
%                 categorical column on the right containing original state
%                 labels
%   - varargin: see input parser section for default parameters
%
% OUTPUT
%   - PredictedOutput: categorical vector, same size as the categorical
%                      column of the input table
%
% Bueno-Junior et al. (2026)

%% Input parser
p = inputParser;

% For splitting the input table into training and held-out tables
addParameter(p,'TrialsPerBlock',25,@isnumeric)

parse(p,varargin{:})
TrialsPerBlock = p.Results.TrialsPerBlock;



%% Indices for randomized trial blocks, followed by...
AllBlocks = num2cell(reshape(1:height(InputTable),...
    TrialsPerBlock,height(InputTable)/TrialsPerBlock),1)';
RandBlocks = randperm(numel(AllBlocks));

% ... splitting
OddBlocks  = cell2mat(AllBlocks(RandBlocks(1:2:end)));
EvenBlocks = cell2mat(AllBlocks(RandBlocks(2:2:end)));



%% Predictor names
PredictorNames = InputTable.Properties.VariableNames(1:end-1);
PredictorExtractionFcn = @(t) t(:,PredictorNames);



%% Two complementary tables: one for training, another for
% prediction of unseen data, and then vice-versa. Specifically:
% train based on odd  -> predict even, and then
% train based on even -> predict odd
OddTable  = InputTable(OddBlocks,:);
EvenTable = InputTable(EvenBlocks,:);



%% Training and prediction, based on the Classification Learner app
OddOrigCateg  = OddTable(:,end);
EvenOrigCateg = EvenTable(:,end);

OddTemplate = templateTree(...
    'MaxNumSplits',height(OddTable)-1);
EvenTemplate = templateTree(...
    'MaxNumSplits',height(EvenTable)-1);

OddModel = fitcensemble(OddTable(:,1:end-1),OddOrigCateg,...
    'Method','Bag',...
    'NumLearningCycles',30,...
    'Learners',OddTemplate,...
    'ClassNames',unique(OddTable.EngagPerfmCateg));

EvenModel = fitcensemble(EvenTable(:,1:end-1),EvenOrigCateg,...
    'Method','Bag',...
    'NumLearningCycles',30,...
    'Learners',EvenTemplate,...
    'ClassNames',unique(EvenTable.EngagPerfmCateg));

OddPredictFcn  = @(x) predict(OddModel,x);
EvenPredictFcn = @(x) predict(EvenModel,x);

OddClassifier.PredictFcn = @(x) OddPredictFcn(...
    PredictorExtractionFcn(x));
EvenClassifier.PredictFcn = @(x) EvenPredictFcn(...
    PredictorExtractionFcn(x));

OddPredict  = EvenClassifier.PredictFcn(OddTable);
EvenPredict = OddClassifier.PredictFcn(EvenTable);



%% Re-sort trials into chronological order
[~,ReSortIdx]   = sort([OddBlocks;EvenBlocks]);
PredictedOutput = [OddPredict;EvenPredict];
PredictedOutput = PredictedOutput(ReSortIdx);

end