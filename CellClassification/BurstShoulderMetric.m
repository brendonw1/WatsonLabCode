function BSM = BurstShoulderMetric(basepath,basename)
% Looks at ratio of "burst" time of ACG vs further away "shoulder" time of
% acg for each cell.  May differentiate cell types.
%
% Brendon Watson

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

burstbounds = [8 12];
shoulderbounds = [25 30];

load(fullfile(basepath,[basename '_ACGCCGsAll.mat']))
acgs = ACGCCGsAll.ACGs{2};%30ms
times = ACGCCGsAll.Times{2};
bursttimes = times>=burstbounds(1) & times<=burstbounds(2);
shouldertimes = times>shoulderbounds(1) & times<shoulderbounds(2);
BSM = mean(acgs(bursttimes,:))./mean(acgs(shouldertimes,:));

save(fullfile(basepath,[basename '_BurstShoulder.mat']),'BSM')