function GammaPhaseModulationWrapper_BigRecording(basepath, basename)
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
[GoodUnitShanks,neighborShanks,~] = SelectNeighboringShank(basepath,basename);


%% find shanks that will be used again
for ii = 1:(length(GoodUnitShanks)-1)
    WillUseShanks{ii} = zeros(size(neighborShanks{ii}));
    for jj = (ii+1):length(GoodUnitShanks)
        [~,iiIdx,~] = intersect(neighborShanks{ii},neighborShanks{jj});
        if ~isempty(iiIdx);
            WillUseShanks{ii}(iiIdx) = 1;
        end
    end
end
WillUseShanks{length(GoodUnitShanks)} = zeros(size(neighborShanks{length(GoodUnitShanks)}));


%% Sorting spikes into different states
load(fullfile(basepath,[basename '-states.mat']),'states');
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');

GoodSleepIdx = (floor(min(GoodSleepInterval.timePairFormat))+1):min(length(states),floor(max(GoodSleepInterval.timePairFormat)));
states = states(GoodSleepIdx);
states = IDXtoINT(states);

%% Computing LFP phases and power
display('Computing LFP phases and amplitudes');
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));
amp = cell(length(Shanks),1);
phases = cell(length(Shanks),1);
for i = 1:length(GoodUnitShanks)
    display([num2str(i) ' out of ' num2str(length(GoodUnitShanks))]);
    if length(neighborShanks{i})==1
        if isempty(amp{Shanks==neighborShanks{i}})
            neighborwt = awt_freqlist(double(lfp{Shanks==neighborShanks{i}}), samplingRate, freqlist); % too big to save all
            neighborAmp = (real(neighborwt).^2 + imag(neighborwt).^2).^.5;
            neighborPhases{i} = atan2(imag(neighborwt),real(neighborwt));
            neighborPhases{i} = mod(neighborPhases{i},2*pi);
            if WillUseShanks{i}
                amp{Shanks==neighborShanks{i}} = neighborAmp;
                phases{Shanks==neighborShanks{i}} = neighborPhases{i};
            else
                amp{Shanks==neighborShanks{i}} = [];
                phases{Shanks==neighborShanks{i}} = [];
            end
        else
            neighborAmp = amp{Shanks==neighborShanks{i}};
            neighborPhases{i} = phases{Shanks==neighborShanks{i}};
        end
        
    elseif length(neighborShanks{i})==2
        for j = 1:2
            if isempty(amp{Shanks==neighborShanks{i}(j)})
                neighborwt = awt_freqlist(double(lfp{Shanks==neighborShanks{i}(j)}), samplingRate, freqlist); % too big to save all
                neighborAmp2{j} = (real(neighborwt).^2 + imag(neighborwt).^2).^.5;
                neighborPhase2{j} = atan2(imag(neighborwt),real(neighborwt));
                neighborPhase2{j} = mod(neighborPhase2{j},2*pi);
                if WillUseShanks{i}(j)
                    amp{Shanks==neighborShanks{i}(j)} = neighborAmp2{j};
                    phases{Shanks==neighborShanks{i}(j)} = neighborPhase2{j};
                else
                    amp{Shanks==neighborShanks{i}(j)} = [];
                    phases{Shanks==neighborShanks{i}(j)} = [];
                end
            else
                neighborAmp2{j} = amp{Shanks==neighborShanks{i}(j)};
                neighborPhase2{j} = phases{Shanks==neighborShanks{i}(j)};
            end
        end
        neighborAmp = mean(cat(3,neighborAmp2{1},neighborAmp2{2}),3);
        Sin = sum(cat(3,sin(neighborPhase2{1}),sin(neighborPhase2{2})),3);
        Cos = sum(cat(3,cos(neighborPhase2{1}),cos(neighborPhase2{2})),3);
        neighborPhases{i} = atan2(Sin, Cos);
        neighborPhases{i} = mod(neighborPhases{i},2*pi);
        clear neighborAmp2 neighborPhase2;
    end
    clear neighborwt;
    [PowerStateIdx{i},PowerIdx{i},StateIdx,AboveInt,BelowInt,AboveInt_all,BelowInt_all] = PowerAndStateLabels(neighborAmp,states,samplingRate,zthreshold,freqlist);
    clear neighborAmp;
end
clear lfp amp phases;

%% Computing spike phases

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

for ii = 1:length(shank)
    cellneighborIdx(ii) = find(GoodUnitShanks==shank(ii));
end

[~,PhstPS] = PhasestatsByPowerAndState...
    (spikes,neighborPhases,cellneighborIdx,PowerStateIdx,PowerIdx,StateIdx,states,freqlist,1:length(freqlist),GoodSleepInterval);
% save(fullfile(basepath,[basename '_SpikePhasesByPowerAndState.mat']),'SpkphasesPS');
save(fullfile(basepath,[basename '_PhasestatsByPowerAndState.mat']),'PhstPS');


%% Jitter spikes

numjitt = 200;
h = waitbar(0,'Please wait');
for ii = 1:length(freqlist)
    jitterwin = 2/freqlist(ii);
    waitbar(ii/length(freqlist));
    for jj = 1:numjitt
        if mod(jj,10) == 1
            display(['Jitter ',num2str(jj),' of ',num2str(numjitt)])
        end
        jitterspikes = JitterSpiketimes(spikes,jitterwin);
        [~,jitterPhasestats] =  PhasestatsByPowerAndState(jitterspikes,neighborPhases,...
            cellneighborIdx,PowerStateIdx,PowerIdx,StateIdx,states,freqlist,ii,GoodSleepInterval); % not saving
        jitterMRL.all(:,ii,jj) = jitterPhasestats.phst.r;
        jitterMRL.H(:,ii,jj) = jitterPhasestats.phstH.r;
        jitterMRL.L(:,ii,jj) = jitterPhasestats.phstL.r;
        jitterMRL.WAKE(:,ii,jj) = jitterPhasestats.WAKEphst.r;
        jitterMRL.WAKEH(:,ii,jj) = jitterPhasestats.WAKEphstH.r;
        jitterMRL.WAKEL(:,ii,jj) = jitterPhasestats.WAKEphstL.r;
        %     if ~isempty(states{2})
        jitterMRL.MA(:,ii,jj) = jitterPhasestats.MAphst.r;
        jitterMRL.MAH(:,ii,jj) = jitterPhasestats.MAphstH.r;
        jitterMRL.MAL(:,ii,jj) = jitterPhasestats.MAphstL.r;
        %     end
        jitterMRL.NREM(:,ii,jj) = jitterPhasestats.NREMphst.r;
        jitterMRL.NREMH(:,ii,jj) = jitterPhasestats.NREMphstH.r;
        jitterMRL.NREML(:,ii,jj) = jitterPhasestats.NREMphstL.r;
        %     if length(states)==5
        jitterMRL.REM(:,ii,jj) = jitterPhasestats.REMphst.r;
        jitterMRL.REMH(:,ii,jj) = jitterPhasestats.REMphstH.r;
        jitterMRL.REML(:,ii,jj) = jitterPhasestats.REMphstL.r;
        %     end
    end
end
close(h);
%%
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
