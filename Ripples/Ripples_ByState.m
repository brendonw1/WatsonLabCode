function Ripples_ByState
warning off

[names,dirs] = GetHippoDataset;

statenames = {'Sleep','SWSPackets','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
%     AllEpochsD{a} = {};
%     AllEpAlignedD{a} = [];
    AllEpochsI{a} = {};
    AllEpAlignedI{a} = [];
end
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 20;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    %loading stuff for each recording
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,'Ripples','RippleData.mat'))
    starts = RippleData.ripples(:,1);
    ends = RippleData.ripples(:,3);    
    
    % gather intervals for each state... should correspond with
    % numstatetypes
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);

    for b = 1:numstatetypes
        tint = stateInts{b};
        t1 = InIntervalsBW(starts,tint);
        t2 = InIntervalsBW(ends,tint);
        good = t1.*t2;
        RippleIncidenceByState(a,b) = sum(good)/sum(diff(tint,[],2));
    end
end

[p,PairwiseCIs,h] = KruskalByLabel(RippleIncidenceByState(:),size(RippleIncidenceByState,1)*ones(length(statenames),1),statenames);
h(end+1) = figure('name','RipplesByStateBPlot');
bplot(RippleIncidenceByState);
set(gca,'xtick',1:length(statenames),'xticklabel',statenames)
ylabel('Events Per Second')
title('Box plot: Red horiz: Medians. +: means. Boxes: 25/75%iles. Errorbars: 9-91%ile','fontweight','normal','fontsize',9)

% xticklabel_rotate

%% saving and plotting

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Ripples/',RippleIncidenceByState)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Ripples/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Ripples/',h,'png')






