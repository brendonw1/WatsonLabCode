function SleepPETHs_SpindleDursIntsOverPacketsSWSEpsSleep
warning off

%D for durations
%I for intervals

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsD{a} = {};
    AllEpAlignedD{a} = [];
    AllEpochsI{a} = {};
    AllEpAlignedI{a} = [];
end
params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 20;

normperiod = 'allin';
normmode = 'meandiv';
normbool = 0;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    %loading stuff for each recording
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,'Spindles','SpindleData.mat'))
    starts = SpindleData.normspindles(:,1);
    ends = SpindleData.normspindles(:,3);    
    
    % gather intervals for each state... should correspond with
    % numstatetypes
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);

    % gathering data which won't change depending on the interval selected:
    times = mean([starts ends],2);
    durs = ends-starts;
    ints = starts(2:end)-ends(1:end-1);    
    timesD = times;
    timesI = mean([starts(2:end) ends(1:end-1)],2);
    
    dataD = durs;
    dataI = ints;

    for b = 1:numstatetypes
        tdataD = dataD;
        tdataI = dataI;
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            status = status1+status2;
            tdataD(~status) = nan; 
            tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataD,timesD,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsD{b},AllEpAlignedD{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsD{b},AllEpAlignedD{b});

        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataI,timesI,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsI{b},AllEpAlignedI{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsI{b},AllEpAlignedI{b});
    end
end


%% saving and plotting
SpindleDursIntsOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsD,AllEpAlignedD,AllEpochsI,AllEpAlignedI);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedD{b},params);
    set(h(end),'name',['SpindleDurationsOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedI{b},params);
    set(h(end),'name',['SpindleIntervalsOver' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Spindles/',SpindleDursIntsOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Spindles/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Spindles/',h,'png')

