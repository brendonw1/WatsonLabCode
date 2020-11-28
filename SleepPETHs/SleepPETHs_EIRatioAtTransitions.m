function SleepPETHs_EIRatioAtTransitions
warning off

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','REM','MA'};
numstatetypes = length(statenames);
statecombonames = {'SWStoREM';'SWStoMA'};
statecombonumbers = [1 2;1 3];
for a = 1:length(statecombonames) %because we will cycle through 7 states
    AllEpochs{a} = {};
    AllPETHs{a} = [];
end

params.figformat = 'png';
prepostsec = [30 30];

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
    sf = 1/mode(diff(times));
    data = EIRatioData.EI;
    numpre = prepostsec(1)*sf;
    numpost = prepostsec(2)*sf;
    
    for b = 1:size(statecombonumbers,1);
%         if strcmp(statenames{b},'SWSSleep')
%             status = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
%             tdata(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
%             % so intervals with only nan are taken out of both numerator
%             % and denominator.  And intervals with only nan are those
%             % totally outside of packets
%         else
            tdata = data;
%         end
        if sum(isnan(tdata)) < numel(tdata)%unless there are no I cells;
            preint = stateInts{statecombonumbers(b,1)};
            postint = stateInts{statecombonumbers(b,2)};
            [epochs,PETH] = TransitionPETH(tdata,preint,postint,prepostsec,sf);
            if normbool
                [epochs,PETH] = NormTransitionPETHToPrePost(epochs,PETH,numpre,numpost);
            end
            AllEpochs{b} = cat(1,AllEpochs{b},epochs);
            AllPETHs{b} = cat(2,AllPETHs{b},PETH.mean);
        end
    end
end    
PETHTimes = PETH.t;

%% saving and plotting
EIRatioOverSleepInts = v2struct(statenames,...
    AllEpochs,AllPETHs);

h = [];
for b = 1:size(statecombonumbers,1);
    h(end+1) = PlotTransitionPETHFigure(PETHTimes,AllPETHs{b});
    xlabel('sec')
    set(h(end),'name',['EIRatioOver' statecombonames{b}])
end

h(end+1) = TransitionPETHComparisonFigure(PETHTimes,AllPETHs);
xlabel('sec')
legend(statecombonames)
set(h(end),'name','ComparisonAcrossTransitions')


MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Transitions/EIRatio/',EIRatioOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Transitions/EIRatio/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Transitions/EIRatio/',h,'png')



    
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
