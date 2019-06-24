function CellPlaceField(file1,file2,smoothed_occupancy_map,SStable)
smoothed_txy = importdata(file1);
sleepboxtime = importdata(file2);
[~,basename] = fileparts(cd);
basepath = cd;
occmap = importdata(smoothed_occupancy_map);
[S,shank,cellIx] = LoadSpikeData(basename);
StableCells = load(SStable);
goodshanks = StableCells.shank;
goodcells = StableCells.cellIx;
good = [];
for i = 1:length(goodshanks)
    for j = 1:length(shank)
        if shank(j)==goodshanks(i) && cellIx(j)==goodcells(i)
            good(end+1) = j;
        end
    end
    
end

for NOC = good
    a = 1;
    timestamps = zeros(length(S{NOC}),1);
    timestamps = TimePoints(S{NOC})-sleepboxtime;
    mint = find(timestamps >= 0,1);
    maxt = find(timestamps <= smoothed_txy.p(end,1),1,'last');
    TSlength = 0;
    TimeSpace = zeros(1,6);
    for i = mint:maxt
        for j = a: length(smoothed_txy.p(:,1))
            if timestamps(i) >= smoothed_txy.p(j,1)-1/2*0.0333 && timestamps(i) < smoothed_txy.p(j,1)+1/2*0.0333 && ~isnan(smoothed_txy.p(j,2)) 
                TSlength = TSlength + 1; 
                TimeSpace(TSlength,1) = timestamps(i);
                TimeSpace(TSlength,2:5) = smoothed_txy.p(j,2:5);
                TimeSpace(TSlength,6) = smoothed_txy.trial(j,1);
                a = j;
                break
            end
        end
    end
    TimeSpace = TimeSpace(1:TSlength,:);
    
    field_map.count = zeros(26,26);
    field_map.time = zeros(26,26);
    field_map.frequency = [];

    maxGap = 0.0334;
    dt = diff(smoothed_txy.p(:,1));
    dt(end+1)=dt(end);
    dt(dt>maxGap) = maxGap;
    for k = 1:length(TimeSpace(:,1))
        field_map.count(TimeSpace(k,4),TimeSpace(k,5)) = field_map.count(TimeSpace(k,4),TimeSpace(k,5))+1;
    end
    for i = 1:length(smoothed_txy.p(:,1))
        field_map.time(smoothed_txy.p(i,4),smoothed_txy.p(i,5)) = field_map.time(smoothed_txy.p(i,4),smoothed_txy.p(i,5))+dt(i);
    end
    
    final_map = field_map.count./occmap;
    field_map.frequency = field_map.count./field_map.time;
    
    nan_map = isnan(final_map);
    for i =1:length(final_map(:,1))
        for j = 1:length(final_map(:,1))
            if nan_map(i,j) == 1
               final_map(i,j) = 0;
            end
        end
    end
    
    filename = strcat('Shank',num2str(shank(NOC)),'_Cell',num2str(cellIx(NOC)));
    final_map = imgaussfilt(final_map,1);
    imagesc(final_map); title(strcat('Shank',num2str(shank(NOC)),' Cell',num2str(cellIx(NOC))));
    axis equal
    
    save(fullfile(basepath,'/PlaceFieldsStable/FiringInformation',[filename '_txy']),'TimeSpace');
    savefig(fullfile(basepath,'/PlaceFieldsStable/Map',filename));
    saveas(gcf,fullfile(basepath,'/PlaceFieldsStable/Map',filename),'png');
    save(fullfile(basepath,'/PlaceFieldsStable/FiringInformation',[filename '_final_map']),'final_map');
    close all        
end


