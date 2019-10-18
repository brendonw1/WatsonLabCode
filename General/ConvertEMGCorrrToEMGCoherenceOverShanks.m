function ConvertEMGCorrrToEMGCoherenceOverShanks(basepath)

basename = bz_BasenameFromBasepath(basepath);
load(fullfile(basepath,[basename, '_EMGCorr.mat']))
EMGFromLFP.timestamps = (1:length(EMGCorr))'/sf_EMG;
EMGFromLFP.data = EMGCorr(:,2);
EMGFromLFP.samplingFrequency = sf_EMG;
EMGFromLFP.channels = nan;
EMGFromLFP.detectorName = 'EMGCoherenceOverShanks';
save(fullfile(basepath,[basename, '.EMGFromLFP.LFP.mat']))

