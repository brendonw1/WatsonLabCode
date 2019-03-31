function SleepPETHs_EIRatioOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochs{a} = {};
    AllEpAligned{a} = [];
end

normperiod = 'allin';
normmode = 'meandiv';

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

    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,[basename '_EIRatio.mat']))

    % gather intervals for each state... should correspond with
    % numstatetypes
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    
    times = EIRatioData.bincentertimes;
    data = EIRatioData.EI;
    sf = 1/mode(diff(times));

    for b = 1:numstatetypes
        tdata = data;
        mask = [];
        if strcmp(statenames{b},'SWSSleep')
            status1 = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            okwake = intervalSet([],[]);
            for c = 1:length(WakeSleep);
                okwake = cat(okwake,subset(WakeSleep{c},1));
            end
            status2 = InIntervalsBW(times,StartEnd(okwake,'s'));
            mask = double(~(status1+status2));
%             tdataE(~status) = nan;
%             tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        else
            tdata = data;
        end
        if ~isempty(stateInts{b})
            if sum(isnan(tdata)) < numel(tdata)%unless there are no I cells;
                [Epochs,~,EpAligned] = IntervalPETH(tdata,stateInts{b},100,sf,params,mask);
        %         [Epochs,~,EpAligned] = IntervalPETHg(tdataE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                if normbool
                    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode);
                end
                [AllEpochs{b},AllEpAligned{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochs{b},AllEpAligned{b});
    %             %E Population CoV
    %             [Epochs,~,EpAligned] = IntervalPETH_Irregular(tdata,times,stateInts{b},binspernormepoch,sffororiginalepochs);
    %             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
    %             [AllEpochs{b},AllEpAligned{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochs{b},AllEpAligned{b});
            end
        end
    end
end    

%% saving and plotting
EIRatioOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochs,AllEpAligned);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAligned{b},params);
    set(h(end),'name',['EIRatioOverSleepInts' statenames{b}])
end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',EIRatioOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',h,'png')



    
    %
%     
%     for b = 1:numstatetypes
%         if strcmp(statenames{b},'SWSSleep')
%             status = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
%             tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
%             % so intervals with only nan are taken out of both numerator
%             % and denominator.  And intervals with only nan are those
%             % totally outside of packets
%         else
%             tdataI = dataI;
%         end
%     
% %% Packets
%     ints = StartEnd(SWSPacketInts,'s');
%     sf = 1/mode(diff(EIRatioData.bincentertimes));
% %     parms.prepostsec = [-20 40];
% 
%     
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsP,AllEpAlignedP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsP,AllEpAlignedP);
%     end
%     %Z'd PerCell EI
%     data = EIRatioData.ZPCEI;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsNP,AllEpAlignedNP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNP,AllEpAlignedNP);
%     end
%     
% %% Episodes
%     ints = StartEnd(SWSEpisodeInts,'s');
%     sf = 1/mode(diff(EIRatioData.bincentertimes));
% %     parms.prepostsec = [-30 60];
% 
%     data = EIRatioData.EI;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsE,AllEpAlignedE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsE,AllEpAlignedE);
%     end
%     %Z'd PerCell EI
%     data = EIRatioData.ZPCEI;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsNE,AllEpAlignedNE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNE,AllEpAlignedNE);
%     end
%     
% %% Sleep
%     ints = StartEnd(SleepInts,'s');
%     sf = 1/mode(diff(EIRatioData.bincentertimes));
% %     parms.prepostsec = [-100 200];
%     
%     data = EIRatioData.EI;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsS,AllEpAlignedS] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsS,AllEpAlignedS);
%     end
%     %Z'd PerCell EI
%     data = EIRatioData.ZPCEI;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketEIRatio';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsNS,AllEpAlignedNS] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNS,AllEpAlignedNS);
%     end%     ints = StartEnd(SleepInts,'s');
% end
% 
% %% saving and plotting
% EIOverSleepInts = v2struct(sf,AllEpochsP,AllEpAlignedP,AllEpochsNP,AllEpAlignedNP,...
%     AllEpochsE,AllEpAlignedE,AllEpochsNE,AllEpAlignedNE,...
%     AllEpochsS, AllEpAlignedS, AllEpochsNS, AllEpAlignedNS);
% 
% h = [];
% h(end+1) = PlotPETHFigure(AllEpAlignedP,params);
% set(h(end),'name','NonNormEIOverPackets')
% h(end+1) = PlotPETHFigure(AllEpAlignedNP,params);
% set(h(end),'name','ZandPerCellNormEIOverPackets')
% h(end+1) = PlotPETHFigure(AllEpAlignedE,params);
% set(h(end),'name','NonNormEIOverEpisodes')
% h(end+1) = PlotPETHFigure(AllEpAlignedNE,params);
% set(h(end),'name','ZandPerCellNormEIOverEpisodes')
% h(end+1) = PlotPETHFigure(AllEpAlignedS,params);
% set(h(end),'name','NonNormEIOverSleep')
% h(end+1) = PlotPETHFigure(AllEpAlignedNS,params);
% set(h(end),'name','ZandPerCellNormEIOverSleep')
% 
% MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',EIOverSleepInts)
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',h)
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/EIRatio/',h,'svg')
