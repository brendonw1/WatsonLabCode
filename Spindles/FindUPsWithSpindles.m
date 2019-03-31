function SpindleUPEvents = FindUPsWithSpindles(basepath,basename)
% Find which ups are spindle ups, partial spindle ups etc
% also save those events.

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = fullfile(cd);
end

cd(basepath)

filepath = fullfile('UPstates',[basename '_SpindleUPEvents.mat']);
if exist('filepath','file')
    t = load(filepath);
    SpindleUPEvents = t.SpindleUPEvents;
else

    try
        bmd = load([basename '_BasicMetaData.mat']);
    catch
        error('must be in a session basefolder')
    end
    numchans = bmd.Par.nChannels;

    %% Load Spindles and UPs
    load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
    normspindles = SpindleData.normspindles;

    t = load([basename, '_UPDOWNIntervals']);
    UPInts = t.UPInts;

    %%
    spindleups=[];
    nonspindleups=[];
    intermedspindleups=[];

    %% Assess whether each UP state is sufficiently overlapped by a spindle
    percentoverlap = 0.5;%proportion of UP state that must be covered by a spindle to be spindleup
    beforestart = 0.150;%spindle must start no more than this many seconds before UP start
    afterstart = 0.300;%spindle must start no more than this many seconds after UP start
    partialUPPercentOverlap  = 0;

    UStartWindows = [Start(UPInts)/10000-beforestart Start(UPInts)/10000+afterstart];
    sstarts = normspindles(:,1);

    sstartsgrid = repmat(sstarts,1,size(UStartWindows,1));
    UStartgridA = repmat(UStartWindows(:,1),1,size(sstarts,1))';
    UStartgridB = repmat(UStartWindows(:,2),1,size(sstarts,1))';

    startsaboveboolA = (sstartsgrid-UStartgridA)>0;
    startsaboveboolB = (sstartsgrid-UStartgridB)<0;

    startbool = startsaboveboolA.*startsaboveboolB;
    goodstartspindles = find(sum(startbool,2));%this should never be greater than 1, and I haven't seen that it has been 
    EarlyStartUPs = find(sum(startbool,1));%this should never be greater than 1, and I haven't seen that it has been 


    %% Find overlap for each up
    maxend = max([normspindles(end,3) End(subset(UPInts,length(length(UPInts))))/10000]);
    SpindleMilliseconds = zeros(1,round(maxend*1000));%1ms resolution of whether spindle in each ms
    for a=1:size(normspindles,1)% set 1s where spindle ms's are found
       SpindleMilliseconds(round(normspindles(a,1)*1000):round(normspindles(a,3)*1000)) = 1; 
    end

    UPPercents = zeros(1,length(length(UPInts)));
    for a = 1:length(length(UPInts))
        % for a = 1:length(goodstartups)
    %     tuidx = goodstartups(a);
        tu = subset(UPInts,a);
        %find the matching spindle(s)
        %look for at least 50% coverage
        thisspanstart = round(Start(tu)/10000*1000);
        thisspanend = round(End(tu)/10000*1000);
        thisspan = SpindleMilliseconds(thisspanstart:thisspanend);

        UPSpindleMsCounts(a) = sum(thisspan);
        UPPercents(a) = mean(thisspan);
    %     if uppercents(a)>=percentoverlap
    %         spindleups(end+1) = a;
    %     elseif uppercents(a)>0
    %         intermedspindleups(end+1) = a;
    %     else)
    %         nonspindleups(end+1) = a;
    %     end
    end

    SpindleUPs = intersect(EarlyStartUPs,find(UPPercents>=percentoverlap));%good start and >percentoverlap
    NoSpindleUPs = find(UPPercents==0);
    PartialSpindleUPs = intersect(1:length(length(UPInts)),find(UPPercents>partialUPPercentOverlap));
    PartialSpindleUPs = setdiff(PartialSpindleUPs,SpindleUPs);
    LateStartUPs = setdiff(find(UPPercents>0),EarlyStartUPs);

    %% Extract and save within-overlap start-start, start-stop, stop-start, and stop-stop timing
    % For overlapping spindle ups, 
    %   - find startstart lags (upstart-sstart)... use code from other
    %   - find startstop lage (upstart-sstop)... use code from other
    %   - find startstart lags (upstop-sstart)... use code from other
    %   - find stopstop lage (upstop-sstop)... use code from other

    %% Get nearest for non-overlapping
    % ustarts = Start(UPInts);
    % ustop = End(UPInts);
    % sstarts = normspindles(:,1);
    % sstops = normspindles(:,3);
    % 
    % sstartsgrid = repmat(sstarts,1,size(ustarts,1));
    % sstopsgrid = repmat(sstarts,1,size(ustarts,1));
    % ustartsgrid = repmat(ustarts,size(sstarts,1),1);
    % ustopsgrid = repmat(ustops,size(sstarts,1),1);
    % 
    % 
    % % For non-overlapping
    % % find nearest up to each spindle
    % % find nearest spindle to each up
    % % ... subtract repmats, then do min(abs(columns))
    SpindleUPEvents = v2struct(SpindleUPs,NoSpindleUPs,PartialSpindleUPs,EarlyStartUPs,LateStartUPs,UPPercents,UPSpindleMsCounts);
    save(filepath,'SpindleUPEvents')
end

