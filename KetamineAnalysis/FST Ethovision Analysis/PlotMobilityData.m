load('MobilitiesMins2to6')

stressnames = {'nostress','mildstress','ucsstress'};
dosenames = {'veh','ket10','ket30'};

stressgroups = [];
dosegroups = [];
sums = [];
means = [];
medians = [];
vars = [];
stds = [];
for sn = 1:length(stressnames)
    for dn = 1:length(dosenames)        
        eval(['temp = MobilitiesMins2to6.' stressnames{sn} '.' dosenames{dn} ';'])
        
        dosegroups = cat(1,dosegroups,dn*ones(size(temp,2),1));
        stressgroups = cat(1,stressgroups,sn*ones(size(temp,2),1));
        
        sums = cat(1,sums,nansum(temp,1)');
        means = cat(1,means,nanmean(temp,1)');
        medians = cat(1,medians,nanmedian(temp,1)');
        vars = cat(1,vars,nanvar(temp,1)');
        stds = cat(1,stds,nanstd(temp,1)');
        
    end
    
end

%% Sums
plot_meanSD_bars(...
    nansum(MobilitiesMins2to6.nostress.veh,1),nansum(MobilitiesMins2to6.nostress.ket10,1),nansum(MobilitiesMins2to6.nostress.ket30,1),...
    nansum(MobilitiesMins2to6.mildstress.veh,1),nansum(MobilitiesMins2to6.mildstress.ket10,1),nansum(MobilitiesMins2to6.mildstress.ket30,1),...
    nansum(MobilitiesMins2to6.ucsstress.veh,1),nansum(MobilitiesMins2to6.ucsstress.ket10,1),nansum(MobilitiesMins2to6.ucsstress.ket30,1)...
    );
set(gcf,'name','RawMobilitySums-BarPlots')

[p,tbl,stats] = anovan(sums,{dosegroups,stressgroups},'model','interaction','varnames',{'dose','stress'});
set(gcf,'name','RawMobilitySums-AnovaTable')
figure
results = multcompare(stats,'Dimension',[1 2]);
set(gcf,'name','RawMobilitySums-MultiCompare')

%% Medians
figure;
plot_meanSD_bars(...
    nanmedian(MobilitiesMins2to6.nostress.veh,1),nanmedian(MobilitiesMins2to6.nostress.ket10,1),nanmedian(MobilitiesMins2to6.nostress.ket30,1),...
    nanmedian(MobilitiesMins2to6.mildstress.veh,1),nanmedian(MobilitiesMins2to6.mildstress.ket10,1),nanmedian(MobilitiesMins2to6.mildstress.ket30,1),...
    nanmedian(MobilitiesMins2to6.ucsstress.veh,1),nanmedian(MobilitiesMins2to6.ucsstress.ket10,1),nanmedian(MobilitiesMins2to6.ucsstress.ket30,1)...
    );
set(gcf,'name','RawMobilityMedians-BarPlots')

[p,tbl,stats] = anovan(medians,{dosegroups,stressgroups},'model','interaction','varnames',{'dose','stress'});
set(gcf,'name','RawMobilityMedians-AnovaTable')
figure
results = multcompare(stats,'Dimension',[1 2]);
set(gcf,'name','RawMobilityMedians-MultiCompare')

%% Variances
figure;
plot_meanSD_bars(...
    nanvar(MobilitiesMins2to6.nostress.veh,1),nanvar(MobilitiesMins2to6.nostress.ket10,1),nanvar(MobilitiesMins2to6.nostress.ket30,1),...
    nanvar(MobilitiesMins2to6.mildstress.veh,1),nanvar(MobilitiesMins2to6.mildstress.ket10,1),nanvar(MobilitiesMins2to6.mildstress.ket30,1),...
    nanvar(MobilitiesMins2to6.ucsstress.veh,1),nanvar(MobilitiesMins2to6.ucsstress.ket10,1),nanvar(MobilitiesMins2to6.ucsstress.ket30,1)...
    );
set(gcf,'name','RawMobilityVariances-BarPlots')

[p,tbl,stats] = anovan(vars,{dosegroups,stressgroups},'model','interaction','varnames',{'dose','stress'});
set(gcf,'name','RawMobilityVariances-AnovaTable')
figure
results = multcompare(stats,'Dimension',[1 2]);
set(gcf,'name','RawMobilityVariances-MultiCompare')

% 
% [p,tbl,stats] = anovan(sums,{stressgroups,dosegroups},'model','interaction','varnames',{'stress','dose'});
% results = multcompare(stats,'Dimension',[1 2]);
% 
% [p,tbl,stats] = anovan(means,{stressgroups,dosegroups},'model','interaction','varnames',{'stress','dose'});
% results = multcompare(stats,'Dimension',[1 2]);
% 
% [p,tbl,stats] = anovan(medians,{stressgroups,dosegroups},'model','interaction','varnames',{'stress','dose'});
% results = multcompare(stats,'Dimension',[1 2]);
% 
% [p,tbl,stats] = anovan(vars,{stressgroups,dosegroups},'model','interaction','varnames',{'stress','dose'});
% results = multcompare(stats,'Dimension',[1 2]);
% 
% [p,tbl,stats] = anovan(stds,{stressgroups,dosegroups},'model','interaction','varnames',{'stress','dose'});
% results = multcompare(stats,'Dimension',[1 2]);
% 
