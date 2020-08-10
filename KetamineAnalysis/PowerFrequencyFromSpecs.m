function [bands,epochs] = PowerFrequencyFromSpecs(basepath, ketamineInjTime)

if ~exist('basepath','var')
    basepath = cd;
end

if ~exist('ketamineInjTime','var')
    ketamineInjTime = 7608; %seconds
end



basename = bz_BasenameFromBasepath(basepath);

%% Load specs file
load(fullfile(basepath,[basename '.specs.mat']))

%% load states file
load(fullfile(basepath,[basename '.SleepState.states.mat']))

%% Defining frequency bands
bands.delta.startstopfreq = [0.5 4];
bands.theta.startstopfreq = [5 10];
bands.spindle.startstopfreq = [11 19];
bands.lowbeta.startstopfreq = [20 30];
bands.highbeta.startstopfreq = [30 40];
bands.lowgamma.startstopfreq = [40 60];
bands.midgamma.startstopfreq = [60 100];
bands.highgamma.startstopfreq = [100 140];
bands.ripple.startstopfreq = [140 180];
bands.thetaratio.startstopfreq = [0 0];
bandnames = fieldnames(bands);

%% Setting up time intervals
epochs.BeforeKetInterval = [1 ketamineInjTime-1];%start stop format
epochs.AfterKetInterval = [ketamineInjTime length(SleepState.idx.timestamps)];%start stop format

epochs.AfterKet5MinInterval = [ketamineInjTime min([ketamineInjTime+5*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet10MinInterval = [ketamineInjTime min([ketamineInjTime+10*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet20MinInterval = [ketamineInjTime min([ketamineInjTime+20*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet30MinInterval = [ketamineInjTime min([ketamineInjTime+30*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet40MinInterval = [ketamineInjTime min([ketamineInjTime+40*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet60MinInterval = [ketamineInjTime min([ketamineInjTime+60*60 length(SleepState.idx.timestamps)])];%start stop format
epochs.AfterKet90MinInterval = [ketamineInjTime min([ketamineInjTime+90*60 length(SleepState.idx.timestamps)])];%start stop format

epochs.BeforeKetWakeIntervals = IntersectEpochs(epochs.BeforeKetInterval,SleepState.ints.WAKEstate);
epochs.AfterKetWakeIntervals = IntersectEpochs(epochs.AfterKetInterval,SleepState.ints.WAKEstate);
epochs.BeforeKetNremIntervals = IntersectEpochs(epochs.BeforeKetInterval,SleepState.ints.NREMstate);
epochs.AfterKetNremIntervals = IntersectEpochs(epochs.AfterKetInterval,SleepState.ints.NREMstate);
epochs.BeforeKetRemIntervals = IntersectEpochs(epochs.BeforeKetInterval,SleepState.ints.REMstate);
epochs.AfterKetRemIntervals = IntersectEpochs(epochs.AfterKetInterval,SleepState.ints.REMstate);

%indices - lists of timestamps (seconds) in each interval/epoch
epochs.BeforeKetIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.BeforeKetInterval);
epochs.AfterKetIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetInterval);

epochs.AfterKet5MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet5MinInterval);
epochs.AfterKet10MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet10MinInterval);
epochs.AfterKet20MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet20MinInterval);
epochs.AfterKet30MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet30MinInterval);
epochs.AfterKet40MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet40MinInterval);
epochs.AfterKet60MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet60MinInterval);
epochs.AfterKet90MinIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet90MinInterval);

epochs.BeforeKetWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.BeforeKetWakeIntervals);
epochs.AfterKetWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetWakeIntervals);
epochs.BeforeKetNremIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.BeforeKetNremIntervals);
epochs.AfterKetNremIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetNremIntervals);
epochs.BeforeKetRemIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.BeforeKetRemIntervals);
epochs.AfterKetRemIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetRemIntervals);

epochs.AfterKetFirstWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetWakeIntervals(1,:));
epochs.AfterKetFirstNremIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetNremIntervals(1,:));
epochs.AfterKetFirstRemIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKetRemIntervals(1,:));

epochs.AfterKetFirst5minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet5MinInterval(1,:));
epochs.AfterKetFirst10minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet10MinInterval(1,:));
epochs.AfterKetFirst20minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet20MinInterval(1,:));
epochs.AfterKetFirst30minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet30MinInterval(1,:));
epochs.AfterKetFirst40minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet40MinInterval(1,:));
epochs.AfterKetFirst60minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet60MinInterval(1,:));
epochs.AfterKetFirst90minWakeIndices = Restrict(1:length(SleepState.idx.timestamps),epochs.AfterKet90MinInterval(1,:));


%% Extracting powers for each frequency band.  (a is indexed over channels)
for b = 1:length(bandnames)% for every band
    tbandname = bandnames{b};
    tband = getfield(bands, tbandname);
    
    %find indices of relevant frequencies for this band
    tband.freqidxs = find(specs(1).freqs >= tband.startstopfreq(1) & specs(1).freqs < tband.startstopfreq(2));
%         tband.freqidxs(a).lowgamma = find(specs(a).freqs >= bands.lowgamma(1) & specs(1).freqs < bands.lowgamma(2));
%         freqidxs(a).midgamma = find(specs(a).freqs >= bands.midgamma(1) & specs(1).freqs < bands.midgamma(2));
%         freqidxs(a).highgamma = find(specs(a).freqs >= bands.highgamma(1) & specs(1).freqs < bands.highgamma(2));

    for a = 1:length(specs) %for every channel
        if strcmp(tbandname,'thetaratio')
            tband.freqidxs = [];
            tband.subspectrograms{a} = [];
            tbandpower = bands.theta.powervectors.All{a} ./ ...
                [bands.delta.powervectors.All{a} + bands.spindle.powervectors.All{a}];
        else
            tband.subspectrograms{a} = specs(a).spec(:,tband.freqidxs);
        %     subspecs(a).lowgamma = specs(a).spec(:,freqidxs(a).lowgamma);
        %     subspecs(a).midgamma = specs(a).spec(:,freqidxs(a).midgamma);
        %     subspecs(a).highgamma = specs(a).spec(:,freqidxs(a).highgamma);

            tbandpower = mean(tband.subspectrograms{a},2);
        end
        tband.powervectors.All{a} = tbandpower;
%         power(a).lowgamma = mean(subspecs(a).lowgamma,2);
%         power(a).midgamma = mean(subspecs(a).midgamma,2);
%         power(a).highgamma = mean(subspecs(a).highgamma,2);


        tband.powervectors.BeforeKetAll{a} = tbandpower(epochs.BeforeKetIndices);
        tband.powervectors.AfterKetAll{a} = tbandpower(epochs.AfterKetIndices);

        tband.powervectors.BeforeKetAllWake{a} = tbandpower(epochs.BeforeKetWakeIndices);
        tband.powervectors.AfterKetAllWake{a} = tbandpower(epochs.AfterKetWakeIndices);
        tband.powervectors.BeforeKetAllNrem{a} = tbandpower(epochs.BeforeKetNremIndices);
        tband.powervectors.AfterKetAllNrem{a} = tbandpower(epochs.AfterKetNremIndices);
        tband.powervectors.BeforeKetAllRem{a} = tbandpower(epochs.BeforeKetRemIndices);
        tband.powervectors.AfterKetAllRem{a} = tbandpower(epochs.AfterKetRemIndices);

        tband.powervectors.AfterKetFirstWake{a} = tbandpower(epochs.AfterKetFirstWakeIndices);
        tband.powervectors.AfterKetFirstNrem{a} = tbandpower(epochs.AfterKetFirstNremIndices);
        tband.powervectors.AfterKetFirstRem{a} = tbandpower(epochs.AfterKetFirstRemIndices);
        
        tband.powervectors.AfterKetFirst5minWake{a} = tbandpower(epochs.AfterKetFirst5minWakeIndices);
        tband.powervectors.AfterKetFirst10minWake{a} = tbandpower(epochs.AfterKetFirst10minWakeIndices);
        tband.powervectors.AfterKetFirst20minWake{a} = tbandpower(epochs.AfterKetFirst20minWakeIndices);
        tband.powervectors.AfterKetFirst30minWake{a} = tbandpower(epochs.AfterKetFirst30minWakeIndices);
        tband.powervectors.AfterKetFirst40minWake{a} = tbandpower(epochs.AfterKetFirst40minWakeIndices);
        tband.powervectors.AfterKetFirst60minWake{a} = tbandpower(epochs.AfterKetFirst60minWakeIndices);
        tband.powervectors.AfterKetFirst90minWake{a} = tbandpower(epochs.AfterKetFirst90minWakeIndices);

        pvnames = fieldnames(tband.powervectors);
        for c = 1:length(pvnames)%loop through all powervectosr above to generate histogram versions of each
            tpvname = pvnames{c};
            tpv = getfield(tband.powervectors,tpvname);
            tpv = tpv{a};
            [bincounts,powerbins] = hist(tpv,100);
            eval(['tband.powerhistograms.' tpvname '{a}.powerbins =  powerbins;'])
            eval(['tband.powerhistograms.' tpvname '{a}.bincounts =  bincounts;'])            
        end
    end
           
    bands = setfield(bands, tbandname, tband);
end

bands.ketamineInjTime = 7608;
save(fullfile(basepath,[basename '.KetamineBandPowers.mat']),'bands')

%% plotting
figs = [];

%power vs time
for a = 1:length(specs)  %for each channel
    ttitle = ['Channel' num2str(a) ' Power Vs Time'];
    figs(end+1) = figure('Name',ttitle,'position',[1 1 1236 1073]);
    plotcounter = 0;
    for b = 1:length(bandnames)% for every band
        tbandname = bandnames{b};
        tband = getfield(bands, tbandname);
        plotcounter = plotcounter+1;
        subplot(4,3,plotcounter);
        plot(tband.powervectors.All{a})
        hold on
        yl = get(gca,'ylim');
        plot([ketamineInjTime ketamineInjTime],yl)
        title(tbandname)
        axis tight
    end
    AboveTitle(ttitle)
end

%power vs time - smoothed
for a = 1:length(specs)  %for each channel
    ttitle = ['Channel' num2str(a) ' Power Vs Time Smoothed 30s'];
    figs(end+1) = figure('Name',ttitle,'position',[1 1 1236 1073]);
    plotcounter = 0;
    for b = 1:length(bandnames)% for every band
        tbandname = bandnames{b};
        tband = getfield(bands, tbandname);
        plotcounter = plotcounter+1;
        subplot(4,3,plotcounter);
        plot(smooth(tband.powervectors.All{a},30))
        hold on
        yl = get(gca,'ylim');
        plot([ketamineInjTime ketamineInjTime],yl)
        title(tbandname)
        axis tight
    end
    AboveTitle(ttitle)
end



%histograms
%AllBefore vs AllAfter
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAll','AfterKetAll',length(specs));

%AllBeforeWake vs AllAfterWake
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetAllWake',length(specs));
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllNrem','AfterKetAllNrem',length(specs));
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllRem','AfterKetAllRem',length(specs));

%AllBeforeWake vs FirstAfterWake
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirstWake',length(specs));
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllNrem','AfterKetFirstNrem',length(specs));
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllRem','AfterKetFirstRem',length(specs));
%AllBeforeWake vs FirstAfterWake - Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirstWake',length(specs));
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllNrem','AfterKetFirstNrem',length(specs));
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllRem','AfterKetFirstRem',length(specs));

%AllBeforeWake vs FirstAfterWake-up to 5min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst5minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 5min - Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst5minWake',length(specs));

%AllBeforeWake vs FirstAfterWake-up to 10min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst10minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 10min - Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst10minWake',length(specs));

%AllBeforeWake vs FirstAfterWake up to 20min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst20minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 20min- Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst20minWake',length(specs));

%AllBeforeWake vs FirstAfterWake up to 30min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst30minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 30min - Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst30minWake',length(specs));

%AllBeforeWake vs FirstAfterWake up to 40min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst40minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 40min- Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst40minWake',length(specs));

%AllBeforeWake vs FirstAfterWake up to 60min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst60minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 60min - Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst60minWake',length(specs));

%AllBeforeWake vs FirstAfterWake up to 90min
figs(end+1:end+3) = plothistograms(bands,'BeforeKetAllWake','AfterKetFirst90minWake',length(specs));
%AllBeforeWake vs FirstAfterWake up to 90min- Normalized
figs(end+1:end+3) = plothistograms_norm(bands,'BeforeKetAllWake','AfterKetFirst60minWake',length(specs));

savefigsasindir(fullfile(basepath,'KetamineBandPowerFigures'),figs,'fig')
savefigsasindir(fullfile(basepath,'KetamineBandPowerFigures'),figs,'png')

1;
% Save figs
% save stateeditor



function h = plothistograms(bands,histoname1,histoname2,nchans)
bandnames = fieldnames(bands);
h = [];
for a = 1:nchans   %for each channel
    ttitle = ['Channel' num2str(a) histoname1 ' vs ' histoname2];
    h(end+1) = figure('Name',ttitle,'position',[1 1 1236 1073]);
    plotcounter = 0;
    for b = 1:length(bandnames)% for every band
        tbandname = bandnames{b};
        tband = getfield(bands, tbandname);
        plotcounter = plotcounter+1;
        subplot(4,3,plotcounter);
        eval(['x = tband.powerhistograms.' histoname1 '{a}.powerbins;'])
        eval(['y = tband.powerhistograms.' histoname1 '{a}.bincounts;'])
        plot(x,y)
        hold on
        eval(['x = tband.powerhistograms.' histoname2 '{a}.powerbins;'])
        eval(['y = tband.powerhistograms.' histoname2 '{a}.bincounts;'])
        plot(x,y)
        title(tbandname)
        axis tight
    end
    legend({'BeforeKet','AfterKet'})
    AboveTitle(ttitle)
end




function h = plothistograms_norm(bands,histoname1,histoname2,nchans)
bandnames = fieldnames(bands);
h = [];
for a = 1:nchans   %for each channel
    ttitle = ['Channel' num2str(a) histoname1 ' vs ' histoname2 ' NORM'];
    h(end+1) = figure('Name',ttitle,'position',[1 1 1236 1073]);
    plotcounter = 0;
    for b = 1:length(bandnames)% for every band
        tbandname = bandnames{b};
        tband = getfield(bands, tbandname);
        plotcounter = plotcounter+1;
        subplot(4,3,plotcounter);
        eval(['x = tband.powerhistograms.' histoname1 '{a}.powerbins;'])
        eval(['y = tband.powerhistograms.' histoname1 '{a}.bincounts;'])
        y = y./max(y);
        plot(x,y)
        hold on
        eval(['x = tband.powerhistograms.' histoname2 '{a}.powerbins;'])
        eval(['y = tband.powerhistograms.' histoname2 '{a}.bincounts;'])
        y = y./max(y);
        plot(x,y)
        title(tbandname)
        axis tight
    end
    legend({'BeforeKet','AfterKet'})
    AboveTitle(ttitle)
end