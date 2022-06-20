function [STA,coherenceCurve,STA_shuff_mean,STA_shuff_SD,coherenceCurve_shuff_mean,coherenceCurve_shuff_SD,freqs] = getCoherence(spkTimes,inputSignal,Fs,windowSize,iterations,plotFlag,varargin)

% Inputs %

% spkTimes: spike times relative to the start of the signal ('inputSignal')
% inputSignal: the continuous signal (e.g. a stimulus, or, a LFP recording) being anlysed relative to the spike times
% Fs: sampling rate of the inputSignal (in Hz)
% windowSize: create the spike-triggered average (STA) by averaging segments of the inputSignal extracted +-windowSize seconds every spike
% plotFlag: input a 1 to plot results, 0 otherwise
% iterations: when getting the null coherence curve (using shuffled spike
% times), obtain the mean shuffled spike coherence curve from n individual curves, where n = iterations.
% If iterations 0, no shuffled spike coherence curve is obtained.
% minFreq and maxFreq: Variable argument inputs. If plotFlag is set to 1, you can
% define the minimum and maximum points of the frequency axis for the
% coherence curve plot. If plotFlag set to 1 and no minFreq and maxFreq
% inputs are declared, the coherence curve is plot from 0 Hz to the Nyquist
% frequency (Fs/2). These inputs are not required when plotFlag is set to 0.

% Notes %

% If spike times are collected in response to repeated presentations of the
% same stimulus, force all spike times relative to the start of their
% respective stimulus time.

% Be aware that the frequency resolution is determined by Fs/L, where L
% is the length of the signal being analysed in the frequency domain, which
% in this case is (windowSize*2)+1. Increase the length of the 
% extracted segments (windowSize) to increase the frequency resolution. It is also
% possible to increase the frequency resolution of the coherence curve by
% increasing the number of points (n) in the FFT (e.g. fft(data,n)), but
% this increases harmonics in the FFTs, which in turn creates artificially 
% high coherence.

% Down-sampling the inputSignal will decrease computation time 

% Outputs %

% STA: the spike-triggered average
% coherenceCurve: % the coherence curve
% STA_shuff_mean: % the mean spike-triggered average using random spike times, from all iterations
% STA_shuff_SD: % the SD of all the spike-triggered averages using random spike times, from all iterations
% coherenceCurve_shuff_mean: % the mean coherence curve using random spike times, from all iterations
% coherenceCurve_shuff_SD: % the SD of all the coherence curves using random spike times, from all iterations
% frequencies: % the coherence curve's frequency axis 

% Example usage %

% 1) [a,b,c,d,e,f,g] = getCoherence(spks,stim,10000,0.1,100,1,10,50);
%         Fs = 10000 (3rd input). window size = 0.1 seconds (4th input). Obtain shuffled results using 100 iterations (5th input).
%         Plot the results (6th input) from 10 Hz (7th input) to 50 Hz (8th input)

% 2) [a,b,c,d,e,f,g] = getCoherence(spks,stim,15000,0.2,200,0);
%         Fs = 15000 (3rd input). window size = 0.2 seconds (4th input). Obtain shuffled results using 200 iterations (5th input).
%         Do not plot the results

% 3) [a,b,c,d,e,f,g] = getCoherence(spks,stim,10000,0.1,0,1,10,50);
%         Fs = 10000 (3rd input). window size = 0.1 seconds (4th input). Do not obtain shuffled results (5th input).
%         Plot the results (6th input) from 10 Hz (7th input) to 50 Hz (8th input)
    

%%%%%% Function %%%%%%


switch nargin
    case 8
        minFreq = varargin{1};
        maxFreq = varargin{2};
    case 7
        error('Only one input added for minFreq and maxFreq. Please enter both or none.')
    otherwise
        minFreq = 0;
        maxFreq = Fs/2;
end
        
SP = 1/Fs; % inputSignal sampling period (in sec)

spkTimesSam = round(spkTimes/SP); % spike times in samples (at the sampling rate of the inputSignal)
windowSizeSam = round(windowSize/SP); % the window size in samples (at the sampling rate of the inputSignal)

freqRes = Fs/((windowSizeSam*2)+1); % the frequency resolution of the FFT

% only take spikes within the start of the stimulus plus the windowSize, and within the
% end of the stimulus minus the windowSize
spkTimesSam = spkTimesSam(spkTimesSam > windowSizeSam & spkTimesSam < (length(inputSignal)-windowSizeSam));

% get the spike-triggered average and the coherence curve for spkTimesSam
[STA,coherenceCurve,freqs] = getCohCurve(spkTimesSam,windowSizeSam,Fs,inputSignal); 

% get the spike-triggered average and the coherence curve for random spike times
if iterations > 0 
    STA_shuff = nan(iterations,length(STA)); % empty matrix to store all the STAs from all iterations
    coherenceCurve_shuff = nan(iterations,length(coherenceCurve)); % empty matrix to store all the coherence curves from all iterations
    fprintf('\nObtaining mean coherence curve from shuffled spike times. Iterations (of %s) Completed: ',num2str(iterations));
    minSpikeSamp = min(spkTimesSam); % the first spike time (in samples)
    maxSpikeSamp = max(spkTimesSam); % the last spike time (in samples)
    for i = 1:iterations
        spkSampsShuff = round((maxSpikeSamp-minSpikeSamp).*rand(length(spkTimesSam),1) + minSpikeSamp); % random spike times
        % get the spike-triggered average and the coherence curve for the current set of random spike times
        [STA_shuff(i,:),coherenceCurve_shuff(i,:),freqs_temp] = getCohCurve(spkSampsShuff,windowSizeSam,Fs,inputSignal); 
        % counter to display the current iteration
        if i > 1
            for blahBlah = 0:log10(i-1)
                fprintf('\b');
            end
        end
        fprintf('%s',num2str(i));
    end
    STA_shuff_mean = mean(STA_shuff); % the mean STA from all iterations
    STA_shuff_SD = std(STA_shuff); % the STA SD from all iterations
    coherenceCurve_shuff_mean = mean(coherenceCurve_shuff); % the mean coherence curve from all iterations
    coherenceCurve_shuff_SD = std(coherenceCurve_shuff); % the coherence curve SD from all iterations
else 
   STA_shuff_mean = nan(iterations,length(STA));
   STA_shuff_SD = nan(iterations,length(STA));
   coherenceCurve_shuff_mean = nan(iterations,length(coherenceCurve));
   coherenceCurve_shuff_SD = nan(iterations,length(coherenceCurve));
end

% Plot the results

if plotFlag == 1
    
    figure
    
    subplot(1,2,1);
    xAxis = linspace(-windowSize,windowSize,length(STA));
    plot(xAxis,STA,'k');
    if iterations > 0
        hold on
        plot(xAxis,STA_shuff_mean,'r');
        hold on
        upperSD = STA_shuff_mean+STA_shuff_SD;
        lowerSD = STA_shuff_mean-STA_shuff_SD;
        xAxisSD = [xAxis fliplr(xAxis) xAxis(1)];
        fill(xAxisSD,[lowerSD fliplr(upperSD) lowerSD(1)],'r','faceAlpha',0.1,'edgeAlpha',0); % plot the SD as a shaded error bar
    end
    hold on;
    gc = gca; gcYLim = gc.YLim;
    plot([0 0],gcYLim,'k--');
    set(gc,'YLim',gcYLim);
    set(gc,'XLim',[-windowSize windowSize]);
    xlabel('Time (sec)');
    ylabel('Amplitude');
    if iterations > 0
        title([{'\color{blue}Dashed line indicates spike time'};{'\color{black}Spike-triggered average (STA); \color{red}Shuffled spike STA'}]);
    else
        title('\color{black}Spike-triggered average (STA)');
    end
    
    subplot(1,2,2);
    minFreqInd = find(abs(freqs - minFreq) == min(abs(freqs - minFreq)));
    maxFreqInd = find(abs(freqs - maxFreq) == min(abs(freqs - maxFreq)));
    freqXaxis = freqs(minFreqInd:maxFreqInd);
    plot(freqXaxis,coherenceCurve(minFreqInd:maxFreqInd),'k')
    if iterations > 0
        hold on
        plot(freqXaxis,coherenceCurve_shuff_mean(minFreqInd:maxFreqInd),'r');
        hold on
        upperSD = coherenceCurve_shuff_mean(minFreqInd:maxFreqInd) + coherenceCurve_shuff_SD(minFreqInd:maxFreqInd);
        lowerSD = coherenceCurve_shuff_mean(minFreqInd:maxFreqInd) - coherenceCurve_shuff_SD(minFreqInd:maxFreqInd);
        xAxisSD = [freqXaxis fliplr(freqXaxis) freqXaxis(1)];
        fill(xAxisSD,[lowerSD fliplr(upperSD) lowerSD(1)],'r','faceAlpha',0.1,'edgeAlpha',0); % plot the SD as a shaded error bar
    end
    set(gca,'YLim',[0 1]);
    if iterations > 0
        title([{['\color{blue}Frequency resolution = ' num2str(freqRes) ' Hz']};{'\color{black}Coherence; \color{red}Shuffled spike coherence'}]);
    else
        title([{['\color{blue}Frequency resolution = ' num2str(freqRes) ' Hz']};{'\color{black}Coherence'}]);
    end
        
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    
end
    
% get the STA and coherence curve
function [STA,coherenceCurve,freqs] = getCohCurve(spkTimesSam,windowSizeSam,Fs,inputSignal)

    lengthSeg = (windowSizeSam*2)+1; % length (in samples) of each spike-triggered portion of inputSignal 
    stimSegments = nan(length(spkTimesSam),lengthSeg); % empty matrix of NaNs to collect the inputSignal portion
    lengthFFT = length(1:lengthSeg/2+1); % length of the inputSignal portion FFT
    segmentFFTs = nan(length(spkTimesSam),lengthFFT); % empty matrix of NaNs to collect the FFTs of all portions
    for j = 1:length(spkTimesSam) % loop through all spike times
        stimSegments(j,:) = inputSignal((spkTimesSam(j)-windowSizeSam):(spkTimesSam(j)+windowSizeSam)); % collect the portion of inputSignal for the current spike
        curFFT = abs(fft(stimSegments(j,:))); % the FFT of this current portion of inputSignal
        segmentFFTs(j,:) = curFFT(1:lengthFFT); % store the first half of all FFTs (dispose of the mirror image)
    end

    meanSegFFT = mean(segmentFFTs); % the mean FFT from all individual inputSignal portion FFTs
    STA = mean(stimSegments); % the spike-triggered average (STA)
    STAFFT_temp = abs(fft(STA)); % the FFT of the STA
    STAFFT = STAFFT_temp(1:lengthFFT); % the first half of STA FFT (dispose of the mirror image)
    coherenceCurve = STAFFT./meanSegFFT; % the coherence curve
    freqs = Fs*(0:(lengthSeg/2))/lengthSeg; % the coherence curve frequency axis

end
 
end
