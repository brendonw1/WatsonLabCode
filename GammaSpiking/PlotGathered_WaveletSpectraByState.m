function PlotGathered_WaveletSpectraByState(freqcorrect)

if ~exist('freqcorrect','var')
    freqcorrect = 1;%multiply by f to correct for 1/f
end

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectraByState.mat'))

t = GatheredWaveletSpectraByState;
stateslist = t.stateslist;
bm = t.bandmeans{1};

broadbandgammarange = [50 180];
BBminbin = find(t.bandmeans{1}>=broadbandgammarange(1),1,'first');
BBmaxbin = find(t.bandmeans{1}<=broadbandgammarange(2),1,'last');
broadbandbins = BBminbin:BBmaxbin;

thetarange = [6 10];
Thetaminbin = find(t.bandmeans{1}>thetarange(1),1,'first');
Thetamaxbin = find(t.bandmeans{1}<thetarange(2),1,'last');
thetabandbins = Thetaminbin:Thetamaxbin;


if freqcorrect == 1
    corrector = bm;
else
    corrector = ones(size(bm));
end

x1 = nanmean(t.SpectrumForWake,1);
h = figure;
plot((x1).* corrector);
axis tight;
% set(gca,'xscale','log')
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bm),5));
set(gca,'xtick',xt)
set(gca,'xticklabel',bm(xt))

x2 = nanmean(t.SpectrumForNrem,1);
hold on;plot(x2.*corrector)
x3 = nanmean(t.SpectrumForRem,1);
hold on;plot(x3.*corrector)
x4 = nanmean(t.SpectrumForWakeMove5,1);
hold on;plot(x4.*corrector)
x5 = nanmean(t.SpectrumForWakeNonmove5,1);
hold on;plot(x5.*corrector)



legend({'Wake','Nrem','Rem','WakeMove5','WakeNonmove5'},'location','northwest')

yl = ylim;
plot([25.5 25.5],yl,'color',[.5 .5 .5])
plot([BBmaxbin BBmaxbin],yl,'color',[.5 .5 .5])
plot([Thetaminbin Thetaminbin],yl,'color',[.5 .5 .5])
plot([Thetamaxbin Thetamaxbin],yl,'color',[.5 .5 .5])

MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','StatewiseWaveletSpectra'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','StatewiseWaveletSpectra'),h,'png')

1;
