addpath(genpath('HelperFunctions'));
addpath(genpath('CompressedEventsFormat'));

load('../Output/PaulsCombinedData.mat')
% load('Output/compressed-out_file_1545.mat', 'OutputDeltasTimestamps')
load('../Output/compressed.mat')
%load('Output/compressed-newest.mat', 'OutputDeltasTimestamps')

varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense'};
labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames);

% binnedEventsTimetable = retime(labjackTimeTable,'hourly','sum','IncludedEdge','right');
% [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned hourly');
 
% binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
binnedEventsTimetable = retime(labjackTimeTable,'daily','sum');
% Drop the last day
numDaysToPlot = length(PaulsData.weight);
binnedEventsTimetable = binnedEventsTimetable(1:numDaysToPlot,:);

% [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned daily');

%% Data starts on 6/5/2019 and spans until
paulPlotProperties.shouldShowEvents = true;
paulPlotProperties.lineThickness = 3;
paulPlotProperties.markerSize = 4;

%% Scatter Plot Figure
PresentationDrinking.sgtitle = 'Drinking Events: Binned Daily';
graphColors.beambreak = 'b';
graphColors.dispense = 'r';
maxBeamBreakCount = max(binnedEventsTimetable{:,1:4},[],'all');
maxDispenseCount = max(binnedEventsTimetable{:,5:8},[],'all');
globalMaxCount = max(maxBeamBreakCount,maxDispenseCount);
graphProperties.yAxisMaxCount = globalMaxCount * 1.2;
graphProperties.verticalLabelAlignment = 'bottom';
graphProperties.beambreak.labels.shouldShow = true;
graphProperties.beambreak.shouldShow = false;
graphProperties.dispense.labels.shouldShow = true;
graphProperties.shouldShowEvents = true;

graphProperties.legend.location = 'northwest';
graphProperties.legend.orientation = 'horizontal';



graphProperties.plot1.color = [0.3010 0.7450 0.9330]; %lighter blue
graphProperties.plot2.color = [0 0.4470 0.7410]; % Darker Blue

dateTimes = binnedEventsTimetable.dateTime;
dayIntoExperiment = 1:length(dateTimes);
% xVariable = dateTimes;
xVariable = dayIntoExperiment;

fig = figure(6);
clf
PresentationDrinking.axH(1) = subplot(3,1,1);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Water1_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Water1_BeamBreak),binnedEventsTimetable.Water1_BeamBreak,num2str(binnedEventsTimetable.Water1_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
b = bar(xVariable, binnedEventsTimetable.Water1_Dispense, graphColors.dispense);
b.FaceColor = graphProperties.plot1.color; %lighter blue
% b.EdgeColor = [0 0.4470 0.7410];
ylabel('Water 1');
ylim([0,graphProperties.yAxisMaxCount]);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water1_Dispense),binnedEventsTimetable.Water1_Dispense,num2str(binnedEventsTimetable.Water1_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
end
if graphProperties.shouldShowEvents
   xline(15,'-',{'Lifted Water' 'Ports'});
   xline(22,'-',{'Changed to' 'Sucrose Water'}); 
end
if graphProperties.beambreak.shouldShow
    legend('BeamBreak','Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
else
    legend('Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
end

PresentationDrinking.axH(2) = subplot(3,1,2);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Water2_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Water2_BeamBreak),binnedEventsTimetable.Water2_BeamBreak,num2str(binnedEventsTimetable.Water2_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
b = bar(xVariable, binnedEventsTimetable.Water2_Dispense, graphColors.dispense);
b.FaceColor = graphProperties.plot2.color; % Darker Blue
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water2_Dispense),binnedEventsTimetable.Water2_Dispense,num2str(binnedEventsTimetable.Water2_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
end
if graphProperties.shouldShowEvents
   xline(15,'-',{'Lifted Water' 'Ports'});
end
ylabel('Water 2');
ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
if graphProperties.beambreak.shouldShow
    legend('BeamBreak','Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
else
    legend('Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
end


%% Plot the measured water consumed
PresentationDrinking.axH(3) = subplot(3,1,3);
plot(dayIntoExperiment(1:length(PaulsData.weight)),PaulsData.regularWaterConsumed, '-o', 'LineWidth',paulPlotProperties.lineThickness, 'MarkerSize',paulPlotProperties.markerSize, 'Color', graphProperties.plot2.color);
box off
hold on;
plot(dayIntoExperiment(1:length(PaulsData.weight)),PaulsData.sucroseWaterConsumed, '-o', 'LineWidth',paulPlotProperties.lineThickness, 'MarkerSize',paulPlotProperties.markerSize, 'Color', graphProperties.plot1.color);
if graphProperties.shouldShowEvents
   xline(15,'-',{'Lifted Water' 'Ports'});
   xline(22,'-',{'Changed to' 'Sucrose Water'}); 
end
title('Measured Water Consumed [mL]')
ylabel('Water Consumed [mL] at 4:00pm')
xlabel('Days into experiment')
legend('regular water', '1% sucrose water','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation);

sgtitle(PresentationDrinking.sgtitle)

linkaxes(PresentationDrinking.axH,'x');

totalWaterConsumed = PaulsData.regularWaterConsumed + PaulsData.sucroseWaterConsumed;


%% Annotations
% June 19, 2019: Day we added the elevated ports
% 6-26-2019: Added sugar water around noon. 
% More reasonable to cluster over night instead of from midnight to midnight.
