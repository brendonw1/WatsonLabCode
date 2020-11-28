function PhaseModulationUsingNeighboringShanks
basepath = cd;
[~,basename] = fileparts(cd);

zthreshold = 0.5;
if exist(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Shanks','Channels');
end
LfpShanks = Shanks;

load(fullfile(basepath,[basename '_SStable.mat']),'shank','cellIx','S_CellFormat');
load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp' num2str(Channels(1)) '_EachFreq.mat']),'freqlist');

GoodUnitShanks = unique(shank);
neighborID = [];

for i = 1:length(LfpShanks)
    load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp' num2str(Channels(i)) '_EachFreq.mat']),'phasestats');
    AllPhasestats{i} = phasestats;
    AllPhasestats{i}.logp = log10(AllPhasestats{i}.p);
    AllPhasestats{i}.logp(isinf(AllPhasestats{i}.logp)) = -324;
end
% load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_zthresh' num2str(zthreshold) '.mat']),'phasestats');
% AllPhasestats = phasestats;
for i = 1:length(LfpShanks)
    AllPhasestats{i}.logp = log10(AllPhasestats{i}.p);
    AllPhasestats{i}.logp(isinf(AllPhasestats{i}.logp)) = -324; 
end

for i = 1:length(GoodUnitShanks)
    if ismember(GoodUnitShanks(i)-1,LfpShanks)
        neighborID(i,1) = GoodUnitShanks(i)-1;
    else
        neighborID(i,1) = NaN;
    end
    if ismember(GoodUnitShanks(i)+1,LfpShanks)
        neighborID(i,2) = GoodUnitShanks(i)+1;
    else
        neighborID(i,2) = NaN;
    end
end

for i = 1:length(GoodUnitShanks)
    Idx = find(shank==GoodUnitShanks(i));
    if isnan(neighborID(i,1)) && isnan(neighborID(i,2))
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                NeighborPhasestats.m(Idx(j),1:length(freqlist)) = [];
                NeighborPhasestats.r(Idx(j),1:length(freqlist)) = [];
                NeighborPhasestats.k(Idx(j),1:length(freqlist)) = [];
                NeighborPhasestats.p(Idx(j),1:length(freqlist)) = [];
                NeighborPhasestats.logp(Idx(j),1:length(freqlist)) = [];
                NeighborPhasestats.mode(Idx(j),1:length(freqlist)) = [];
            end
        end
    elseif isnan(neighborID(i,1)) || isnan(neighborID(i,2))
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                NeighborPhasestats.m(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.m(Idx(j),k);
                NeighborPhasestats.r(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.r(Idx(j),k);
                NeighborPhasestats.k(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.k(Idx(j),k);
                NeighborPhasestats.p(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.p(Idx(j),k);
                NeighborPhasestats.logp(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.logp(Idx(j),k);
                NeighborPhasestats.mode(Idx(j),k) = AllPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.mode(Idx(j),k);
            end
        end
    else
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                NeighborPhasestats.m(Idx(j),k) = CircularMean([AllPhasestats{neighborID(i,1)}.m(Idx(j),k);...
                    AllPhasestats{neighborID(i,2)}.m(Idx(j),k)]);
                NeighborPhasestats.r(Idx(j),k) = mean([AllPhasestats{neighborID(i,1)}.r(Idx(j),k),...
                    AllPhasestats{neighborID(i,2)}.r(Idx(j),k)]);
                NeighborPhasestats.k(Idx(j),k) = mean([AllPhasestats{neighborID(i,1)}.k(Idx(j),k),...
                    AllPhasestats{neighborID(i,2)}.k(Idx(j),k)]);
                NeighborPhasestats.p(Idx(j),k) = mean([AllPhasestats{neighborID(i,1)}.p(Idx(j),k),...
                    AllPhasestats{neighborID(i,2)}.p(Idx(j),k)]);
                NeighborPhasestats.logp(Idx(j),k) = mean([AllPhasestats{neighborID(i,1)}.logp(Idx(j),k),...
                    AllPhasestats{neighborID(i,2)}.logp(Idx(j),k)]); % how to calculate mean p-values
                NeighborPhasestats.mode(Idx(j),k) = CircularMean([AllPhasestats{neighborID(i,1)}.mode(Idx(j),k);...
                    AllPhasestats{neighborID(i,2)}.mode(Idx(j),k)]); % not perfect, maybe need to compare two distributions
            end
        end
    end
end

%% find cells having higher MRL at gamma frequency band (30-200Hz)
% HighMRLIdx = NeighborPhasestats.r>0.08;
FreqIdx = 27:59;
HighMRLCellIdx = zeros(length(cellIx),1);
for a = 1:length(cellIx)
    if ~isempty(find(NeighborPhasestats.r(a,FreqIdx)>0.08))
        HighMRLCellIdx(a) = 1;
    end
end
HighMRLCellIdx = logical(HighMRLCellIdx);

%%
load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_zthresh' num2str(zthreshold) '_low.mat']),'phasestats');
LowPhasestats = phasestats;
for i = 1:length(LfpShanks)
    LowPhasestats{i}.logp = log10(LowPhasestats{i}.p);
    LowPhasestats{i}.logp(isinf(LowPhasestats{i}.logp)) = -324; 
end


for i = 1:length(GoodUnitShanks)
    Idx = find(shank==GoodUnitShanks(i));
    if isnan(neighborID(i,1)) && isnan(neighborID(i,2))
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                LowNeighborPhasestats.m(Idx(j),1:length(freqlist)) = [];
                LowNeighborPhasestats.r(Idx(j),1:length(freqlist)) = [];
                LowNeighborPhasestats.k(Idx(j),1:length(freqlist)) = [];
                LowNeighborPhasestats.p(Idx(j),1:length(freqlist)) = [];
                LowNeighborPhasestats.logp(Idx(j),1:length(freqlist)) = [];
                LowNeighborPhasestats.mode(Idx(j),1:length(freqlist)) = [];
            end
        end
    elseif isnan(neighborID(i,1)) || isnan(neighborID(i,2))
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                LowNeighborPhasestats.m(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.m(Idx(j),k);
                LowNeighborPhasestats.r(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.r(Idx(j),k);
                LowNeighborPhasestats.k(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.k(Idx(j),k);
                LowNeighborPhasestats.p(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.p(Idx(j),k);
                LowNeighborPhasestats.logp(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.logp(Idx(j),k);
                LowNeighborPhasestats.mode(Idx(j),k) = LowPhasestats{neighborID(i,~isnan(neighborID(i,:)))}.mode(Idx(j),k);
            end
        end
    else
        for j = 1:length(Idx)
            for k = 1:length(freqlist)
                LowNeighborPhasestats.m(Idx(j),k) = CircularMean([LowPhasestats{neighborID(i,1)}.m(Idx(j),k);...
                    LowPhasestats{neighborID(i,2)}.m(Idx(j),k)]);
                LowNeighborPhasestats.r(Idx(j),k) = mean([LowPhasestats{neighborID(i,1)}.r(Idx(j),k),...
                    LowPhasestats{neighborID(i,2)}.r(Idx(j),k)]);
                LowNeighborPhasestats.k(Idx(j),k) = mean([LowPhasestats{neighborID(i,1)}.k(Idx(j),k),...
                    LowPhasestats{neighborID(i,2)}.k(Idx(j),k)]);
                LowNeighborPhasestats.p(Idx(j),k) = mean([LowPhasestats{neighborID(i,1)}.p(Idx(j),k),...
                    LowPhasestats{neighborID(i,2)}.p(Idx(j),k)]);
                LowNeighborPhasestats.logp(Idx(j),k) = mean([LowPhasestats{neighborID(i,1)}.logp(Idx(j),k),...
                    LowPhasestats{neighborID(i,2)}.logp(Idx(j),k)]); % how to calculate mean p-values
                LowNeighborPhasestats.mode(Idx(j),k) = CircularMean([LowPhasestats{neighborID(i,1)}.mode(Idx(j),k);...
                    LowPhasestats{neighborID(i,2)}.mode(Idx(j),k)]); % not perfect, maybe need to compare two distributions
            end
        end
    end
end

%% plot
% figure;
% subplot(5,2,1);
% plot(log10(freqlist),mean(NeighborPhasestats.m(CellIDs.EAll,:)));
% title('Mean Angle E Cells');
%
% subplot(5,2,2);
% plot(log10(freqlist),mean(NeighborPhasestats.m(CellIDs.IAll,:)));
% title('Mean Angle I Cells');
%
% subplot(5,2,3);
% plot(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.EAll,:)));
% title('Mean Resultant Length E Cells');
%
% subplot(5,2,4);
% plot(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.IAll,:)));
% title('Mean Resultant Length I Cells');
%
% subplot(5,2,5);
% plot(log10(freqlist),mean(NeighborPhasestats.k(CellIDs.EAll,:)));
% title('Concentration E Cells');
%
% subplot(5,2,6);
% plot(log10(freqlist),mean(NeighborPhasestats.k(CellIDs.IAll,:)));
% title('Concentration I Cells');
%
% subplot(5,2,7);
% plot(log10(freqlist),log(mean(NeighborPhasestats.p(CellIDs.EAll,:))));
% title('p values E Cells');
%
% subplot(5,2,8);
% plot(log10(freqlist),log(mean(NeighborPhasestats.p(CellIDs.IAll,:))));
% title('p values I Cells');
%
% subplot(5,2,9);
% plot(log10(freqlist),mean(NeighborPhasestats.mode(CellIDs.EAll,:)));
% title('Mode E Cells');
%
% subplot(5,2,10);
% plot(log10(freqlist),mean(NeighborPhasestats.mode(CellIDs.IAll,:)));
% title('Mode I Cells');



% figure;
% subplot(5,2,1);
% boundedline(log10(freqlist),mean(NeighborPhasestats.m(CellIDs.EAll,:)),std(NeighborPhasestats.m(CellIDs.EAll,:)));
% title('Mean Angle E Cells');
%
% subplot(5,2,2);
% boundedline(log10(freqlist),mean(NeighborPhasestats.m(CellIDs.IAll,:)),std(NeighborPhasestats.m(CellIDs.IAll,:)));
% title('Mean Angle I Cells');
%
% subplot(5,2,3);
% boundedline(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.EAll,:)),std(NeighborPhasestats.r(CellIDs.EAll,:)));
% title('Mean Resultant Length E Cells');
%
% subplot(5,2,4);
% boundedline(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.IAll,:)),std(NeighborPhasestats.r(CellIDs.IAll,:)));
% title('Mean Resultant Length I Cells');
%
% subplot(5,2,5);
% boundedline(log10(freqlist),mean(NeighborPhasestats.k(CellIDs.EAll,:)),std(NeighborPhasestats.k(CellIDs.EAll,:)));
% title('Concentration E Cells');
%
% subplot(5,2,6);
% boundedline(log10(freqlist),mean(NeighborPhasestats.k(CellIDs.IAll,:)),std(NeighborPhasestats.k(CellIDs.IAll,:)));
% title('Concentration I Cells');
%
% subplot(5,2,7);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.EAll,:))),log10(std(NeighborPhasestats.p(CellIDs.EAll,:))));
% title('p values E Cells');
%
% subplot(5,2,8);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.IAll,:))),log10(std(NeighborPhasestats.p(CellIDs.IAll,:))));
% title('p values I Cells');
%
% subplot(5,2,9);
% boundedline(log10(freqlist),mean(NeighborPhasestats.mode(CellIDs.EAll,:)),std(NeighborPhasestats.mode(CellIDs.EAll,:)));
% title('Mode E Cells');
%
% subplot(5,2,10);
% boundedline(log10(freqlist),mean(NeighborPhasestats.mode(CellIDs.IAll,:)),std(NeighborPhasestats.mode(CellIDs.IAll,:)));
% title('Mode I Cells');


% figure;
% fig = gcf;
% fig.Position = [1 1 1280 920];
% xt = [1 2 4 6 8 10 20 40 60 80 100 200 400 600 800 1000];
% subplot(2,2,1);
% [meanEm,~,~,~,~,stdEm] = CircularMean(NeighborPhasestats.m(CellIDs.EAll,:));
% [meanIm,~,~,~,~,stdIm] = CircularMean(NeighborPhasestats.m(CellIDs.IAll,:));
% boundedline(log10(freqlist),meanEm,stdEm,'b',...
%     log10(freqlist),meanIm,stdIm,'r','alpha');
% title('Mean Angles');
% legend(['E Cells';'I Cells']);
% set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
% 
% subplot(2,2,2);
% boundedline(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.EAll,:)),std(NeighborPhasestats.r(CellIDs.EAll,:)),'b',...
%     log10(freqlist),mean(NeighborPhasestats.r(CellIDs.IAll,:)),std(NeighborPhasestats.r(CellIDs.IAll,:)),'r','alpha');
% title('Mean Resultant Lengths');
% legend(['E Cells';'I Cells']);
% set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
% 
% % subplot(3,2,3);
% % boundedline(log10(freqlist),mean(NeighborPhasestats.k(CellIDs.EAll,:)),std(NeighborPhasestats.k(CellIDs.EAll,:)),'b',...
% %     log10(freqlist),mean(NeighborPhasestats.k(CellIDs.IAll,:)),std(NeighborPhasestats.k(CellIDs.IAll,:)),'r','alpha');
% % title('Concentration');
% % legend(['E Cells';'I Cells']);
% 
% subplot(2,2,3);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.EAll,:))),log10(std(NeighborPhasestats.p(CellIDs.EAll,:))),'b',...
%     log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.IAll,:))),log10(std(NeighborPhasestats.p(CellIDs.IAll,:))),'r','alpha');
% title('p values');
% legend(['E Cells';'I Cells']);
% set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
% 
% subplot(2,2,4);
% [meanEmode,~,~,~,~,stdEmode] = CircularMean(NeighborPhasestats.mode(CellIDs.EAll,:));
% [meanImode,~,~,~,~,stdImode] = CircularMean(NeighborPhasestats.mode(CellIDs.IAll,:));
% boundedline(log10(freqlist),meanEmode,stdEmode,'b',...
%     log10(freqlist),meanImode,stdImode,'r','alpha');
% title('Mode');
% legend(['E Cells';'I Cells']);
% set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
% suptitle('z-score threshold: 0 (lower part)');
% print(fullfile(basepath,[basename '_PhaseLockingFig'],['General_1-625Hz_zthreshold0_low']),'-dpng','-r0');



%% plot high power and low power/unstable together

figure;
fig = gcf;
fig.Position = [1 1 1280 920];
xt = [1 2 4 6 8 10 20 40 60 80 100 200 400 600 800 1000];
subplot(2,2,1);
[meanEm,~,~,~,~,stdEm] = CircularMean(NeighborPhasestats.m(CellIDs.EAll,:));
[meanIm,~,~,~,~,stdIm] = CircularMean(NeighborPhasestats.m(CellIDs.IAll,:));
[meanEmlow,~,~,~,~,stdEmlow] = CircularMean(LowNeighborPhasestats.m(CellIDs.EAll,:));
[meanImlow,~,~,~,~,stdImlow] = CircularMean(LowNeighborPhasestats.m(CellIDs.IAll,:));
boundedline(log10(freqlist),meanEm,stdEm,log10(freqlist),meanIm,stdIm,...
    log10(freqlist),meanEmlow,stdEmlow,log10(freqlist),meanImlow,stdImlow,'cmap',RainbowColors(4),'alpha');
title('Mean Angles');
legend(['E Cells (high)';'I Cells (high)';'E Cells (low) ';'I Cells (low) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,2);
boundedline(log10(freqlist),mean(NeighborPhasestats.r(CellIDs.EAll,:)),std(NeighborPhasestats.r(CellIDs.EAll,:)),...
    log10(freqlist),mean(NeighborPhasestats.r(CellIDs.IAll,:)),std(NeighborPhasestats.r(CellIDs.IAll,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.r(CellIDs.EAll,:)),std(LowNeighborPhasestats.r(CellIDs.EAll,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.r(CellIDs.IAll,:)),std(LowNeighborPhasestats.r(CellIDs.IAll,:)),...
    'cmap',RainbowColors(4),'alpha');
title('Mean Resultant Lengths');
legend(['E Cells (high)';'I Cells (high)';'E Cells (low) ';'I Cells (low) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,3);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.EAll,:))),log10(std(NeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.IAll,:))),log10(std(NeighborPhasestats.p(CellIDs.IAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.EAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.IAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.IAll,:))),...
%     'cmap',RainbowColors(4),'alpha');
boundedline(log10(freqlist),mean(NeighborPhasestats.logp(CellIDs.EAll,:)),std(NeighborPhasestats.logp(CellIDs.EAll,:)),...
    log10(freqlist),mean(NeighborPhasestats.logp(CellIDs.IAll,:)),std(NeighborPhasestats.logp(CellIDs.IAll,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.logp(CellIDs.EAll,:)),std(LowNeighborPhasestats.logp(CellIDs.EAll,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.logp(CellIDs.IAll,:)),std(LowNeighborPhasestats.logp(CellIDs.IAll,:)),...
    'cmap',RainbowColors(4),'alpha');
title('p values');
legend(['E Cells (high)';'I Cells (high)';'E Cells (low) ';'I Cells (low) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,4);
[meanEmode,~,~,~,~,stdEmode] = CircularMean(NeighborPhasestats.mode(CellIDs.EAll,:));
[meanImode,~,~,~,~,stdImode] = CircularMean(NeighborPhasestats.mode(CellIDs.IAll,:));
[meanEmodelow,~,~,~,~,stdEmodelow] = CircularMean(LowNeighborPhasestats.mode(CellIDs.EAll,:));
[meanImodelow,~,~,~,~,stdImodelow] = CircularMean(LowNeighborPhasestats.mode(CellIDs.IAll,:));
boundedline(log10(freqlist),meanEmode,stdEmode,log10(freqlist),meanImode,stdImode,...
    log10(freqlist),meanEmodelow,stdEmodelow,log10(freqlist),meanImodelow,stdImodelow,'cmap',RainbowColors(4),'alpha');
title('Mode');
legend(['E Cells (high)';'I Cells (high)';'E Cells (low) ';'I Cells (low) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
suptitle(['z-score threshold: ' num2str(zthreshold) ' (all)']);
print(fullfile(basepath,[basename '_PhaseLockingFig'],['General_1-625Hz_zthreshold' num2str(zthreshold) '_all.png']),'-dpng','-r0');



%% plot p-values for each cell 
figure;
fig = gcf;
fig.Position = [1 1 1280 920];
xt = [1 2 4 6 8 10 20 40 60 80 100 200 400 600 800 1000];
for i = 1:length(CellIDs.EAll)
    subplot(6,7,i);
    plot(log10(freqlist),NeighborPhasestats.r(CellIDs.IAll(i),:));
    hold on;
    plot(log10(freqlist),LowNeighborPhasestats.r(CellIDs.IAll(i),:));
end
legend(['High power';'Low power ']);





%% plot high power and low power/unstable together seperated by MRL

figure;
fig = gcf;
fig.Position = [1 1 1280 920];
xt = [1 2 4 6 8 10 20 40 60 80 100 200 400 600 800 1000];
subplot(2,2,1);
[meanHMm,~,~,~,~,stdHMm] = CircularMean(NeighborPhasestats.m(HighMRLCellIdx,:));
[meanLMm,~,~,~,~,stdLMm] = CircularMean(NeighborPhasestats.m(~HighMRLCellIdx,:));
[meanHMmlow,~,~,~,~,stdHMmlow] = CircularMean(LowNeighborPhasestats.m(HighMRLCellIdx,:));
[meanLMmlow,~,~,~,~,stdLMmlow] = CircularMean(LowNeighborPhasestats.m(~HighMRLCellIdx,:));
boundedline(log10(freqlist),meanHMm,stdHMm,log10(freqlist),meanLMm,stdLMm,...
    log10(freqlist),meanHMmlow,stdHMmlow,log10(freqlist),meanLMmlow,stdLMmlow,'cmap',RainbowColors(4),'alpha');
title('Mean Angles');
legend(['High MRL (high power)';'Low MRL  (high power)';'High MRL (low power) ';'Low MRL  (low power) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,2);
boundedline(log10(freqlist),mean(NeighborPhasestats.r(HighMRLCellIdx,:)),std(NeighborPhasestats.r(HighMRLCellIdx,:)),...
    log10(freqlist),mean(NeighborPhasestats.r(~HighMRLCellIdx,:)),std(NeighborPhasestats.r(~HighMRLCellIdx,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.r(HighMRLCellIdx,:)),std(LowNeighborPhasestats.r(HighMRLCellIdx,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.r(~HighMRLCellIdx,:)),std(LowNeighborPhasestats.r(~HighMRLCellIdx,:)),...
    'cmap',RainbowColors(4),'alpha');
title('Mean Resultant Lengths');
legend(['High MRL (high power)';'Low MRL  (high power)';'High MRL (low power) ';'Low MRL  (low power) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,3);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.EAll,:))),log10(std(NeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.IAll,:))),log10(std(NeighborPhasestats.p(CellIDs.IAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.EAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.IAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.IAll,:))),...
%     'cmap',RainbowColors(4),'alpha');
boundedline(log10(freqlist),mean(NeighborPhasestats.logp(HighMRLCellIdx,:)),std(NeighborPhasestats.logp(HighMRLCellIdx,:)),...
    log10(freqlist),mean(NeighborPhasestats.logp(~HighMRLCellIdx,:)),std(NeighborPhasestats.logp(~HighMRLCellIdx,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.logp(HighMRLCellIdx,:)),std(LowNeighborPhasestats.logp(HighMRLCellIdx,:)),...
    log10(freqlist),mean(LowNeighborPhasestats.logp(~HighMRLCellIdx,:)),std(LowNeighborPhasestats.logp(~HighMRLCellIdx,:)),...
    'cmap',RainbowColors(4),'alpha');
title('p values');
legend(['High MRL (high power)';'Low MRL  (high power)';'High MRL (low power) ';'Low MRL  (low power) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,4);
[meanHMmode,~,~,~,~,stdHMmode] = CircularMean(NeighborPhasestats.mode(HighMRLCellIdx,:));
[meanLMmode,~,~,~,~,stdLMmode] = CircularMean(NeighborPhasestats.mode(~HighMRLCellIdx,:));
[meanHMmodelow,~,~,~,~,stdHMmodelow] = CircularMean(LowNeighborPhasestats.mode(HighMRLCellIdx,:));
[meanLMmodelow,~,~,~,~,stdLMmodelow] = CircularMean(LowNeighborPhasestats.mode(~HighMRLCellIdx,:));
boundedline(log10(freqlist),meanHMmode,stdHMmode,log10(freqlist),meanLMmode,stdLMmode,...
    log10(freqlist),meanHMmodelow,stdHMmodelow,log10(freqlist),meanLMmodelow,stdLMmodelow,'cmap',RainbowColors(4),'alpha');
title('Mode');
legend(['High MRL (high power)';'Low MRL  (high power)';'High MRL (low power) ';'Low MRL  (low power) ']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
suptitle(['z-score threshold: ' num2str(zthreshold) ' (all)']);
print(fullfile(basepath,[basename '_PhaseLockingFig'],['General_1-625Hz_zthreshold' num2str(zthreshold) '_all.png']),'-dpng','-r0');
end
