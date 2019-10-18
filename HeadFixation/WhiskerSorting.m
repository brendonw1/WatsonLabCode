% To analyze outputs from PiezoMUA.m (i.e., piezo-locked MUA from S1
% cortical layers) for whisker-barrel somatotopy under anesthesia. It
% compares data from a stationary linear probe recorded while stimulating
% one whisker at a time. Data to be compared (across channels): mean Z
% score during piezo, and latency to response peak.
%
%
%
% USAGE ___________________________________________________________________
% - Keep outputs from PiezoMUA.m available in the workspace, and run. Such
%   outputs are 1 x n structures, n being the number of chunks (whiskers).
%
%
%
% LSBuenoJr _______________________________________________________________



%% Sorts whiskers based on averaged Z scores and latencies (across channels).
% This will control the order with which areas and bars are plotted.
sortedWhiskers  = cell(length(stackedChannels),5);
for i           = 1:length(stackedChannels)
    % Retrieving whisker IDs
    sortedWhiskers{i,1} = stackedChannels(i).whiskerID;
    
    % Mean Z score during piezo (with smoothing for the figure)
    sortedWhiskers{i,2} = smooth(stackedChannels(i).meanZscDurPiezo,...
        10,'sgolay');
    
    % Mean Z score during piezo averaged into a single value per whisker
    sortedWhiskers{i,3} = mean(stackedChannels(i).meanZscDurPiezo);
    
    % Latency to peak response (in ms; with smoothing for the figure)
    sortedWhiskers{i,4} = smooth(stackedChannels(i).peakLatencyMS,...
        10,'sgolay');

    % Peak latencies averaged into a single value per whisker
    sortedWhiskers{i,5} = mean(stackedChannels(i).peakLatencyMS);
end



%% Puts some RGB and facealpha values into cells. Colors will be assigned
% to whiskers in a fixed manner. Facealphas, on the other hand, will be
% increasingly transparent over successive area plots.
colors = [get(gca,'ColorOrder');get(gca,'ColorOrder')+0.05];figure;
alphas = 1:-0.05:0.35;alphas = alphas';
colorsAlphas = cell(length(colors),2);
for i = 1:length(colors)
    colorsAlphas{i,1} = colors(i,:);
    colorsAlphas{i,2} = alphas(i);
end;clear colors alphas

sortedWhiskers  = [sortrows(sortedWhiskers,3,'descend') ...
    colorsAlphas(1:size(sortedWhiskers,1),1) ...
    colorsAlphas(1:size(sortedWhiskers,1),2)]; 

sortedZscores   = sortedWhiskers(:,[1:3 6:7]);
sortedLatencies = sortrows(sortedWhiskers(:,[1 4:6]),3,'descend');
sortedLatencies = [sortedLatencies ...
    colorsAlphas(1:size(sortedLatencies,1),2)];
clear sortedWhiskers colorsAlphas



%% Figure
% Top left
figure;subplot('position',[0.05 0.35 0.40 0.60]);
for i = 1:size(sortedZscores,1)
    a = area(sortedZscores{i,2});
    a.FaceColor = sortedZscores{i,4};
    a.FaceAlpha = sortedZscores{i,5};hold on
end;xlim([1 64]);camroll(-90)
ylim([floor(min(cell2mat(sortedZscores(:,2)))*10)/10 ...
    ceil(max(cell2mat(sortedZscores(:,2)))*10)/10]);
xlabel('Channels across S1 layers')
ylabel('Mean Z scored MUA during piezo')

% Top right
subplot('position',[0.54 0.35 0.40 0.60]);
for i = 1:size(sortedLatencies,1)
    a = area(sortedLatencies{i,2});
    a.FaceColor = sortedLatencies{i,4};
    a.FaceAlpha = sortedLatencies{i,5};hold on
end;xlim([1 64]);camroll(-90);clear a
ylim([(floor(min(cell2mat(sortedLatencies(:,2)))*10)/10)-50 ...
    (ceil(max(cell2mat(sortedLatencies(:,2)))*10)/10)+50]);
xticklabels([]);ylabel('Latency of first MUA response peak (ms)')

% Bottom left
subplot('position',[0.05 0.10 0.40 0.20]);
b            = bar(cell2mat(sortedZscores(:,3)));
b.FaceColor  = 'flat';
for i = 1:size(sortedZscores,1)
    b.CData(i,:) = sortedZscores{i,4};
end
xticklabels(cell2mat(sortedZscores(:,1)))
ylabel('Z score');xlabel('Whiskers')

% Bottom right
sortedLatencies = sortrows(sortedLatencies,3);
subplot('position',[0.54 0.10 0.40 0.20]);
b            = bar(cell2mat(sortedLatencies(:,3)));
b.FaceColor  = 'flat';
for i = 1:size(sortedLatencies,1)
    b.CData(i,:) = sortedLatencies{i,4};
end;xticklabels(cell2mat(sortedLatencies(:,1)))
ylabel('Latency (ms)');clear b i