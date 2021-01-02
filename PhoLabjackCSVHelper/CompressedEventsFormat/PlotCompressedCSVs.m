function fighandle = PlotCompressedCSVs(CompressedFilePath)


% Loads the compressed.mat events and plots them

%% setting paths for function 
thisfuncpath = mfilename('fullpath');
tpath1 = fileparts(thisfuncpath);
tpath2 = fileparts(tpath1);
addpath(genpath(fullfile(tpath2,'HelperFunctions')));
addpath(genpath(fullfile(tpath2,'CompressedEventsFormat')));

%% Parsing inputs
if ~exist('CompressedFilePath','var')
	[cfile,cpath] = uigetfile;
	CompressedFilePath = fullfile(cpath,cfile);
end

%% Grab data
% load('Output/compressed-out_file_1545.mat', 'OutputDeltasTimestamps')
load(CompressedFilePath)
%load('Output/compressed-newest.mat', 'OutputDeltasTimestamps')

varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense'};
labjackTimeTable = CompressedEvents2Timetable(DeltaIdxs, DeltaTimestamps, varNames);

% binnedEventsTimetable = retime(labjackTimeTable,'hourly','sum','IncludedEdge','right');
% [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned hourly');
 
% binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
binnedEventsTimetable = retime(labjackTimeTable,'daily','sum');
% [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Port Events: binned daily');


%% Multi-Event Bar Plot Figure
graphProperties.sgtitle = 'Port Events: Binned Daily';

graphColors.beambreak = 'b';
graphColors.dispense = 'r';
maxBeamBreakCount = max(binnedEventsTimetable{:,1:4},[],'all');
maxDispenseCount = max(binnedEventsTimetable{:,5:8},[],'all');
globalMaxCount = max(maxBeamBreakCount,maxDispenseCount);
graphProperties.yAxisMaxCount = globalMaxCount * 1.2;
graphProperties.verticalLabelAlignment = 'bottom';
graphProperties.beambreak.shouldShow = true;
graphProperties.beambreak.labels.shouldShow = false;
graphProperties.dispense.labels.shouldShow = true;

graphProperties.shouldShowEvents = true;

graphProperties.legend.location = 'northwest';
graphProperties.legend.orientation = 'vertical';

dateTimes = binnedEventsTimetable.dateTime;
dayIntoExperiment = 1:length(dateTimes);
% xVariable = dateTimes;
xVariable = dayIntoExperiment;

fighandle = figure('position',[560 100 1100 850]);
clf
axH(1) = subplot(4,1,1);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Water1_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Water1_BeamBreak),binnedEventsTimetable.Water1_BeamBreak,num2str(binnedEventsTimetable.Water1_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
bar(xVariable, binnedEventsTimetable.Water1_Dispense);
ylabel('Water 1');
% ylim([0,graphProperties.yAxisMaxCount]);
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

axH(2) = subplot(4,1,2);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Water2_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Water2_BeamBreak),binnedEventsTimetable.Water2_BeamBreak,num2str(binnedEventsTimetable.Water2_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
bar(xVariable, binnedEventsTimetable.Water2_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water2_Dispense),binnedEventsTimetable.Water2_Dispense,num2str(binnedEventsTimetable.Water2_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
end
if graphProperties.shouldShowEvents
   xline(15,'-',{'Lifted Water' 'Ports'});
end
ylabel('Water 2');
% ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
if graphProperties.beambreak.shouldShow
    legend('BeamBreak','Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
else
    legend('Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
end

axH(3) = subplot(4,1,3);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Food1_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Food1_BeamBreak),binnedEventsTimetable.Food1_BeamBreak,num2str(binnedEventsTimetable.Food1_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
bar(xVariable, binnedEventsTimetable.Food1_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Food1_Dispense),binnedEventsTimetable.Food1_Dispense,num2str(binnedEventsTimetable.Food1_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
end
if graphProperties.shouldShowEvents
   xline(22,'-',{'Changed to ' 'High-Fat'}); 
end
ylabel('Food 1');
% ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
if graphProperties.beambreak.shouldShow
    legend('BeamBreak','Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
else
    legend('Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
end

axH(4) = subplot(4,1,4);
if graphProperties.beambreak.shouldShow
    bar(xVariable, binnedEventsTimetable.Food2_BeamBreak);
    if graphProperties.beambreak.labels.shouldShow
        text(1:length(binnedEventsTimetable.Food2_BeamBreak),binnedEventsTimetable.Food2_BeamBreak,num2str(binnedEventsTimetable.Food2_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.beambreak);
    end
end
box off
hold on;
bar(xVariable, binnedEventsTimetable.Food2_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Food2_Dispense),binnedEventsTimetable.Food2_Dispense,num2str(binnedEventsTimetable.Food2_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color',graphColors.dispense);
end
if graphProperties.shouldShowEvents
   xline(22,'-',{'Changed to ' 'Regular'}); 
end
ylabel('Food 2');
% ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
if graphProperties.beambreak.shouldShow
    legend('BeamBreak','Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
else
    legend('Dispense','Location',graphProperties.legend.location,'Orientation',graphProperties.legend.orientation)
end
xlabel('Days into experiment')
% dynamicDateTicks(axH, 'link', 'mm/dd')

sgtitle(graphProperties.sgtitle)

%% Annotations
% June 19, 2019: Day we added the elevated ports
% 6-26-2019: Added sugar water around noon. 
% More reasonable to cluster over night instead of from midnight to midnight.



