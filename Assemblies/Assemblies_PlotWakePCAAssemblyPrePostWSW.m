function Assemblies_PlotWakePCAAssemblyPrePostWSW(WakePCAEAssembliesPrePostSleep)

if ~exist('WakePCAEAssembliesPrePostSleep','var')
    WakePCAEAssembliesPrePostSleep = Assemblies_GatherWakePCAAssemblyPrePostWSW;
end
v2struct(WakePCAEAssembliesPrePostSleep)%extracts field names as variables (necessary for labeling in fcns below)

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
    ['N Sleeps = ' num2str(sum(NumSleeps))];...
    ['N Assemblies = ' num2str(sum(NumAssemblies))];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicCounts')

%%
th = PlotPrePost(FirstSWSEAas,LastSWSEAas);
h = cat(2,h,th);
th = PlotPrePost(PrewakeEAas,PostwakeEAas);
h = cat(2,h,th);
th = PlotPrePost(FirstThirdSleepSWSEAas,LastThirdSleepSWSEAas);
h = cat(2,h,th);
th = PlotPrePost(First5SleepEAas,Last5SleepEAas);
h = cat(2,h,th);
th = PlotPrePost(Last5PreWakeEAas,First5PostWakeEAas);
h = cat(2,h,th);

%% Save Figs

dirpath = '/mnt/brendon4/Dropbox/Data/Assemblies/WakePCABeforeAfterSleep';
filetype = 'fig';
MakeDirSaveFigsThereAs(dirpath,h,filetype)

