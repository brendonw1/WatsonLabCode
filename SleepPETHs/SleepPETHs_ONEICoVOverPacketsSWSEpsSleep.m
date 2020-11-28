function SleepPETHs_ONEICoVOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsCoVE{a} = {};
    AllEpAlignedCoVE{a} = [];
    AllEpochsCoVI{a} = {};
    AllEpAlignedCoVI{a} = [];
    AllEpochsEIR{a} = {};
    AllEpAlignedEIR{a} = [];
end
params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 20;

normperiod = 'allin';
normmode = 'meandiv';
normbool = 1;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    %loading stuff for each recording
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,'UPstates',[basename '_UPONCovEI.mat']))
    load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']))
    
% gathering data which won't change depending on the interval selected:
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    
    starts = Start(ONInts,'s');
    ends = End(ONInts,'s');
    times = mean([starts ends],2);

    dataCoVE = UPONCovEI.PerONCoVE;
    dataCoVI = UPONCovEI.PerONCoVI;
    dataEIR = UPONCovEI.PerONEIZ;
    
    for b = 1:numstatetypes
        tdataCoVE = dataCoVE;
        tdataCoVI = dataCoVI;
        tdataEIR = dataEIR;
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            status = status1+status2;
            tdataCoVE(~status) = nan; 
            tdataCoVI(~status) = nan; 
            tdataEIR(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
        
        %E Population CoV
        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataCoVE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsCoVE{b},AllEpAlignedCoVE{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsCoVE{b},AllEpAlignedCoVE{b});
        
        %EIR
        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataEIR,times,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsEIR{b},AllEpAlignedEIR{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEIR{b},AllEpAlignedEIR{b});

        % I Population CoV
        if sum(isnan(tdataCoVI)) < numel(tdataCoVI)%unless there are no I cells;
            [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataCoVI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            if normbool
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            end
            [AllEpochsCoVI{b},AllEpAlignedCoVI{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsCoVI{b},AllEpAlignedCoVI{b});
        end
    end
    
%     
%     
end


%% saving and plotting
ONEICoVOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsCoVE,AllEpAlignedCoVE,AllEpochsCoVI,AllEpAlignedCoVI,AllEpochsEIR,AllEpAlignedEIR);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedCoVE{b},params);
    set(h(end),'name',['ECellONCoVOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedCoVI{b},params);
    set(h(end),'name',['ICellONCoVOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedEIR{b},params);
    set(h(end),'name',['ONEIROver' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',ONEICoVOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h,'png')
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPRates/',h,'svg')

