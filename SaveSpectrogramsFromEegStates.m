function specs = SaveSpectrogramsFromEegStates(basepath)

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);


eegstatesname = fullfile(basepath,[basename '.eegstates.mat']);
savespecname = fullfile(basepath,[basename '.specs.mat']);

load(eegstatesname);
% will load "stateInfo"

for a = 1:length(StateInfo.fspec);
    specs(a).spec = StateInfo.fspec{a}.spec;
    specs(a).freqs = StateInfo.fspec{a}.fo;
    specs(a).times = StateInfo.fspec{a}.to;    
end

save(savespecname,'specs');
