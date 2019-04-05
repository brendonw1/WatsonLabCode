function SleepDataset_ExtractBinaryMotionOverDatasets

binningfactor = 100000;%10sec
numplots = 0;
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWCellsSynapses;

for a = 1:length(dirs);
    t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
    WSWEpisodes = t.WSWEpisodes;
    numplots = numplots+size(WSWEpisodes,2);
end
    
plotcounter = 1;
for a = 1:length(dirs);
    t = load([fullfile(dirs{a},names{a}) '_Motion.mat']);
    motiondata = t.motiondata;
    clear t
    
    filttype = motiondata.filttype;
    
    movementsecs = filtermotionsig(motiondata.motion,filttype);
    title([names{a},' ',filttype])
    
    
    motiondata.thresholdedsecs = movementsecs;


    save([fullfile(dirs{a},names{a}) '_Motion.mat'],'motiondata')
end



%% user-classifying as noisy vs clean and making an initial _Motion.mat
% binningfactor = 100000;%10sec
% numplots = 0;
% [names,dirs] = SleepDataset_GetDatasetsDirs_WSWCellsSynapses;
% 
% for a = 1:length(dirs);
%     t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
%     WSWEpisodes = t.WSWEpisodes;
%     numplots = numplots+size(WSWEpisodes,2);
% end
%     
% plotcounter = 1;
% for a = 1:length(dirs);
%     t = load([fullfile(dirs{a},names{a}) '.eegstates.mat']);
%     motion = t.StateInfo.motion;
%     clear t
%     
%      movementsecs = filtermotionsig(motion);
%      title(names{a})
% 
% %     movementsecs = filtermotionsig(motion);
% %     title(names{a})
% 
%     strs = {'Clean (Baseline fluct OK)';'High Freq Noise'};
%     [s,v] = listdlg('PromptString','Clean or noisy baseline?','SelectionMode','single','ListString',strs);
% 
%     motiondata.motion = motion;
%     switch s
%         case 1
%             motiondata.filttype = 'clean';
%         case 2 
%             motiondata.filttype = 'noisybaseline';
%     end
%     save([fullfile(dirs{a},names{a}) '_Motion.mat'],'motiondata')
% %     motiondata.thresholdedsecs = movementsecs;
% end
