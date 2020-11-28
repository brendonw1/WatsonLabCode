function FSTKetamineVsSaline(KetamineGroup,Date)
basepath = cd;
[~,basename,~] = fileparts(cd);

SalineGroup = setdiff(1:8,KetamineGroup);

load('FSTData.mat');
KetamineData = [];
SalineData = [];

KetamineData(end+1:end+length(KetamineGroup),1:3) = FSTData(KetamineGroup,Date,:).*5; % 5 seconds per chunk
SalineData(end+1:end+length(SalineGroup),1:3) = FSTData(SalineGroup,Date,:).*5;

MeanKetamine = mean(KetamineData);
MeanSaline = mean(SalineData);
Mean = [MeanKetamine' MeanSaline'];

StdKetamine = std(KetamineData);
StdSaline = std(SalineData);
Std = [StdKetamine' StdSaline'];

figure;
h = bar(Mean);
set(h,'BarWidth',1);   
set(gca,'xtick',[1:3],'XTickLabel',{'Immobile','Swimming','Climbing'})
lh = legend('Ketamine','Saline');
set(lh,'Location','BestOutside','Orientation','horizontal')
hold on;
numgroups = size(Mean, 1); 
numbars = size(Mean, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, Mean(:,i), Std(:,i), 'k', 'linestyle', 'none');
end

savefig(fullfile(basepath,[basename '_KetamineVsSalinePlot']));
print(fullfile(basepath,[basename '_KetamineVsSalinePlot']),'-dpng','-r0');
end

