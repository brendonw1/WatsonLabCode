function h = PlotEventSimilarities_UPs(m,times,rates,durs,SleepStartIdxs,SleepStopIdxs)

smoothWindow = 10;
if ~exist('SleepStartIdxs','var');
    SleepStartIdxs = [];
end
if ~exist('SleepStopIdxs','var');
    SleepStopIdxs = [];
end

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
pereventmetric = sum(m,2);
bools = logical(rates);

meanrates = mean(rates,2);
sumbools = sum(bools,2);

h = [];

SleepStartTimes = times(SleepStartIdxs);
SleepStopTimes = times(SleepStopIdxs);

h(end+1) = figure;
imagesc(m);
hold on;for a = 1:length(SleepStopTimes);plot([SleepStopTimes(a) SleepStopTimes(a)],[0 size(m,2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([SleepStartTimes(a) SleepStartTimes(a)],[0 size(m,2)],'color','g','LineWidth',2);end
hold on;for a = 1:length(SleepStopTimes);plot([0 size(m,1)],[SleepStopTimes(a) SleepStopTimes(a)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([0 size(m,1)],[SleepStartTimes(a) SleepStartTimes(a)],'color','g','LineWidth',2);end
AboveTitle(['All to All Similarity between events using' celltype 'Cells'])


h(end+1) = figure('position',[1 1 560 840]);
subplot(4,1,1)
plot(times,smooth(pereventmetric,smoothWindow),'.')
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopTimes);plot([SleepStopTimes(a) SleepStopTimes(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([SleepStartTimes(a) SleepStartTimes(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('Similarity Metric','fontweight','normal')
axis tight

subplot(4,1,2)
plot(times,smooth(meanrates,smoothWindow),'.')
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopTimes);plot([SleepStopTimes(a) SleepStopTimes(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([SleepStartTimes(a) SleepStartTimes(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('Mean Rates','fontweight','normal')
axis tight

subplot(4,1,3)
plot(times,smooth(sumbools,smoothWindow),'.')
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopTimes);plot([SleepStopTimes(a) SleepStopTimes(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([SleepStartTimes(a) SleepStartTimes(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('# Participants','fontweight','normal')
axis tight

subplot(4,1,4)
plot(times,smooth(durs,smoothWindow),'.')
yl = get(gca,'ylim');
hold on;for a = 1:length(SleepStopTimes);plot([SleepStopTimes(a) SleepStopTimes(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
hold on;for a = 1:length(SleepStartTimes);plot([SleepStartTimes(a) SleepStartTimes(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
title('UP state durations','fontweight','normal')
axis tight
% 
% subplot(6,1,5)
% plot(smooth(amps,smoothWindow))
% yl = get(gca,'ylim');
% hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
% hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
% title('Spindle Max Amplitudes')
% axis tight
% 
% subplot(6,1,6)
% plot(smooth(durs,smoothWindow))
% yl = get(gca,'ylim');
% hold on;for a = 1:length(SleepStopIdxs);plot([SleepStopIdxs(a) SleepStopIdxs(a)],[yl(1) yl(2)],'color','r','LineWidth',2);end
% hold on;for a = 1:length(SleepStartIdxs);plot([SleepStartIdxs(a) SleepStartIdxs(a)],[yl(1) yl(2)],'color','g','LineWidth',2);end
% title('Spindle Duration')
% axis tight

AboveTitle(['Timecourse of measures using ' celltype 'Cells'])


h(end+1) = figure;
% mcorr_bw(perspindlemetric,meanrates,sumbools,freqs,amps,durs);
mcorr_bw(pereventmetric,meanrates,sumbools,durs);
AboveTitle(['Correlations between measures using ' celltype 'Cells'])
