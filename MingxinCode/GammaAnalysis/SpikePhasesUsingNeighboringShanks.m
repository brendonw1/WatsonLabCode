function [spkphases,phasedistros, phasestats] = SpikePhasesUsingNeighboringShanks(spikes,freqlist,phase)
basepath = cd;
[~,basename] = fileparts(cd);
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');
numBins = 180;
samplingRate = 1250;
spkphases = cell(length(spikes),length(freqlist));

[~,~,NeighborShankEachCell] = SelectNeighboringShank;

for i = 1:length(spikes)
    neighbor = NeighborShankEachCell{i};
    spikes{i} = spikes{i}(logical(belong(GoodSleepInterval.intervalSetFormat,spikes{i})));
    if length(neighbor)==1
        for j = 1:length(freqlist)
            spkphases{i,j} = phase{neighbor}(round(spikes{i}*samplingRate)>0,j);
            spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
        end
    elseif length(neighbor)==2
        for j = 1:length(freqlist)
            for k = 1:length(spikes{i})
                if ~isnan(phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j)) && ~isnan(phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j))
                    spkphases{i,j}(k) = CircularMean([phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j);...
                        phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j)]);
                elseif ~isnan(phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j))
                    spkphases{i,j}(k) = phase{neighbor(1)}(round(spikes{i}(k)*samplingRate),j);
                elseif ~isnan(phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j))
                    spkphases{i,j}(k) = phase{neighbor(2)}(round(spikes{i}(k)*samplingRate),j);
                else
                    spkphases{i,j}(k) = NaN;
                end
            end
            spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
        end
    end
end

% phasedistros(1:numBins,1:length(spikes),1:length(freqlist)) = [];
% phasestats.m(1:length(spikes),1:length(freqlist)) = [];
% phasestats.r(1:length(spikes),1:length(freqlist)) = [];
% phasestats.k(1:length(spikes),1:length(freqlist)) = [];
% phasestats.p(1:length(spikes),1:length(freqlist)) = [];
% phasestats.mode(1:length(spikes),1:length(freqlist)) = [];
% for i = 1:length(spikes)
%     for j = 1:length(freqlist)
%         if ~isempty(spkphases{i,j})
%             [phasedistros(:,i,j),~,ps]=CircularDistribution(spkphases{i,j},'nBins',numBins);
%             phasestats.m(i,j) = mod(ps.m,2*pi);
%             phasestats.r(i,j) = ps.r;
%             phasestats.k(i,j) = ps.k;
%             phasestats.p(i,j) = ps.p;
%             phasestats.mode(i,j) = ps.mode;
%         end
%     end
% end