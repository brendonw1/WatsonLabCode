function [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, title)
%PLOTBINNEDEVENTSTIMETABLE Summary of this function goes here
maxBeamBreakCount = max(binnedEventsTimetable{:,1:4},[],'all');
maxDispenseCount = max(binnedEventsTimetable{:,5:8},[],'all');
globalMaxCount = max(maxBeamBreakCount,maxDispenseCount);
graphProperties.yAxisMaxCount = globalMaxCount * 1.2;
graphProperties.verticalLabelAlignment = 'bottom';
graphProperties.beambreak.labels.shouldShow = false;
graphProperties.dispense.labels.shouldShow = true;
dateTimes = binnedEventsTimetable.dateTime;

fig = figure(3);
clf
axH(1) = subplot(4,1,1);
bar(dateTimes, binnedEventsTimetable.Water1_BeamBreak);
if graphProperties.beambreak.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water1_BeamBreak),binnedEventsTimetable.Water1_BeamBreak,num2str(binnedEventsTimetable.Water1_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color','b');
end
box off
hold on;
bar(dateTimes, binnedEventsTimetable.Water1_Dispense);
ylabel('Water 1');
ylim([0,graphProperties.yAxisMaxCount]);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water1_Dispense),binnedEventsTimetable.Water1_Dispense,num2str(binnedEventsTimetable.Water1_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center');
end
legend('BeamBreak','Dispense')

axH(2) = subplot(4,1,2);
bar(dateTimes, binnedEventsTimetable.Water2_BeamBreak);
if graphProperties.beambreak.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water2_BeamBreak),binnedEventsTimetable.Water2_BeamBreak,num2str(binnedEventsTimetable.Water2_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color','b');
end
box off
hold on;
bar(dateTimes, binnedEventsTimetable.Water2_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Water2_Dispense),binnedEventsTimetable.Water2_Dispense,num2str(binnedEventsTimetable.Water2_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center');
end
ylabel('Water 2');
ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
legend('BeamBreak','Dispense')

axH(3) = subplot(4,1,3);
bar(dateTimes, binnedEventsTimetable.Food1_BeamBreak);
if graphProperties.beambreak.labels.shouldShow
    text(1:length(binnedEventsTimetable.Food1_BeamBreak),binnedEventsTimetable.Food1_BeamBreak,num2str(binnedEventsTimetable.Food1_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color','b');
end
box off
hold on;
bar(dateTimes, binnedEventsTimetable.Food1_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Food1_Dispense),binnedEventsTimetable.Food1_Dispense,num2str(binnedEventsTimetable.Food1_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center');
end
ylabel('Food 1');
ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
legend('BeamBreak','Dispense')

axH(4) = subplot(4,1,4);
bar(dateTimes, binnedEventsTimetable.Food2_BeamBreak);
if graphProperties.beambreak.labels.shouldShow
text(1:length(binnedEventsTimetable.Food2_BeamBreak),binnedEventsTimetable.Food2_BeamBreak,num2str(binnedEventsTimetable.Food2_BeamBreak),'vert',graphProperties.verticalLabelAlignment,'horiz','center','color','b');
end
box off
hold on;
bar(dateTimes, binnedEventsTimetable.Food2_Dispense);
if graphProperties.dispense.labels.shouldShow
    text(1:length(binnedEventsTimetable.Food2_Dispense),binnedEventsTimetable.Food2_Dispense,num2str(binnedEventsTimetable.Food2_Dispense),'vert',graphProperties.verticalLabelAlignment,'horiz','center');
end
ylabel('Food 2');
ylim([0,graphProperties.yAxisMaxCount]);
% ylim([0,maxBeamBreakCount]);
legend('BeamBreak','Dispense')

dynamicDateTicks(axH, 'link', 'mm/dd')

sgtitle(title)
end

