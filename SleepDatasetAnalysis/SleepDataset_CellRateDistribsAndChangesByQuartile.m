function SleepDataset_CellRateDistribsAndChangesByQuartile

%% get dataset info from directory
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;

%% gather actual data
for a = 1:length(dirs);
    p = fullfile(dirs{a},[names{a} '_CellRateVariables.mat']);
    t = load(p);
    c = t.CellRateVariables;
    
    fn = fieldnames(c);
    if a == 1;
        CellRateVariables = c;
    else
        for b = 1:length(fn)
            t = fn{b};
            if ~strcmp(t,'basename') & ~strcmp(t,'basepath')
               eval(['CellRateVariables.' t '= cat(1,CellRateVariables.' t ',c.' t ');']); 
            end
        end
    end
end

CellRateVariables.basename = ['SleepDataset' date];
CellRateVariables.basepath = cd;

%% plotting

h = SpikingAnalysis_IndividalCellRatesWithSleep_PlotByQuartile(CellRateVariables);

%% Output
n = ['CellRateDstribsAndChanges_On_' date];

CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
% save(n,'CellRateVariables')
% 
% savethesefigsas(h,'eps')
% ! rm -R CellRateDistributionFigs/