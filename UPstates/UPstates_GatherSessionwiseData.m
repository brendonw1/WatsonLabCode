function UPDetectionEval = UPstates_GatherSessionwiseData

statename = 'nrem';

wsw = 0;
synapses = 0;
spindles = 0;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

UPDetectionEval.TotalSpindles = [];
UPDetectionEval.OccurrenceRates = [];
% UPDetectionEval.PeakAmplitudeMeans = [];
% UPDetectionEval.PeakAmplitudeSDs = [];
UPDetectionEval.UPDurationMeans = [];
UPDetectionEval.UPDurationSDs = [];
UPDetectionEval.DOWNDurationMeans = [];
UPDetectionEval.DOWNDurationSDs = [];
UPDetectionEval.UPDOWNDurationMeanRatio = [];
% UPDetectionEval.PeakFrequencyMeans = [];
% UPDetectionEval.PeakFrequencySDs = [];
UPDetectionEval.SessionNames = {};
UPDetectionEval.RatNames = {};
UPDetectionEval.Anatomies = {};
UPDetectionEval.UPDetectionChan = [];
assignin('base','UPDetectionEval',UPDetectionEval)

for a = 1:length(names)
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    bmd = load([basename '_BasicMetaData.mat']);
    st = dir('*-states.mat*');
    st = load (st.name);
    anat = GetChannelAnatomy(basename,bmd.goodeegchannel);

    cd (basepath)

    UPDOWNIntervals = load([basename '_UPDOWNIntervals.mat']);
    UPInts = UPDOWNIntervals.UPInts;
    DNInts = UPDOWNIntervals.DNInts;

    %% BW summary stats
    totalUPs = length(length(UPInts));
%     meanamp = mean(SpindleData.data.peakAmplitude);
%     sdamp = std(SpindleData.data.peakAmplitude);
%     meanfreq = mean(SpindleData.data.peakFrequency);
%     sdfreq = std(SpindleData.data.peakFrequency);
    meandurationUP = mean(Data(length(UPInts)));
    sddurationUP = std(Data(length(UPInts)));
    meandurationDOWN = mean(Data(length(DNInts)));
    sddurationDOWN = std(Data(length(DNInts)));

    UPDOWNDurationMeanRatio = meandurationUP/meandurationDOWN;
    
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

    occurrencerate = totalUPs/stateduration;
%     underscores = strfind(basename,'_');
    
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);
    if isfield(UPDOWNIntervals,'UPstatechannel')
        detectionchan = UPDOWNIntervals.UPstatechannel;
    elseif isfield(UPDOWNIntervals,'UPchannel')
        detectionchan = UPDOWNIntervals.UPchannel;
    elseif isfield(UPDOWNIntervals,'goodeegchannel')
        detectionchan = UPDOWNIntervals.goodeegchannel;
    end
    % save to a larger struct
    % [~,basename,~] = fileparts(cd);

    UPDetectionEval = assignout('base','UPDetectionEval');

    UPDetectionEval.TotalSpindles(end+1) = totalUPs;
    UPDetectionEval.OccurrenceRates(end+1) = occurrencerate;
%     SpindleDetectionEval.PeakAmplitudeMeans(end+1) = 1000000*meanamp;
%     SpindleDetectionEval.PeakAmplitudeSDs(end+1) = 1000000*sdamp;
    UPDetectionEval.UPDurationMeans(end+1) = 1000*meandurationUP;
    UPDetectionEval.UPDurationSDs(end+1) = 1000*sddurationUP;
    UPDetectionEval.DOWNDurationMeans(end+1) = 1000*meandurationDOWN;
    UPDetectionEval.DOWNDurationSDs(end+1) = 1000*sddurationDOWN;
    UPDetectionEval.UPDOWNDurationMeanRatio(end+1) = UPDOWNDurationMeanRatio;
%     SpindleDetectionEval.PeakFrequencyMeans(end+1) = meanfreq;
%     SpindleDetectionEval.PeakFrequencySDs(end+1) = sdfreq;
    UPDetectionEval.SessionNames{end+1} = basename;
    UPDetectionEval.Anatomies{end+1} = anat;
    UPDetectionEval.RatNames{end+1} = ratname;
    UPDetectionEval.UPDetectionChan{end+1} = detectionchan;
    
    assignin('base','UPDetectionEval',UPDetectionEval)
end

savestr = ['UPDetectionEval',date,'Sleep+Spikes'];
if wsw
    savestr = strcat(savestr,'+WSW');
end
if synapses
    savestr = strcat(savestr,'+Synapses');
end
if spindles
    savestr = strcat(savestr,'+Spindles');
end

save(fullfile('/mnt/brendon4/Dropbox/Data/UPstateDetection/', savestr),'UPDetectionEval')

