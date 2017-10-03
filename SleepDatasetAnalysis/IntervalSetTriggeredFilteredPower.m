function [TriggeredPETHSpectrumData,fig] = IntervalSetTriggeredPower(basepaths,basenames,beforesample,aftersample)


filter in beta band
get prestarts and poststarts
grab values from beta vector
plot mean lfp and mean beta vector (normalized, green)

if ~exist('beforesample','var')
    beforesample = 0.100;%seconds
end
if ~exist('aftersample','var')
    aftersample = 0.200;%seconds
end

tssampfreq = 10000;%timebase of the tstoolbox objects used here
FreqRange = [0 200];

%go through dataset
for a = 1:length(basepaths);
    disp(['Starting ' basenames{a}])
    basename = basenames{a};
    basepath = basepaths{a};
    
    % get metadata
    warning off
    t = load([fullfile(basepath,basename) '_BasicMetaData.mat']);
    channum = t.goodeegchannel;
    Par = t.Par;
    
    % get anatomy
    spikegroupanatomy = read_mixed_csv([fullfile(basepath,basename) '_SpikeGroupAnatomy.csv'],',');
    spikegroupanatomy = spikegroupanatomy(2:end,:);
    channelanatomy = read_mixed_csv([fullfile(basepath,basename) '_ChannelAnatomy.csv'],',');

    %% EEG Data
    %load channel (mostly from "SpindleDetectionParameterFinding.m")
    lfppath = findsessioneeglfpfile(basename,basepath);
    lfp = LoadLfp(lfppath,Par.nChannels,channum);    
    disp('Loaded LFP')
    lfpsamplerate = 10000/mode(diff(TimePoints(lfp)));
    datatimes = Range(lfp, 's');
    datavalues = double(Data(lfp));
    
    spindleband = [9 20];%frequency band
    belowspindleband = [0 spindleband(1)];
    abovespindleband = [spindleband(2) FreqRange(2)];

    % Filter in spindle band 
    spindlepower = FilterLFP([datatimes datavalues], 'passband', spindleband);
    spindlepowerraw = spindlepower(:,2);
    % spindlepower = convtrim(abs(spindlepowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
    spindlepower = hilbertenvelope(spindlepowerraw);

    % get UP states
    t = load([fullfile(basepath,basename) '_UPDOWNIntervals.mat']);
    UPInts = t.UPInts;

    % get starts/stops for sampling
    % [prestarts,poststarts,intervalidxs] = getIntervalStartsWithinBounds(intervals{statenumber},beforesample,aftersample,GoodSleepInterval,tssampfreq);
    intervalstarts = Start(UPInts)/tssampfreq;%episode start time in sec
    prestarts = intervalstarts - beforesample;%get pre-start time
    poststarts = intervalstarts + aftersample;% and post
    for b = length(poststarts):-1:1;%make sure poststart is in the interval... not making sure anything about prestart for now
        if ~belong(subset(UPInts,b),poststarts(b));
            prestarts(b) = [];
            poststarts(b) = [];
        end
    end
    
    intervalLFPs = zeros(round(lfpsamplerate*[beforesample+aftersample]), length(prestarts));
    intervalSpindleBand = zeros(round(lfpsamplerate*[beforesample+aftersample]), length(prestarts));
    for b = 1:length(prestarts);
        intervalLFPs(:,prestarts) = datavalues(prestarts(b):poststarts(b));
        intervalSpindleBand(:,prestarts) = spindlepower(prestarts(b):poststarts(b));
        %could add an index to say which SWS episode each UP is in an then
        %plot by SWS episode... or just over time        
    end
        
    fig = figure;
    plot(1:size(intervalLFPs,1)/lfpsamplerate,bwnormalize(mean(intervalLFPs,2)),'k')
%     plot(1:size(intervalLFPs,1)/lfpsamplerate,zscore(mean(intervalLFPs,2)))
    hold on
    plot(1:size(intervalLFPs,1)/lfpsamplerate,bwnormalize(mean(intervalSpindleBand,2)),'g')
%     plot(1:size(intervalLFPs,1)/lfpsamplerate,zscore(mean(intervalSpindleBand,2)),'g')
    title('Black: normalized DOWN-UP LFP.  Green: normalized DOWN-UP spindle power'])
    xlabel('Seconds')
    set(fig,'name',[basename 'UPstate-triggeredSpindlePower'])

%     set(fig,'name',['SpectrogramPETHfor' type 'Start|' ...
%         num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
%         basename 'Ch' num2str(channum)...
%         '|' SpikesAnatomy 'Spiking'])
% end

end

