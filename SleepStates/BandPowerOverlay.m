function BandPowerOverlay(MinFreq,MaxFreq,basepath,basename)

if ~exist('MinFreq','var')
    MinFreq = 0.5;
end
if ~exist('MaxFreq','var')
    MaxFreq = 4;
end
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
   freqidxs = find(StateInfo.fspec{a}.fo>=MinFreq & StateInfo.fspec{a}.fo<MaxFreq);
   spec = StateInfo.fspec{a}.spec(:,freqidxs);
   spec = zscore(log10(spec'),0,2);
   p = sum(spec,1);
    
   allpowers = cat(1,allpowers,p);
end

save(fullfile(basepath,[basename '_StateEditorOverlay_Band' num2str(MinFreq) '-' num2str(MaxFreq) 'Hz.mat']),'allpowers')