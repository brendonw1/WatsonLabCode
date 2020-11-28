function map = PlayPlaceField(RawPositionInfo,SmoothedPositionInfo,FiringInfoPath,RawOccmap,SmoothedOccmap,RewardPts,varargin)
raw_txy = importdata(RawPositionInfo);
smoothed_txy = importdata(SmoothedPositionInfo);
FiringFiles = dir(fullfile(cd,FiringInfoPath,'*_txy.mat'));

raw_occmap = importdata(RawOccmap);
smoothed_occmap = importdata(SmoothedOccmap);
rewards = importdata(RewardPts);
reward_pts(:,2) = rewards(:,1)/20+0.5;
reward_pts(:,1) = rewards(:,2)/20+0.5;
first = 5;
last = 5;
totalTrial = max(smoothed_txy.trial);
every = fix((totalTrial-first-last)/3);

for a = 1:length(FiringFiles)
    
    TimeSpace = importdata(FiringFiles(a).name);
    if ~isempty(TimeSpace)
        FigName = char(FiringFiles(a).name(1:end-8));
        for b = 1:length(FigName)
            if FigName(b) =='_'
                FigName(b) = ' ';
            end
        end
        maxFrequency = 0;
        maxTime = 0;
        maxCount = 0;
        
        for i = 1:2:length(varargin),
            if ~ischar(varargin{i}),
                error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help Map">Map</a>'' for details).']);
            end
            switch(lower(varargin{i})),
                case 'first',
                    first = varargin{i+1};
                    if ~isivector(first,'>0') || length(first) > 2,
                        error('Incorrect value for property ''first'' (type ''help <a href="matlab:help Map">Map</a>'' for details).');
                    end
                case 'last',
                    last = varargin{i+1};
                    if ~isivector(last,'>0') || length(last) > 2,
                        error('Incorrect value for property ''last'' (type ''help <a href="matlab:help Map">Map</a>'' for details).');
                    end
                    every = fix((totalTrial-first-last)/3);
                case 'every',
                    every = varargin{i+1};
                    if ~isivector(every,'>0') || length(every) > 2,
                        error('Incorrect value for property ''every'' (type ''help <a href="matlab:help Map">Map</a>'' for details).');
                    end
            end
        end
        
        Trial1 = 0;
        Trial2 = 0;
        
        if ~isempty(first)
            Trial1 = 1;
            Trial2 = first;
            map{1} = PlaceFieldCertainTrials(smoothed_txy,TimeSpace,Trial1,Trial2);
        end
        
        if ~isempty(every)
            i = 2;
            for i = 2:fix((totalTrial-first-last)/every)+1
                Trial1 = (i-2)*every+first+1;
                Trial2 = (i-1)*every+first;
                if ~isempty(last) && Trial2+every > totalTrial-last
                    Trial2 = totalTrial-last;
                end
                map{i} = PlaceFieldCertainTrials(smoothed_txy,TimeSpace,Trial1,Trial2);
            end
        end
        
        if ~isempty(last)
            i = i+1;
            Trial1 = totalTrial-last+1;
            Trial2 = totalTrial;
            map{i} = PlaceFieldCertainTrials(smoothed_txy,TimeSpace,Trial1,Trial2);
        end
        
        for j = 1:i
            digits(4);
            totalTime(j) = sum(sum(map{j}.Time));
            totalCounts(j) = sum(sum(map{j}.FiringCount));
            AverageFrequency(j) = totalCounts(j)/totalTime(j);
            MapPrediction{j} = map{1}.Frequency.*map{j}.Time/totalTime(j)*1000;
            SmoothedMapPrediction{j} = imgaussfilt(MapPrediction{j},1);
            x{j} = map{j}.SmoothedFiringCount.*1000/totalTime(j);
            %         map_perTrial{j} = PlaceFieldCertainTrials(smoothed_txy,TimeSpace,j,j);
            %         if max(max(map{j}.Frequency)) > maxFrequency
            %             maxFrequency = max(max(map{j}.Frequency));
            %         end
            if max(max(map{j}.SmoothedFrequency)) > maxFrequency
                maxFrequency = max(max(map{j}.SmoothedFrequency));
            end
            %         if max(max(map_perTrial{j}.Frequency)) > maxFrequency
            %             maxFrequency = max(max(map_perTrial{j}.Frequency));
            %         end
            if max(max(map{j}.Time)) > maxTime
                maxTime = max(max(map{j}.Time));
            end
            if max(max(x{j})) > maxCount
                maxCount = max(max(map{j}.SmoothedFiringCount));
            end
            if max(max(SmoothedMapPrediction{j})) > maxCount
                maxCount = max(max(SmoothedMapPrediction{j}));
            end
        end
        
        for j = 1:i
            digits(4);
            totalTime = sum(sum(map{j}.Time));
            totalCounts = sum(sum(map{j}.FiringCount));
            AverageFrequency = totalCounts/totalTime;
            
            subplot(i,4,4*j-3);
            imagesc(map{j}.SmoothedFrequency);
            if j ==1
                title('Frequency Map');
            end
            ylabel(map{j}.name);
            xlabel([num2str(AverageFrequency) ' Hz']);
            axis xy equal tight
            colorbar
            caxis([0 maxFrequency])
            viscircles(reward_pts,[1;1;1],'LineWidth',1);
            
            subplot(i,4,4*j-2);
            imagesc(map{j}.Time);
            if j ==1
                title('Occupancy Map');
            end
            %         title([map{j}.name ' Occupancy Map']);
            xlabel([num2str(totalTime) ' s']);
            axis xy equal tight
            colorbar
            caxis([0 maxTime])
            viscircles(reward_pts,[1;1;1],'LineWidth',1);
            
            subplot(i,4,4*j-1);
            imagesc(SmoothedMapPrediction{j});
            if j==1
                title('Predicted Count Map');
            end
            %         title([map{j}.name ' Predicted Count Map']);
            xlabel(sum(sum(MapPrediction{j})));
            axis xy equal tight
            colorbar
            caxis([0 maxCount])
            viscircles(reward_pts,[1;1;1],'LineWidth',1);
            
            subplot(i,4,4*j);
            imagesc(x{j});
            if j==1
                title('Real Count Map');
            end
            %         title([map{j}.name ' Real Count Map']);
            xlabel(sum(sum(x{j})));
            axis xy equal tight
            colorbar
            caxis([0 maxCount])
            viscircles(reward_pts,[1;1;1],'LineWidth',1);
            
            %         subplot(i,4,4*j-1);
            %         imagesc(map_perTrial{j}.Frequency);
            %         title(map_perTrial{j}.name);
            %         axis([0 26 0 26]);
            %         axis xy equal tight
            %         colorbar
            %         caxis([0 maxFrequency])
            %         viscircles(reward_pts,[1;1;1],'LineWidth',1);
        end
        %     subplot(i,4,4);
        %     imagesc(raw_occmap);
        %     title('Raw Occupancy Map');
        %     axis xy equal tight
        %     colorbar
        %     viscircles(reward_pts,[1;1;1],'LineWidth',1);
        %
        %     subplot(i,4,8);
        %     imagesc(smoothed_occmap);
        %     title('Smoothed Occupancy Map');
        %     axis xy equal tight
        %     colorbar
        %     viscircles(reward_pts,[1;1;1],'LineWidth',1);
        %
        %     subplot(i,4,12);
        %     start = find(raw_txy.trial>=1,1);
        %     stop = find(raw_txy.trial<=first,1,'last');
        %     plot(raw_txy.p(start:stop,2),raw_txy.p(start:stop,3));
        %     title(['Path: ' map{1}.name]);
        %     axis([0 500 0 500],'square');
        %     viscircles(rewards,[15;15;15],'LineWidth',1);
        %
        %     subplot(i,4,16);
        %     start = find(raw_txy.trial>=totalTrial-last+1,1);
        %     stop = find(raw_txy.trial<=totalTrial,1,'last');
        %     plot(raw_txy.p(start:stop,2),raw_txy.p(start:stop,3));
        %     title(['Path: ' map{i}.name]);
        %     axis([0 500 0 500],'square');
        %     viscircles(rewards,[15;15;15],'LineWidth',1);
        %
        %     subplot(i,4,20);
        %     subtraction = map{1}.Frequency-map{i}.Frequency;
        %     imagesc(subtraction);
        %     title(['Subtraction: first ' num2str(first) ' - last ' num2str(last)]);
        %     axis xy equal tight
        %     colorbar
        %     viscircles(reward_pts,[1;1;1],'LineWidth',1);
        
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        text(0.5, 1,FigName,'HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',20)
        
        savefig(fullfile('PlaceFieldsStable/FullAnalysis',[FigName '(comparison)']));
        saveas(gcf,fullfile('PlaceFieldsStable/FullAnalysis',[FigName '(comparison)']),'png');
        
    end
end

function map = PlaceFieldCertainTrials(smoothed_txy,TimeSpace,Trial1,Trial2)
basepath = cd;
% occmap = zeros(26,26);
map.FiringCount = zeros(26,26);
map.Time = zeros(26,26);
map.Frequency = [];
map.name = [];
maxGap = 0.0334;
minTime = 0.1;
dt = diff(smoothed_txy.p(:,1));
dt(end+1)=dt(end);
dt(dt>maxGap) = maxGap;

startF = find(TimeSpace(:,6)>=Trial1,1);
stopF = find(TimeSpace(:,6)<=Trial2,1,'last');
startP = find(smoothed_txy.trial>=Trial1,1);
stopP = find(smoothed_txy.trial<=Trial2,1,'last');
filename = strcat('Trial ',num2str(TimeSpace(startF,6)),' to ',num2str(TimeSpace(stopF,6)));
if isempty(startF) || isempty(startP) ||isempty(stopF) ||isempty(stopP) || startF > stopF || startP > stopP
    warning(['Firing info / position info for trial ' num2str(Trial1) ' to trial ' num2str(Trial2) ' does not exist.']);
    filename = strcat('No Information');
end
for k = startF:stopF
    map.FiringCount(TimeSpace(k,4),TimeSpace(k,5)) = map.FiringCount(TimeSpace(k,4),TimeSpace(k,5)) + 1;
end

for l = startP:stopP
    %     occmap(smoothed_txy.p(i,4),smoothed_txy.p(i,5)) = occmap(smoothed_txy.p(i,4),smoothed_txy.p(i,5)) + 1;
    if ~isnan(smoothed_txy.p(l,2))
        map.Time(smoothed_txy.p(l,4),smoothed_txy.p(l,5)) = map.Time(smoothed_txy.p(l,4),smoothed_txy.p(l,5))+dt(l);
    end
end
map.FiringCount(map.Time<minTime) = 0;

% final_map = map.count./map.time;% field_map.count./occmap;
% map.FiringCount = imgaussfilt(map.FiringCount,0.5);
% map.Time = imgaussfilt(map.Time,0.5);
map.Frequency = map.FiringCount./map.Time;

nan_map = isnan(map.Frequency);
for m =1:length(map.Frequency(:,1))
    for n = 1:length(map.Frequency(:,1))
        if nan_map(m,n) == 1
            map.Frequency(m,n) = 0;
        end
    end
end
map.SmoothedFrequency = imgaussfilt(map.Frequency,1);
map.SmoothedFiringCount = imgaussfilt(map.FiringCount,1);
map.name = filename;
