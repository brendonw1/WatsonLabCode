function StateRateBins = GatherStateRateBinMatrices(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin,RestrictInterval)
% makes rate matrices for cell x timebin for wake, rem, moving wake,
% non-moving wake at the specified seconds per bin.  For UP states,
% SpindleUPstates, Spindles and No-DOWN Spindles the entire event is taken
% as a rate bin.  Default time bin duration = 1sec

RateMtxSpindlesE = [];
RateMtxNDSpindlesE = [];
RateMtxUPE = [];
RateMtxSUPE = [];
RateMtxNSUPE = [];

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('secondsPerDetectionBin','var')
    secondsPerDetectionBin = 1;
end
if ~exist('secondsPerProjectionBin','var')
    secondsPerProjectionBin = 1;
end

% pointsPerDetectionBin = secondsPerDetectionBin * 10000;
pointsPerProjectionBin = secondsPerProjectionBin * 10000;

savematname = fullfile(basepath,[basename '_StateRateBins_' num2str(secondsPerProjectionBin) 'sec.mat']);
if exist(savematname,'file')
    t = load(savematname);
    StateRateBins = t.StateRateBins;
else
    t = load(fullfile(basepath,[basename,'_SSubtypes.mat']));
    Se = t.Se;

    % Spindles
    t = load(fullfile(basepath,'Spindles',[basename '_SpindleSpikeStats.mat']));%load spindles with no DOWN states
    sisse = t.isse;
    if secondsPerProjectionBin==1% if 1 sec, use whole event as the bin
        RateMtxSpindlesE = sisse.spkrates;
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
            for a=length(sisse.intstarts):-1:1
                if sisse.intends(a)>e | sisse.intstarts(a)<s
                    RateMtxSpindlesE(a,:) = [];
                end
            end
        end
    else %in most cases grab bins of specified length, as long as they fit in the event
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
        else
            s = -Inf;
            e = Inf;
        end
        for a=1:length(sisse.intstarts)
            if sisse.intends(a)<e & sisse.intstarts(a)>s
                ti = intervalSet(sisse.intstarts(a)*10000,sisse.intends(a)*10000);
    %             RateMtxSpindles = go through each sisse.spkrates, bin it, 
                bins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
                bins = intervalSet(bins(:,1)*10000,bins(:,2)*10000);
                S  = Restrict(sisse.S,ti);
                tmtx = MakeQfromS(S,bins);%bin every 1000pts, which is 100msec (10000 pts per sec)
                RateMtxSpindlesE = cat(1,RateMtxSpindlesE,Data(tmtx));
            end
        end
    end
    clear sisse

    % NoDOWNSpindles
    t = load(fullfile(basepath,'Spindles',[basename '_SpindleNoDOWNSpikeStats.mat']));%load spindles with no DOWN states
    ndisse = t.isse;
    if secondsPerProjectionBin==1% if 1 sec, use whole event as the bin
        RateMtxNDSpindlesE = ndisse.spkrates;
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
            for a=length(ndisse.intstarts):-1:1
                if ndisse.intends(a)>e | ndisse.intstarts(a)<s
                    RateMtxNDSpindlesE(a,:) = [];
                end
            end
        end
    else %in most cases grab bins of specified length, as long as they fit in the event
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
        else
            s = -Inf;
            e = Inf;
        end
        for a=1:length(ndisse.intstarts)
            if ndisse.intends(a)<e & ndisse.intstarts(a)>s
                ti = intervalSet(ndisse.intstarts(a)*10000,ndisse.intends(a)*10000);
    %             RateMtxSpindles = go through each sisse.spkrates, bin it, 
                bins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
                bins = intervalSet(bins(:,1)*10000,bins(:,2)*10000);
                S  = Restrict(ndisse.S,ti);
                tmtx = MakeQfromS(S,bins);%bin every 1000pts, which is 100msec (10000 pts per sec)
                RateMtxNDSpindlesE = cat(1,RateMtxNDSpindlesE,Data(tmtx));
            end
        end
    end
    clear ndisse


    % UPstates
    t = load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']));
    uisse = t.isse;
    if secondsPerProjectionBin==1% if 1 sec, use whole event as the bin
        RateMtxUPE = uisse.spkrates;
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
            for a=length(uisse.intstarts):-1:1
                if uisse.intends(a)>e | uisse.intstarts(a)<s
                    RateMtxUPE(a,:) = [];
                end
            end
        end
    else %in most cases grab bins of specified length, as long as they fit in the event
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
        else
            s = -Inf;
            e = Inf;
        end
        for a=1:length(uisse.intstarts)
            if uisse.intends(a)<e & uisse.intstarts(a)>s
                ti = intervalSet(uisse.intstarts(a)*10000,uisse.intends(a)*10000);
    %             RateMtxSpindles = go through each sisse.spkrates, bin it, 
                bins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
                bins = intervalSet(bins(:,1)*10000,bins(:,2)*10000);
                S  = Restrict(uisse.S,ti);
                tmtx = MakeQfromS(S,bins);%bin every 1000pts, which is 100msec (10000 pts per sec)
                RateMtxUPE = cat(1,RateMtxUPE,Data(tmtx));
            end
        end
    end
    clear uisse

    % SpindleUPstates
    t = load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']));
    uisse = t.isse;
    t = load(fullfile(basepath,'UPstates',[basename '_SpindleUPEvents.mat']));
    SupStarts = uisse.intstarts(t.SpindleUPEvents.SpindleUPs,:);
    SupEnds = uisse.intends(t.SpindleUPEvents.SpindleUPs,:);
    if secondsPerProjectionBin==1% if 1 sec, use whole event as the bin
        RateMtxSUPE = uisse.spkrates(t.SpindleUPEvents.SpindleUPs,:);
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
            for a=length(SupStarts):-1:1
                if SupEnds(a)>e || SupStarts(a)<s
                    RateMtxSUPE(a,:) = [];
                end
            end
        end
    else %in most cases grab bins of specified length, as long as they fit in the event
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
        else
            s = -Inf;
            e = Inf;
        end
        for a=1:length(SupStarts)
            if SupEnds(a)<e && SupStarts(a)>s
                ti = intervalSet(SupStarts(a)*10000,SupEnds(a)*10000);
    %             RateMtxSpindles = go through each sisse.spkrates, bin it, 
                bins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
                bins = intervalSet(bins(:,1)*10000,bins(:,2)*10000);
                S  = Restrict(uisse.S,ti);
                tmtx = MakeQfromS(S,bins);%bin every 1000pts, which is 100msec (10000 pts per sec)
                RateMtxSUPE = cat(1,RateMtxSUPE,Data(tmtx));
            end
        end
    end
    clear uisse


    % NonSpindleUPstates
    t = load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']));
    uisse = t.isse;
    t = load(fullfile(basepath,'UPstates',[basename '_SpindleUPEvents.mat']));
    NSupStarts = uisse.intstarts(t.SpindleUPEvents.NoSpindleUPs,:);
    NSupEnds = uisse.intends(t.SpindleUPEvents.NoSpindleUPs,:);
    if secondsPerProjectionBin==1% if 1 sec, use whole event as the bin
        RateMtxNSUPE = uisse.spkrates(t.SpindleUPEvents.NoSpindleUPs,:);
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
            for a=length(NSupStarts):-1:1
                if NSupEnds(a)>e || NSupStarts(a)<s
                    RateMtxNSUPE(a,:) = [];
                end
            end
        end
    else %in most cases grab bins of specified length, as long as they fit in the event
        if exist('RestrictInterval','var')
            s = Start(RestrictInterval,'s'); 
            e = End(RestrictInterval,'s');
        else
            s = -Inf;
            e = Inf;
        end
        for a=1:length(NSupStarts)
            if NSupEnds(a)<e && NSupStarts(a)>s
                ti = intervalSet(NSupStarts(a)*10000,NSupEnds(a)*10000);
    %             RateMtxSpindles = go through each sisse.spkrates, bin it, 
                bins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
                bins = intervalSet(bins(:,1)*10000,bins(:,2)*10000);
                S  = Restrict(uisse.S,ti);
                tmtx = MakeQfromS(S,bins);%bin every 1000pts, which is 100msec (10000 pts per sec)
                RateMtxNSUPE = cat(1,RateMtxNSUPE,Data(tmtx));
            end
        end
    end
    clear uisse


    intervals = load(fullfile(basepath,[basename '_Intervals']));

    % Wake
    ti = intervals.intervals{1};
    if exist('RestrictInterval','var')
        ti = intersect(ti,RestrictInterval);
    end
    wakesecs = [Start(ti,'s') End(ti,'s')];%for motion later
    wakebins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
    wakebins = intervalSet(wakebins(:,1)*10000,wakebins(:,2)*10000);
    WakeSeBinned = MakeQfromS(Se,wakebins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxWakeE = Data(WakeSeBinned);
    % Moving Wake
    t = load(fullfile(basepath,[basename '_Motion.mat']));
    wakesecs = inttobool(wakesecs,length(t.motiondata.thresholdedsecs));
    movewake = wakesecs.*t.motiondata.thresholdedsecs';
    movewake2 = booltoint(movewake);
    mwbins = NonClippedBinsFromIntervals(movewake2,secondsPerProjectionBin);
    mwbins = intervalSet(mwbins(:,1)*10000,mwbins(:,2)*10000);
    MWSeBinned = MakeQfromS(Se,mwbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxMWakeE = Data(MWSeBinned);
    % Non-moving Wake
    nonmovewake = ~movewake;
    nonmovewake = nonmovewake .* wakesecs;%Have to take times that are both (notmoving) and (yeswake)
    nonmovewake2 = booltoint(nonmovewake);
    nmwbins = NonClippedBinsFromIntervals(nonmovewake2,secondsPerProjectionBin);
    nmwbins = intervalSet(nmwbins(:,1)*10000,nmwbins(:,2)*10000);
    NMWSeBinned = MakeQfromS(Se,nmwbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxNMWakeE = Data(NMWSeBinned);

    % REM
    ti = intervals.intervals{5};
    if exist('RestrictInterval','var')
        ti = intersect(ti,RestrictInterval);
    end
    REMbins = NonClippedBinsFromIntervals(ti,secondsPerProjectionBin);
    REMbins = intervalSet(REMbins(:,1)*10000,REMbins(:,2)*10000);
    REMSeBinned = MakeQfromS(Se,REMbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxREME = Data(REMSeBinned);


    StateRateBins = v2struct(RateMtxSpindlesE,RateMtxNDSpindlesE,...
        RateMtxUPE,RateMtxSUPE,RateMtxNSUPE,...
        RateMtxWakeE,RateMtxREME,RateMtxMWakeE,RateMtxNMWakeE);

    savematname = fullfile(basepath,[basename '_StateRateBins_' num2str(secondsPerProjectionBin) 'sec.mat']);
    save(savematname,'StateRateBins')
end