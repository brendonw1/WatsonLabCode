function DeltaPowerOverlay(basepath,basename)

maxfreq = 4;
minfreq = 0.5;

if ~exist('basepath','var')
 [~,basename,~] = fileparts(cd);
 basepath = cd;   
end

bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
if isfield(bmd,'masterpath')
    basepath = bmd.masterpath;
    basename = bmd.mastername;
end

% load(fullfile(basepath,[basename '.states.mat']))%brings in states, transitions, events
load(fullfile(basepath,[basename '.eegstates.mat']))%brings in StateInfo variable
nspec = length(StateInfo.Chs);

allpowers = [];

for a = 1:nspec
   freqidxs = find(StateInfo.fspec{a}.fo>=minfreq & StateInfo.fspec{a}.fo<maxfreq);
   spec = StateInfo.fspec{a}.spec(:,freqidxs);
   spec = zscore(log10(spec'),0,2);
   p = sum(spec,1);
    
   allpowers = cat(1,allpowers,p);
end

save(fullfile(basepath,[basename '_StateEditorOverlay_DeltaPower.mat']),'allpowers')