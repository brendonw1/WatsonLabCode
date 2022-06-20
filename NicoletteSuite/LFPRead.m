LFPdata = readtable('Professor X FP05.csv');
LFParray = table2array(LFPdata);

SampFreq = 1000;
SigLength = length(LFParray);
time = (0:SigLength) / SampFreq;

transedcomplex = fft(LFParray);
Spectrum = abs(transedcomplex((SigLength/2):end) / SigLength);
f = SampFreq*(0:(SigLength/2))/SigLength;

filteredf = f(f < 140);
filteredSpec = Spectrum(f < 140)';
filteredcomplex = transedcomplex([flip(f<140) ,f < 140])';
    filteredcomplex(end) = [];
filteredSig = ifft(filteredcomplex);


plot(filteredf,filteredSpec);

%since it is sampled at 1000 times a second, 1 second is going to be at x =
%1000... This means that if we want the rate in Hz, we're going to have to
%rescale the ffted signal. I'm gonna assume that it thinks that 
% 
%For the spectrogram
% spectrogram(LFParray,10,[],[],1000,'yaxis');
% ylim([0 200])