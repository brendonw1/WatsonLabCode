function frametime_position_openfield(analogin, LEDs)
data = LoadBinary_FMA(analogin,'nChannels',2,'channels',2);
[pathstr,name,~] = fileparts(LEDs);
frequency = 20000;
frameperiod = continuousabove2(data,0,100,100000)/frequency; % special for video recording???
frametime = mean(frameperiod,2);

load(LEDs);
[n,~] = size(whl);
count = 0;
whl(end+1,:) = zeros(4,1);
startpts = [70 80];

for i = 1:n+1
    if whl(i,3)==-1
        count = count+1;
    elseif count > 0 && count <= 40 && sum(abs(whl(i,3:4)-whl(i-count-1,3:4))) <= 30
        for p = 1:count
            whl(i-p,3:4) = p/count*whl(i-count-1,3:4)+(1-p/count)*whl(i,3:4);
        end
        count = 0;
    elseif count > 0 && (count > 40 || sum(abs(whl(i,3:4)-whl(i-count-1,3:4)))> 30)
        for p = 1:count
            if whl(i-p,1)~=-1
            whl(i-p,3:4) = whl(i-p,1:2);
            end
        end
        count = 0;
    end
end

for i = 1:n+1
    if whl(i,1)==-1
        count = count+1;
    elseif count > 0 && count <= 40 && sum(abs(whl(i,1:2)-whl(i-count-1,1:2))) <= 30
        for p = 1:count
            whl(i-p,1:2) = p/count*whl(i-count-1,1:2)+(1-p/count)*whl(i,1:2);
        end
        count = 0;
    elseif count>0 && (count > 40 || sum(abs(whl(i,1:2)-whl(i-count-1,1:2))) > 30)
        for p = 1:count
            if whl(i-p,3)~= -1
            whl(i-p,1:2) = whl(i-p,3:4);
            end
        end
        count = 0;
    end
end

% whl(55302:end,:) = 0;

Position = (whl(:,1:2)+whl(:,3:4))./2;

txy = NaN(n,3);
for i = 1:n
    if Position(i,1)~=-1 && Position(i,1)~=0
        %for c3po_160406,change according to cheeseboard position in different videos
        txy(i,2:3) = Position(i,:);
    end
end
txy(:,1) = frametime(end-n-2:end-3);


% modify by velocity & smooth
length_smoothed_txy = 0;
for j = 1:length(txy(:,1))
    if ~isnan(txy(j,2))
%         if txy()
        length_smoothed_txy = length_smoothed_txy+1;
        raw_txy(length_smoothed_txy,1:3) = txy(j,1:3);
%         raw_txy.trial(length_smoothed_txy,1) = txy.trial(j);
    end
end

edges = cell(1,2);
edges{1} = 0:11:461;
edges{2} = 0:11:274;
submatrix = zeros(length(raw_txy(:,1)),2);
submatrix(:,1) = startpts(1);
submatrix(:,2) = startpts(2);
raw_occmap = hist3(raw_txy(:,2:3)-submatrix,'Edges',edges); 
figure;imagesc(raw_occmap)
axis equal
save(fullfile(pathstr,['Original_occupancy_by_position_' name(7:end)]),'raw_txy');
save(fullfile(pathstr,['Original_occupancy_map_' name(7:end)]),'raw_occmap');

smoothed_txy(:,1) = raw_txy(:,1);
smoothed_txy(:,2:3) = Smooth(raw_txy(:,2:3),[5 0]);
smoothed_v = LinearVelocity(raw_txy(:,1:3),5);
smoothed_v(:,2) = smoothed_v(:,2)./400*181;

% diff_x = diff(txy(:,2));
% diff_y = diff(txy(:,3));
% diff_t = diff(txy(:,1));
% v = sqrt(diff_x.^2+diff_y.^2)./diff_t/380*120; % 380 pixels for 120cm diameter of cheeseboard
% average_v = mean(v,'omitnan');
% % std_v = std(v,'omitnan');

slow = find(smoothed_v(:,2)<1);
uncontinuous = find(diff(slow)<9 & diff(slow)>1);

smoothed_txy(:,4) = fix((smoothed_txy(:,2)-submatrix(:,1))/11)+1;
smoothed_txy(:,5) = fix((smoothed_txy(:,3)-submatrix(:,2))/11)+1;
move_from_bins = find(abs(diff(smoothed_txy(:,4)))+abs(diff(smoothed_txy(:,5)))>0);

smoothed_txy(slow,2:3) = NaN;
smoothed_v(slow,2) = NaN;
for m = 1:length(uncontinuous)
    smoothed_v(slow(uncontinuous(m))+1:slow(uncontinuous(m)+1)-1,2) = NaN;
    smoothed_txy(slow(uncontinuous(m))+1:slow(uncontinuous(m)+1)-1,2:3) = NaN;
end
for n = 1:length(move_from_bins)-1
    if move_from_bins(n+1) - move_from_bins(n) < 3
        smoothed_v(move_from_bins(n)+1:move_from_bins(n+1),2) = NaN;
        smoothed_txy(move_from_bins(n)+1:move_from_bins(n+1),2:3) = NaN;
    end
end

occmap = hist3(smoothed_txy(:,2:3)-submatrix,'Edges',edges); 
figure;imagesc(occmap)
axis equal
% viscircle(reward_pts,[15;15;15]);
save(fullfile(pathstr,['Smoothed_occupancy_by_position_' name(7:end)]),'smoothed_txy');
save(fullfile(pathstr,['Smoothed_Occupancy_map_' name(7:end)]),'occmap');