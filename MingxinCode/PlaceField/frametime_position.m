function [txy,occmap] = frametime_position(file1,file2)
data = LoadBinary_FMA(file1,'nChannels',2,'channels',2);
[pathstr,name,~] = fileparts(file2);
frequency = 20000;
frameperiod = continuousabove2(data,0,100,100000)/frequency*2; % special for video recording???
frametime = mean(frameperiod,2);

load(file2);
RedLED = whl.p(:,1:2);
BlueLED = whl.p(:,3:4);
[n,~] = size(whl.p);
count = 0;

for i = 1:n
    if RedLED(i,1)==-1
        count = count+1;
    else if count > 50
            for p = 1:count
                RedLED(i-p,:) = BlueLED(i-p,:);
            end
            count = 0;
        else
            for p = 1:count
                RedLED(i-p,:) = p/count*RedLED(i-count-1,:)+(1-p/count)*RedLED(i,:);
            end
            count = 0;
        end
    end
end

Position = (RedLED+BlueLED)./2;

txy.p = NaN(n,3);
for i = 1:n
    if Position(i,1)~=0 && Position(i,2)~=0 && Position(i,1)<=410
        %for c3po_160406,change according to cheeseboard position in different videos
        txy.p(i,2:3) = Position(i,:);
    end
end
txy.p(:,1) = frametime(end-2-n:end-3);
txy.trial = whl.trial;


% modify by velocity & smooth
length_smoothed_txy = 0;
for j = 1:length(txy.p(:,1))
    if ~isnan(txy.p(j,2))
        length_smoothed_txy = length_smoothed_txy+1;
        raw_txy.p(length_smoothed_txy,1:3) = txy.p(j,1:3);
        raw_txy.trial(length_smoothed_txy,1) = txy.trial(j);
    end
end

edges = cell(1,2);
edges{1} = 0:20:500;
edges{2} = 0:20:500;
raw_occmap = hist3(raw_txy.p(:,2:3),'Edges',edges); 
figure;imagesc(raw_occmap)
axis equal
save(fullfile(pathstr,['Original_occupancy_by_position_' name(7:14)]),'raw_txy');
save(fullfile(pathstr,['Original_occupancy_map_' name(7:14)]),'raw_occmap');

smoothed_txy.p(:,1) = raw_txy.p(:,1);
smoothed_txy.p(:,2:3) = Smooth(raw_txy.p(:,2:3),[5 0]);
smoothed_txy.trial = raw_txy.trial;
smoothed_v = LinearVelocity(raw_txy.p(:,1:3),5);
smoothed_v(:,2) = smoothed_v(:,2)./380*120;

% diff_x = diff(txy(:,2));
% diff_y = diff(txy(:,3));
% diff_t = diff(txy(:,1));
% v = sqrt(diff_x.^2+diff_y.^2)./diff_t/380*120; % 380 pixels for 120cm diameter of cheeseboard
% average_v = mean(v,'omitnan');
% % std_v = std(v,'omitnan');

slow = find(smoothed_v(:,2)<5);
uncontinuous = find(diff(slow)<9 & diff(slow)>1);

smoothed_txy.p(:,4) = fix(smoothed_txy.p(:,2)/20)+1;
smoothed_txy.p(:,5) = fix(smoothed_txy.p(:,3)/20)+1;
move_from_bins = find(abs(diff(smoothed_txy.p(:,4)))+abs(diff(smoothed_txy.p(:,5)))>0);

smoothed_txy.p(slow,2:3) = NaN;
smoothed_v(slow,2) = NaN;
for m = 1:length(uncontinuous)
    smoothed_v(slow(uncontinuous(m))+1:slow(uncontinuous(m)+1)-1,2) = NaN;
    smoothed_txy.p(slow(uncontinuous(m))+1:slow(uncontinuous(m)+1)-1,2:3) = NaN;
end
for n = 1:length(move_from_bins)-1
    if move_from_bins(n+1) - move_from_bins(n) < 3
        smoothed_v(move_from_bins(n)+1:move_from_bins(n+1),2) = NaN;
        smoothed_txy.p(move_from_bins(n)+1:move_from_bins(n+1),2:3) = NaN;
    end
end

edges = cell(1,2);
edges{1} = 0:20:500;
edges{2} = 0:20:500;
occmap = hist3(smoothed_txy.p(:,2:3),'Edges',edges); 
figure;imagesc(occmap)
axis equal
% viscircle(reward_pts,[15;15;15]);
save(fullfile(pathstr,['Smoothed_occupancy_by_position_' name(7:14)]),'smoothed_txy');
save(fullfile(pathstr,['Smoothed_Occupancy_map_' name(7:14)]),'occmap');

