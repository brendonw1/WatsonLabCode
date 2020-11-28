function CreateWaveletsForGammaAnalysis(basepath,basename)
% Wavelets ~log spaced from 1-625Hz on channels used in .eegstates.  Pretty
% minimal and efficient.
% Brendon Watson 2017




if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end
par = LoadParameters(fullfile(basepath,[basename '.xml']));
sampfreq = par.lfpSampleRate;


% bandstarts = [0:1:19 20:2:38 40:5:195]';
% bandstops = [1:1:20 22:2:40 45:5:200 ]';
% bands = cat(2,bandstarts,bandstops);
% bandmeans = mean([bandstarts bandstops],2);
bandmeans = unique(round(logspace(0,log10(625),63)));%1 to 650, log spaced except elim some repetitive values near 1-4Hz

% notchidxs = (fo>59 & fo<61);

load(fullfile(basepath, [basename '.eegstates.mat']))
thischannel_base1 = StateInfo.Chs(1);
clear StateInfo

signal = LoadBinary(fullfile(basepath,[basename '.lfp']),'channels', thischannel_base1,...
    'nChannels',par.nChannels,'frequency',sampfreq);
signal = double(signal);
[wt,freqlist] = awt_freqlist(signal, sampfreq, bandmeans);

clear x 

amp = (real(wt).^2 + imag(wt).^2).^.5;
phase = atan(imag(wt)./real(wt));

save(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp','bandmeans','sampfreq','thischannel_base1','-v7.3')
% save(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp','phase','-v7.3')