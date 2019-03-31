function SleepPETHs_RippleAmpFreqOverPacketsSWSEpsSleep
warning off

%D for durations
%I for intervals

[names,dirs] = GetHippoDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsF{a} = {};
    AllEpAlignedF{a} = [];
    AllEpochsA{a} = {};
    AllEpAlignedA{a} = [];
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
    load(fullfile(basepath,'Ripples','RippleData.mat'))
    starts = RippleData.ripples(:,1);
    ends = RippleData.ripples(:,3);    
    
    % gather intervals for each state... should correspond with
    % numstatetypes
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);

    % gathering data which won't change depending on the interval selected:
    times = mean([starts ends],2);
    
    dataF = RippleData.data.peakFrequency;
    dataA = RippleData.data.peakAmplitude;

    for b = 1:numstatetypes
        tdataF = dataF;
        tdataA = dataA;
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            status = status1+status2;
            tdataF(~status) = nan; 
            tdataA(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
        [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdataF,times,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsF{b},AllEpAlignedF{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsF{b},AllEpAlignedF{b});

        [Epochs,~,EpAligned] = IntervalPETH_Irregular(dataA,times,stateInts{b},binspernormepoch,sffororiginalepochs);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsA{b},AllEpAlignedA{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsA{b},AllEpAlignedA{b});
    end
end


%% saving and plotting
RippleAmpFreqOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsF,AllEpAlignedF,AllEpochsA,AllEpAlignedA);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedF{b},params);
    set(h(end),'name',['RippleFrequencyOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedA{b},params);
    set(h(end),'name',['RippleAmplitudeOver' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',RippleAmpFreqOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',h,'png')

