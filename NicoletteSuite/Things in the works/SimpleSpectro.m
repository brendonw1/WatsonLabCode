function [disone,fraxis,thisspec,freq] = SimpleSpectro(signal,fs,freqrange)
    %SIMPLESPECTRO basically spits out a spectrum (I accidentally named it 
    %after a spectrogram, and yes, I'm embarrased, so let's just drop it,
    % okay?) given a signal, sampling
    %rate, which is fs, and a frequency range that you wanna plot
    % to keep things simpler, make sure that freqrange is an integer
    % thisspec is the entire frequency range by the way.
    
    samples = length(signal);
    df = fs/samples; % Don't think super hard about this... It's the nature of ffts
    freq = 0:df:fs/2; freq(1) = []; %take out the 0
    thisspec = abs(fft(signal));
    disone = thisspec(freq < freqrange)'; %a normal spectrum  with #nofilter
    fraxis = freq(freq < freqrange);
end

