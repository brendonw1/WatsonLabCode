function map = PlaceFieldComparison(SmoothedPositionInfo1,SmoothedPositionInfo2,SmoothedPositionInfo3,FiringInfoPath,RewardPts)
% raw_txy = importdata(RawPositionInfo);
smoothed_txy{1} = importdata(SmoothedPositionInfo1);
smoothed_txy{2} = importdata(SmoothedPositionInfo2);
smoothed_txy{3} = importdata(SmoothedPositionInfo3);
Cell = dir(FiringInfoPath);
% FiringFiles = dir(fullfile(cd,FiringInfoPath,'*_txy.mat'));

% raw_occmap = importdata(RawOccmap);
% smoothed_occmap = importdata(SmoothedOccmap);
rewards = importdata(RewardPts);
reward_pts(:,2) = (rewards(:,1)-70)/11+0.5;
reward_pts(:,1) = (rewards(:,2)-80)/11+0.5;

for c = 4:length(Cell)
    maxFrequency = 0;
    maxTime = 0;
    %     map = cell(3,4);
    FiringFiles(1) = dir(fullfile(cd,FiringInfoPath,Cell(c).name,'*_txy_2obj.mat'));
    FiringFiles(2) = dir(fullfile(cd,FiringInfoPath,Cell(c).name,'*_txy_1obj.mat'));
    FiringFiles(3) = dir(fullfile(cd,FiringInfoPath,Cell(c).name,'*_txy_1obj_test.mat'));
    for i = 1:length(FiringFiles)
        FiringTimeSpace = importdata(FiringFiles(i).name);
        map{i} = PlaceFieldOneThird(smoothed_txy{i},FiringTimeSpace);
        
        for j = 1:4
            %         MapPrediction{j} = map{1}.Frequency.*map{j}.Time;
            %         map_perTrial{j} = PlaceFieldOneThird(smoothed_txy,FiringTimeSpace,j,j);
            
            if max(max(map{i}{j}.Frequency)) > maxFrequency
                maxFrequency = max(max(map{i}{j}.Frequency));
            end
            if j<4 && max(max(map{i}{j}.SmoothedTime)) > maxTime
                maxTime = max(max(map{i}{j}.SmoothedTime));
            end
            %         if max(max(map_perTrial{j}.Frequency)) > maxFrequency
            %             maxFrequency = max(max(map_perTrial{j}.Frequency));
            %         end
            %         if max(max(map{j}.Time)) > maxTime
            %             maxTime = max(max(map{j}.Time));
            %         end
        end
        
    end
    %     figure;
    clf;
    ha = tight_subplot(4,6,[0.02 0.02],[0.02 0.06],[0.07 0.04]);
    
    for i = 1:length(FiringFiles)
        FigName = char(FiringFiles(i).name(end-7:end-4));
        for j = 1:4
            axes(ha(6*(j-1)+2*i-1));
            imagesc(map{i}{j}.Frequency);
            if j==1
                title([FigName ' Rate Map']);
            end
            if i==1
%                 text(0.33*(i-1)+0.3, 0.23*j-0.1,map{i}{j}.name,'Interpreter','none','HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',10)
                text(0, 24,map{i}{j}.name,'Interpreter','none','HorizontalAlignment','right','VerticalAlignment', 'top','FontSize',11,'FontWeight','bold');
            end
%             text(0.33*(i-1), 0.23*j+0.06,[num2str(map{i}{j}.AverageRate) ' Hz'],'Interpreter','none','HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',10)
            text(12, 0,[num2str(map{i}{j}.AverageRate) ' Hz'],'Interpreter','none','HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',10);
            axis xy equal tight off
            caxis([0 maxFrequency])
            if i==1
                viscircles(reward_pts,[1;1],'LineWidth',1,'LineStyle',':');
            else
                viscircles(reward_pts,[1;1],'LineWidth',1);
            end

            axes(ha(6*(j-1)+2*i));
            if j==4
                imagesc(map{i}{j}.SmoothedTime./3);
            else
                imagesc(map{i}{j}.SmoothedTime);
            end
            if j==1
                title([FigName ' Occupancy Map']);
            end
            axis xy equal tight off
            caxis([0 maxTime])
            if i==1
                viscircles(reward_pts,[1;1],'LineWidth',0.8,'LineStyle',':');
            else
                viscircles(reward_pts,[1;1],'LineWidth',0.8);
            end
        end
        
        
        hb = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        text(0.5, 1,Cell(c).name,'Interpreter','none','HorizontalAlignment','center','VerticalAlignment', 'top','FontSize',20)
        hf = axes('Position',[0.685 0.02 0.15 0.215]);
        f = colorbar(hf,'Limits',[0 maxFrequency]);
        f.Label.String = 'Frequency (Hz)';
        axis tight off
        caxis(hf,[0 maxFrequency]);
        
        ht = axes('Position',[0.837 0.02 0.15 0.215]);
        t = colorbar(ht,'Limits',[0 maxTime]);
        t.Label.String = 'Sqrt Time (sqrt s)';
        axis off
        caxis(ht,[0 maxTime]);
    end
    savefig(fullfile('PlaceField',Cell(c).name,[Cell(c).name '_full_analysis']));
    fig = gcf;
%     fig.PaperUnits = 'normalized';
%     fig.PaperPosition = [0 0 1 0.6];
%     fig.PaperSize = [fig.Position(3) fig.Position(4)];
    fig.PaperPositionMode = 'auto';
    print(fullfile('PlaceField/OutputFig/RateMapByTime',Cell(c).name),'-dpng','-r0');
%     saveas(gcf,fullfile('PlaceField/OutputFig/v2',[Cell(c).name '_v2']),'png');
end

%%
function map = PlaceFieldOneThird(smoothed_txy,TimeSpace)
basepath = cd;
maxGap = 0.0334;
minTime = 0.1;
dt = diff(smoothed_txy(:,1));
dt(end+1)=dt(end);
dt(dt>maxGap) = maxGap;

startT = 1;
stopT = 1;
startF = [];
stopF = [];
for p = 1:4
    if p<4
        map{p}.FiringCount = zeros(42,25);
        map{p}.Time = zeros(42,25);
        map{p}.Frequency = [];
        map{p}.name = [];
        stopT = find(smoothed_txy(:,1) <= p/3*smoothed_txy(end,1)+(1-3/p)*smoothed_txy(1,1),1,'last');
        for l = startT:stopT
            %     occmap(smoothed_txy.p(i,4),smoothed_txy.p(i,5)) = occmap(smoothed_txy.p(i,4),smoothed_txy.p(i,5)) + 1;
            if ~isnan(smoothed_txy(l,2))
                map{p}.Time(smoothed_txy(l,4),smoothed_txy(l,5)) = map{p}.Time(smoothed_txy(l,4),smoothed_txy(l,5))+dt(l);
            end
        end
        if ~isempty(TimeSpace)
            startF = find(TimeSpace(:,1)>=smoothed_txy(startT,1),1);
            stopF = find(TimeSpace(:,1)<=smoothed_txy(stopT,1),1,'last');
        end
        
        filename = strcat(num2str(10*(p-1)),' to  ',num2str(10*p),' min');
        if isempty(startF) || isempty(startT) ||isempty(stopF) ||isempty(stopT) || startF > stopF || startT > stopT
            warning(['Firing info / position info for time ' num2str(10*(p-1)) ' to ' num2str(10*p) ' min does not exist.']);
            %             filename = strcat(filename,' No Information');
%             filename = strcat('No Firing');
        end
        map{p}.name = filename;
        for k = startF:stopF
            map{p}.FiringCount(TimeSpace(k,4),TimeSpace(k,5)) = map{p}.FiringCount(TimeSpace(k,4),TimeSpace(k,5)) + 1;
        end
        startT = find(smoothed_txy(:,1) > smoothed_txy(stopT,1),1);
    else
        map{4}.FiringCount = map{1}.FiringCount+map{2}.FiringCount+map{3}.FiringCount;
        map{4}.Time = map{1}.Time+map{2}.Time+map{3}.Time;
        map{4}.name = strcat('Total time');
    end
    
    map{p}.FiringCount(map{p}.Time<minTime) = 0;
    
    % final_map = map.count./map.time;% field_map.count./occmap;
    % map.FiringCount = imgaussfilt(map.FiringCount,0.5);
    % map.Time = imgaussfilt(map.Time,0.5);
    map{p}.Frequency = map{p}.FiringCount./map{p}.Time;
    
    nan_map = isnan(map{p}.Frequency);
    for m =1:length(map{p}.Frequency(:,1))
        for n = 1:length(map{p}.Frequency(1,:))
            if nan_map(m,n) == 1
                map{p}.Frequency(m,n) = 0;
            end
        end
    end
    map{p}.Frequency = imgaussfilt(map{p}.Frequency,1);
    map{p}.SmoothedTime = sqrt(imgaussfilt(map{p}.Time,1));
    TotalTime = sum(sum(map{p}.Time));
    TotalFiringCount = sum(sum(map{p}.FiringCount));
    map{p}.AverageRate = TotalFiringCount/TotalTime;
    
end