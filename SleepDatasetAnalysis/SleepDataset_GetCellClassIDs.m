function CompleteCellIDs = SleepDataset_GetCellClassIDs

[names,dirs] = GetDefaultDataset;

CompleteCellIDs = [];
for a = 1:length(dirs);
    p = fullfile(dirs{a},[names{a} '_CellIDs']);
    tci = load(p);
    tci = tci.CellIDs;
    
    p = fullfile(dirs{a},[names{a} '_CellClassificationOutput']);
    tcc = load(p);
    tcc = tcc.CellClassificationOutput;

    tcci = SpikingAnalysis_MakeCompleteCellID(tcc,tci);

    if a == 11;
        1;
    end
    

    tcci = cat(2,a*ones(size(tcci,1),1),tcci);%tacking on which recording it was from

%     disp([num2str(length(tci.EAll)) ' ' num2str(length(tci.IAll))]) 
%     disp(size(tcci,1))
%     disp(size(CompleteCellIDs,1))
    CompleteCellIDs = cat(1,CompleteCellIDs,tcci);
%     disp(size(CompleteCellIDs,1))
end



% n = ['SleepPopulation_CellClassification_On_' date];
% 
% CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
% save(n,'SleepDataset_CellIDs')
