function SleepPETHs_BurstIndexOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;


% statenames = {'Sleep','SWSSleep'};
statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','Wake'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsE{a} = {};
    AllEpAlignedE{a} = [];
    AllEpochsI{a} = {};
    AllEpAlignedI{a} = [];
end

normperiod = 'allin';
normmode = 'raw';
normbool = 0;

params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 50;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,[basename '_BurstPerBinData.mat']))

    % gather intervals for each state... should correspond with
    % numstatetypes
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    
    times = BurstPerBinData.bincentertimes;
    dataE = BurstPerBinData.MBIE;
    dataI = BurstPerBinData.MBII;
    sf = 1/mode(diff(times));
    
    for b = 1:numstatetypes
        tdataE = dataE;
        tdataI = dataI;
        mask = [];
        if strcmp(statenames{b},'SWSSleep')
            status = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
            mask = double(~status);
%             tdataE(~status) = nan;
%             tdataI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
            % so intervals with only nan are taken out of both numerator
            % and denominator.  And intervals with only nan are those
            % totally outside of packets
        end
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
        end
        %E Population
        if ~isempty(stateInts{b})
            [Epochs,~,EpAligned] = IntervalPETH(tdataE,stateInts{b},100,sf,params,mask);
            if normbool
                [Epochs,~,EpAligned] = IntervalPETHg(tdataE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            end
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode);
            [AllEpochsE{b},AllEpAlignedE{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsE{b},AllEpAlignedE{b});

            % I Population 
            if sum(isnan(tdataI)) < numel(tdataI)%unless there are no I cells;
                [Epochs,~,EpAligned] = IntervalPETH(tdataI,stateInts{b},100,sf,params,mask);
                if normbool
                    [Epochs,~,EpAligned] = IntervalPETHg(tdataI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                end
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs,normperiod,normmode);
                [AllEpochsI{b},AllEpAlignedI{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsI{b},AllEpAlignedI{b});
            end
        end
    end
end    

%% saving and plotting
MeanBurstIndexOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsE,AllEpAlignedE,AllEpochsI,AllEpAlignedI);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedE{b},params);
    set(h(end),'name',['ECellBurstIdxOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedI{b},params);
    set(h(end),'name',['ICellBurstIdxOver' statenames{b}])
end


MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/BurstIndex/',MeanBurstIndexOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/BurstIndex/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/BurstIndex/',h,'png')



% AllEpochsEP = {};
% AllEpAlignedEP = [];
% AllEpochsIP = {};
% AllEpAlignedIP = [];
% AllEpochsEE = {};
% AllEpAlignedEE = [];
% AllEpochsIE = {};
% AllEpAlignedIE = [];
% AllEpochsES = {};
% AllEpAlignedES = [];
% AllEpochsIS = {};
% AllEpAlignedIS = [];
% AllEpochsER = {};
% AllEpAlignedER = [];
% AllEpochsIR = {};
% AllEpAlignedIR = [];
% AllEpochsER_P = {};
% AllEpAlignedER_P = [];
% AllEpochsIR_P = {};
% AllEpAlignedIR_P = [];
% AllEpochsER_W = {};
% AllEpAlignedER_W = [];
% AllEpochsIR_W = {};
% AllEpAlignedIR_W = [];
% AllEpochsEW = {};
% AllEpAlignedEW = [];
% AllEpochsIW = {};
% AllEpAlignedIW = [];
% 
% params.figformat = 'png';
% parms.prepostsec = [-10 40];
% 
% for a = 1:length(dirs);
%     basename = names{a};
%     basepath = dirs{a};
% 
%     load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
%     load(fullfile(basepath,[basename '_BurstPerBinData.mat']))
% %     savedir = fullfile(basepath,'SleepPETHFigs');
% %     if ~exist(savedir,'dir')
% %         mkdir(savedir)
% %     end
% %     params.saveloc = savedir
% 
% %% Packets
%     ints = StartEnd(SWSPacketInts,'s');
%     sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %     parms.prepostsec = [-20 40];
% 
%     % E Population Coefficient of Variation
%     data = BurstPerBinData.MBIE;
% %     params.figname = 'PacketEPopCovariance';
%     [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%     [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%     [AllEpochsEP,AllEpAlignedEP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEP,AllEpAlignedEP);
%     
%     % I Population Coefficient of Variation
%     data = BurstPerBinData.MBII;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketIPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsIP,AllEpAlignedIP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIP,AllEpAlignedIP);
%     end
%     
% %% Episodes
%     ints = StartEnd(SWSEpisodeInts,'s');
%     sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %     parms.prepostsec = [-30 60];
%     
%     % E Population Coefficient of Variation
%     data = BurstPerBinData.MBIE;
% %     params.figname = 'PacketEPopCovariance';
%     [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%     [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%     [AllEpochsEE,AllEpAlignedEE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEE,AllEpAlignedEE);
%     
%     % I Population Coefficient of Variation
%     data = BurstPerBinData.MBII;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketIPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsIE,AllEpAlignedIE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIE,AllEpAlignedIE);
%     end
%     
% %% Sleep
%     ints = StartEnd(SleepInts,'s');
%     sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %     parms.prepostsec = [-100 200];
%     
%     % E Population Coefficient of Variation
%     data = BurstPerBinData.MBIE;
% %     params.figname = 'PacketEPopCovariance';
%     [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%     [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%     [AllEpochsES,AllEpAlignedES] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsES,AllEpAlignedES);
%     
%     % I Population Coefficient of Variation
%     data = BurstPerBinData.MBII;
%     if sum(isnan(data)) < numel(data)%unless there are no I cells;
% %         params.figname = 'PacketIPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsIS,AllEpAlignedIS] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIS,AllEpAlignedIS);
%     end
%     
% %% REM
%     ints = StartEnd(REMEpisodeInts,'s');
%     if ~isempty(ints)
%         sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %         parms.prepostsec = [-20 40];
% 
%         % E Population Coefficient of Variation
%         data = BurstPerBinData.MBIE;
%     %     params.figname = 'PacketEPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsER,AllEpAlignedER] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER,AllEpAlignedER);
% 
%         % I Population Coefficient of Variation
%         data = BurstPerBinData.MBII;
%         if sum(isnan(data)) < numel(data)%unless there are no I cells;
%     %         params.figname = 'PacketIPopCovariance';
%             [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%             [AllEpochsIR,AllEpAlignedIR] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR,AllEpAlignedIR);
%         end
%     end
% %% REM followed by SWS Packets
%     ints = StartEnd(REMEpisodeInts,'s');
%     sints = StartEnd(SWSPacketInts,'s');
%     evergood = zeros(size(ints,1),1);
%     for b = 1:size(ints,1);
%         d = sints(:,1)-ints(b,2);
%         g = d<10 & d>0;%if packet within 2 secs of end of REM
%         evergood(b) = logical(sum(g));
%     end
%     ints = ints(logical(evergood),:);
%     if ~isempty(ints)
%         sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %         parms.prepostsec = [-20 40];
% 
%         % E Population Coefficient of Variation
%         data = BurstPerBinData.MBIE;
%     %     params.figname = 'PacketEPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsER_P,AllEpAlignedER_P] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER_P,AllEpAlignedER_P);
% 
%         % I Population Coefficient of Variation
%         data = BurstPerBinData.MBII;
%         if sum(isnan(data)) < numel(data)%unless there are no I cells;
%     %         params.figname = 'PacketIPopCovariance';
%             [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%             [AllEpochsIR_P,AllEpAlignedIR_P] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR_P,AllEpAlignedIR_P);
%         end
%     end
%     %% REM followed by Wake
%     ints = StartEnd(REMEpisodeInts,'s');
%     sints = StartEnd(WakeInts,'s');
%     evergood = zeros(size(ints,1),1);
%     for b = 1:size(ints,1);
%         d = sints(:,1)-ints(b,2);
%         g = d<10 & d>0;%if packet within 2 secs of end of REM
%         evergood(b) = logical(sum(g));
%     end
%     ints = ints(logical(evergood),:);
%     if ~isempty(ints)
%         sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %         parms.prepostsec = [-20 40];
% 
%         % E Population Coefficient of Variation
%         data = BurstPerBinData.MBIE;
%     %     params.figname = 'PacketEPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsER_W,AllEpAlignedER_W] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER_W,AllEpAlignedER_W);
% 
%         % I Population Coefficient of Variation
%         data = BurstPerBinData.MBII;
%         if sum(isnan(data)) < numel(data)%unless there are no I cells;
%     %         params.figname = 'PacketIPopCovariance';
%             [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%             [AllEpochsIR_W,AllEpAlignedIR_W] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR_W,AllEpAlignedIR_W);
%         end
%     end
% %% Wake
%     ints = StartEnd(WakeInts,'s');
%     if ~isempty(ints)
%         sf = 1/mode(diff(BurstPerBinData.bincentertimes));
% %         parms.prepostsec = [-20 40];
% 
%         % E Population Coefficient of Variation
%         data = BurstPerBinData.MBIE;
%     %     params.figname = 'PacketEPopCovariance';
%         [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%         [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         [AllEpochsEW,AllEpAlignedEW] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEW,AllEpAlignedEW);
% 
%         % I Population Coefficient of Variation
%         data = BurstPerBinData.MBII;
%         if sum(isnan(data)) < numel(data)%unless there are no I cells;
%     %         params.figname = 'PacketIPopCovariance';
%             [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%             [AllEpochsIW,AllEpAlignedIW] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIW,AllEpAlignedIW);
%         end
%     end
%     
%     
% end
% 
% 
% %% saving and plotting
% MeanBurstIndexOverSleepInts = v2struct(sf,AllEpochsEP,AllEpAlignedEP,AllEpochsIP,AllEpAlignedIP,...
%     AllEpochsEE,AllEpAlignedEE,AllEpochsIE,AllEpAlignedIE,...
%     AllEpochsES, AllEpAlignedES, AllEpochsIS, AllEpAlignedIS);
% 
% h = [];
% h(end+1) = PlotPETHFigure(AllEpAlignedEP,params);
% set(h(end),'name','ECellMeanBurstIndexOverPackets')
% h(end+1) = PlotPETHFigure(AllEpAlignedIP,params);
% set(h(end),'name','ICellMeanBurstIndexOverPackets')
% h(end+1) = PlotPETHFigure(AllEpAlignedEE,params);
% set(h(end),'name','ECellMeanBurstIndexOverEpisodes')
% h(end+1) = PlotPETHFigure(AllEpAlignedIE,params);
% set(h(end),'name','ICellMeanBurstIndexOverEpisodes')
% h(end+1) = PlotPETHFigure(AllEpAlignedES,params);
% set(h(end),'name','ECellMeanBurstIndexOverSleep')
% h(end+1) = PlotPETHFigure(AllEpAlignedIS,params);
% set(h(end),'name','ICellMeanBurstIndexOverSleep')
% h(end+1) = PlotPETHFigure(AllEpAlignedER,params);
% set(h(end),'name','ECellMeanBurstIndexOverREM')
% h(end+1) = PlotPETHFigure(AllEpAlignedIR,params);
% set(h(end),'name','ICellMeanBurstIndexOverREM')
% h(end+1) = PlotPETHFigure(AllEpAlignedER_P,params);
% set(h(end),'name','ECellMeanBurstIndexOverREM_Packet')
% h(end+1) = PlotPETHFigure(AllEpAlignedIR_P,params);
% set(h(end),'name','ICellMeanBurstIndexOverREM_Packet')
% h(end+1) = PlotPETHFigure(AllEpAlignedER_W,params);
% set(h(end),'name','ECellMeanBurstIndexOverREM_Wake')
% h(end+1) = PlotPETHFigure(AllEpAlignedIR_W,params);
% set(h(end),'name','ICellMeanBurstIndexOverREM_Wake')
% h(end+1) = PlotPETHFigure(AllEpAlignedEW,params);
% set(h(end),'name','ECellMeanBurstIndexOverWake')
% h(end+1) = PlotPETHFigure(AllEpAlignedIW,params);
% set(h(end),'name','ICellMeanBurstIndexOverWake')

