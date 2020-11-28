function CreateWaveletsUpTo150Hz(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end


% bandstarts = [0:1:9 20:2:38 40:5:195]';
% bandstops = [1:1:20 22:2:40 45:5:200 ]';
% bands = cat(2,bandstarts,bandstops);
% bandmeans = mean([bandstarts bandstops],2);
bandmeans = [1:10 12:2:20 23:3:36 40:5:60 70:10:150];
% bandmeans = unique(round(logspace(0,log10(150),60)));%1 to 650, log spaced except elim some repetitive values near 1-4Hz

% notchidxs = (fo>59 & fo<61);

par = LoadParameters(fullfile(basepath,[basename '.xml']));

load([basename '.eegstates.mat'])
thischannel_base1 = StateInfo.Chs(1);
clear StateInfo
sampfreq = par.lfpSampleRate;

signal = LoadBinary(fullfile(basepath,[basename '.lfp']),'channels',thischannel_base1,...
    'nChannels',par.nChannels,'frequency',sampfreq);
signal = double(signal);

%% generate actual wavelet
%awt_freqlist
[wt,freqlist] = awt_freqlist(signal, sampfreq, bandmeans);
%Dan L's 
% numwaveletcycles = 5;
% for f_i = 1:length(bandmeans)
%     if mod(f_i,10) == 1;
%         display(['freq ',num2str(f_i),' of ',num2str(length(bandmeans))]);
%     end
%     wt(f_i,:) = WaveFilt(x,bandmeans(f_i),numwaveletcycles,sampfreq);
% end

% get amplitude and phase
amp = (real(wt).^2 + imag(wt).^2).^.5;
phase = atan(imag(wt)./real(wt));

save(fullfile(basepath,[basename '_WaveletsUpTo150Hz.mat']),'amp','phase','bandmeans','sampfreq','thischannel_base1','-v7.3')

%% plotting first million points
zamp = zscore(log(amp(1:1000000,:)));
h = figure;
imagesc(1:1000000,1:length(bandmeans),(zamp));axis xy
bandmeanidxstotick = 1:round(length(bandmeans)/10):length(bandmeans);
set(gca,'YTick',bandmeanidxstotick,'YTickLabel',bandmeans(bandmeanidxstotick))
colormap jet
hold on
plot(zscore(signal(1:1000000))*round(length(bandmeans)/7)+length(bandmeans)/2)