function SleepPETHs_RippleIncidenceOverPacketsSWSEpsSleep
warning off

%I for intervals

[names,dirs] = GetHippoDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
%     AllEpochsD{a} = {};
%     AllEpAlignedD{a} = [];
    AllEpochsI{a} = {};
    AllEpAlignedI{a} = [];
end
params.figformat = 'png';
params.prepostsec = [-10 40];
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
    dataI = ones(size(times));

    for b = 1:numstatetypes
        tdataI = dataI;
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            status = status1+status2;
            status = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
        if sum(isnan(tdataI)) < numel(tdataI)%unless there are no I cells;
            [Epochs,~,EpAligned] = IntervalPETH_IrregularSumPerSec(tdataI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            if normbool
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            end
            [AllEpochsI{b},AllEpAlignedI{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsI{b},AllEpAlignedI{b});
        end
    end
end


%% saving and plotting
RippleIncidenceOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsI,AllEpAlignedI);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedI{b},params);
    set(h(end),'name',['RippleIncidenceOver' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',RippleIncidenceOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Ripples/',h,'png')






