function MoveFileTypesPerSession_all

dest2 = '/home/brendon/Desktop/Dropbox/Dan&Brendon/Aug28NewSpikingFiles/';

% [names,dirs]=GetDefaultDataset('new');
[names,dirs]=GetDefaultDataset;

if ~exist(dest2,'dir')
    mkdir (dest2)
end

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

%     dest2 = fullfile(dest,basename);
%     if ~exist(dest2,'dir')
%         mkdir(dest2)
%     end
    
    t = load(fullfile(basepath,[basename,'_BasicMetaData.mat']));


%% specifics below
% 
%     fname1 = fullfile(basepath,[basename '_BasicMetaData.mat']);
%     copyfile(fname1,dest2);
%     
%     if isfield(t,'masterpath');
%         fname1 = fullfile(t.masterpath,[t.mastername '.res*']);
%     else
%         fname1 = fullfile(basepath,[basename '.res*']);
%     end
%     copyfile(fname1,dest2);
% 
%     if isfield(t,'masterpath');
%         fname1 = fullfile(t.masterpath,[t.mastername '.clu*']);
%     else
%         fname1 = fullfile(basepath,[basename '.clu*']);
%     end
%     copyfile(fname1,dest2);
% 
%     if isfield(t,'masterpath');
%         fname1 = fullfile(t.masterpath,[t.mastername '.fet*']);
%     else
%         fname1 = fullfile(basepath,[basename '.fet*']);
%     end
%     copyfile(fname1,dest2);
% 
%     if isfield(t,'masterpath');
%         fname1 = fullfile(t.masterpath,[t.mastername '.spk*']);
%     else
%         fname1 = fullfile(basepath,[basename '.spk*']);
%     end
%     copyfile(fname1,dest2);
% 
%     if isfield(t,'masterpath');
%         fname1 = fullfile(t.masterpath,[t.mastername '.xml']);
%     else
%         fname1 = fullfile(basepath,[basename '.xml']);
%     end
%     copyfile(fname1,dest2);
%     
%     fname1 = fullfile(basepath,[basename '_Intervals.mat']);
%     copyfile(fname1,dest2);
% 
    fname1 = fullfile(basepath,[basename '_SStable.mat']);
    copyfile(fname1,dest2);

    fname1 = fullfile(basepath,[basename '_SSubtypes.mat']);
    copyfile(fname1,dest2);
    
    fname1 = fullfile(basepath,[basename '_CellIDs.mat']);
    copyfile(fname1,dest2);
%     
%     fname1 = fullfile(basepath,[basename '_SpikeGroupAnatomy.csv']);
%     copyfile(fname1,dest2);
%
%     fname1 = fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']);
%     copyfile(fname1,dest2);
% 
%     fname1 = fullfile(basepath,[basename '_funcsynapsesMS_DiffShank.mat']);
%     copyfile(fname1,dest2);
% 
%     fname1 = fullfile(basepath,[basename '_WSWEpisodes.mat']);
%     copyfile(fname1,dest2);
% 
%     fname1 = fullfile(basepath,[basename '_EMGCorr.mat']);
%     copyfile(fname1,dest2);
% 
%     fname1 = fullfile(basepath,[basename '_UPDOWNIntervals.mat']);
%     copyfile(fname1,dest2);

    fname1 = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsAll.mat']);
    copyfile(fname1,dest2);
    fname1 = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']);
    copyfile(fname1,dest2);
    fname1 = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsI.mat']);
    copyfile(fname1,dest2);
end
