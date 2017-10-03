function UPstates_PlotSessionwiseData(UPDetectionEval)

if ~exist('UPDetectionEval','var')
    UPDetectionEval = assignout('base','UPDetectionEval');
end

v2struct(UPDetectionEval)%extracts field names as variables (necessary for labeling in fcns below)

figure;
mcorr_bw(OccurrenceRates,UPDurationMeans,DOWNDurationMeans,UPDOWNDurationMeanRatio);

figure;
StatsByLabel(Anatomies,UPDurationMeans,DOWNDurationMeans,UPDOWNDurationMeanRatio,OccurrenceRates);

figure
StatsByLabel(RatNames,UPDurationMeans,DOWNDurationMeans,UPDOWNDurationMeanRatio,OccurrenceRates);


DetectionChans = {};
for a = 1:length(UPDetectionEval.TotalSpindles)
    DetectionChans{a} = [UPDetectionEval.SessionNames{a}, ': ' num2str(UPDetectionEval.UPDetectionChan{a})];
end
figure    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',DetectionChans)
