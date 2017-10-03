function SleepPETHs_UDRatioOverPacketsSWSEpsSleep
warning off

[names,dirs] = GetDefaultDataset;

statenames = {'SWSPackets','SWSEpisodes','Sleep'};
numstatetypes = length(statenames);
for a = 1:numstatetypes %because we will cycle through 7 states
    AllEpochsU{a} = {};
    AllEpAlignedU{a} = [];
    AllEpochsD{a} = {};
    AllEpAlignedD{a} = [];
    AllEpochsNoUD{a} = {};
    AllEpAlignedNoUD{a} = [];
    AllEpochsUvD{a} = {};
    AllEpAlignedUvD{a} = [];

    AllEpochsN{a} = {};
    AllEpAlignedN{a} = [];
    AllEpochsF{a} = {};
    AllEpAlignedF{a} = [];
    AllEpochsNoNF{a} = {};
    AllEpAlignedNoNF{a} = [];
    AllEpochsNvF{a} = {};
    AllEpAlignedNvF{a} = [];
end
params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.5;%samples per second
binspernormepoch = 20;

normperiod = 'allin';
normmode = 'meandiv';
normbool = 0;

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    %loading stuff for each recording
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,[basename '_UPDownOnOffRatios.mat']))
    
% gathering data which won't change depending on the interval selected:
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    
    times = UPDownOnOffRatios.bincentertimes;
    sf = 1/mode(diff(times));

    dataU = UPDownOnOffRatios.up_pct;
    dataD = UPDownOnOffRatios.dn_pct;
    dataNoUD = UPDownOnOffRatios.nonud_pct;
    dataUvD = UPDownOnOffRatios.upvdn_pct;
    
    dataN = UPDownOnOffRatios.on_pct;
    dataF = UPDownOnOffRatios.off_pct;
    dataNoNF = UPDownOnOffRatios.nonnf_pct;
    dataNvF = UPDownOnOffRatios.onvoff_pct;

    for b = 1:numstatetypes
        tdataU = dataU;
        tdataD = dataD;
        tdataNoUD = dataNoUD;
        tdataUvD = dataUvD;
        
        tdataN = dataN;
        tdataF = dataF;
        tdataNoNF = dataNoNF;
        tdataNvF = dataNvF;

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
        
        [Epochs,~,EpAligned] = IntervalPETH(tdataU,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsU{b},AllEpAlignedU{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsU{b},AllEpAlignedU{b});

        [Epochs,~,EpAligned] = IntervalPETH(tdataD,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsD{b},AllEpAlignedD{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsD{b},AllEpAlignedD{b});
        
        [Epochs,~,EpAligned] = IntervalPETH(tdataNoUD,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsNoUD{b},AllEpAlignedNoUD{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNoUD{b},AllEpAlignedNoUD{b});

%         [Epochs,~,EpAligned] = IntervalPETH(tdataUvD,stateInts{b},100,sf,params,mask);
%         if normbool
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         end
%         [AllEpochsUvD{b},AllEpAlignedUvD{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsUvD{b},AllEpAlignedUvD{b});
%%
        [Epochs,~,EpAligned] = IntervalPETH(tdataN,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsN{b},AllEpAlignedN{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsN{b},AllEpAlignedN{b});
        
        [Epochs,~,EpAligned] = IntervalPETH(tdataF,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsF{b},AllEpAlignedF{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsF{b},AllEpAlignedF{b});
        
        [Epochs,~,EpAligned] = IntervalPETH(tdataNoNF,stateInts{b},100,sf,params,mask);
        if normbool
            [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
        end
        [AllEpochsNoNF{b},AllEpAlignedNoNF{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNoNF{b},AllEpAlignedNoNF{b});

%         [Epochs,~,EpAligned] = IntervalPETH(tdataNvF,stateInts{b},100,sf,params,mask);
%         if normbool
%             [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
%         end
%         [AllEpochsNvF{b},AllEpAlignedNvF{b}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsNvF{b},AllEpAlignedNvF{b});

    end
end


%% saving and plotting
UPDNRatioOverSleepInts = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsU,AllEpAlignedU,AllEpochsD,AllEpAlignedD,AllEpochsNoUD,AllEpAlignedNoUD,...
    AllEpochsN,AllEpAlignedN,AllEpochsF,AllEpAlignedF,AllEpochsNoNF,AllEpAlignedNoNF);
%     AllEpochsU,AllEpAlignedU,AllEpochsD,AllEpAlignedD,AllEpochsNoUD,AllEpAlignedNoUD,AllEpochsUvD,AllEpAlignedUvD,...
%     AllEpochsN,AllEpAlignedN,AllEpochsF,AllEpAlignedF,AllEpochsNoNF,AllEpAlignedNoNF,AllEpochsNvF,AllEpAlignedNvF);

h = [];
for b = 1:numstatetypes
    h(end+1) = PlotPETHFigure(AllEpAlignedU{b},params);
    set(h(end),'name',['UPPctOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedD{b},params);
    set(h(end),'name',['DNPctOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedNoUD{b},params);
    set(h(end),'name',['NoUpDownOver' statenames{b}])
%     h(end+1) = PlotPETHFigure(AllEpAlignedUvD{b},params);
%     set(h(end),'name',['UpVsDownOver' statenames{b}])

    h(end+1) = PlotPETHFigure(AllEpAlignedN{b},params);
    set(h(end),'name',['ONPctOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedF{b},params);
    set(h(end),'name',['OFFPctOver' statenames{b}])
    h(end+1) = PlotPETHFigure(AllEpAlignedNoNF{b},params);
    set(h(end),'name',['NoOnOffPctOver' statenames{b}])
%     h(end+1) = PlotPETHFigure(AllEpAlignedNvF{b},params);
%     set(h(end),'name',['OnVsOffPctOver' statenames{b}])
end

MakeDirSaveVarThere(fullfile(getdropbox,'/BW OUTPUT/SleepProject/PETHS/UPs/'),UPDNRatioOverSleepInts)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h,'png')
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPRates/',h,'svg')

