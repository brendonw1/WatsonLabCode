function ConvertAllCnxnsToBurstFilter

executestring = 'ConvertAllCnxnsToBurstFilter_Subfunc(basename,basepath,S,shank,cellIx,funcsynapses)';
varstograb = {'S';'funcsynapses'};
datasets = 'WSW';

SleepDataset_ExecuteOnDatasets(executestring,varstograb,datasets)

% go to folder
% Open metadata
% open SAll
% 
% Sbf
% save sbf
% 
% save old funccnxs to _PreBF.mat
% Read badcnxns
% funcconnection now
% jump ahead to badcnxns, use those to re-make the funccnxns
% save _funcconnetions or whatever

