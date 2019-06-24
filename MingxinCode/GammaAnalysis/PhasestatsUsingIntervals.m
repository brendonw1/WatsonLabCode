function [phasestats,spkphasesIn,spkNumIn,spkInIdx] = PhasestatsUsingIntervals(spikes,spkphases,Interval,cellneighborIdx,freqlist,SamplingRate)

% if length(size(spikes))<3
spkNumIn = zeros(length(cellneighborIdx),length(freqlist));
spkphasesIn = cell(length(cellneighborIdx),length(freqlist));
spkInIdx = cell(length(cellneighborIdx),length(freqlist));
for ii = 1:length(spikes)
    for jj = 1:length(freqlist)
        if ~isempty(Interval{cellneighborIdx(ii),jj})
            [status,~,~] = InIntervals(spikes{ii}*SamplingRate,Interval{cellneighborIdx(ii),jj});
        else
            status = false(length(spikes{ii}),1);
        end
        spkphasesIn{ii,jj} = spkphases{ii,jj}(status);
        spkNumIn(ii,jj) = sum(status);
        spkInIdx{ii,jj} = status;
        if spkNumIn(ii,jj)>0
            [~,~,stats] = CircularDistribution(double(spkphasesIn{ii,jj}),'nBins',180);
            phasestats.m(ii,jj) = stats.m;
            phasestats.r(ii,jj) = stats.r;
            phasestats.k(ii,jj) = stats.k;
            phasestats.p(ii,jj) = stats.p;
            phasestats.mode(ii,jj) = stats.mode;
        else
            phasestats.m(ii,jj) = nan;
            phasestats.r(ii,jj) = nan;
            phasestats.k(ii,jj) = nan;
            phasestats.p(ii,jj) = nan;
            phasestats.mode(ii,jj) = nan;
        end
    end
end

% else

%     spkNumIn = zeros(length(cellneighborIdx),length(freqlist),size(spkphases,3));
%     spkphasesIn = cell(length(cellneighborIdx),length(freqlist),size(spkphases,3));
%     for ii = 1:length(spikes)
%         for jj = 1:length(freqlist)
%             for kk = 1:size(spkphases,3)
%                 if ~isempty(Interval{cellneighborIdx(ii),jj})
%                     [status,~,~] = InIntervals(spikes{ii,jj,kk}*SamplingRate,Interval{cellneighborIdx(ii),jj});
%                     spkphasesIn{ii,jj,kk} = spkphases{ii,jj,kk}(status);
%                     spkNumIn(ii,jj,kk) = sum(status);
%                 end
%                 if spkNumIn(ii,jj,kk)>0
%                     [~,~,stats] = CircularDistribution(spkphasesIn{ii,jj,kk},'nBins',180);
%                     phasestats.m(ii,jj,kk) = stats.m;
%                     phasestats.r(ii,jj,kk) = stats.r;
%                     phasestats.k(ii,jj,kk) = stats.k;
%                     phasestats.p(ii,jj,kk) = stats.p;
%                     phasestats.mode(ii,jj,kk) = stats.mode;
%                 else
%                     phasestats.m(ii,jj,kk) = nan;
%                     phasestats.r(ii,jj,kk) = nan;
%                     phasestats.k(ii,jj,kk) = nan;
%                     phasestats.p(ii,jj,kk) = nan;
%                     phasestats.mode(ii,jj,kk) = nan;
%                 end
%             end
%         end
%     end
% end