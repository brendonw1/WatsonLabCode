function PlotPhasestats(phasestats,freqlist,figtitle)
basepath = cd;
[~,basename] = fileparts(cd);

load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
figure;
fig = gcf;
fig.Position = [1 1 1280 920];
xt = [1 2 4 6 8 10 20 40 60 80 100 200 400 600 800 1000];
subplot(2,2,1);
[meanEm,~,~,~,~,stdEm] = CircularMean(phasestats.m(CellIDs.EAll,:));
[meanIm,~,~,~,~,stdIm] = CircularMean(phasestats.m(CellIDs.IAll,:));
boundedline(log10(freqlist),meanEm,stdEm,'r',log10(freqlist),meanIm,stdIm,'b','alpha');
title('Mean Angles');
legend(['E Cells';'I Cells']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,2);
boundedline(log10(freqlist),mean(phasestats.r(CellIDs.EAll,:)),std(phasestats.r(CellIDs.EAll,:)),'r',...
    log10(freqlist),mean(phasestats.r(CellIDs.IAll,:)),std(phasestats.r(CellIDs.IAll,:)),'b','alpha');
title('Mean Resultant Lengths');
legend(['E Cells';'I Cells']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,3);
% boundedline(log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.EAll,:))),log10(std(NeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(NeighborPhasestats.p(CellIDs.IAll,:))),log10(std(NeighborPhasestats.p(CellIDs.IAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.EAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.EAll,:))),...
%     log10(freqlist),log10(mean(LowNeighborPhasestats.p(CellIDs.IAll,:))),log10(std(LowNeighborPhasestats.p(CellIDs.IAll,:))),...
%     'cmap',RainbowColors(4),'alpha');
boundedline(log10(freqlist),log10(mean(phasestats.p(CellIDs.EAll,:))),log10(std(phasestats.p(CellIDs.EAll,:))),'r',...
    log10(freqlist),log10(mean(phasestats.p(CellIDs.IAll,:))),log10(std(phasestats.p(CellIDs.IAll,:))),'b','alpha');
title('p values');
legend(['E Cells';'I Cells']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);

subplot(2,2,4);
[meanEmode,~,~,~,~,stdEmode] = CircularMean(phasestats.mode(CellIDs.EAll,:));
[meanImode,~,~,~,~,stdImode] = CircularMean(phasestats.mode(CellIDs.IAll,:));
boundedline(log10(freqlist),meanEmode,stdEmode,'r',log10(freqlist),meanImode,stdImode,'b','alpha');
title('Mode');
legend(['E Cells';'I Cells']);
set(gca,'XTick',log10(xt),'XTickLabel',xt,'XTickLabelRotation',45);
suptitle(figtitle);
print(fullfile(basepath,[basename '_PhaseLockingFig'],[figtitle '.png']),'-dpng','-r0');
end
