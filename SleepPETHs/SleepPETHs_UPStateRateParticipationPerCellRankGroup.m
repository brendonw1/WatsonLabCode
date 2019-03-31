function SleepPETHs_UPStateRateParticipationPerCellRankGroup
warning off

%% coordinating spike rate divisions
NumRateGroups = 6;  %how many groups to break cells into
d = getdropbox;
load(fullfile(d,'/BW OUTPUT/SleepProject/StateRates/StateRates.mat'),'StateRates')
erates = sort(StateRates.EWSWakeRates);
t = linspace(1,length(erates),NumRateGroups+1);
ecutoffs = [t(1:end-1)' t(2:end)'];
ecutoffs = erates(round(ecutoffs));
ecutoffs(end,end) = Inf;%this means I can use a < for the upper of each cutoff pair

irates = sort(StateRates.IWSWakeRates);
t = linspace(1,length(irates),NumRateGroups+1);
icutoffs = [t(1:end-1)' t(2:end)'];
icutoffs = irates(round(icutoffs));
icutoffs(end,end) = Inf;

%% basic states and other params
statenames = {'SWSPackets','SWSEpisodes','Sleep'};
numstatetypes = length(statenames);
for g = 1:numstatetypes %because we will cycle through 7 states
    for b = 1:NumRateGroups;%cycle through cell rate groups
        %setting up boolean participation containers
        AllEpochsEP{g,b} = {};
        AllEpAlignedEP{g,b} = [];
        AllEpochsIP{g,b} = {};
        AllEpAlignedIP{g,b} = [];
        %setting up spike rate containers
        AllEpochsER{g,b} = {};
        AllEpAlignedER{g,b} = [];
        AllEpochsIR{g,b} = {};
        AllEpAlignedIR{g,b} = [];
        %setting up spike rate containers FOR PARTICIPATED EVENTS ONLY
        AllEpochsEPR{g,b} = {};
        AllEpAlignedEPR{g,b} = [];
        AllEpochsIPR{g,b} = {};
        AllEpAlignedIPR{g,b} = [];
    end
end
params.figformat = 'png';
parms.prepostsec = [-10 40];
sffororiginalepochs = 0.2;%samples per second
binspernormepoch = 20;

[names,dirs] = GetDefaultDataset;

normperiod = 'allin';
normmode = 'meandiv';
normbool = 0;


for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
    load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']))
    load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsI.mat']))
    load(fullfile(basepath,[basename '_StateRates.mat']),'StateRates')

    % gathering data which won't change depending on the interval selected:
    stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts);
    for g = 1:NumRateGroups
        okE = StateRates.EWSWakeRates >= ecutoffs(g,1) & StateRates.EWSWakeRates<ecutoffs(g,2);
        okI = StateRates.IWSWakeRates >= icutoffs(g,1) & StateRates.IWSWakeRates<icutoffs(g,2);
        
        times = mean([isse.intstarts isse.intends],2);

        tparticE = sum(isse.spkbools(:,okE),2)/sum(okE);%partic percentage over cells in this quartile
        trateE = mean(isse.spkrates(:,okE),2);%avg rate over cells in this quartile
        tparticI = sum(issi.spkbools(:,okI),2)/sum(okI);%summate over cells in this quartile
        trateI = mean(issi.spkrates(:,okI),2);%avg over cells in this quartile

        participatedRE = isse.spkrates(:,okE);
        participatedRE(participatedRE == 0) = nan;
        participatedRI = issi.spkrates(:,okI);
        participatedRI(participatedRI == 0) = nan;
                
        for b = 1:numstatetypes
            ttparticE = tparticE;
            ttrateE = trateE;
            tparticipatedRE = participatedRE;
            ttparticI = tparticI;
            ttrateI = trateI;
            tparticipatedRI = participatedRI;
            if strcmp(statenames{b},'SWSSleep')
                status = InIntervalsBW(times,StartEnd(SWSPacketInts,'s'));
                ttparticE(~status) = nan; 
                ttrateE(~status) = nan;  
                ttparticI(~status) = nan; 
                ttrateI(~status) = nan;%setting to nan works because in eventual mean/plot we use nanmean.  
                % so intervals with only nan are taken out of both numerator
                % and denominator.  And intervals with only nan are those
                % totally outside of packets
            end

            %E Population Participation
            [Epochs,~,EpAligned] = IntervalPETH_Irregular(ttparticE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            if normbool
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            end
            [AllEpochsEP{b,g},AllEpAlignedEP{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEP{b,g},AllEpAlignedEP{b,g});
            %E Population Rates
            [Epochs,~,EpAligned] = IntervalPETH_Irregular(ttrateE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
            if normbool
                [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
            end
            [AllEpochsER{b,g},AllEpAlignedER{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsER{b,g},AllEpAlignedER{b,g});
            %E Population Rates just in events where that cell participated
            if prod(size(tparticipatedRE))
                [Epochs,~,EpAligned] = IntervalPETH_Irregular(tparticipatedRE,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                if normbool
                    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
                end
            [AllEpochsEPR{b,g},AllEpAlignedEPR{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsEPR{b,g},AllEpAlignedEPR{b,g});
            end
            
            % I Population 
%             if sum(isnan(tparticI)) < numel(tparticI)%unless there are no I cells;
            %I Population Participation
                [Epochs,~,EpAligned] = IntervalPETH_Irregular(ttparticI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                if normbool
                    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
                end
                [AllEpochsIP{b,g},AllEpAlignedIP{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIP{b,g},AllEpAlignedIP{b,g});
                %I Population Rates
                [Epochs,~,EpAligned] = IntervalPETH_Irregular(ttrateI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                if normbool
                    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
                end
                [AllEpochsIR{b,g},AllEpAlignedIR{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIR{b,g},AllEpAlignedIR{b,g});
               %I Population Rates just in events where that cell participated
             if prod(size(tparticipatedRI))
                [Epochs,~,EpAligned] = IntervalPETH_Irregular(tparticipatedRI,times,stateInts{b},binspernormepoch,sffororiginalepochs);
                if normbool
                    [EpAligned,Epochs] = NormPETHToPrePost(EpAligned,Epochs);
                end
                [AllEpochsIPR{b,g},AllEpAlignedIPR{b,g}] = ConcatIntervalPETHData(Epochs,EpAligned,AllEpochsIPR{b,g},AllEpAlignedIPR{b,g});
             end
%             end
        end
    end    
end

%% saving and plotting
UPStateRateParticipationPerCellRankGroup = v2struct(normbool,normmode,normperiod,sffororiginalepochs,binspernormepoch,statenames,...
    AllEpochsEP,AllEpAlignedEP,AllEpochsER,AllEpAlignedER,AllEpochsEPR,AllEpAlignedEPR,...
    AllEpochsIP,AllEpAlignedIP,AllEpochsIR,AllEpAlignedIR,AllEpochsIPR,AllEpAlignedIPR);

col = OrangeColorsConfined(NumRateGroups);
h = [];
for b = 1:numstatetypes
    h(end+1) = figure('name',['ECellGroupsSpikeRatesOver' statenames{b}]);
    epax = subplot(2,2,1);
    set(epax,'NextPlot','add','yscale','log')
    title('E Cell Partic Per UPstate','fontweight','normal')
    eprax = subplot(2,2,2);
    set(eprax,'NextPlot','add','yscale','log')
    title('E Rate Per Partic UPstate','fontweight','normal')
    erax = subplot(2,4,6:7);
    set(erax,'NextPlot','add','yscale','log')
    title('E Rate Per UPstate','fontweight','normal')

    h(end+1) = figure('name',['ICellGroupsSpikeRatesOver' statenames{b}]);
    ipax = subplot(2,2,1);
    set(ipax,'NextPlot','add','yscale','log')
    title('I Partic Per UPstate','fontweight','normal')
    iprax = subplot(2,2,2);
    set(iprax,'NextPlot','add','yscale','log')
    title('I Rate Per Partic UPstate','fontweight','normal')
    irax = subplot(2,4,6:7);
    set(irax,'NextPlot','add','yscale','log')
    title('I Rate Per UPstate','fontweight','normal')

    for g = 1:NumRateGroups
        PlotPETHNormAxesData(AllEpAlignedEP{b,g},epax,col(g,:),0);
        PlotPETHNormAxesData(AllEpAlignedEPR{b,g},eprax,col(g,:),0);
        PlotPETHNormAxesData(AllEpAlignedER{b,g},erax,col(g,:),0);
        PlotPETHNormAxesData(AllEpAlignedIP{b,g},ipax,col(g,:),0);
        PlotPETHNormAxesData(AllEpAlignedIPR{b,g},iprax,col(g,:),0);
        PlotPETHNormAxesData(AllEpAlignedIR{b,g},irax,col(g,:),0);
    end
 end

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',UPStateRateParticipationPerCellRankGroup)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/',h,'png')
% MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPRates/',h,'svg')

