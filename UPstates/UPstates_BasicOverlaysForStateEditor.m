function UPstates_BasicOverlaysForStateEditor(basename,iss,starts)
%% Save stats trains out for StateEditor

celltype = inputname(2);
switch celltype
    case 'iss'
        celltype = 'All';
    case 'isse'
        celltype = 'E';
    case 'issi'
        celltype = 'I';
    case 'issed'
        celltype = 'EDef';
    case 'issid'
        celltype = 'IDef';
end        


t = load([basename '-states.mat']);
nsec = size(t.states,2);
clear t

spikecounts = zeros(1,nsec);
durations = zeros(1,nsec);
spikerates = zeros(1,nsec);
% amplitudes = zeros(1,nsec);
% frequencies = zeros(1,nsec);

% starts = floor(SpindleData.normspindles(:,1));
starts = floor(starts);

ns = bwnormalize(iss.intspkcounts);
nd = bwnormalize(iss.intends - iss.intstarts);
nr = bwnormalize(iss.intspkcounts ./ (iss.intends-iss.intstarts));
% na = bwnormalize(SpindleData.data.peakAmplitude);
% nf = bwnormalize(SpindleData.data.peakFrequency);

for a = 1:length(starts)
    spikecounts(starts(a)) =  ns(a);
    durations(starts(a)) = nd(a);
    spikerates(starts(a)) = nr(a);
%     amplitudes(starts(a)) = na(a);
%     frequencies(starts(a)) = nf(a);
end

% spikecounts = zscore(spikecounts);
% durations = zscore(durations);
% spikerates = zscore(spikerates);
% amplitudes = zscore(amplitudes);
% frequencies = zscore(frequencies);

CountDurRate = cat(1,spikecounts,durations,spikerates);
save(fullfile('UPstates',[basename '_StateEditorOverlay_UPstateSpkcountDurationSpkrate' celltype]),'CountDurRate')

% DurAmpFreq = cat(1,durations,amplitudes,frequencies);
% save(fullfile('Spindles',[basename '_StateEditorOverlay_SpindleDurationAmplitudeFrequency' celltype]),'DurAmpFreq')
% 
% RateAmpFreq = cat(1,spikerates,amplitudes,frequencies);
% save(fullfile('Spindles',[basename '_StateEditorOverlay_SpindleSpkrateAmplitudeFrequency' celltype]),'RateAmpFreq')

