function outputwave = generateFrequencyWave(desiredfreq,samplingfreq,lengthinsamples);
% function outputwave = generateFrequencyWave(desiredfreq,samplingfreq,lengthinsamples);
% Generates an outputwave with sinusoidal oscilations at frequency
% "desiredfreq" with samples generated at "samplingfreq" frequency for a
% number of samples specified in "lengthinsamples".
% Brendon Watson 2013

numsec = lengthinsamples/samplingfreq;
numcycles = desiredfreq*numsec;
samplespercycle = samplingfreq/desiredfreq;
outputwave = 0:(2*pi/samplespercycle):((2*pi)*numcycles);
outputwave(end) = [];
outputwave = sin(outputwave);