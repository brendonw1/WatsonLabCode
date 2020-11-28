function TransferToDropbox_BandPowerVsSingleUnit(basepath)

warning off

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);
% [~,animalname] = fileparts(cd);


%% Raw vector plots
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','RawVectorsOverTime');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RawBandPowerAndPopTracesOverlaid.png'),fullfile(destdir,['RawBandPowerAndPopTracesOverlaid_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RawBandPowerAndPopTracesOverlaid.fig'),fullfile(destdir,['RawBandPowerAndPopTracesOverlaid_' basename '.fig']));

%% Histograms
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','Histograms');
mkdir(destdir)
%
copyfile(fullfile(basepath,'GammaPowerRateFigs','FrequencyBandPowerHistograms.png'),fullfile(destdir,['FrequencyBandPowerHistograms_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','FrequencyBandPowerHistograms.fig'),fullfile(destdir,['FrequencyBandPowerHistograms_' basename '.fig']));
%
copyfile(fullfile(basepath,'GammaPowerRateFigs','PopulationSpikeRateHistograms_AllCells.png'),fullfile(destdir,['PopulationSpikeRateHistograms_AllCells_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','PopulationSpikeRateHistograms_AllCells.fig'),fullfile(destdir,['PopulationSpikeRateHistograms_AllCells_' basename '.fig']));
%
copyfile(fullfile(basepath,'GammaPowerRateFigs','PopulationSpikeRateHistograms_ECellRateGroups.png'),fullfile(destdir,['PopulationSpikeRateHistograms_ECellRateGroups_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','PopulationSpikeRateHistograms_ECellRateGroups.fig'),fullfile(destdir,['PopulationSpikeRateHistograms_ECellRateGroups_' basename '.fig']));

%% Pointwise correlation plots
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','EPopVsBandXYCorrs');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','BandEPopCorrelationPlots.png'),fullfile(destdir,['BandEPopCorrelationPlots_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','BandEPopCorrelationPlots.fig'),fullfile(destdir,['BandEPopCorrelationPlots_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','EPopVsBandXYCorrs');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','BandIPopCorrelationPlots.png'),fullfile(destdir,['BandIPopCorrelationPlots_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','BandIPopCorrelationPlots.fig'),fullfile(destdir,['BandIPopCorrelationPlots_' basename '.fig']));

%% EPop and IPop vs bands (no bin size) - @1sec
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','EPopVsBand');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqForEPop.png'),fullfile(destdir,['RatePowerByFreqForEPop_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqForEPop.fig'),fullfile(destdir,['RatePowerByFreqForEPop_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','IPopVsBand');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqForIPop.png'),fullfile(destdir,['RatePowerByFreqForIPop_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqForIPop.fig'),fullfile(destdir,['RatePowerByFreqForIPop_' basename '.fig']));

%% EPop and IPop vs bands and bin size
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','EPopVsBandAndBinSz');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqAndBinForEPop.png'),fullfile(destdir,['RatePowerByFreqAndBinForEPop' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqAndBinForEPop.fig'),fullfile(destdir,['RatePowerByFreqAndBinForEPop' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','IPopVsBandAndBinSz');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqAndBinForIPop.png'),fullfile(destdir,['RatePowerByFreqAndBinForIPop_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByFreqAndBinForIPop.fig'),fullfile(destdir,['RatePowerByFreqAndBinForIPop_' basename '.fig']));

%% Sextiles
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SextileVsBand_AllT');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_AllTime.png'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_AllTime_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_AllTime.fig'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_AllTime_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SextileVsBand_Wake');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_Wake.png'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_Wake_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_Wake.fig'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_Wake_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SextileVsBand_NREM');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_NREM.png'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_NREM_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_NREM.fig'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_NREM_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SextileVsBand_REM');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_REM.png'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_REM_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_REM.fig'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_REM_' basename '.fig']));
%
destdir = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SextileVsBand_MA');
mkdir(destdir) 
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_MA.png'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_MA_' basename '.png']));
copyfile(fullfile(basepath,'GammaPowerRateFigs','RatePowerByBin+Freq+Sextile_MA.fig'),fullfile(destdir,['RatePowerByBin+Freq+Sextile_MA_' basename '.fig']));








