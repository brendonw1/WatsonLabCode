function DefaultDatasetSleepStats

[names,dirs]=GetDefaultDataset;

%% Declare empty fields
WakeSleepDurs = [];
WakeDurs = [];
SleepDurs = [];
SWSEpisodeDurs = [];
SWSPacketDurs = [];
REMEpisodeDurs = [];
REMDurs = [];
REMLatencies = [];

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)

%     bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    w = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));

%     ws = w.WSEpisodes;
    WakeSleepDurs = [];

    WakeDurs = cat(1,WakeDurs,Data(length(w.WakeInts,'s')));
    SleepDurs = cat(1,SleepDurs,Data(length(w.SleepInts,'s')));
    
    SWSEpisodeDurs = cat(1,SWSEpisodeDurs,Data(length(w.SWSEpisodeInts,'s')));
    SWSPacketDurs = cat(1,SWSPacketDurs,Data(length(w.SWSPacketInts,'s')));
    
    REMEpisodeDurs = cat(1,REMEpisodeDurs,Data(length(w.REMEpisodeInts,'s')));
    REMDurs = cat(1,REMDurs,Data(length(w.REMInts,'s')));
    
    for b = 1:length(w.WakeSleep)
        WakeSleepDurs(end+1) = tot_length(w.WakeSleep{b},'s');
        theserem = intersect(subset(w.SleepInts,b),w.REMInts);
        if length(length(theserem))
            REMLatencies(end+1) = FirstTime(theserem,'s')-Start(subset(w.SleepInts,b),'s');
        end
    end
end


 
DefaultDatasetSleepStats = v2struct(WakeDurs,SleepDurs,...
    SWSEpisodeDurs,SWSPacketDurs,REMEpisodeDurs,REMDurs,REMLatencies);

texttext = {['WakeSleep Duration Mean+SEM= ' num2str(mean(WakeSleepDurs)) ' +- ' num2str(sem(WakeDurs)) ' sec'];...
    ['WakeSleep Duration Median+SD= ' num2str(median(WakeSleepDurs)) ' +- ' num2str(std(WakeDurs)) ' sec'];...
    ['Wake Duration Mean+SEM = ' num2str(mean(WakeDurs)) ' +- ' num2str(sem(WakeDurs)) ' sec'];...
    ['Wake Duration Median+SD = ' num2str(median(WakeDurs)) ' +- ' num2str(std(WakeDurs)) ' sec'];...
    ['Sleep Duration Mean+SEM = ' num2str(mean(SleepDurs)) ' +- ' num2str(sem(SleepDurs)) ' sec'];...
    ['Sleep Duration Median+SD = ' num2str(median(SleepDurs)) ' +- ' num2str(std(SleepDurs)) ' sec'];...
    ['SWS Episode Duration Mean+SEM = ' num2str(mean(SWSEpisodeDurs)) ' +- ' num2str(sem(SWSEpisodeDurs)) ' sec'];...
    ['SWS Episode Duration Median+SD = ' num2str(median(SWSEpisodeDurs)) ' +- ' num2str(std(SWSEpisodeDurs)) ' sec'];...
    ['SWS Packet Duration Mean+SEM = ' num2str(mean(SWSPacketDurs)) ' +- ' num2str(sem(SWSPacketDurs)) ' sec'];...
    ['SWS Packet Duration Median+SD = ' num2str(median(SWSPacketDurs)) ' +- ' num2str(std(SWSPacketDurs)) ' sec'];...
    ['REM Episode Duration Mean+SEM = ' num2str(mean(REMEpisodeDurs)) ' +- ' num2str(sem(REMEpisodeDurs)) ' sec'];...
    ['REM Episode Duration Median+SD = ' num2str(median(REMEpisodeDurs)) ' +- ' num2str(std(REMEpisodeDurs)) ' sec'];...
    ['REM ("Packet") Duration Mean+SEM= ' num2str(mean(REMDurs)) ' +- ' num2str(sem(REMDurs)) ' sec'];...
    ['REM ("Packet") Duration Median+SD= ' num2str(median(REMDurs)) ' +- ' num2str(std(REMDurs)) ' sec'];...
    ['REM Latency Mean+SEM= ' num2str(mean(REMLatencies)) ' +- ' num2str(sem(REMLatencies')) ' sec'];...
    ['REM Latency Median+SD= ' num2str(median(REMLatencies)) ' +- ' num2str(std(REMLatencies)) ' sec'];...
%     ['----------'];...
%     ['Wake Duration = ' num2str(mean(WakeDurs)/60) ' +- ' num2str(std(WakeDurs)/60) ' sec'];...
%     ['Sleep Duration = ' num2str(mean(SleepDurs)/60) ' +- ' num2str(std(SleepDurs)/60) ' min'];...
%     ['SWS Episode Duration = ' num2str(mean(SWSEpisodeDurs)/60) ' +- ' num2str(std(SWSEpisodeDurs)/60) ' min'];...
%     ['SWS Packet Duration = ' num2str(mean(SWSPacketDurs)/60) ' +- ' num2str(std(SWSPacketDurs)/60) ' min'];...
%     ['REM Episode Duration = ' num2str(mean(REMEpisodeDurs)/60) ' +- ' num2str(std(REMEpisodeDurs)/60) ' min'];...
%     ['REM ("Packet") Duration = ' num2str(mean(REMDurs)/60) ' +- ' num2str(std(REMDurs)/60) ' min'];...
%     ['REM Latency = ' num2str(mean(REMLatencies)/60) ' +- ' num2str(std(REMLatencies)/60) ' min'];...
    };
h = figure('position',[2 200 560 520],'name','DatasetSleepStats');    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)

h(end+1) = figure('position',[2 2 800 875]);
subplot(3,2,1);
    semilogxhist(WakeDurs,20);
    title('Wake Episode Seconds')
    set(gca,'XScale','log')
subplot(3,2,2);
    semilogxhist(SleepDurs,10);
    set(gca,'XScale','log')
    title('Sleep Episode Seconds')
subplot(3,2,3);
    semilogxhist(SWSEpisodeDurs,100);
    set(gca,'XScale','log')
    title('SWS Episode Seconds')
subplot(3,2,4);
    semilogxhist(SWSPacketDurs,100);
    set(gca,'XScale','log')
    title('SWS Packet Seconds')
subplot(3,2,5);
    semilogxhist(REMEpisodeDurs,100);
    set(gca,'XScale','log')
    title('REM Episode Seconds')
subplot(3,2,6);
    semilogxhist(REMLatencies,20);
    set(gca,'XScale','log')
    title('REM Latency Seconds')


%% save data
MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',DefaultDatasetSleepStats)
%% save fig
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',h,'png')
