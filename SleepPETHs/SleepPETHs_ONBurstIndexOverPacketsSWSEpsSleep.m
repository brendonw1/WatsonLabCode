function SleepPETHs_ONBurstIndexOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsE{a} = {};
    AllEpAlignedE{a} = [];
    AllEpochsI{a} = {};
    AllEpAlignedI{a} = [];
end

normperiod = 'allin';
normmode = 'meandiv';
normbool = 0;

params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 20;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    %loading stuff for each recording
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,'UPstates',[basename '_UPONBurst.mat']))
    
% gathering data which won't change depending on the interval selected:
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    

    dataE = UPONBurst.OMBIE;
    dataI = UPONBurst.OMBII;
    times = UPONBurst.bincentertimes;

    for b = 1:numstatetypes
        tdataE = dataE;
        tdataI = dataI;
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            status = status1+status2;
            tdataE(~status) = nan; 
            tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
        
        %E Population Mean bursting
        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode);
        end
        [AllEpochsE{b},AllEpAlignedE{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsE{b},AllEpAlignedE{b});

        % I Population Mean Bursting
        if sum(isnan(tdataI)) < numel(tdataI)%unless there are no I cells;
            [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            if normbool
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode);
            end
            [AllEpochsI{b},AllEpAlignedI{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsI{b},AllEpAlignedI{b});
        end
    end
end


%% saving and plotting
UPEIBurstIndexOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsE,AllEpAlignedE,AllEpochsI,AllEpAlignedI);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedE{b},params);
    set(h(end),'name',['ECellONBurstIndexOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedI{b},params);
    set(h(end),'name',['ICellUPONBurstIndexOver' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',ONEIBurstIndexOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h,'png')
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPRates/',h,'svg')

