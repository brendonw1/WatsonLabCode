function Spindles_PlotSessionwiseData(SpindleDetectionEval)

if ~exist('SpindleDetectionEval','var')
    SpindleDetectionEval = Spindles_GatherSessionwiseData
    
    SpindleDetectionEval = assignout('base','SpindleDetectionEval');
end

v2struct(SpindleDetectionEval)%extracts field names as variables (necessary for labeling in fcns below)

figure;
mcorr_bw(OccurrenceRates,PeakAmplitudeMeans,DurationMeans,PeakFrequencyMeans);

figure;
StatsByLabel(Anatomies,PeakAmplitudeMeans,DurationMeans,PeakFrequencyMeans,OccurrenceRates);

figure
StatsByLabel(RatNames,PeakAmplitudeMeans,DurationMeans,PeakFrequencyMeans,OccurrenceRates);


DetectionChans = {};
for a = 1:length(SpindleDetectionEval.TotalSpindles)
    DetectionChans{a} = [SpindleDetectionEval.SessionNames{a}, ': ' num2str(SpindleDetectionEval.SpDetectionChan{a})];
end
figure    

% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',DetectionChans)
