function UPNearestEvents = FindNearestToUps(basepath,basename)


if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end
cd(basepath)

savefilename = fullfile('UPstates',[basename '_UPNearestEvents']);
if exist(savefilename)
    t = load(savefilename);
    UPNearestEvents = t.UPNearestEvents;
else 
    %% Load ups, get starts, stops
    t = load([basename, '_UPDOWNIntervals']);
    UPints = t.UPInts;
    UPstarts = Start(UPints)/10000;
    UPstops = End(UPints)/10000;

    %% Load Spindles, get starts, stops
    load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
    normspindles = SpindleData.normspindles;
    sp_starts = normspindles(:,1);
    sp_stops = normspindles(:,3);

    %% Gather relative timing info for various event types, to later correlate
    % Find times with at least 5min of waking beween SWS Epochs
    t = load([basename,'_Intervals.mat']);
    intervals = t.intervals;

    sleepborders = mergeCloseIntervals(intervals{3},300*10000);
    % sleepbordertimes = Start(sleepborders);
    SleepStartTimes = Start(sleepborders,'s'); 
    SleepStopTimes = End(sleepborders,'s');

    REMstarts = Start(t.intervals{5},'s');
    REMstops = End(t.intervals{5},'s');
    SWSstarts = Start(t.intervals{3},'s');
    SWSstops = End(t.intervals{3},'s');

    %%
    % UPstarts,sp_starts,sp_stops,SleepStartTimes,SleepStopTimes,REMstarts,REMstops)

    %%

    % - time since sleep start
    % - time to sleep end
    % - Time since SWS start
    % - Time to SWS end
    % - time til next rem
    % - time since last rem

    [~,UPTimeSinceLastSleepStart,~] = FindLastTimeBefore(UPstarts,SleepStartTimes);
    [~,UPTimeSinceLastSWSStart,~] = FindLastTimeBefore(UPstarts,SWSstarts);
    [~,UPTimeSinceLastREMEnd,~] = FindLastTimeBefore(UPstarts,REMstops);
    [~,UPTimeSinceLastSpindle,~] = FindLastTimeBefore(UPstarts,sp_stops);

    [~,UPTimeToNextSleepEnd,~] = FindLastTimeBefore(UPstarts,SleepStopTimes);
    [~,UPTimeToNextSWSEnd,~] = FindLastTimeBefore(UPstarts,SWSstops);
    [~,UPTimeToNextREMStart,~] = FindLastTimeBefore(UPstarts,REMstarts);
    [~,UPTimeToNextSpindle,~] = FindLastTimeBefore(UPstarts,sp_starts);


    % Correct jumps over sleep episodes, not intersted in these
    UPTimeSinceLastREMEnd(UPTimeSinceLastREMEnd>UPTimeSinceLastSleepStart) = NaN;
    UPTimeToNextREMStart(UPTimeToNextREMStart>UPTimeToNextSleepEnd) = NaN;
    UPTimeToNextSWSEnd(UPTimeToNextSWSEnd>UPTimeToNextSleepEnd) = NaN;
    UPTimeSinceLastSWSStart(UPTimeSinceLastSWSStart>UPTimeSinceLastSleepStart) = NaN;
    UPTimeSinceLastSpindle(UPTimeSinceLastSpindle>UPTimeSinceLastSleepStart) = NaN;
    UPTimeToNextSpindle(UPTimeToNextSpindle>UPTimeToNextSleepEnd) = NaN;
    
    UPTimeToClosestSpindle = min([UPTimeSinceLastSpindle;UPTimeToNextSpindle]);

    UPNearestEvents = v2struct(UPTimeSinceLastSleepStart,UPTimeSinceLastSWSStart,...
        UPTimeSinceLastREMEnd, UPTimeSinceLastSpindle,...
        UPTimeToNextSleepEnd, UPTimeToNextSWSEnd, UPTimeToNextREMStart,... 
        UPTimeToNextSpindle, UPTimeToClosestSpindle);

    % - Time to nearest spindle (if non-spindle only)
    % - UP vs spindle start time (nan if none)
    % - UP vs spindle end time (nan if none)

%% save
    save(savefilename,'UPNearestEvents')
end
