function GammaPhaseModIsolatedBand(basepath,basename)
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
zthreshold = 0.5;
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

load(fullfile(basepath,[basename '-states.mat']),'states');
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');
load(fullfile(basepath,[basename '_SStable.mat']),'S','shank');
if isa(S,'tsdArray')
    spikes = cellArray(S);
    for ii = 1:length(spikes)
        spikes{ii} = Data(spikes{ii});
    end
elseif isa(S,'cell')
    spikes = S;
end
clear S;

GoodSleepIdx = (floor(min(GoodSleepInterval.timePairFormat))+1):min(length(states),floor(max(GoodSleepInterval.timePairFormat)));
states = states(GoodSleepIdx);
states = IDXtoINT(states);

%% Select Neighboring shank
if exist(fullfile(basepath,[basename '_NeighboringShanks.mat']),'file')
    load(fullfile(basepath,[basename '_NeighboringShanks.mat']),'neighborShanks');
else
    [~,neighborShanks,~] = SelectNeighboringShank(basepath,basename);
end

%% Computing LFP phases and power
display('Computing LFP phases');
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));
for i = 1:length(Channels)
    wt = awt_freqlist(double(lfp{i}), SamplingRate, freqlist); % too big to save all
    %     amp{i} = (real(wt).^2 + imag(wt).^2).^.5;
    phase{i} = single(atan2(imag(wt),real(wt)));
    phase{i} = mod(phase{i},2*pi);
    %     % for bigger recordings
    %     amp{i} = single((real(wt).^2 + imag(wt).^2).^.5);
    %     phase{i} = single(atan2(imag(wt),real(wt)));
    %     phase{i} = mod(phase{i},2*pi);
    lfp{i} = [];
    clear wt;
end
% clear lfp wt;
clear lfp;

display('Computing LFP phases from neighboring shanks');
[neighborPhases,cellneighborIdx] = ComputingNeighborLFPPhase(phase,shank,Shanks,neighborShanks);
clear phase;
%% save high/low power good oscillation intervals of local lfp
% [AboveInt,BelowInt,AboveInt_all,BelowInt_all] = ZScoreIntervals(amp,states,SamplingRate,zthreshold_all,freqlist);
% if ~exist(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),'file')
%     [AboveInt_ZByState,BelowInt_ZByState,AboveInt_ZCombined,BelowInt_ZCombined] = ZScoreIntervals(amp,states,SamplingRate,zthreshold_all,freqlist);
%
%     save(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),...
%         'AboveInt_ZByState','BelowInt_ZByState','AboveInt_ZCombined','BelowInt_ZCombined',...
%         'Shanks','freqlist','zthreshold_all','SamplingRate','-v7.3');
%     clear AboveInt_ZByState BelowInt_ZByState AboveInt_ZCombined BelowInt_ZCombined;
% end
%% do the same for neighbor shank lfp
% if ~exist(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),'file')
%     display('Computing LFP phases and amplitudes from neighboring shanks');
% [neighborPhases,neighborAmp,cellneighborIdx] = ComputingNeighborLFPPhaseAmp(phase,amp,shank,Shanks,neighborShanks);
%     neighborAmp = ComputingNeighborLFPAmp(amp,shank,Shanks,neighborShanks);
%     clear amp;

% [PowerStateIdx,PowerIdx,StateIdx,AboveInt,BelowInt,AboveInt_all,BelowInt_all] = ...
%     PowerAndStateLabels(neighborAmp,states,samplingRate,zthreshold_all,freqlist);
% save(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),...
%     'AboveInt','BelowInt','AboveInt_all','BelowInt_all','neighborShanks','freqlist','zthreshold_all','SamplingRate');


% [PowerStateIdx,PowerIdx,StateIdx,~,~,~,~] = ...
%     PowerAndStateLabels(neighborAmp,states,SamplingRate,zthreshold_all,freqlist);

%     [PowerStateIdx,PowerIdx,StateIdx,AboveInt_ZByState,BelowInt_ZByState,AboveInt_ZCombined,BelowInt_ZCombined] = ...
%         PowerAndStateLabels(neighborAmp,states,SamplingRate,zthreshold_all,freqlist);
%
%     save(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),...
%         'AboveInt_ZByState','BelowInt_ZByState','AboveInt_ZCombined','BelowInt_ZCombined',...
%         'neighborShanks','freqlist','zthreshold_all','SamplingRate','-v7.3');
%
%     clear AboveInt_ZByState BelowInt_ZByState AboveInt_ZCombined BelowInt_ZCombined;
% else
if ~exist(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervals.mat']),'file')
StateIdx = zeros(size(neighborPhases{1},1),1);
for ii = 1:length(states)
    StateIdx(InIntervals((1:size(neighborPhases{1},1))/SamplingRate,states{ii})) = ii;
end
load(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervals.mat']),'IsolatedBandAboveZData');
for ii = 1:size(neighborShanks,1)
    for jj = 1:length(freqlist)
        IsolatedAboveInt{ii,jj} = IsolatedBandAboveZData.IsolatedAboveInt_ZByState{ii,jj,2};
        AboveIdx = InIntervals(1:size(neighborPhases{1},1),IsolatedAboveInt{ii,jj});
        AboveIntByState = IDXtoINT(AboveIdx.*StateIdx);
        WAKEAboveInt{ii,jj} = AboveIntByState{1};
        MAAboveInt{ii,jj} = AboveIntByState{2};
        NREMAboveInt{ii,jj} = AboveIntByState{3};
        if length(AboveIntByState)==5
            REMAboveInt{ii,jj} = AboveIntByState{5};
        else
            REMAboveInt{ii,jj} = [];
        end
    end
end
save(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervalsByState.mat']),'WAKEAboveInt','NREMAboveInt','REMAboveInt','MAAboveInt','-v7.3');
clear IsolatedBandAboveZData;
elseif ~exist(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'file')
    load(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervalsByState.mat']));
end

%% Computing spike phases
if exist(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'file')
    load(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'spkIdx');
else
display('Computing spike phases and phase statistics');
    for i = 1:length(spikes)
        spikes{i} = spikes{i}(logical(belong(GoodSleepInterval.intervalSetFormat,spikes{i})));
        spikes{i} = spikes{i}(logical(logical(round(spikes{i}*SamplingRate)>0).*logical(round(spikes{i}*SamplingRate)<=size(neighborPhases{1},1))));
        for j = 1:length(freqlist)
            spkphases{i,j} = neighborPhases{cellneighborIdx(i)}(round(spikes{i}*SamplingRate),j);
        end
    end
    save(fullfile(basepath,[basename '_SpikePhases.mat']),'spkphases','-v7.3');
    %     save(fullfile(basepath,[basename '_PhasestatsByPowerAndState.mat']),'PhstPS');
% end
[phasestats.phstH,spkphasesIso.H,spkNum.H,spkIdx.H] = PhasestatsUsingIntervals(spikes,spkphases,IsolatedAboveInt,cellneighborIdx,freqlist,SamplingRate);
[phasestats.WAKEphstH,spkphasesIso.WAKEH,spkNum.WAKEH,spkIdx.WAKEH] = PhasestatsUsingIntervals(spikes,spkphases,WAKEAboveInt,cellneighborIdx,freqlist,SamplingRate);
[phasestats.NREMphstH,spkphasesIso.NREMH,spkNum.NREMH,spkIdx.NREMH] = PhasestatsUsingIntervals(spikes,spkphases,NREMAboveInt,cellneighborIdx,freqlist,SamplingRate);
[phasestats.REMphstH,spkphasesIso.REMH,spkNum.REMH,spkIdx.REMH] = PhasestatsUsingIntervals(spikes,spkphases,REMAboveInt,cellneighborIdx,freqlist,SamplingRate);
[phasestats.MAphstH,spkphasesIso.MAH,spkNum.MAH,spkIdx.MAH] = PhasestatsUsingIntervals(spikes,spkphases,MAAboveInt,cellneighborIdx,freqlist,SamplingRate);

% save(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'phasestats','spkphasesIso','spkNum','spkIdx','-v7.3');
save(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'phasestats','spkNum','spkIdx','-v7.3');
clear spkphases spkphasesIso IsolatedAboveInt WAKEAboveInt NREMAboveInt REMAboveInt MAAboveInt;
end
%% Jitter spikes
numjitt = 200;
% jitterspikes = cell(length(spikes),length(freqlist),numjitt);
jitterSpkphases = cell(length(spikes),length(freqlist),numjitt);
h = waitbar(0,'Please wait');
for ii = 1:length(freqlist)
    jitterwin = 2/freqlist(ii);
    waitbar(ii/length(freqlist));
    for jj = 1:numjitt
        jitterspikes = JitterSpiketimes(spikes,jitterwin);
        for kk = 1:length(jitterspikes)
            jitterSpkphases{kk,ii,jj} = single(nan(length(jitterspikes{kk}),1));
            jitterspikes{kk}(round(jitterspikes{kk}*SamplingRate)<=0 | round(jitterspikes{kk}*SamplingRate)>size(neighborPhases{1},1)) = nan;
%             jitterspikes{kk}(logical((round(jitterspikes{kk}*SamplingRate)>0).*(round(jitterspikes{kk}*SamplingRate)<=size(neighborPhases{1},1))));
            jitterSpkphases{kk,ii,jj}(~isnan(jitterspikes{kk})) = neighborPhases{cellneighborIdx(kk)}(round(jitterspikes{kk}(~isnan(jitterspikes{kk}))*SamplingRate),ii);
        end
    end
end
close(h);
clear neighborPhases jitterspikes;
% save(fullfile(basepath,[basename '_JitterSpikes.mat']),'jitterspikes');
% save(fullfile(basepath,[basename '_JitterSpikePhases.mat']),'jitterSpkphases','-v7.3');
%%
[jitphasestats.H,jitspkphasesIso.H] = PhasestatsUsingIndices(jitterSpkphases,spkIdx.H);
[jitphasestats.WAKEH,jitspkphasesIso.WAKEH] = PhasestatsUsingIndices(jitterSpkphases,spkIdx.WAKEH);
[jitphasestats.NREMH,jitspkphasesIso.NREMH] = PhasestatsUsingIndices(jitterSpkphases,spkIdx.NREMH);
[jitphasestats.REMH,jitspkphasesIso.REMH] = PhasestatsUsingIndices(jitterSpkphases,spkIdx.REMH);
[jitphasestats.MAH,jitspkphasesIso.MAH] = PhasestatsUsingIndices(jitterSpkphases,spkIdx.MAH);
% clear jitterSpkphases;
%%
% jitmeanMRL.all = nanmean(jitterMRL.all,3);
jitmeanMRL.H = nanmean(jitphasestats.H.r,3);
% jitmeanMRL.L = nanmean(jitterMRL.L,3);
% jitmeanMRL.WAKE = nanmean(jitterMRL.WAKE,3);
jitmeanMRL.WAKEH = nanmean(jitphasestats.WAKEH.r,3);
% jitmeanMRL.WAKEL = nanmean(jitterMRL.WAKEL,3);

% jitmeanMRL.MA = nanmean(jitterMRL.MA,3);
jitmeanMRL.MAH = nanmean(jitphasestats.MAH.r,3);
% jitmeanMRL.MAL = nanmean(jitterMRL.MAL,3);

% jitmeanMRL.NREM = nanmean(jitterMRL.NREM,3);
jitmeanMRL.NREMH = nanmean(jitphasestats.NREMH.r,3);
% jitmeanMRL.NREML = nanmean(jitterMRL.NREML,3);

% jitmeanMRL.REM = nanmean(jitterMRL.REM,3);
jitmeanMRL.REMH = nanmean(jitphasestats.REMH.r,3);
% jitmeanMRL.REML = nanmean(jitterMRL.REML,3);

% jitstdMRL.all = nanstd(jitterMRL.all,[],3);
% jitstdMRL.H = nanstd(jitterMRL.H,[],3);
% jitstdMRL.L = nanstd(jitterMRL.L,[],3);
% jitstdMRL.WAKE = nanstd(jitterMRL.WAKE,[],3);
% jitstdMRL.WAKEH = nanstd(jitterMRL.WAKEH,[],3);
% jitstdMRL.WAKEL = nanstd(jitterMRL.WAKEL,[],3);
% 
% jitstdMRL.MA = nanstd(jitterMRL.MA,[],3);
% jitstdMRL.MAH = nanstd(jitterMRL.MAH,[],3);
% jitstdMRL.MAL = nanstd(jitterMRL.MAL,[],3);
% 
% jitstdMRL.NREM = nanstd(jitterMRL.NREM,[],3);
% jitstdMRL.NREMH = nanstd(jitterMRL.NREMH,[],3);
% jitstdMRL.NREML = nanstd(jitterMRL.NREML,[],3);
% 
% jitstdMRL.REM = nanstd(jitterMRL.REM,[],3);
% jitstdMRL.REMH = nanstd(jitterMRL.REMH,[],3);
% jitstdMRL.REML = nanstd(jitterMRL.REML,[],3);

% figure;
% for ii = 1:length(freqlist)
%     subplot(8,10,ii);
%     a = reshape(jitterMRL.all(1,ii,:),[],1);
%     hist(a);
% end
% SpkPhaseSig = (PhstPS.phst.r-jitmeanMRL.all)./jitstdMRL.all;
% save(fullfile(basepath,[basename '_JitterMRL.mat']),'jitterMRL','jitmeanMRL','jitstdMRL');
% save(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'jitphasestats','jitmeanMRL','jitspkphasesIso','-v7.3');
save(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'jitphasestats','jitmeanMRL','-v7.3');
% clear jitspkphasesIso;
% save(fullfile(basepath,[basename '_Sig.mat']),'SpkPhaseSig');
% jitterstd = std(jitterbuffer,[],3);
% spikephasesig = (spikephasemag-jittermean)./jitterstd;


%% superplot
% load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
% if ~exist(fullfile(basepath,[basename '_PhaseLockingFig']),'dir')
%     mkdir(fullfile(basepath,[basename '_PhaseLockingFig']));
% end
% PlotMRLSummary(freqlist,PhstPS,jitmeanMRL,zthreshold,CellIDs,1);
% print(fullfile(basepath,[basename '_PhaseLockingFig'],[basename '_MRLSummary(SameScale)_v2.png']),'-dpng','-r0');
% 
% PlotMRLSummary(freqlist,PhstPS,jitmeanMRL,zthreshold,CellIDs,0);
% print(fullfile(basepath,[basename '_PhaseLockingFig'],[basename '_MRLSummary_v2.png']),'-dpng','-r0');

end
