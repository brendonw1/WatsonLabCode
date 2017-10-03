function SimilarityMetricToStateEditorOverlay(m,evttimes,basename,metricname)
% save sum of m matrix on one dimension to a state editor overlay

% metricname = inputname(1);
% switch metricname(end)
%     case 'iss'
%         celltype = 'All';
%     case 'isse'
%         celltype = 'E';
%     case 'issi'
%         celltype = 'I';
%     case 'issed'
%         celltype = 'EDef';
%     case 'issid'
%         celltype = 'IDef';
% end        

%get number of secs
t = load([basename '-states.mat']);
nsec = size(t.states,2);
clear t

m(isnan(m)) = 0;
metricperevent = sum(m,1);
nm = bwnormalize(metricperevent);
metricpertime = zeros(1,nsec);

for a = 1:length(evttimes)
    metricpertime(round(evttimes(a))) =  nm(a);
end

% spikecounts = zscore(spikecounts);
% durations = zscore(durations);
% spikerates = zscore(spikerates);
% amplitudes = zscore(amplitudes);
% frequencies = zscore(frequencies);

save(fullfile('Spindles',[basename '_StateEditorOverlay_' metricname]),'metricpertime')