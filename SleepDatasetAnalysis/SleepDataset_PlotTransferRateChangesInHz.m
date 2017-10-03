function SleepDataset_PlotTransferRateChangesInHz

[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;
for a = 1:length(dirs);
	n = [names{a} '_TransferStrengthsOverSleep_NormByRateChg.mat'];
    p = fullfile(dirs{a},n);
    
    t = load(p);
    t = t.TransferStrengthsOverSleep_NormByRateChg;
    
    if a == 1;
        CellTransferVariables = t;
%         for b = 1:length(fn);
%             f = fn{b};
%             eval(['CellTransferVariables.' f ' = [];'])
%         end
    else
        fn = fieldnames(t);
        for b = 1:length(fn);
            f = fn{b};
            eval(['CellTransferVariables.' f ' = cat(2,CellTransferVariables.' f ',t.' f ');'])
        end
    end
end

CellRateVariables.basename = ['SleepDataset' date];

h = SpikingAnalysis_TransferRatesOverSleep_Plot(CellTransferVariables);

%% Output
n = ['CellTransferDistribsAndChanges_On_' date];

CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
save(n,'CellTransferVariables')

savethesefigsas(h,'fig')
savethesefigsas(h,'eps')
