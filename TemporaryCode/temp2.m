max_zscored_val = 5;

lfp = bz_GetLFP([4,174]);
wavespec = bz_WaveSpec(lfp,'frange',[0.5 200],'nfreqs',50,'roundfreqs',true,'saveMatPath',cd,'MatNameExtraText','4&174');

dz = zscore(real(wavespec.data(:,:,1))',[],2);

% cap extreme values
dz(dz>max_zscored_val) = max_zscored_val;
dz(dz<-max_zscored_val) = -max_zscored_val;

figure;imagesc('XData',wavespec.timestamps,'YData',wavespec.freqs,'CData',dz);
axis xy tight
colorbar

