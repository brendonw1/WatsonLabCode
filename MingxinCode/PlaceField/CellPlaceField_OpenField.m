function CellPlaceField_OpenField(file1,TimeSeparations,smoothed_occupancy_map)
smoothed_txy = importdata(file1);
load(TimeSeparations);
sleepboxtime = TimeSeparations(5);
[~,basename] = fileparts(cd);
basepath = cd;
occmap = importdata(smoothed_occupancy_map);
% load(fullfile([basename '_SStable.mat']),'S','shank','cellIx');
goodshanks = [4:5, 7:11];
[S,shank,cellIx] = LoadSpikeData(basename,goodshanks);

for NOC = 1:length(S)
    a = 1;
    timestamps = zeros(length(S{NOC}),1);
    timestamps = TimePoints(S{NOC})-sleepboxtime;
    mint = find(timestamps >= 0,1);
    maxt = find(timestamps <= smoothed_txy(end,1),1,'last');
    TSlength = 0;
    TimeSpace = zeros(1,5);
    for i = mint:maxt
        for j = a: length(smoothed_txy(:,1))
            if timestamps(i) >= smoothed_txy(j,1)-1/2*0.0333 && timestamps(i) < smoothed_txy(j,1)+1/2*0.0333 && ~isnan(smoothed_txy(j,2)) 
                TSlength = TSlength + 1; 
                TimeSpace(TSlength,1) = timestamps(i);
                TimeSpace(TSlength,2:5) = smoothed_txy(j,2:5);
                a = j;
                break
            end
        end
    end
    TimeSpace = TimeSpace(1:TSlength,:);
    
    field_map.count = zeros(size(occmap));
    field_map.time = zeros(size(occmap));
    field_map.frequency = [];

    maxGap = 0.0334;
    dt = diff(smoothed_txy(:,1));
    dt(end+1)=dt(end);
    dt(dt>maxGap) = maxGap;
    for k = 1:length(TimeSpace(:,1))
        field_map.count(TimeSpace(k,4),TimeSpace(k,5)) = field_map.count(TimeSpace(k,4),TimeSpace(k,5))+1;
    end
    for i = 1:length(smoothed_txy(:,1))
        if ~isnan(smoothed_txy(:,2))
           field_map.time(smoothed_txy(i,4),smoothed_txy(i,5)) = field_map.time(smoothed_txy(i,4),smoothed_txy(i,5))+dt(i);
        end
    end
    
    final_map = field_map.count./occmap;
    field_map.frequency = field_map.count./field_map.time;
    
    nan_map = isnan(final_map);
    for i =1:length(final_map(:,1))
        for j = 1:length(final_map(1,:))
            if nan_map(i,j) == 1
               final_map(i,j) = 0;
            end
        end
    end
    
    filename = strcat('Shank',num2str(shank(NOC)),'_Cell',num2str(cellIx(NOC)));
    final_map = imgaussfilt(final_map,1);
    imagesc(final_map); title(strcat('Shank',num2str(shank(NOC)),'  Cell',num2str(cellIx(NOC)),'  1obj (test)'))
    axis equal
    
%     if ~isdir(fullfile('.../PlaceField',filename))
%         mkdir('PlaceField',filename);
%     end
%     
    save(fullfile(basepath,'/PlaceField',filename,[filename '_txy_1obj (test)']),'TimeSpace');
    savefig(fullfile(basepath,'/PlaceField',filename,[filename '_1obj (test)']));
%     saveas(gcf,fullfile(basepath,filename,filename),'png');
    save(fullfile(basepath,'/PlaceField',filename,[filename '_final_map_1obj (test)']),'final_map');       
end


