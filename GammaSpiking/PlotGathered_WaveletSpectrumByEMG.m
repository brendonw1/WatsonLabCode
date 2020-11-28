function PlotGathered_WaveletSpectrumByEMG

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectrumByEMG.mat'))
saveloc = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','WaveletSpectrumByEMG','DatasetMeans');

u = GatheredWaveletSpectrumByEMG;
ndivs = u.NumDivisions(1);

t = nanmean(u.WakeSpectra,3);
t = (t.*repmat(u.bandmeans{1},[ndivs,1]))';
h = figure('position',[100 100 900 700],'Name','WaveletSpectrumByEMGLevel_WholeDataset');
% GrayscalePlotLinesInOrder(t);
RainbowPlotLinesInOrder(t);
hold on

%Nrem
t = nanmean(u.NremSpectra,2)';
t = (t.*u.bandmeans{1})';
plot(t,'color',[.5 .5 .5])

%Rem
t = nanmean(u.RemSpectra,2)';
t = (t.*u.bandmeans{1})';
plot(t,'color',[0 0 0])

xlabel('Frequency')
ylabel('Power x Frequency')
title('Spectrum by EMG power, per second')

axis tight
xt = get(gca,'xtick');
set(gca,'xticklabel',u.bandmeans{1}(xt));

legtext = {};
for a = 1:ndivs
    if a == 1
        legtext{a} = [num2str(a) ' - Lowest EMG'];
    elseif a ==ndivs
        legtext{a} = [num2str(a) ' - Highest EMG'];
    else
        legtext{a} = num2str(a);
    end
end
legtext{end+1} = 'Nrem';
legtext{end+1} = 'Rem';

legend(legtext,'location','southeast')

MakeDirSaveFigsThere(fullfile(saveloc),h,'fig')
MakeDirSaveFigsThere(fullfile(saveloc),h,'png')
