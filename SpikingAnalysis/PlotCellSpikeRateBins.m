function PlotCellSpikeRateBins(binseconds,basepath)

%% inputs and defaults
if ~exist('binseconds','var')
    binseconds = 5;%default
end
if ~exist('basepath','var')
    basepath = cd;%default
end


%% setup
basename = bz_BasenameFromBasepath(basepath);


%% Gather and bin spikes
spikes = bz_GetSpikes;
BinnedSpikes = bz_SpktToSpkmat(spikes,'dt',5);

%% Load states to overlay
try
    load(fullfile(basepath,[basename '.SleepState.states.mat']))
end

%% Load EMG
try
    load(fullfile(basepath,[basename '.eegstates.mat']))
    StateInfo.motion
end

%% Get spectral band powes
try
    ThetaRatio = SleepState.detectorinfo.detectionparms.SleepScoreMetrics.thratio;
    SlowWave = SleepState.detectorinfo.detectionparms.SleepScoreMetrics.broadbandSlowWave;
    Gamma = StateInfo.fspec{1}.spec;
    gammaband = StateInfo.fspec{1}.fo>=40 & StateInfo.fspec{1}.fo<=120;
    Gamma = Gamma(:,gammaband);
    Gamma = double(sum(Gamma,2));
    Spindle = StateInfo.fspec{1}.spec;
    spindleband = StateInfo.fspec{1}.fo>=10 & StateInfo.fspec{1}.fo<=19;
    Spindle = Spindle(:,spindleband);
    Spindle = double(sum(Spindle,2));
end

%% Load .dat start/stop times
try
    load(fullfile(basepath,[basename '_DatsMetadata.mat']))
    datends = cumsum(DatsMetadata.Recordings.Seconds);
end

%% Plot
for a = 1:size(BinnedSpikes.data,2)
    figure('position', [200 400 785 615]);
    plot(BinnedSpikes.timestamps,BinnedSpikes.data(:,a));
    hold on
    axis tight
    
    try
        %plot EMG/motion
        yl = ylim;
        oldbottom = yl(1);
        addtobottom = 0.075*diff(yl);
        newbottom = yl(1)-addtobottom;
        ylim ([newbottom yl(2)])
        motion = bwnormalize(StateInfo.motion);%bound btw 1 and 0
        motion = motion*(oldbottom-newbottom) + newbottom;
        xl = xlim;
    %     plot([xl],[oldbottom oldbottom],'k')
        plot(motion,'g');
    end

    try
        %plot Gamma power
        yl = ylim;
        oldbottom = yl(1);
        addtobottom = 0.075*diff(yl);
        newbottom = yl(1)-addtobottom;
        ylim ([newbottom yl(2)])
        Gamma = zscore(Gamma)/5;%bound btw 1 and 0
        Gamma = Gamma*(oldbottom-newbottom) + newbottom;
        xl = xlim;
    %     plot([xl],[oldbottom oldbottom],'k')
        plot(Gamma,'c');
    end

    try
        %plot SlowWave power
        yl = ylim;
        oldbottom = yl(1);
        addtobottom = 0.075*diff(yl);
        newbottom = yl(1)-addtobottom;
        ylim ([newbottom yl(2)])
        SlowWave = zscore(SlowWave)/5;%bound btw 1 and 0
        SlowWave = SlowWave*(oldbottom-newbottom) + newbottom;
        xl = xlim;
    %     plot([xl],[oldbottom oldbottom],'k')
        plot(SlowWave,'m');
    end

    try
        %plot Spindle power
        yl = ylim;
        oldbottom = yl(1);
        addtobottom = 0.075*diff(yl);
        newbottom = yl(1)-addtobottom;
        ylim ([newbottom yl(2)])
        Spindle = zscore(Spindle)/5;%bound btw 1 and 0
        Spindle = Spindle*(oldbottom-newbottom) + newbottom;
        xl = xlim;
    %     plot([xl],[oldbottom oldbottom],'k')
        plot(Spindle,'b');
    end

    try
        %plot ThetaRatio power
        yl = ylim;
        oldbottom = yl(1);
        addtobottom = 0.075*diff(yl);
        newbottom = yl(1)-addtobottom;
        ylim ([newbottom yl(2)])
        ThetaRatio = zscore(ThetaRatio)/5;%bound btw 1 and 0
        ThetaRatio = ThetaRatio*(oldbottom-newbottom) + newbottom;
        xl = xlim;
    %     plot([xl],[oldbottom oldbottom],'k')
        plot(ThetaRatio,'r');
    end

    try
        %plot .dat ends
        yl = ylim;
        for b = 1:length(datends)
            plot([datends(b) datends(b)],yl,'k','linestyle','--')
        end
    end

    try        
        %plot states
        plotIntervalsStrip(gca,SleepState.ints,1)
    end   
    % Legend
    legend('Spikes','EMG','Gamma','SlowWave','Spindle','ThetaRatio')
end