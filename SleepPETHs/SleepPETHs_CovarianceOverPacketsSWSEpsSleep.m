function SleepPETHs_CovarianceOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;
AllEpochsEP = {};
AllEpAlignedEP = [];
AllEpochsIP = {};
AllEpAlignedIP = [];
AllEpochsEE = {};
AllEpAlignedEE = [];
AllEpochsIE = {};
AllEpAlignedIE = [];
AllEpochsES = {};
AllEpAlignedES = [];
AllEpochsIS = {};
AllEpAlignedIS = [];
AllEpochsESnoR = {};
AllEpAlignedESnoR = [];
AllEpochsISnoR = {};
AllEpAlignedISnoR = [];
AllEpochsER = {};
AllEpAlignedER = [];
AllEpochsIR = {};
AllEpAlignedIR = [];
AllEpochsER_P = {};
AllEpAlignedER_P = [];
AllEpochsIR_P = {};
AllEpAlignedIR_P = [];
AllEpochsER_W = {};
AllEpAlignedER_W = [];
AllEpochsIR_W = {};
AllEpAlignedIR_W = [];
AllEpochsEW = {};
AllEpAlignedEW = [];
AllEpochsIW = {};
AllEpAlignedIW = [];

params.figformat = 'png';
parms.prepostsec = [-10 40];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,[basename '_SpikingCoeffVaration.mat']))
%     savedir = fullfile(basepath,'SleepPETHFigs');
%     if ~exist(savedir,'dir')
%         mkdir(savedir)
%     end
%     params.saveloc = savedir;

%% Packets
    ints = StartEnd(SWSPacketInts,'s');
    sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%     parms.prepostsec = [-20 40];

    % E Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVE;
%     params.figname = 'PacketEPopCovariance';
    [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
    [AllEpochsEP,AllEpAlignedEP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEP,AllEpAlignedEP);
    
    % I Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVI;
    if sum(isnan(data)) < numel(data)%unless there are no I cells;
%         params.figname = 'PacketIPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsIP,AllEpAlignedIP] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIP,AllEpAlignedIP);
    end
    
%% Episodes
    ints = StartEnd(SWSEpisodeInts,'s');
    sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%     parms.prepostsec = [-30 60];
    
    % E Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVE;
%     params.figname = 'PacketEPopCovariance';
    [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
    [AllEpochsEE,AllEpAlignedEE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEE,AllEpAlignedEE);
    
    % I Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVI;
    if sum(isnan(data)) < numel(data)%unless there are no I cells;
%         params.figname = 'PacketIPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsIE,AllEpAlignedIE] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIE,AllEpAlignedIE);
    end
    
%% Sleep _ NO REM
    ints = StartEnd(SleepInts,'s');
    sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%     parms.prepostsec = [-100 200];
    
    % E Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVE;
!    >> EXCLUDE REM << 
    
%     params.figname = 'PacketEPopCovariance';
    [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
    [AllEpochsESnoR,AllEpAlignedESnoR] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsESnoR,AllEpAlignedESnoR);
    
    % I Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVI;
!    >> EXCLUDE REM << 

    if sum(isnan(data)) < numel(data)%unless there are no I cells;
%         params.figname = 'PacketIPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsISnoR,AllEpAlignedISnoR] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsISnoR,AllEpAlignedISnoR);
    end%% Sleep
    ints = StartEnd(SleepInts,'s');
    sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%     parms.prepostsec = [-100 200];
    
%% Sleep
    % E Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVE;
%     params.figname = 'PacketEPopCovariance';
    [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
    [AllEpochsES,AllEpAlignedES] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsES,AllEpAlignedES);
    
    % I Population Coefficient of Variation
    data = SpikingCoeffVarationData.CoVI;
    if sum(isnan(data)) < numel(data)%unless there are no I cells;
%         params.figname = 'PacketIPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsIS,AllEpAlignedIS] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIS,AllEpAlignedIS);
    end
    
%% REM
    ints = StartEnd(REMEpisodeInts,'s');
    if ~isempty(ints)
        sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%         parms.prepostsec = [-20 40];

        % E Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVE;
    %     params.figname = 'PacketEPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsER,AllEpAlignedER] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER,AllEpAlignedER);

        % I Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVI;
        if sum(isnan(data)) < numel(data)%unless there are no I cells;
    %         params.figname = 'PacketIPopCovariance';
            [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            [AllEpochsIR,AllEpAlignedIR] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR,AllEpAlignedIR);
        end
    end
%% REM followed by SWS Packets
    ints = StartEnd(REMEpisodeInts,'s');
    sints = StartEnd(SWSPacketInts,'s');
    evergood = zeros(size(ints,1),1);
    for b = 1:size(ints,1);
        d = sints(:,1)-ints(b,2);
        g = d<10 & d>0;%if packet within 2 secs of end of REM
        evergood(b) = logical(sum(g));
    end
    ints = ints(logical(evergood),:);
    if ~isempty(ints)
        sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%         parms.prepostsec = [-20 40];

        % E Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVE;
    %     params.figname = 'PacketEPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsER_P,AllEpAlignedER_P] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER_P,AllEpAlignedER_P);

        % I Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVI;
        if sum(isnan(data)) < numel(data)%unless there are no I cells;
    %         params.figname = 'PacketIPopCovariance';
            [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            [AllEpochsIR_P,AllEpAlignedIR_P] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR_P,AllEpAlignedIR_P);
        end
    end
    %% REM followed by Wake
    ints = StartEnd(REMEpisodeInts,'s');
    sints = StartEnd(WakeInts,'s');
    evergood = zeros(size(ints,1),1);
    for b = 1:size(ints,1);
        d = sints(:,1)-ints(b,2);
        g = d<10 & d>0;%if packet within 2 secs of end of REM
        evergood(b) = logical(sum(g));
    end
    ints = ints(logical(evergood),:);
    if ~isempty(ints)
        sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%         parms.prepostsec = [-20 40];

        % E Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVE;
    %     params.figname = 'PacketEPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsER_W,AllEpAlignedER_W] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER_W,AllEpAlignedER_W);

        % I Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVI;
        if sum(isnan(data)) < numel(data)%unless there are no I cells;
    %         params.figname = 'PacketIPopCovariance';
            [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            [AllEpochsIR_W,AllEpAlignedIR_W] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR_W,AllEpAlignedIR_W);
        end
    end
%% Wake
    ints = StartEnd(WakeInts,'s');
    if ~isempty(ints)
        sf = 1/mode(diff(SpikingCoeffVarationData.bincentertimes));
%         parms.prepostsec = [-20 40];

        % E Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVE;
    %     params.figname = 'PacketEPopCovariance';
        [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
        [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        [AllEpochsEW,AllEpAlignedEW] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEW,AllEpAlignedEW);

        % I Population Coefficient of Variation
        data = SpikingCoeffVarationData.CoVI;
        if sum(isnan(data)) < numel(data)%unless there are no I cells;
    %         params.figname = 'PacketIPopCovariance';
            [Epochs,~,EpAligned] = IntervalPETH(data,ints,100,sf,params);
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            [AllEpochsIW,AllEpAlignedIW] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIW,AllEpAlignedIW);
        end
    end
    
    
end


%% saving and plotting
CoeffVarOverSleepInts = v2struct(sf,AllEpochsEP,AllEpAlignedEP,AllEpochsIP,AllEpAlignedIP,...
    AllEpochsEE,AllEpAlignedEE,AllEpochsIE,AllEpAlignedIE,...
    AllEpochsES, AllEpAlignedES, AllEpochsIS, AllEpAlignedIS,...
    AllEpochsESnoR, AllEpAlignedESnoR, AllEpochsISnoR, AllEpAlignedISnoR);

h = [];
h(end+1) = PlotPETHFigure(AllEpAlignedEP,params);
set(h(end),'name','ECellCoeffVarOverPackets')
h(end+1) = PlotPETHFigure(AllEpAlignedIP,params);
set(h(end),'name','ICellCoeffVarOverPackets')
h(end+1) = PlotPETHFigure(AllEpAlignedEE,params);
set(h(end),'name','ECellCoeffVarOverEpisodes')
h(end+1) = PlotPETHFigure(AllEpAlignedIE,params);
set(h(end),'name','ICellCoeffVarOverEpisodes')
h(end+1) = PlotPETHFigure(AllEpAlignedES,params);
set(h(end),'name','ECellCoeffVarOverSleep')
h(end+1) = PlotPETHFigure(AllEpAlignedIS,params);
set(h(end),'name','ICellCoeffVarOverSleep')
h(end+1) = PlotPETHFigure(AllEpAlignedESnoR,params);
set(h(end),'name','ECellCoeffVarOverSleepNoRem')
h(end+1) = PlotPETHFigure(AllEpAlignedISnoR,params);
set(h(end),'name','ICellCoeffVarOverSleepNoRem')
h(end+1) = PlotPETHFigure(AllEpAlignedER,params);
set(h(end),'name','ECellCoeffVarOverREM')
h(end+1) = PlotPETHFigure(AllEpAlignedIR,params);
set(h(end),'name','ICellCoeffVarOverREM')
h(end+1) = PlotPETHFigure(AllEpAlignedER_P,params);
set(h(end),'name','ECellCoeffVarOverREM_Packet')
h(end+1) = PlotPETHFigure(AllEpAlignedIR_P,params);
set(h(end),'name','ICellCoeffVarOverREM_Packet')
h(end+1) = PlotPETHFigure(AllEpAlignedER_W,params);
set(h(end),'name','ECellCoeffVarOverREM_Wake')
h(end+1) = PlotPETHFigure(AllEpAlignedIR_W,params);
set(h(end),'name','ICellCoeffVarOverREM_Wake')
h(end+1) = PlotPETHFigure(AllEpAlignedEW,params);
set(h(end),'name','ECellCoeffVarOverWake')
h(end+1) = PlotPETHFigure(AllEpAlignedIW,params);
set(h(end),'name','ICellCoeffVarOverWake')

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/CoeffVar/',CoeffVarOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/CoeffVar/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/CoeffVar/',h,'svg')
