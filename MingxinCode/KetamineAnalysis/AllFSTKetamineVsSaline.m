function AllFSTKetamineVsSaline
writepath = '/balrog_zpool/AllFST';
ds = GetFSTGroupsSessionMatrix;

KetamineData = [];
SalineData = [];

for i = 1:length(ds)
    if strcmp(char(ds(i).InjectionType),'Ketamine') && ds(i).Date~=170202
        KetamineData(end+1,1:3) = [ds(i).Immobile_s_ ds(i).Swimming_s_ ds(i).Climbing_s_];
    elseif strcmp(char(ds(i).InjectionType),'Saline')
        SalineData(end+1,1:3) = [ds(i).Immobile_s_ ds(i).Swimming_s_ ds(i).Climbing_s_];
    end
end

MeanKetamine = mean(KetamineData);
MeanSaline = mean(SalineData);
Mean = [MeanSaline' MeanKetamine'];

StdKetamine = std(KetamineData);
StdSaline = std(SalineData);
Std = [StdSaline' StdKetamine'];

figure;
h = bar(Mean);
set(h,'BarWidth',1);   
set(gca,'xtick',[1:3],'XTickLabel',{'Immobile','Swimming','Climbing'})
ylabel('Time (s)')
lh = legend(['Saline (' num2str(length(KetamineData)) ')'],['Ketamine (' num2str(length(SalineData)) ')']);
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

savefig('/balrog_zpool/AllFST/AllFSTKetamineVsSalinePlot.fig');
print(fullfile(writepath,'AllFSTKetamineVsSalinePlot'),'-dpng','-r0');
end