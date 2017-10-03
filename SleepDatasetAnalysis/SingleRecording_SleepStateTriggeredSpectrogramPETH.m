function [TriggeredPETHSpectrumData,fig] = SingleRecording_SleepStateTriggeredSpectrogramPETH(basepath,basename,statenumber,beforesample,aftersample,binsize,STypes)


if ~exist('statenumber','var')
    statenumber = 5;%default is REM
end
if ~exist('beforesample','var')
    beforesample = 100;%seconds
end
if ~exist('aftersample','var')
    aftersample = 30;%seconds
end
if ~exist('binsize','var')
    binsize = 1;%seconds
end
if exist('STypes','var')
    Ss = strfind(STypes,'S');
    try
        es = strfind(STypes(Ss+1),'e');
    catch
        es = [];
    end
    try
        is = strfind(STypes(Ss+1),'i');
    catch
        is = [];
    end
    Ss([es is]) = [];
    Sbool = ~isempty(Ss);
    Sebool = ~isempty(strfind(STypes,'Se'));
    Sibool = ~isempty(strfind(STypes,'Si'));
else
    STypes = 'S';
    Sbool = 1;
    Sebool = 0;
    Sibool = 0;
end
if ~exist('plotting','var')
    plotting = 0;%boolean for PETH command
end
tssampfreq = 10000;%timebase of the tstoolbox objects used here
% eventtime = beforesample/binsize;

switch(statenumber)
    case 1 
        statestring = 'Waking'
    case 2 
        statestring = 'Drowsy';
    case 3 
        statestring = 'SWS';
    case 4 
        statestring = 'Intermed';
    case 5 
        statestring = 'REM';
end



%% load variables
warning off
t = load([fullfile(basepath,basename) '_Intervals.mat']);
intervals = t.intervals;
t = load([fullfile(basepath,basename) '_GoodSleepInterval.mat']);
GoodSleepInterval = t.GoodSleepInterval;
t = load([fullfile(basepath,basename) '_BasicMetaData.mat']);
goodshanks = t.goodshanks;
channum = t.goodeegchannel;
%     t = load([fullfile(basepath,basename) '_WSWEpisodes.mat']);
%     WSEpisodes = t.WSEpisodes;
%     WSBestIdx = t.WSBestIdx;
spikegroupanatomy = read_mixed_csv([fullfile(basepath,basename) '_SpikeGroupAnatomy.csv'],',');
spikegroupanatomy = spikegroupanatomy(2:end,:);
channelanatomy = read_mixed_csv([fullfile(basepath,basename) '_ChannelAnatomy.csv'],',');

Scell = cell(3,1);
if Sbool%if want to look at all cells
    t = load([fullfile(basepath,basename) '_SStable.mat']);
    Scell{1} = t.S;
end
if Sebool%if want to look at E/RS cells
    t = load([fullfile(basepath,basename) '_SSubtypes.mat']);
    Scell{2} = t.Se;
end
if Sibool%if want to look at I/FS cells
    t = load([fullfile(basepath,basename) '_SSubtypes.mat']);
    Scell{3} = t.Si;
end

% t = load([fullfile(basepath,basename) '.eegstates.mat']);
% chans = t.StateInfo.Chs;

warning on
tcell = {};
for b = 1:size(spikegroupanatomy,1)
   if ismember(b,goodshanks)
       tcell{end+1} = spikegroupanatomy{b,2};
   end
end
t = unique(tcell);
for b = 1:length(t);
    if b == 1;
        SpikesAnatomy = [t{b}];
    else
        SpikesAnatomy = [SpikesAnatomy,'&',t{b}];
    end
end
%% for each channel in the state editor, plot graphs
% for b = 1:length(chans)
%     channum = chans(b);
    [meanspectrogram,fig] = StateTriggeredSpectrogram...
        (statenumber,beforesample,aftersample,channum,intervals,GoodSleepInterval,tssampfreq,basepath,basename);
    thischannelanat = channelanatomy{channum,2};

    [normtotalcounts_struct, AvailCells_struct, rawcounts_struct, befaftvals_struct, diffsPs_struct, SpikesAnatomies_struct] = GatherStateTriggeredSpikingNormalized...
            (Scell,intervals,statenumber,beforesample,aftersample,GoodSleepInterval,binsize,SpikesAnatomy);

    % these extact fields from the structures below and assign them as
    % variables inthis workspace:
    v2struct(normtotalcounts_struct);
    v2struct(AvailCells_struct);
%     v2struct(rawcounts_struct);
%     v2struct(befaftvals_struct);
%     v2struct(diffsPs_struct);
%     v2struct(SpikesAnatomies_struct);

    intervalstouse = intervals{statenumber};%use the same intervals as above, next line
    [prestarts,poststarts,intervalidxs] = getIntervalStartsWithinBounds(intervalstouse,beforesample,aftersample,GoodSleepInterval,tssampfreq);

    %plot spiking lines onto figure initated by StateTriggeredSpectrogram
    hold on
    ttext = get(get(gca,'Title'),'String');
    ttext = {['SPIKES FROM: ',SpikesAnatomy,'.  n = ',num2str(length(intervalidxs)),' episodes'];...
        ['Spectrogram from ',ttext]};
    title(ttext)
    if Sbool
        plot(normtotalcounts*10+40,'Color','w','LineWidth',2.5)
    end
    if Sebool
        plot(Enormtotalcounts*10+40,'Color',[.2 .2 .2],'LineWidth',3)%background line for visibility
        plot(Enormtotalcounts*10+40,'Color',[.1 .7 .1],'LineWidth',1)
    end
    if Sibool
        if sum(sum(IAvailCells))
            plot(Inormtotalcounts*10+40,'Color',[.2 .2 .2],'LineWidth',3)
            plot(Inormtotalcounts*10+40,'Color',[1 .3 .3],'LineWidth',1)
        end
    end
    set(fig,'name',['SpectrogramPETHfor' statestring 'Start|' ...
        num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
        basename 'Ch' num2str(channum)...
        '|' SpikesAnatomy 'Spiking'])
% end

% extracting total, E and I versions of each of tehse variables
v2struct(rawcounts_struct);
v2struct(befaftvals_struct);
v2struct(diffsPs_struct);
v2struct(SpikesAnatomies_struct);


TriggeredPETHSpectrumData = v2struct(normtotalcounts,Enormtotalcounts,Inormtotalcounts,...
    rawcounts,Erawcounts,Irawcounts,...
    AvailCells,EAvailCells,IAvailCells,...
    befaftvals,Ebefaftvals,Ibefaftvals,EIRatiobefaftVals,...
    diffsPs,EdiffsPs,IdiffsPs,EIRatiodiffsPs,...
    SpikesAnatomies, ESpikesAnatomies, ISpikesAnatomies, EIRatioSpikesAnatomies);

