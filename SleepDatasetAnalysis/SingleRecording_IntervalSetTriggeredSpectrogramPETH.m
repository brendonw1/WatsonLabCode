function [TriggeredPETHSpectrumData,fig] = SingleRecording_IntervalSetTriggeredSpectrogramPETH(intervalset,basepath,basename,beforesample,aftersample,STypes)


if ~exist('statenumber','var')
    statenumber = 5;%default is REM
end
if ~exist('beforesample','var')
    beforesample = 100;%seconds
end
if ~exist('aftersample','var')
    aftersample = 30;%seconds
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
binsize = 1;%seconds
% eventtime = beforesample/binsize;


%% load variables
warning off
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
    [meanspectrogram,fig] = IntervalsetTriggeredSpectrogram...
        (intervalset,beforesample,aftersample,channum,tssampfreq,basepath,basename);
    thischannelanat = channelanatomy{channum,2};

    [normtotalcounts_struct, AvailCells_struct, rawcounts_struct, befaftvals_struct, diffsPs_struct, SpikesAnatomies_struct] = ...
        GatherStateTriggeredSpikingNormalized...
            (Scell,intervalset,beforesample,aftersample,binsize,SpikesAnatomy);

    % these extact fields from the structures below and assign them as
    % variables inthis workspace:
    v2struct(normtotalcounts_struct);
    v2struct(AvailCells_struct);
%     v2struct(rawcounts_struct);
%     v2struct(befaftvals_struct);
%     v2struct(diffsPs_struct);
%     v2struct(SpikesAnatomies_struct);

    intervalstarts = Start(intervalset)/tssampfreq;%episode start time in sec
    prestarts = intervalstarts - beforesample;%get pre-start time
    poststarts = intervalstarts + aftersample;% and post

    %plot spiking lines onto figure initated by StateTriggeredSpectrogram
    hold on
    ttext = get(get(gca,'Title'),'String');
    ttext = {['SPIKES FROM: ',SpikesAnatomy,'.  n = ',num2str(length(prestarts)),' intervals'];...
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
    
    %set up alittle dialog box for user to specify text for type of interval used
    itb = findobj('Tag','IntervalTypeBox');
    if length(itb) > 1
        close (itb);
    end
    if length(itb == 1;
        string = get(findobj('Tag','MessageBox'),'String');
        string = string{1};
        t = strfind(string,': ');
        type = string(t+2:end);
    else
        type = inputdlg('Enter descriptor of input IntervalSet');
        h = msgbox(['Name of interval type: ' type]);
        set(h,'HandleVisibility','on','Tag','IntervalTypeBox')
    end
    
    set(fig,'name',['SpectrogramPETHfor' type 'Start|' ...
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
    befaftvals,Ebefaftvals,Ibefaftvals,...
    diffsPs,EdiffsPs,IdiffsPs,...
    SpikesAnatomies, ESpikesAnatomies, ISpikesAnatomies);

