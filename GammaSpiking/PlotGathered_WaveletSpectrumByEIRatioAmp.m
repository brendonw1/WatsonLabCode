function PlotGathered_WaveletSpectrumByEIRatioAmp

midgamma = [40 75];
highgamma = [50 180];

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectrumByEIRatioAmp.mat'))
saveloc = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','WaveletSpectrumByEIRatioAmp');

t = GatheredWaveletSpectrumByEIRatioAmp;


h = [];
ax = [];
c = [];
h(end+1) = figure('position',[5 5 800 600],'name','WaveletSpectrumByEIRatio');


ax(end+1) = subplot(2,3,1);
imagesc(nanmean(t.meanwavelet_w,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake')
c(end+1,:) = caxis(ax(end));

ax(end+1) = subplot(2,3,2);
imagesc(nanmean(t.meanwavelet_wm,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake_Move5')
c(end+1,:) = caxis(ax(end));

ax(end+1) = subplot(2,3,3);
imagesc(nanmean(t.meanwavelet_wnm,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake_Nonmove5')
c(end+1,:) = caxis(ax(end));

ax(end+1) = subplot(2,3,4);
imagesc(nanmean(t.meanwavelet_n,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('nonREM')
c(end+1,:) = caxis(ax(end));

ax(end+1) = subplot(2,3,5);
imagesc(nanmean(t.meanwavelet_r,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('REM')
c(end+1,:) = caxis(ax(end));

ax(end+1) = subplot(2,3,6);
imagesc(nanmean(t.meanwavelet_all,3))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('All states')
c(end+1,:) = caxis(ax(end));

set(h(end),'name','WaveletSpectrumByState_UniversalScale')
h(end+1) = copyfig(h(end));
set(h(end),'name','WaveletSpectrumByState_IndividScale')

c = [min(c(:,1)) max(c(:,2))];
for aidx = 1:length(ax)
    caxis(ax(aidx),c);
end


% Zscore fig
ax = [];
cluts = [];
h(end+1) = figure('position',[5 5 800 600],'name','WaveletSpectrumByEIRatio_SmoothZscore');

ax(end+1) = subplot(2,3,1);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_w,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake')

ax(end+1) = subplot(2,3,2);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_wm,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake_Move5')

ax(end+1) = subplot(2,3,3);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_wnm,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('Wake_Nonmove5')

ax(end+1) = subplot(2,3,4);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_n,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('nonREM')

ax(end+1) = subplot(2,3,5);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_r,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('REM')

ax(end+1) = subplot(2,3,6);
imagesc(zscore(smooth2a(nanmean(t.meanwavelet_all,3),5,1),[],2))
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',t.bandmeans{1}(yticks))
xlabel('Low -> High EIRatio')
colorbar
title('All states')


%% midgamma vs highgamma

m_wnm = nanmean(t.meanwavelet_wnm,3);
figure;RainbowPlotLinesInOrder(m_wnm)
axis tight
xt = get(gca,'xtick');
set(gca,'xticklabel',t.bandmeans{1}(xt))

z_wnm = zscore(smooth2a(nanmean(t.meanwavelet_wnm,3),5,1),[],2);
figure;RainbowPlotLinesInOrder(z_wnm)
axis tight
xt = get(gca,'xtick');
set(gca,'xticklabel',t.bandmeans{1}(xt))

1;


MakeDirSaveFigsThere(saveloc,h,'fig')
MakeDirSaveFigsThere(saveloc,h,'png')


