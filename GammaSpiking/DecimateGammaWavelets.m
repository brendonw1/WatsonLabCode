function DecimateGammaWavelets(basepath)


%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

%% Load up
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'bandmeans')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'sampfreq')
load(fullfile(basepath,[basename '_Motion']),'motiondata')

%%
sz = size(amp);
over = rem(sz(1),sampfreq);
if over>0
    amp(end-over+1:end,:) = [];
    sz = size(amp);
end

amp = squeeze(mean(reshape(amp',[sz(2) sampfreq sz(1)/sampfreq]),2));
amp_bandcorrected = amp .* repmat(bandmeans',[1,size(amp,2)]);



%% subranges of the spectrum for plotting powers
ranges = {[1 4];[6 10];[11 18];[21 35];[36 49];[50 180];[250 600]};
rangenames = {'delta','theta','sigma','beta','lowgamma','broadbandgamma','highghighgamma'};

% deltarange = [1 4];
% thetarange = [6 10];
% sigmarange = [11 18];
% betarange = [21 35];
% lowgammarange = [36 49];
% broadbandgammarange = [50 180];
% highghighgammarange = [250 600];

for ridx = 1:length(ranges);
    minbin = find(bandmeans>=ranges{ridx}(1),1,'first');
    maxbin = find(bandmeans<=ranges{ridx}(2),1,'last');
    bandbins = minbin:maxbin;
    bandvals(ridx,:) = mean(amp_bandcorrected(bandbins,:),1);
    
    subplot(length(ranges),1,ridx)
    plot(bandvals(ridx,:))
    axis tight
    ylabel(rangenames{ridx})
end
    
DecimatedGammaWaveletData = v2struct(amp,amp_bandcorrected,bandmeans,...
    sampfreq,motiondata,ranges,rangenames);

save(fullfile(basepath,[basename '_DecimatedGammaWavelets.mat']),'DecimatedGammaWaveletData')
%%
plotting = 1;
if plotting
    h = [];
    
    h(end+1) = figure('name','SecondwiseSpectrumWMotion');
    subplot(3,1,1:2)
    imagesc(amp_bandcorrected);
    axis xy
    axis tight
    yt = get(gca,'ytick');
    set(gca,'yticklabel',bandmeans(yt))
    ylabel('freq(Hz)')

    subplot(3,1,3)
    plot(motiondata.motion)
    ylabel('EMGCorr')
    axis tight
    AboveTitle('ForAlignment')

    h(end+1) = figure('name','SecondwiseSpectrumWColorbar');
    imagesc(amp_bandcorrected);
    axis xy
    axis tight
    yt = get(gca,'ytick');
    set(gca,'yticklabel',bandmeans(yt))
    ylabel('freq(Hz)')
    colorbar
    title('For Colorbar')

    h(end+1) = figure('name','SecondwiseBandPowers');
    for ridx = 1:length(ranges);
        subplot(length(ranges),1,ridx)
        plot(bandvals(ridx,:))
        axis tight
        ylabel(rangenames{ridx})
    end
    
    MakeDirSaveFigsThereAs(fullfile(basepath,'DecimatedGammaWaveletsFigs'),h,'fig')
    MakeDirSaveFigsThereAs(fullfile(basepath,'DecimatedGammaWaveletsFigs'),h,'png')
end


