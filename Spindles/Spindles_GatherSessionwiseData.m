function SpindleDetectionEval = Spindles_GatherSessionwiseData

statename = 'nrem';

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

SpindleDetectionEval.TotalSpindles = [];
SpindleDetectionEval.OccurrenceRates = [];
SpindleDetectionEval.PeakAmplitudeMeans = [];
SpindleDetectionEval.PeakAmplitudeSDs = [];
SpindleDetectionEval.DurationMeans = [];
SpindleDetectionEval.DurationSDs = [];
SpindleDetectionEval.PeakFrequencyMeans = [];
SpindleDetectionEval.PeakFrequencySDs = [];
SpindleDetectionEval.SessionNames = {};
SpindleDetectionEval.RatNames = {};
SpindleDetectionEval.Anatomies = {};
SpindleDetectionEval.SpDetectionChan = [];
assignin('base','SpindleDetectionEval',SpindleDetectionEval)

for a = 1:length(names)
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    bmd = load([basename '_BasicMetaData.mat']);
    st = dir('*-states.mat*');
    st = load (st.name);
    anat = GetChannelAnatomy(basename,bmd.goodeegchannel);

    cd (fullfile(basepath,'Spindles'))

    SpindleData = load('SpindleData');
    SpindleData = SpindleData.SpindleData;

    %% BW summary stats
    totalspindles = length(SpindleData.normspindles);
    meanamp = mean(SpindleData.data.peakAmplitude);
    sdamp = std(SpindleData.data.peakAmplitude);
    meanfreq = mean(SpindleData.data.peakFrequency);
    sdfreq = std(SpindleData.data.peakFrequency);
    meanduration = mean(SpindleData.data.duration);
    sdduration = std(SpindleData.data.duration);

    
    % States handling
    StateIntervals = ConvertStatesVectorToIntervalSets(st.states);                 % 6 Intervalsets representing sleep states
    if strcmp(lower(statename),'allstates')
        stateduration = size(st.states,2);
    elseif strcmp(lower(statename),'nrem') | strcmp(lower(statename),'sws')
        stateints = or(StateIntervals{2}, StateIntervals{3});
        stateduration = tot_length(stateints,'s');
    elseif strcmp(lower(statename), 'rem'),
        stateints = StateIntervals{5};
        stateduration = tot_length(stateints,'s');
    else strcmp(lower(statename), 'wake'),
        stateints = StateIntervals{1};
        stateduration = tot_length(stateints,'s');
    end
    clear t StateIntervals stateints

    occurrencerate = totalspindles/stateduration;
    underscores = strfind(basename,'_');
    
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);
    detectionchan = SpindleData.detectionchan;
    % save to a larger struct
    % [~,basename,~] = fileparts(cd);

    SpindleDetectionEval = assignout('base','SpindleDetectionEval');

    SpindleDetectionEval.TotalSpindles(end+1) = totalspindles;
    SpindleDetectionEval.OccurrenceRates(end+1) = occurrencerate;
    SpindleDetectionEval.PeakAmplitudeMeans(end+1) = 1000000*meanamp;
    SpindleDetectionEval.PeakAmplitudeSDs(end+1) = 1000000*sdamp;
    SpindleDetectionEval.DurationMeans(end+1) = 1000*meanduration;
    SpindleDetectionEval.DurationSDs(end+1) = 1000*sdduration;
    SpindleDetectionEval.PeakFrequencyMeans(end+1) = meanfreq;
    SpindleDetectionEval.PeakFrequencySDs(end+1) = sdfreq;
    SpindleDetectionEval.SessionNames{end+1} = basename;
    SpindleDetectionEval.Anatomies{end+1} = anat;
    SpindleDetectionEval.RatNames{end+1} = ratname;
    SpindleDetectionEval.SpDetectionChan{end+1} = detectionchan;
    
    assignin('base','SpindleDetectionEval',SpindleDetectionEval)
end

savestr = ['SpindleDetectionEval_',date,'Sleep+Spikes'];
if wsw
    savestr = strcat(savestr,'+WSW');
end
if synapses
    savestr = strcat(savestr,'+Synapses');
end
if spindles
    savestr = strcat(savestr,'+Spindles');
end

save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleDetection/', savestr),'SpindleDetectionEval')

