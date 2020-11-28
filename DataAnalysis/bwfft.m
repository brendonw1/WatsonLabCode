function [f, fftout] = bwfft(y,Fs)
%
% function fftout = bwfft(y,Fs);
% Gives the absolute valued, single-sided output of fft performed on input 
% y at maximum number of frequencies assessable given the length of y (uses
% 1/y, nyquist frequency).
%
% INPUTS
% y = is signal, a single vector
% Fs = is sampling frequency (hz)
%
% OUTPUTS:
% f = is frequencies for power readings, 
%  >> the number of outputs is equal to half the length of the number of points... 
%        max frequency is based on that number multiplied by Fs, others are
%        linearly spaced below that
% fftout = out is spectral powers at those freqs
%
% Adapted from matlab doc
% Brendon Watson 2013


T = 1/Fs; % Sample time
L = length(y);% Length of signal
t=(0:L-1)*T;% Time vector (ie corrected for samplin freq)

% NFFT = 2^nextpow2(L);% Next power of 2 from length of y
NFFT = 1000;
Y = fft(y,NFFT)/L;

fftout = 2*abs(Y(1:NFFT/2+1));

f = Fs/2*linspace(0,1,NFFT/2+1);
figure;
plot(f,fftout);



% fs = 100;                                % Sample frequency (Hz)
% t = 0:1/fs:10-1/fs;                      % 10 sec sample
% x = (1.3)*sin(2*pi*15*t) ...             % 15 Hz component
% + (1.7)*sin(2*pi*40*(t-2)) ...         % 40 Hz component
% + 2.5*gallery('normaldata',size(t),4); % Gaussian noise;
% m = length(x);          % Window length
% n = pow2(nextpow2(m));  % Transform length
% y = fft(x,n);           % DFT
% f = (0:n-1)*(fs/n);     % Frequency range
% power = y.*conj(y)/n;   % Power of the DFT
% plot(f,power)
% xlabel('Frequency (Hz)')
% ylabel('Power')
% title('{\bf Periodogram}')