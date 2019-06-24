%% compare lfp channel usage strategy
function CompareNeighborShanks(spikes,shank,phase,amp,freqlist)
numBins = 180;
samplingRate = 1250;
% spkphases = cell(length(spikes),length(freqlist));

[~,~,NeighborShankEachCell] = SelectNeighboringShank;

for i = 1:34
    % for i = 1:length(spikes)
    neighbor = NeighborShankEachCell{i};
    %     if length(neighbor)==1
    %         for j = 1:length(freqlist)
    %             spkphases{i,j} = phase{neighbor}(round(spikes{i}*samplingRate),j);
    %             spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
    %         end
    if length(neighbor)==2
        for j = 1:length(freqlist)
            N1Spkphases{i,j} = phase{neighbor(1)}(round(spikes{i}*samplingRate),j);
            N2Spkphases{i,j} = phase{neighbor(2)}(round(spikes{i}*samplingRate),j);
            LocalSpkphases{i,j} = phase{shank(i)}(round(spikes{i}*samplingRate),j);
            for k = 1:length(spikes{i})
                MeanSpkphases{i,j}(k) = CircularMean([phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j);...
                    phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j)]);
                [~,HighPowerNeighbor] = max([amp{neighbor(1)}(round(spikes{i}(k)*samplingRate),j),...
                    amp{neighbor(2)}(round(spikes{i}(k)*samplingRate),j)]);
                HighPowerSpkphases{i,j}(k) = phase{neighbor(HighPowerNeighbor)}(round(spikes{i}(k)*samplingRate),j);
                [~,LowPowerNeighbor] = min([amp{neighbor(1)}(round(spikes{i}(k)*samplingRate),j),...
                    amp{neighbor(2)}(round(spikes{i}(k)*samplingRate),j)]);
                LowPowerSpkphases{i,j}(k) = phase{neighbor(LowPowerNeighbor)}(round(spikes{i}(k)*samplingRate),j);
                %                 if ~isnan(phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j)) && ~isnan(phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j))
                %                     spkphases{i,j}(k) = CircularMean([phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j);...
                %                         phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j)]);
                %                 elseif ~isnan(phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j))
                %                     spkphases{i,j}(k) = phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j);
                %                 elseif ~isnan(phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j))
                %                     spkphases{i,j}(k) = phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j);
                %                 else
                %                     spkphases{i,j}(k) = NaN;
                %                 end
            end
            %             spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
        end
    end
end

for i = 1:34
    % for i = 1:length(spikes)
    for j = 1:length(freqlist)
        [~,~,n1ps]=CircularDistribution(N1Spkphases{i,j},'nBins',numBins);
        N1MRL(i,j) = n1ps.r;
        [~,~,n2ps]=CircularDistribution(N2Spkphases{i,j},'nBins',numBins);
        N2MRL(i,j) = n2ps.r;
        [~,~,lps]=CircularDistribution(LocalSpkphases{i,j},'nBins',numBins);
        LocalMRL(i,j) = lps.r;
        [~,~,mps]=CircularDistribution(MeanSpkphases{i,j},'nBins',numBins);
        MeanMRL(i,j) = mps.r;
        [~,~,hpps]=CircularDistribution(HighPowerSpkphases{i,j},'nBins',numBins);
        HighPowerMRL(i,j) = hpps.r;
        [~,~,lpps]=CircularDistribution(LowPowerSpkphases{i,j},'nBins',numBins);
        LowPowerMRL(i,j) = lpps.r;
        %             phasestats.m(i,j) = mod(ps.m,2*pi);
        %             phasestats.r(i,j) = ps.r;
        %             phasestats.k(i,j) = ps.k;
        %             phasestats.p(i,j) = ps.p;
        %             phasestats.mode(i,j) = ps.mode;
    end
end
%% plot

figure;
fig = gcf;
fig.Position = [1 1 920 920];
xt = [1 10 30 100 600];
for i = 1:34
    subplot(7,5,i);
    %     plot(log10(freqlist),LocalMRL(i,:));
    hold on;
    plot(log10(freqlist),N1MRL(i,:));
    plot(log10(freqlist),N2MRL(i,:));
    plot(log10(freqlist),MeanMRL(i,:));
    plot(log10(freqlist),HighPowerMRL(i,:));
    plot(log10(freqlist),LowPowerMRL(i,:));
    axis tight;
    title(['Cell' num2str(i) ' (S' num2str(shank(i)) ')']);
    set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
    %     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    if i == 34
        %     legend(['Local     ';'Neighbor 1';'Neighbor 2';'Mean      ';'High Power']);
        legend(['Neighbor 1';'Neighbor 2';'Mean      ';'High Power';'Low Power ']);
    end
end
end
