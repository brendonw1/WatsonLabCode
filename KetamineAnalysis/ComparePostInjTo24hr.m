function CompareMatrix = ComparePostInjTo24hr(basepath,basename,CompareMatrix)

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end

%% do not execute if data unavailable
hrlrpath = fullfile(basepath,[basename '_HighLowFRRatio.mat']);
icipath = fullfile(basepath,[basename '_InjectionComparisionIntervals.mat']);
if ~exist(hrlrpath,'file') && exist(icipath,'file')
    disp(['Files for binned data comparisons do not exist for ' basename])
    return
end

%% open data
load(fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']),'KetamineBinnedDataByIntervalState')
load(fullfile(basepath,[basename '_KetaminePostInjectionWake.mat']),'KetaminePostInjectionWakeData')

%% collect into bins
if ~exist('CompareMatrix','var')
    CompareMatrix  = [];
end