function GammaPhaseModulationWrapper_EachFreq(basepath,basename)
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

samplingRate = bmd.Par.lfpSampleRate;
passband = [1 625];
nvoice = 12;
zthreshold = 0.5;
zthreshold_all = [0.25 0.5 1];
numjitt = 200;

if exist(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
else
    for i = 1:length(Channels)
        lfp{i} = LoadBinary([basename '.lfp'],'frequency',samplingRate,'nChannels',bmd.Par.nChannels,'channels',Channels(i));
    end
    save(fullfile(basepath,[basename '_LFPForGammaAnalysis.mat']),'lfp');
end
clear bmd;
%% Select Neighboring shank
[~,neighborShanks,~] = SelectNeighboringShank(basepath,basename);


%% find shanks that will be used again
% for ii = 1:(length(GoodUnitShanks)-1)
%     WillUseShanks{ii} = zeros(size(neighborShanks{ii}));
%     for jj = (ii+1):length(GoodUnitShanks)
%         [~,iiIdx,~] = intersect(neighborShanks{ii},neighborShanks{jj});
%         if ~isempty(iiIdx);
%             WillUseShanks{ii}(iiIdx) = 1;
%         end
%     end
% end
% WillUseShanks{length(GoodUnitShanks)} = zeros(size(neighborShanks{length(GoodUnitShanks)}));



%% Sorting spikes into different states
load(fullfile(basepath,[basename '-states.mat']),'states');
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');

GoodSleepIdx = (floor(min(GoodSleepInterval.timePairFormat))+1):min(length(states),floor(max(GoodSleepInterval.timePairFormat)));
states = states(GoodSleepIdx);
states = IDXtoINT(states);

if exist(fullfile(basepath,[basename '_NeighborZScoreIntervals_thresh_0.5.mat']),'file')
    load(fullfile(basepath,[basename '_NeighborZScoreIntervals_thresh_0.5.mat']));
end

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

%% Computing LFP phases and power
display('Computing LFP phases and amplitudes');
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));
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

for jj = 1:length(Shanks)
    wt = awt_freqlist(double(lfp{jj}), samplingRate, freqlist);
    amp_all{jj} = single((real(wt).^2 + imag(wt).^2).^.5);
    phases_all{jj} = single(atan2(imag(wt),real(wt)));
    phases_all{jj} = mod(phases_all{jj},2*pi);
end
clear lfp wt;

PhstPS = cell(15,1);
for kk = 1:15
    PhstPS{kk} = cell(5,1);
end
h = waitbar(0,'Please wait');

for ii = 1:length(freqlist)
    waitbar(ii/length(freqlist));
    for jj = 1:length(Shanks)
% %     wt = awt_freqlist(double(lfp{jj}), samplingRate, freqlist(ii));
%     amp{jj} = (real(wt{jj}(:,ii)).^2 + imag(wt{jj}(:,ii)).^2).^.5;
%     phases{jj} = atan2(imag(wt{jj}(:,ii)),real(wt{jj}(:,ii)));
%     phases{jj} = mod(phases{jj},2*pi);
    amp{jj} = amp_all{jj}(:,ii);
    phases{jj} = phases_all{jj}(:,ii);
    end
    [neighborPhases,neighborAmp,cellneighborIdx] = ComputingNeighborLFPPhaseAmp(phases,amp,shank,Shanks,neighborShanks);
    clear phases;
    
    [~,~,~,LAboveInt,LBelowInt,LAboveInt_all,LBelowInt_all] = ...
        PowerAndStateLabels(amp,states,samplingRate,zthreshold_all,freqlist(ii));
    clear amp;
    if ii==1
        AboveInt = LAboveInt;
        BelowInt = LBelowInt;
        AboveInt_all = LAboveInt_all;
        BelowInt_all = LBelowInt_all;
    else
        AboveInt = cat(2,AboveInt,LAboveInt);
        BelowInt = cat(2,BelowInt,LBelowInt);
        AboveInt_all = cat(2,AboveInt_all,LAboveInt_all);
        BelowInt_all = cat(2,BelowInt_all,LBelowInt_all);
    end
    clear LAboveInt LBelowInt LAboveInt_all LBelowInt_all;
    
    [PowerStateIdx,PowerIdx,StateIdx,NAboveInt,NBelowInt,NAboveInt_all,NBelowInt_all] = ...
        PowerAndStateLabels(neighborAmp,states,samplingRate,zthreshold_all,freqlist(ii));
    clear neighborAmp;
    
    if ii==1
        NeighborAboveInt = NAboveInt;
        NeighborBelowInt = NBelowInt;
        NeighborAboveInt_all = NAboveInt_all;
        NeighborBelowInt_all = NBelowInt_all;
    else
        NeighborAboveInt = cat(2,NeighborAboveInt,NAboveInt);
        NeighborBelowInt = cat(2,NeighborBelowInt,NBelowInt);
        NeighborAboveInt_all = cat(2,NeighborAboveInt_all,NAboveInt_all);
        NeighborBelowInt_all = cat(2,NeighborBelowInt_all,NBelowInt_all);
    end
    clear NAboveInt NBelowInt NAboveInt_all NBelowInt_all;
    
    [~,SpkPhasestats] = PhasestatsByPowerAndState(spikes,neighborPhases,cellneighborIdx,...
             PowerStateIdx,PowerIdx,StateIdx,states,freqlist,1,GoodSleepInterval); %dangerous, need to fix PhasestatsByPowerAndState.m
    
    if ii==1
        fields1 = fieldnames(SpkPhasestats);
        fields2 = fieldnames(SpkPhasestats.phst);
    end
    SpkPhasestats = struct2cell(SpkPhasestats);
    for kk = 1:length(SpkPhasestats)
        SpkPhasestats{kk} = struct2cell(SpkPhasestats{kk});
        for ll = 1:length(SpkPhasestats{kk})
            PhstPS{kk}{ll} = cat(2,PhstPS{kk}{ll},SpkPhasestats{kk}{ll});
        end
    end
    jitterwin = 2/freqlist(ii);
    for jj = 1:numjitt
        jitterspikes = JitterSpiketimes(spikes,jitterwin);
        [~,jitterPhasestats] =  PhasestatsByPowerAndState(jitterspikes,neighborPhases,...
            cellneighborIdx,PowerStateIdx,PowerIdx,StateIdx,states,freqlist,1,GoodSleepInterval); % not saving 
        jitterMRL.all(:,ii,jj) = jitterPhasestats.phst.r;
        jitterMRL.H(:,ii,jj) = jitterPhasestats.phstH.r;
        jitterMRL.L(:,ii,jj) = jitterPhasestats.phstL.r;
        jitterMRL.WAKE(:,ii,jj) = jitterPhasestats.WAKEphst.r;
        jitterMRL.WAKEH(:,ii,jj) = jitterPhasestats.WAKEphstH.r;
        jitterMRL.WAKEL(:,ii,jj) = jitterPhasestats.WAKEphstL.r;
        jitterMRL.MA(:,ii,jj) = jitterPhasestats.MAphst.r;
        jitterMRL.MAH(:,ii,jj) = jitterPhasestats.MAphstH.r;
        jitterMRL.MAL(:,ii,jj) = jitterPhasestats.MAphstL.r;
        jitterMRL.NREM(:,ii,jj) = jitterPhasestats.NREMphst.r;
        jitterMRL.NREMH(:,ii,jj) = jitterPhasestats.NREMphstH.r;
        jitterMRL.NREML(:,ii,jj) = jitterPhasestats.NREMphstL.r;
        jitterMRL.REM(:,ii,jj) = jitterPhasestats.REMphst.r;
        jitterMRL.REMH(:,ii,jj) = jitterPhasestats.REMphstH.r;
        jitterMRL.REML(:,ii,jj) = jitterPhasestats.REMphstL.r;
    end
    clear neighborPhases;
end
close(h);
clear wt;

for kk = 1:length(PhstPS)
    PhstPS{kk} = cell2struct(PhstPS{kk},fields2,1);
end
PhstPS = cell2struct(PhstPS,fields1,1);
save(fullfile(basepath,[basename '_PhasestatsByPowerAndState.mat']),'PhstPS');
save(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),...
    'AboveInt','BelowInt','AboveInt_all','BelowInt_all','Shanks','freqlist','zthreshold_all');
AboveInt = NeighborAboveInt;
BelowInt = NeighborBelowInt;
AboveInt_all = NeighborAboveInt_all;
BelowInt_all = NeighborBelowInt_all;
save(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),...
    'AboveInt','BelowInt','AboveInt_all','BelowInt_all','neighborShanks','freqlist','zthreshold_all');
clear AboveInt BelowInt AboveInt_all BelowInt_all NeighborAboveInt NeighborBelowInt NeighborAboveInt_all NeighborBelowInt_all;


%% Computing spike phases

jitmeanMRL.all = nanmean(jitterMRL.all,3);
jitmeanMRL.H = nanmean(jitterMRL.H,3);
jitmeanMRL.L = nanmean(jitterMRL.L,3);
jitmeanMRL.WAKE = nanmean(jitterMRL.WAKE,3);
jitmeanMRL.WAKEH = nanmean(jitterMRL.WAKEH,3);
jitmeanMRL.WAKEL = nanmean(jitterMRL.WAKEL,3);

jitmeanMRL.MA = nanmean(jitterMRL.MA,3);
jitmeanMRL.MAH = nanmean(jitterMRL.MAH,3);
jitmeanMRL.MAL = nanmean(jitterMRL.MAL,3);

jitmeanMRL.NREM = nanmean(jitterMRL.NREM,3);
jitmeanMRL.NREMH = nanmean(jitterMRL.NREMH,3);
jitmeanMRL.NREML = nanmean(jitterMRL.NREML,3);

jitmeanMRL.REM = nanmean(jitterMRL.REM,3);
jitmeanMRL.REMH = nanmean(jitterMRL.REMH,3);
jitmeanMRL.REML = nanmean(jitterMRL.REML,3);

jitstdMRL.all = nanstd(jitterMRL.all,[],3);
jitstdMRL.H = nanstd(jitterMRL.H,[],3);
jitstdMRL.L = nanstd(jitterMRL.L,[],3);
jitstdMRL.WAKE = nanstd(jitterMRL.WAKE,[],3);
jitstdMRL.WAKEH = nanstd(jitterMRL.WAKEH,[],3);
jitstdMRL.WAKEL = nanstd(jitterMRL.WAKEL,[],3);

jitstdMRL.MA = nanstd(jitterMRL.MA,[],3);
jitstdMRL.MAH = nanstd(jitterMRL.MAH,[],3);
jitstdMRL.MAL = nanstd(jitterMRL.MAL,[],3);

jitstdMRL.NREM = nanstd(jitterMRL.NREM,[],3);
jitstdMRL.NREMH = nanstd(jitterMRL.NREMH,[],3);
jitstdMRL.NREML = nanstd(jitterMRL.NREML,[],3);

jitstdMRL.REM = nanstd(jitterMRL.REM,[],3);
jitstdMRL.REMH = nanstd(jitterMRL.REMH,[],3);
jitstdMRL.REML = nanstd(jitterMRL.REML,[],3);

% figure;
% for ii = 1:length(freqlist)
%     subplot(8,10,ii);
%     a = reshape(jitterMRL.all(1,ii,:),[],1);
%     hist(a);
% end
% SpkPhaseSig = (PhstPS.phst.r-jitmeanMRL.all)./jitstdMRL.all;
save(fullfile(basepath,[basename '_JitterMRL.mat']),'jitterMRL','jitmeanMRL','jitstdMRL');
% save(fullfile(basepath,[basename '_Sig.mat']),'SpkPhaseSig');
% jitterstd = std(jitterbuffer,[],3);
% spikephasesig = (spikephasemag-jittermean)./jitterstd;


%% superplot
load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
if ~exist(fullfile(basepath,[basename '_PhaseLockingFig']),'dir')
    mkdir(fullfile(basepath,[basename '_PhaseLockingFig']));
end
PlotMRLSummary(freqlist,PhstPS,jitmeanMRL,zthreshold,CellIDs,1);
print(fullfile(basepath,[basename '_PhaseLockingFig'],[basename '_MRLSummary(SameScale).png']),'-dpng','-r0');

PlotMRLSummary(freqlist,PhstPS,jitmeanMRL,zthreshold,CellIDs,0);
print(fullfile(basepath,[basename '_PhaseLockingFig'],[basename '_MRLSummary.png']),'-dpng','-r0');

end
