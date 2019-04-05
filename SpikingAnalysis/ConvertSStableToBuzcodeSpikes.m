function ConvertSStableToBuzcodeSpikes(basepath)

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

%% Get spikes
spikes = bz_GetSpikes('basepath',basepath);
save([basepath filesep basename '.spikes-Orig.cellinfo.mat'],'spikes')

%% Correct by SStable bad cells
load(fullfile(basepath,[basename '_SStable.mat']),'badcells')
bad = badcells.allbadcells;

% for bidx = 1:length(bad)
%     spikes.spindices((spikes.spindices(:,2) == bad(bidx)),:) = [];
% end
% spikes.numcells = spikes.numcells-length(bad);
if isfield (spikes,'spindices')
    spikes = rmfield(spikes,'spindices');
end
if isfield (spikes,'numcells')
    spikes = rmfield(spikes,'numcells');
end

spikes.UID(bad) = [];
spikes.times(bad) = [];
spikes.shankID(bad) = [];
spikes.cluID(bad) = [];
spikes.rawWaveform(bad) = [];
spikes.maxWaveformCh(bad) = [];

save([basepath filesep basename '.spikes.cellinfo.mat'],'spikes')

