function [PeakCounts,Envel,PeakTstamps] = ...
    REM_SpectrFreeTheta(LFPepoch,SamplFreq)
%
% [PeakCounts,Envel,PeakTstamps] = REM_SpectrFreeTheta(LFPepoch,SamplFreq)
%
% Spectrogram-free analysis of theta frequency and theta power
% fluctuations.
%
% USAGE
%   - LFPepoch: vector of time samples (can be int16, double, etc.).
%
% OUTPUTS
%   - PeakCounts:  count x time histogram (1 s bins)
%   - Envel:       envelope, same binning
%   - PeakTstamps: to plot markers on each theta wave (optional)
% 
% Bueno-Junior et al. (2023)

%% Filtering
ThetaBand = [5 10]; % hard coded
[b,a] = butter(2,[...
    ThetaBand(1)/round(SamplFreq/2) ...
    ThetaBand(2)/round(SamplFreq/2)],'bandpass');
FiltLFPepoch  = filtfilt(b,a,LFPepoch);



%% Wave peaks
[~,FiltPeaks] = findpeaks(FiltLFPepoch);
PeakTstamps   = FiltPeaks;
FiltPeaks     = FiltPeaks/SamplFreq;
PeakCounts    = histcounts(...
    FiltPeaks,0:length(FiltLFPepoch)/SamplFreq)';



%% Envelope
Envel = REM_BinnedVector(envelope(FiltLFPepoch),SamplFreq)';

end