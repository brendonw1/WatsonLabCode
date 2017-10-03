function WSSnippets_GatherSpikeSynAss_all(ep1,ep2)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%
% Brendon Watson 2015


if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end


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
    WSSnippets_GatherSpikeSynAss(ep1,ep2);
    close all
end
