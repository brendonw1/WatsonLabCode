% PaulsData.weight = AnimalWeightData;
% PaulsData.regularWaterConsumed = WaterData(:,1);
% PaulsData.sucroseWaterConsumed = WaterData(:,2);


%% Data starts on 6/5/2019 and spans until
paulPlotProperties.shouldShowEvents = true;
paulPlotProperties.lineThickness = 3;
paulPlotProperties.markerSize = 4;



figure(5);
%% Plot the animal's weight:
plot(dayIntoExperiment(1:length(PaulsData.weight)),PaulsData.weight, '-o', 'LineWidth',paulPlotProperties.lineThickness, 'MarkerSize',paulPlotProperties.markerSize, 'Color', 'g');
title('Weight [g]')
ylabel('Mouse Weight [g] at 4:00pm')
xlabel('Days into experiment')
box off
hold on;
if graphProperties.shouldShowEvents
   xline(15,'-',{'Lifted Water' 'Ports'});
   xline(22,'-',{'Changed to' 'Sucrose Water'}); 
end


% figure(6);
% %% Plot the measured water consumed
% plot(dayIntoExperiment(1:length(PaulsData.weight)),PaulsData.regularWaterConsumed, '-o', 'LineWidth',paulPlotProperties.lineThickness, 'MarkerSize',paulPlotProperties.markerSize);
% box off
% hold on;
% plot(dayIntoExperiment(1:length(PaulsData.weight)),PaulsData.sucroseWaterConsumed, '-o', 'LineWidth',paulPlotProperties.lineThickness, 'MarkerSize',paulPlotProperties.markerSize);
% if graphProperties.shouldShowEvents
%    xline(15,'-',{'Lifted Water' 'Ports'});
%    xline(22,'-',{'Changed to' 'Sucrose Water'}); 
% end
% title('Measured Water Consumed [mL]')
% ylabel('Water Consumed [mL] at 4:00pm')
% xlabel('Days into experiment')
% legend('regular water', '1% sucrose water');


