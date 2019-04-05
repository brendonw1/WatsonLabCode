function Assemblies_CrossStateMeans_all(secondsperbin)

if ~exist('secondsperbin','var')
    secondsperbin = 1;
end

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%      StateRateBins = GatherStateRateBinMatrices(basepath,basename,1,1);
%     fname1 = fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesPCA_' num2str(secondsperbin) 'sec']);
%     fname2 = fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesPCA_' num2str(secondsperbin) 'sec.mat']);
%     if exist(fname1,'file')
%         movefile(fname1,fname2)
%     end
%     fname1 = fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesICA_' num2str(secondsperbin) 'sec']);
%     fname2 = fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesICA_' num2str(secondsperbin) 'sec.mat']);
%     if exist(fname1,'file')
%         movefile(fname1,fname2)
%     end

    Assemblies_CrossStateMeans(basepath,basename,secondsperbin);
%     close all
end
