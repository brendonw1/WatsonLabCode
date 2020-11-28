function GammaPhasePrecision

basepath = cd;
[~,basename] = fileparts(cd);

alpha = 0.01; % significant level
minfreq = 1; % 30;
maxfreq = 625; % 200;
passband = [minfreq maxfreq];
intervals = [0 Inf];
numBins = 180;
samplingRate = 1250;
% bandwidth = 20;
plotting = 1;
lfpChannels = [10 57 54 55 19 27];
% load(fullfile(basepath,[basename '_lfp27PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% load(fullfile(basepath,[basename '_lfp27PhaseRawData30-200Hz.mat']),'lfpPhaseRawData');
% load(fullfile(basepath,[basename '_lfp27PhaseRawData30-200Hz_amp.mat']),'amp');
% load(fullfile(basepath,[basename '_lfp27PhaseRawData30-200Hz_phase.mat']),'phase');
load(fullfile(basepath,[basename '_SStable.mat']),'S_CellFormat');

% freqlist = lfpPhaseRawData.freqlist;
% mIdx = lfpPhaseRawData.mIdx;
% [~,~,freqbins] = histcounts(freqlist,minfreq:bandwidth:(maxfreq+10));

for i = 1:length(lfpChannels)
    lfp = LoadBinary('BWRat19_032413.lfp','frequency',1250,'nChannels',135,'channels',lfpChannels(i));
    nvoice = 12;
    freqlist = unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));
    wt = awt_freqlist(double(lfp), samplingRate, freqlist);
    amp = (real(wt).^2 + imag(wt).^2).^.5;
    phase = atan2(imag(wt),real(wt));
    phase = mod(phase,2*pi);
    [~,mIdx] = max(amp'); %get index with max power for each timepiont
    for j = 1:size(wt,1)
        lfpphase(j) = phase(j,mIdx(j));
    end
%     lfpphase = mod(lfpphase,2*pi);
    
    
    
    
    % for i = 1:max(freqbins)
    %     if length(find(freqbins==i))==1
    %         bandphase{i} = phase(:,freqbins==i);
    %     else
    %         [~,bandIdx{i}] = max(amp(:,freqbins==i)');
    %         bandIdx{i} = bandIdx{i} + find(freqbins==i,1) - 1;
    %         for j = 1:size(amp,1)
    %             bandphase{i}(j) = phase(j,bandIdx{i}(j));
    %         end
    %     end
    %     bandphase{i} = mod(bandphase{i},2*pi);
    % end
    %% Get phases for each spike for each cell
    h = [];
    spikes = S_CellFormat;
    spkphases = cell(length(spikes),size(phase,2));
    for a = 1:length(spikes)
        
        bools = InIntervals(spikes{a},intervals);
        s =spikes{a}(bools);
        %     s = spikes{a};
        
        for b = 1:length(freqlist)
            if isempty(s)
                phasedistros(:,a,b) = zeros(numBins,1);
                phasestats.m(a,b) = nan;
                phasestats.r(a,b) = nan;
                phasestats.k(a,b) = nan;
                phasestats.p(a,b) = nan;
                phasestats.mode(a,b) = nan;
                spkphases{a,b} = nan;
            else
                spkphases{a,b} = phase(round(s*samplingRate),b);
                [phasedistros(:,a,b),phasebins,ps]=CircularDistribution(spkphases{a,b},'nBins',numBins);
                phasestats.m(a,b) = mod(ps.m,2*pi);
                phasestats.r(a,b) = ps.r;
                phasestats.k(a,b) = ps.k;
                phasestats.p(a,b) = ps.p;
                phasestats.mode(a,b) = ps.mode;
            end
        end
        %% plotting
        if plotting
            h(end+1) = figure;
            for b = 1:length(freqlist)
%                 hax = subplot(round(max(freqbins)/3),6,2*b-1);
%                 rose(spkphases{a,b})
%                 title(hax,{[num2str(minfreq+(b-1)*bandwidth) 'to' num2str(minfreq+b*bandwidth) ' Hz']; ['Rayleigh p = ' num2str(phasestats.p(a,b))]});
%                 
%                 hax = subplot(round(max(freqbins)/3),6,2*b);
%                 bar(phasebins*180/pi,phasedistros(:,a,b))
%                 xlim([0 360])
%                 set(hax,'XTick',[0 90 180 270 360])
%                 hold on;
%                 plot([0:360],cos(pi/180*[0:360])*0.05*max(phasedistros(:,a,b))+0.95*max(phasedistros(:,a,b)),'color',[.7 .7 .7])
%                 
                hax = subplot(10,8,b);
                bar(phasebins*180/pi,phasedistros(:,a,b))
                xlim([0 360])
                set(hax,'XTick',[0 90 180 270 360])
                hold on;
                plot([0:360],cos(pi/180*[0:360])*0.05*max(phasedistros(:,a,b))+0.95*max(phasedistros(:,a,b)),'color',[.7 .7 .7])
            end
            set(h(end),'name',['PhaseModPlotsForCell' num2str(a)]);
            fig = gcf;
            fig.Position = [1 1 1280 920];
        %     print(fullfile('BWRat19_032413_PhaseLockingFig/30-200Hz_lfpChannel27',['PhaseModPlotsForCell' num2str(a) '_30-200Hz_lfp27(20HzBand)']),'-dpng','-r0');
        %     print(fullfile('BWRat19_032413_PhaseLockingFig/30-200Hz_lfpChannel',['PhaseModPlotsForCell' num2str(a) '_30-200Hz_lfp27(20HzBand)']),'-dpng','-r0');
        end
    end
    save([basename '_PhaseLockingData' num2str(minfreq) '-' num2str(maxfreq) 'Hz_lfp' num2str(lfpChannels(i)) '_EachFreq.mat'],'spkphases','phasedistros','phasestats','freqlist');
    % MRL = PhaseLockingData.phasestats.r;
    % for i = 1:length(PhaseLockingData.spkphases)
    % nspk(i) = length(PhaseLockingData.spkphases{i});
    % p_value(i) = exp(-MRL(i)^2*nspk(i));
    % end
    
    % %% p value analysis
    % p_values = PhaseLockingData.phasestats.p;
    % CellNum = length(PhaseLockingData.spkphases);
    % CorrID = find(p_values*CellNum*max(freqbins)<alpha); % Bonferroni correction for p values
    %
    % %%band difference? ANOVA?
    % % distinguish general/specifically correlated cells?
    %
end