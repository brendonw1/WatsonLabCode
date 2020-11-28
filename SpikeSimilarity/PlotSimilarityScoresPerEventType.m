function [outstruct,h] = PlotSimilarityScoresPerEventType(dotm,corrm,distm,sov)


minsharedcells = 3;

outstruct.dotm = dotm;
outstruct.corrm = corrm;
outstruct.distm = distm;

outstruct.minsharedcells = minsharedcells;
outstruct.availoverlaps = unique(sov);
outstruct.availoverlaps(outstruct.availoverlaps<minsharedcells) = [];

% outcell = cell(2,length(availoverlaps);

tgood = sov > minsharedcells;
tdotm0 = dotm;
tcorrm0 = corrm;
tdistm0 = distm;
tov0(~tgood) = 0;
tdotm0(~tgood) = 0;
tcorrm0(~tgood) = 0;
tdistm0(~tgood) = 0;

outstruct.meandotscorepertime = sum(tdotm0,2)./sum(tgood,2);
outstruct.meancorrscorepertime = sum(tcorrm0,2)./sum(tgood,2);
outstruct.meandistscorepertime = sum(tdistm0,2)./sum(tgood,2);

for a = 1:length(outstruct.availoverlaps)
    tnov = outstruct.availoverlaps(a);
    outstruct.nums(a) = tnov;
    tov = sov;
    tdotm = dotm;
    tcorrm = corrm;
    tdistm = distm;
    tdotm0 = dotm;
    tcorrm0 = corrm;
    tdistm0 = distm;

    tgood = tov==tnov;
    
    tov(~tgood) = NaN;
    tdotm(~tgood) = NaN;
    tcorrm(~tgood) = NaN;
    tdistm(~tgood) = NaN;
    tov0(~tgood) = 0;
    tdotm0(~tgood) = 0;
    tcorrm0(~tgood) = 0;
    tdistm0(~tgood) = 0;
    
    outstruct.numevtspertime(a,:) = sum(tgood,1);
    
    outstruct.dotoverallmeans(a) = mean(tdotm(~isnan(tdotm)));
    outstruct.corroverallmeans(a) = mean(tcorrm(~isnan(tcorrm)));
    outstruct.distoverallmeans(a) = mean(tdistm(~isnan(tdistm)));

    outstruct.dotoverallsds(a) = std(tdotm(~isnan(tdotm)));
    outstruct.corroverallsds(a) = std(tcorrm(~isnan(tcorrm)));
    outstruct.distoverallsds(a) = std(tdistm(~isnan(tdistm)));    
    
    outstruct.meandotscorepertimeperovnum(a,:) = sum(tdotm0,2)./sum(tgood,2);
    outstruct.meancorrscorepertimeperovnum(a,:) = sum(tcorrm0,2)./sum(tgood,2);
    outstruct.meandistscorepertimeperovnum(a,:) = sum(tdistm0,2)./sum(tgood,2);    

    outstruct.meandotscorepertimeperovnumZ(a,:) = (outstruct.meandotscorepertimeperovnum(a,:)-outstruct.dotoverallmeans(a))/outstruct.dotoverallsds(a);
    outstruct.meancorrscorepertimeperovnumZ(a,:) = (outstruct.meancorrscorepertimeperovnum(a,:)-outstruct.corroverallmeans(a))/outstruct.corroverallsds(a);
    outstruct.meandistscorepertimeperovnumZ(a,:) = (outstruct.meandistscorepertimeperovnum(a,:)-outstruct.distoverallmeans(a))/outstruct.distoverallsds(a);
end


h = [];
numtodisp = 5;
% div = range(availoverlaps)/3;
% ovnums = min(outstruct.availoverlaps)+round(div*[0 1 2 3]);
ovnums = round(logspace(log10(min(outstruct.availoverlaps)),log10(max(outstruct.availoverlaps)),numtodisp));

%% DotM
%- Plot matrix
h(end+1) = figure;
% subplot(8,12,[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,1)
imagesc(outstruct.dotm);
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Overall DotM matrix')

%- Smoothed mean score per event/time
% subplot(8,12,48+[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,4)
plot(smooth(outstruct.meandotscorepertime,50))
title('Mean score per event')

%- Count of num events with varying numbers of shared cells
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+2)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.numevtspertime(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end

%Ratios of counts of different share-count events
for a = 1:numtodisp
    taidx = find(outstruct.availoverlaps == ovnums(a));
    for b = a+1:numtodisp    
        tbidx = find(outstruct.availoverlaps == ovnums(b));
        subplot(9,12,(a-1)*12+(b-1)+64)
        plot(smooth(outstruct.numevtspertime(tbidx,:),50)./smooth(outstruct.numevtspertime(taidx,:),50))
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis tight
        title ([num2str(ovnums(b)) '/' num2str(ovnums(a))])    
    end
end

% Average score for each type of event
subplot(2,3,3);
plot(outstruct.nums,outstruct.dotoverallmeans,'o');
title('Mean score per num of shared cells')
xlabel('Num shared cells per pair')
ylabel('Average score')

% Timecourse of scores for pairs with each # of overlaps
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+18)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.meandotscorepertimeperovnum(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end


%% CorrM
%- Plot matrix
h(end+1) = figure;
% subplot(8,12,[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,1)
imagesc(outstruct.corrm);
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Overall CorrM matrix')

%- Smoothed mean score per event/time
% subplot(8,12,48+[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,4)
plot(smooth(outstruct.meancorrscorepertime,50))
title('Mean score per event')

%- Count of num events with varying numbers of shared cells
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+2)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.numevtspertime(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end

%Ratios of counts of different share-count events
for a = 1:numtodisp
    taidx = find(outstruct.availoverlaps == ovnums(a));
    for b = a+1:numtodisp    
        tbidx = find(outstruct.availoverlaps == ovnums(b));
        subplot(9,12,(a-1)*12+(b-1)+64)
        plot(smooth(outstruct.numevtspertime(tbidx,:),50)./smooth(outstruct.numevtspertime(taidx,:),50))
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis tight
        title ([num2str(ovnums(b)) '/' num2str(ovnums(a))])    
    end
end

% Average score for each type of event
subplot(2,3,3);
plot(outstruct.nums,outstruct.corroverallmeans,'o');
title('Mean score per num of shared cells')
xlabel('Num shared cells per pair')
ylabel('Average score')

% Timecourse of scores for pairs with each # of overlaps
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+18)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.meancorrscorepertimeperovnum(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end


%% DistM
%- Plot matrix
h(end+1) = figure;
% subplot(8,12,[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,1)
imagesc(outstruct.distm);
set(gca,'xtick',[])
set(gca,'ytick',[])
title('Overall DistM matrix')

%- Smoothed mean score per event/time
% subplot(8,12,48+[1 2 3 4 13 14 15 16 25 26 27 28 37 38 39 40])
subplot(2,3,4)
plot(smooth(outstruct.meandistscorepertime,50))
title('Mean score per event')

%- Count of num events with varying numbers of shared cells
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+2)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.numevtspertime(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end

%Ratios of counts of different share-count events
for a = 1:numtodisp
    taidx = find(outstruct.availoverlaps == ovnums(a));
    for b = a+1:numtodisp    
        tbidx = find(outstruct.availoverlaps == ovnums(b));
        subplot(9,12,(a-1)*12+(b-1)+64)
        plot(smooth(outstruct.numevtspertime(tbidx,:),50)./smooth(outstruct.numevtspertime(taidx,:),50))
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        axis tight
        title ([num2str(ovnums(b)) '/' num2str(ovnums(a))])    
    end
end

% Average score for each type of event
subplot(2,3,3);
plot(outstruct.nums,outstruct.distoverallmeans,'o');
title('Mean score per num of shared cells')
xlabel('Num shared cells per pair')
ylabel('Average score')

% Timecourse of scores for pairs with each # of overlaps
for a = 1:numtodisp
%     subplot(8,12,(a-1)*12+[5 6 7 8])
    subplot(10,3,(a-1)*3+18)
    tidx = find(outstruct.availoverlaps == ovnums(a));
    plot(smooth(outstruct.meandistscorepertimeperovnum(tidx,:),50))
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    axis tight
    title (['# Pairs with ' num2str(ovnums(a)) 'shared cells'])    
end

