function h = PlotUPEventSimilarities(m,rates,durs,SleepStartIdxs,SleepStopIdxs)

smoothWindow = 10;

% for labeling, look at caps at end of m input name
i = inputname(1);
u = FindUppercase(i);
lastlower = find(~u,1,'last');
ti = i(lastlower+1:end);
switch ti
    case 'A'
        celltype = 'All';
    case 'E'
        celltype = 'E';
    case 'I' 
        celltype = 'I';
    case 'ED'
        celltype = 'EDef';
    case 'ID' 
        celltype = 'IDef';
end

m(isnan(m)) = 0;
perUPmetric = sum(m,2);
bools = logical(rates);

meanrates = mean(rates,2);
sumbools = sum(bools,2);

h = [];

h(end+1) = figure;
imagesc(m);
hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[0 size(m,2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[0 size(m,2)],'color','g','LineWidth',2);end
hold on;for a = 1:length(SleepStopIdxs);plot([0 size(m,1)],[SleepStopIdxs(a) SleepStopIdxs(a)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([0 size(m,1)],[SleepStartIdxs(a) SleepStartIdxs(a)],'color','g','LineWidth',2);end
AboveTitle(['All to All Similarity between events using' celltype 'Cells'])


h(end+1) = figure('position',[1320 1 560 840]);
subplot(4,1,1)
plot(smooth(perUPmetric,smoothWindow))
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('Similarity Metric')
axis tight

subplot(4,1,2)
plot(smooth(meanrates,smoothWindow))
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('Mean Rates')
axis tight

subplot(4,1,3)
plot(smooth(sumbools,smoothWindow))
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('# Participants')
axis tight
% 
% subplot(6,1,4)
% plot(smooth(freqs,smoothWindow))
% yl = get(gca,'ylim');
% hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
% hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
% title('Spindle Frequency @ Max Amplitude Point')
% axis tight
% 
% subplot(6,1,5)
% plot(smooth(amps,smoothWindow))
% yl = get(gca,'ylim');
% hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
% hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
% title('Spindle Max Amplitudes')
% axis tight

subplot(4,1,4)
plot(smooth(durs,smoothWindow))
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('Spindle Duration')
axis tight

AboveTitle(['Timecourse of measures using ' celltype 'Cells'])


h(end+1) = figure;
mcorr_bw(perUPmetric,meanrates,sumbools,durs);
AboveTitle(['Correlations between measures using ' celltype 'Cells'])
