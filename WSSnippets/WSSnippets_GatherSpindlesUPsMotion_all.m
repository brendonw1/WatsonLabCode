function WSSnippets_GatherSpindlesUPsMotion_all

wsw = 1;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
    
    if ~exist(fullfile(basepath,[basename '_WSWEpisodes2.mat']),'file')
        copyfile(fullfile(basepath,[basename '_WSWEpisodes.mat']),fullfile(basepath,[basename '_WSWEpisodes2.mat']))
    end    
%     if exist(fullfile(basepath,'Snippets','dir'))
%         delete(fullfile(basepath,'Snippets','dir'))
%     end
    WSSnippets_GatherSpindlesUPsMotion;
    close all
end
