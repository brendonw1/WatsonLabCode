function ModulationStrengthByFrequency

basepath = cd;
[~,basename] = fileparts(cd);

load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
load(fullfile(basepath,[basename '_SStable.mat']),'shank');
load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp10_EachFreq.mat']),'phasestats','freqlist');
pvalues10 = phasestats.p;
logp10 = log10(pvalues10);
logp10(isinf(logp10)) = -324;
phases(:,:,1) = phasestats.m;
MRL(:,:,1) = phasestats.r; 

load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp57_EachFreq.mat']),'phasestats');
pvalues57 = phasestats.p;
logp57 = log10(pvalues57);
logp57(isinf(logp57)) = -324;
phases(:,:,2) = phasestats.m;
MRL(:,:,2) = phasestats.r; 

load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp54_EachFreq.mat']),'phasestats');
pvalues54 = phasestats.p;
logp54 = log10(pvalues54);
logp54(isinf(logp54)) = -324;
phases(:,:,3) = phasestats.m;
MRL(:,:,3) = phasestats.r; 

load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp55_EachFreq.mat']),'phasestats');
pvalues55 = phasestats.p;
logp55 = log10(pvalues55);
logp55(isinf(logp55)) = -324;
phases(:,:,4) = phasestats.m;
MRL(:,:,4) = phasestats.r; 

load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp19_EachFreq.mat']),'phasestats');
pvalues19 = phasestats.p;
logp19 = log10(pvalues19);
logp19(isinf(logp19)) = -324;
phases(:,:,5) = phasestats.m;
MRL(:,:,5) = phasestats.r; 

load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp27_EachFreq.mat']),'phasestats');
pvalues27 = phasestats.p;
logp27 = log10(pvalues27);
logp27(isinf(logp27)) = -324;
phases(:,:,6) = phasestats.m;
MRL(:,:,6) = phasestats.r; 

% for i = 1:size(pvalues54,1)
%     figure;
%     plot(log10(pvalues54(i,:)),'-o');
% %     legend(['lfp54']);
%     hold on;
%     plot(log10(pvalues55(i,:)),'-o');
% %     legend(['lfp55']);
%     legend(['lfp54';'lfp55']);
% end

%% p-value correction for multiple comparison

pvalues(:,:,1) = pvalues10;
pvalues(:,:,2) = pvalues57;
pvalues(:,:,3) = pvalues54;
pvalues(:,:,4) = pvalues55;
pvalues(:,:,5) = pvalues19;
pvalues(:,:,6) = pvalues27;

p_Bon = pvalues*size(pvalues,1)*size(pvalues,2)*size(pvalues,3);

ModCell = zeros(size(pvalues,1),1);
for i = 1:size(pvalues,1)
    if find(p_Bon(i,:,:)<0.01)
        ModCell(i) = 1;
    end
end

%% plot p values for each cell (x: frequency band; y: p values; colored line for each lfp channel)
figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
for i = 1:length(CellIDs.EAll)
    subplot(6,7,i);
    plot(log10(freqlist),logp10(CellIDs.EAll(i),:));
    hold on;
    plot(log10(freqlist),logp57(CellIDs.EAll(i),:));
    plot(log10(freqlist),logp54(CellIDs.EAll(i),:));
    plot(log10(freqlist),logp55(CellIDs.EAll(i),:));
    plot(log10(freqlist),logp19(CellIDs.EAll(i),:));
    plot(log10(freqlist),logp27(CellIDs.EAll(i),:));
    axis tight;
%     plot(logp10(CellIDs.EAll(i),:),'-o');
%     hold on;
%     plot(logp57(CellIDs.EAll(i),:),'-o');
%     plot(logp54(CellIDs.EAll(i),:),'-o');
%     plot(logp55(CellIDs.EAll(i),:),'-o');
%     plot(logp19(CellIDs.EAll(i),:),'-o');
%     plot(logp27(CellIDs.EAll(i),:),'-o');
    title(['Cell' num2str(CellIDs.EAll(i)) ' (S' num2str(shank(CellIDs.EAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    if i == length(CellIDs.EAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(9,840,'Phase Modulation Strength of ECells','FontSize',18,'FontWeight','bold');


figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
for i = 1:length(CellIDs.IAll)
    subplot(4,4,i);
    plot(log10(freqlist),logp10(CellIDs.IAll(i),:));
    hold on;
    plot(log10(freqlist),logp57(CellIDs.IAll(i),:));
    plot(log10(freqlist),logp54(CellIDs.IAll(i),:));
    plot(log10(freqlist),logp55(CellIDs.IAll(i),:));
    plot(log10(freqlist),logp19(CellIDs.IAll(i),:));
    plot(log10(freqlist),logp27(CellIDs.IAll(i),:));
    axis tight;
    title(['Cell' num2str(CellIDs.IAll(i)) ' (S' num2str(shank(CellIDs.IAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    if i == length(CellIDs.IAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(12,1800,'Phase Modulation Strength of ICells','FontSize',18,'FontWeight','bold');


%% plot mean phases for each cell (x: frequency band; y: mean phases; colored line for each lfp channel)
figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
phasesSig = phases;
phasesSig(p_Bon>0.01) = NaN;
Colors = RainbowColors(size(phases,3));
% phasesNoSig = phases;
% phasesNoSig
for i = 1:length(CellIDs.EAll)
    subplot(6,7,i);
    hold on;
    for j = 1:size(phases,3)
        plot(log10(freqlist),phasesSig(CellIDs.EAll(i),:,j),'Color',Colors(j,:));
        plot(log10(freqlist),phases(CellIDs.EAll(i),:,j),'--','Color',Colors(j,:));
    end
    title(['Cell' num2str(CellIDs.EAll(i)) ' (S' num2str(shank(CellIDs.EAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    ylim([0 2*pi]);
    xlim([0 log10(625)]);
%     axis tight;
    if i == length(CellIDs.EAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(9,840,'Mean Phases of E Cells','FontSize',18,'FontWeight','bold');


figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
for i = 1:length(CellIDs.IAll)
    subplot(4,4,i);
    hold on;
    for j = 1:size(phases,3)
        plot(log10(freqlist),phases(CellIDs.IAll(i),:,j));
    end
    title(['Cell' num2str(CellIDs.IAll(i)) ' (S' num2str(shank(CellIDs.IAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    ylim([0 2*pi]);
    xlim([0 log10(625)]);
%     axis tight;
%     set(gca,'ytick',[1:5],'YTickLabel',{0:pi/2:2*pi},'FontSize',7);
    if i == length(CellIDs.IAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(12,1800,'Mean Phases of I Cells','FontSize',18,'FontWeight','bold');

%% plot mean resultant lengths for each cell (x: frequency band; y: mean phases; colored line for each lfp channel)

figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
for i = 1:length(CellIDs.EAll)
    subplot(6,7,i);
    hold on;
    for j = 1:size(MRL,3)
        plot(log10(freqlist),MRL(CellIDs.EAll(i),:,j));
    end
    title(['Cell' num2str(CellIDs.EAll(i)) ' (S' num2str(shank(CellIDs.EAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    ylim([0 2*pi]);
    axis tight;
    if i == length(CellIDs.EAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(9,840,'Mean Resultant Length of E Cells','FontSize',18,'FontWeight','bold');


figure; 
fig = gcf;
fig.Position = [1 1 1280 920];
for i = 1:length(CellIDs.IAll)
    subplot(4,4,i);
    hold on;
    for j = 1:size(MRL,3)
        plot(log10(freqlist),MRL(CellIDs.IAll(i),:,j));
    end
    title(['Cell' num2str(CellIDs.IAll(i)) ' (S' num2str(shank(CellIDs.IAll(i))) ')']);
%     set(gca,'xtick',[1:9],'XTickLabel',{40:20:200},'FontSize',7,'XTickLabelRotation',45);
    ylim([0 2*pi]);
    axis tight;
%     set(gca,'ytick',[1:5],'YTickLabel',{0:pi/2:2*pi},'FontSize',7);
    if i == length(CellIDs.IAll)
    legend(['lfp10 (S1)';'lfp57 (S2)';'lfp54 (S3)';'lfp55 (S4)';'lfp19 (S5)';'lfp27 (S6)']);
    end
end
text(12,1800,'Mean Resultant Length of I Cells','FontSize',18,'FontWeight','bold');


%% shank distance effect
logp{1} = logp10;
logp{2} = logp57;
logp{3} = logp54;
logp{4} = logp55;
logp{5} = logp19;
logp{6} = logp27;

minus2 = NaN(length(shank),9);
minus1 = NaN(length(shank),9);
plus0 = NaN(length(shank),9);
plus1 = NaN(length(shank),9);
plus2 = NaN(length(shank),9);

for i = 1:9
    for j = 1:length(shank)
        if shank(j)-2>0
            minus2(j,i) = logp{shank(j)-2}(j,i);
        end
        if shank(j)-1>0
            minus1(j,i) = logp{shank(j)-1}(j,i);
        end
        plus0(j,i) = logp{shank(j)}(j,i);
        if shank(j)+1<7
            plus1(j,i) = logp{shank(j)+1}(j,i);
        end
        if shank(j)+2<7
            plus2(j,i) = logp{shank(j)+2}(j,i);
        end
    end
end
% compare local and cross shank modulation in each frequency band
meansband = [mean(minus2,'omitnan');mean(minus1,'omitnan');mean(plus0,'omitnan');mean(plus1,'omitnan');mean(plus2,'omitnan')];
stdsband = [std(minus2,'omitnan');std(minus1,'omitnan');std(plus0,'omitnan');std(plus1,'omitnan');std(plus2,'omitnan')];
figure;
for i = 1:9
    subplot(3,3,i)
    errorbar(-2:2,meansband(:,i),stdsband(:,i));
    title([num2str(i*20+10) ' to ' num2str(i*20+30) ' Hz']);
    axis tight;
    xlabel('distance (#shanks)');
    ylabel('log p value');
end

% compare local and cross shank modulation in each cell
meanscell = [mean(minus2,2,'omitnan') mean(minus1,2,'omitnan') mean(plus0,2,'omitnan') mean(plus1,2,'omitnan') mean(plus2,2,'omitnan')];
stdscell = [std(minus2,0,2,'omitnan') std(minus1,0,2,'omitnan') std(plus0,0,2,'omitnan') std(plus1,0,2,'omitnan') std(plus2,0,2,'omitnan')];
figure;
for j = 1:50
    subplot(8,7,j)
    errorbar(-2:2,meanscell(j,:),stdscell(j,:)');
    title(['Cell ' num2str(j)]);
    axis tight;
    xlabel('distance (#shanks)');
    ylabel('log p value');
end

%% plot general changing trend of p values for E and I cells
% use p values for 30 to 200 Hz broad band
% load(fullfile(basepath,[basename '_lfp10PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,1) = PhaseLockingData.phasestats.p;
% load(fullfile(basepath,[basename '_lfp57PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,2) = PhaseLockingData.phasestats.p;
% load(fullfile(basepath,[basename '_lfp54PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,3) = PhaseLockingData.phasestats.p;
% load(fullfile(basepath,[basename '_lfp55PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,4) = PhaseLockingData.phasestats.p;
% load(fullfile(basepath,[basename '_lfp19PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,5) = PhaseLockingData.phasestats.p;
% load(fullfile(basepath,[basename '_lfp27PhaseLockingData30-200Hz.mat']),'PhaseLockingData');
% pvalues_broad(:,6) = PhaseLockingData.phasestats.p;
% logp_broad = log10(pvalues_broad);
% logp_broad(isinf(logp_broad)) = -324;

% meansE_broad = mean(mean(logp_broad(CellIDs.EAll,:)));
% meansI_broad = mean(mean(logp_broad(CellIDs.IAll,:)));

logps(:,:,1) = logp10; % 3 dim. 1 cellID; 2 frequency band; 3 lfp channel
logps(:,:,2) = logp57;
logps(:,:,3) = logp54;
logps(:,:,4) = logp55;
logps(:,:,5) = logp19;
logps(:,:,6) = logp27;

for i = 1:size(logps)
    logpsNoLocalLFP(i,:,:) = logps(i,:,setdiff(1:6,shank(i)));
end

meansEAllLFP = mean(logps(CellIDs.EAll,:,:),3);
meansIAllLFP = mean(logps(CellIDs.IAll,:,:),3);
meansEAllLFPAllCell = mean(meansEAllLFP);
meansIAllLFPAllCell = mean(meansIAllLFP);

meansENoLocalLFP = mean(logpsNoLocalLFP(CellIDs.EAll,:,:),3);
meansINoLocalLFP = mean(logpsNoLocalLFP(CellIDs.IAll,:,:),3);
meansENoLocalLFPAllCell = mean(meansENoLocalLFP);
meansINoLocalLFPAllCell = mean(meansINoLocalLFP);

figure;
subplot(3,2,1)
errorbar(40:20:200,meansEAllLFPAllCell,std(meansEAllLFP));
hold on;
errorbar(40:20:200,meansENoLocalLFPAllCell,std(meansENoLocalLFP));
ylabel('mean log p-values');
legend(['All LFPs    ';'No local LFP']);
title('E Cells');

subplot(3,2,2)
errorbar(40:20:200,meansIAllLFPAllCell,std(meansIAllLFP));
hold on;
errorbar(40:20:200,meansINoLocalLFPAllCell,std(meansINoLocalLFP));
ylabel('mean log p-values');
legend(['All LFPs    ';'No local LFP']);
title('I Cells');


% subplot(3,2,3)
% 
% ylabel('mean log p-values');
% subplot(3,2,4)
% 
% ylabel('mean log p-values');
end