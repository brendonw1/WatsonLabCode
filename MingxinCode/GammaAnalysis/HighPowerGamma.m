function HighPowerGamma
basepath = cd;
[~,basename] = fileparts(cd);
load(fullfile(basepath,[basename '_SStable.mat']),'S_CellFormat');
spikes = S_CellFormat;
load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Channels');
load(fullfile(basepath,[basename '-states.mat']),'states');
statesInt = IDXtoINT(states);

zthreshold = 1;
intervals = [0 Inf];
passband = [1 625];
samplingRate = 1250;
numBins = 180;
nvoice = 12;
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));

if exist(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
else
    for i = 1:length(Channels)
        lfp{i} = LoadBinary('BWRat19_032413.lfp','frequency',1250,'nChannels',135,'channels',Channels(i));
    end
    save(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
end
for i = 1:length(Channels)
    wt{i} = awt_freqlist(double(lfp{i}), samplingRate, freqlist);
    amp{i} = (real(wt{i}).^2 + imag(wt{i}).^2).^.5;
    phase{i} = atan2(imag(wt{i}),real(wt{i}));
    phase{i} = mod(phase{i},2*pi);
end


% [~,mIdx] = max(amp');
% for i = 1:size(wt,1)
%     lfpphase(i) = phase(i,mIdx(i));
% end
% lfpphase = mod(lfpphase,2*pi);
for i = 1:length(lfp)
    HighPowerPhase{i} = nan(size(phase{i}));
    LowPowerPhase{i} = nan(size(phase{i}));
    for j =1:length(freqlist)
        zs{i}(:,j) = zscore(log(amp{i}(:,j))); % log for normalizing power data??
        [AboveInt,BelowInt] = continuousabove2(zs{i}(:,j),zthreshold,1/freqlist(j)*3*samplingRate); % z-score threshold??
        for k = 1:length(BelowInt)
%             HighPowerPhase{i}(AboveInt(k,1):AboveInt(k,2),j) = phase{i}(AboveInt(k,1):AboveInt(k,2),j);
            LowPowerPhase{i}(BelowInt(k,1):BelowInt(k,2),j) = phase{i}(BelowInt(k,1):BelowInt(k,2),j);
        end
    end
end


%% Get phases for each spike for each cell
% h = [];
%     spikes = S_CellFormat;
spkphases = cell(length(Channels),length(spikes),length(freqlist));
% for c = 1:length(Channels)
%     for a = 1:length(spikes)
%         bools = InIntervals(spikes{a},intervals);
%         s =spikes{a}(bools);
%         for b = 1:length(freqlist)
%             spkphases{c,a,b} = HighPowerPhase{c}(round(s*samplingRate),b);
%             spkphases{c,a,b} = spkphases{c,a,b}(~isnan(spkphases{c,a,b}));
%             [phasedistros{c}(:,a,b),phasebins,ps]=CircularDistribution(spkphases{c,a,b},'nBins',numBins);
%             phasestats{c}.m(a,b) = mod(ps.m,2*pi);
%             phasestats{c}.r(a,b) = ps.r;
%             phasestats{c}.k(a,b) = ps.k;
%             phasestats{c}.p(a,b) = ps.p;
%             phasestats{c}.mode(a,b) = ps.mode;
%         end
%         %% plotting
%         %                 if plotting
%         %                     h(end+1) = figure;
%         %                     for b = 1:length(freqlist)
%         %         %                 hax = subplot(round(max(freqbins)/3),6,2*b-1);
%         %         %                 rose(spkphases{a,b})
%         %         %                 title(hax,{[num2str(minfreq+(b-1)*bandwidth) 'to' num2str(minfreq+b*bandwidth) ' Hz']; ['Rayleigh p = ' num2str(phasestats.p(a,b))]});
%         %         %
%         %         %                 hax = subplot(round(max(freqbins)/3),6,2*b);
%         %         %                 bar(phasebins*180/pi,phasedistros(:,a,b))
%         %         %                 xlim([0 360])
%         %         %                 set(hax,'XTick',[0 90 180 270 360])
%         %         %                 hold on;
%         %         %                 plot([0:360],cos(pi/180*[0:360])*0.05*max(phasedistros(:,a,b))+0.95*max(phasedistros(:,a,b)),'color',[.7 .7 .7])
%         %         %
%         %                         hax = subplot(10,8,b);
%         %                         bar(phasebins*180/pi,phasedistros(:,a,b))
%         %                         xlim([0 360])
%         %                         set(hax,'XTick',[0 90 180 270 360])
%         %                         hold on;
%         %                         plot([0:360],cos(pi/180*[0:360])*0.05*max(phasedistros(:,a,b))+0.95*max(phasedistros(:,a,b)),'color',[.7 .7 .7])
%         %                     end
%         %                     set(h(end),'name',['PhaseModPlotsForCell' num2str(a)]);
%         %                     fig = gcf;
%         %                     fig.Position = [1 1 1280 920];
%         %         %     print(fullfile('BWRat19_032413_PhaseLockingFig/30-200Hz_lfpChannel27',['PhaseModPlotsForCell' num2str(a) '_30-200Hz_lfp27(20HzBand)']),'-dpng','-r0');
%         %         %     print(fullfile('BWRat19_032413_PhaseLockingFig/30-200Hz_lfpChannel',['PhaseModPlotsForCell' num2str(a) '_30-200Hz_lfp27(20HzBand)']),'-dpng','-r0');
%         %                 end
%     end
% end
% save(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_zthresh' num2str(zthreshold) '.mat']),'spkphases','phasedistros','phasestats');


for c = 1:length(Channels)
    for a = 1:length(spikes)
        bools = InIntervals(spikes{a},intervals);
        s =spikes{a}(bools);
        for b = 1:length(freqlist)
            spkphases{c,a,b} = LowPowerPhase{c}(round(s*samplingRate),b);
            spkphases{c,a,b} = spkphases{c,a,b}(~isnan(spkphases{c,a,b}));
            [phasedistros{c}(:,a,b),~,ps]=CircularDistribution(spkphases{c,a,b},'nBins',numBins);
            phasestats{c}.m(a,b) = mod(ps.m,2*pi);
            phasestats{c}.r(a,b) = ps.r;
            phasestats{c}.k(a,b) = ps.k;
            phasestats{c}.p(a,b) = ps.p;
            phasestats{c}.mode(a,b) = ps.mode;
        end
    end
end
save(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_zthresh' num2str(zthreshold) '_low.mat']),'spkphases','phasedistros','phasestats');


