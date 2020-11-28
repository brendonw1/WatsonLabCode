function ZScoreIntervalsWrapper(basepath,basename)
%% load basic data
if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'bmd');
load(fullfile(basepath,[basename '_SStable.mat']),'shank');
if exist(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Shanks','Channels'); % Channels are neuroscope+1
else
    warning('No channels specified for gamma analysis.');
    [~,Channels] = WriteChannelsForGammaAnalysis(basepath,basename);
end

SamplingRate = bmd.Par.lfpSampleRate;
passband = [1 625];
nvoice = 12;
zthreshold_all = [0.25 0.5 1];

if exist(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
else
    for i = 1:length(Channels)
        lfp{i} = LoadBinary([basename '.lfp'],'frequency',SamplingRate,'nChannels',bmd.Par.nChannels,'channels',Channels(i));
    end
    save(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
end
clear bmd;
%% Select Neighboring shank
[~,neighborShanks,~] = SelectNeighboringShank(basepath,basename);


%% Computing LFP phases and power
display('Computing LFP amplitudes');
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));
for i = 1:length(Channels)
    wt = awt_freqlist(double(lfp{i}), SamplingRate, freqlist); % too big to save all
    amp{i} = (real(wt).^2 + imag(wt).^2).^.5;
end
clear lfp wt;

%% Sorting spikes into different states
load(fullfile(basepath,[basename '-states.mat']),'states');
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');

GoodSleepIdx = (floor(min(GoodSleepInterval.timePairFormat))+1):min(length(states),floor(max(GoodSleepInterval.timePairFormat)));
states = states(GoodSleepIdx);
states = IDXtoINT(states);

%% Distinguishing high/low power gamma oscillation
[AboveInt_ZByState,BelowInt_ZByState,AboveInt_ZCombined,BelowInt_ZCombined] = ZScoreIntervals(amp,states,SamplingRate,zthreshold_all,freqlist);
save(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),...
    'AboveInt_ZByState','BelowInt_ZByState','AboveInt_ZCombined','BelowInt_ZCombined','Shanks',...
    'freqlist','zthreshold_all','SamplingRate','-v7.3');
clear AboveInt_ZByState BelowInt_ZByState AboveInt_ZCombined BelowInt_ZCombined;

%% The same for neighbor shank lfp
display('Computing LFP amplitudes from neighboring shanks');
neighborAmp = ComputingNeighborLFPAmp(amp,shank,Shanks,neighborShanks);
clear amp;
[AboveInt_ZByState,BelowInt_ZByState,AboveInt_ZCombined,BelowInt_ZCombined] = ZScoreIntervals(neighborAmp,states,SamplingRate,zthreshold_all,freqlist);
save(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),...
    'AboveInt_ZByState','BelowInt_ZByState','AboveInt_ZCombined','BelowInt_ZCombined','neighborShanks',...
    'freqlist','zthreshold_all','SamplingRate','-v7.3');
end