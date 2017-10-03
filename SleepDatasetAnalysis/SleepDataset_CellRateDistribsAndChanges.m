function SleepDataset_CellRateDistribsAndChanges

%% get dataset info from directory
% [names,dirs] = SleepDataset_GetDatasetsDirs_WSWCells;
wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);


%% gather actual data
for a = 1:length(dirs);
    p = fullfile(dirs{a},[names{a} '_CellRateVariables.mat']);
    t = load(p);
    c = t.CellRateVariables;
    
    fn = fieldnames(c);
    if a == 1;
        CellRateVariables = c;
        CellRateVariables.basename = {CellRateVariables.basename};
        CellRateVariables.basepath = {CellRateVariables.basepath};
    else
        for b = 1:length(fn)
            t = fn{b};
            if ~strcmp(t,'basename') & ~strcmp(t,'basepath')
               eval(['CellRateVariables.' t '= cat(1,CellRateVariables.' t ',c.' t ');']); 
%             else
%                eval(['CellRateVariables.' t '{end+1} = c.' t ';']); 
            end
        end
    end
    bmd = load(fullfile(c.basepath,[c.basename '_BasicMetaData.mat']));
    anat = GetChannelAnatomy(fullfile(c.basepath,c.basename),bmd.goodeegchannel);
    slashes = strfind(c.basepath,'/');
    ratname = c.basepath(slashes(3)+1:slashes(4)-1);
    
    if a==1
        CellRateVariables.SessionNames = {c.basename};
        CellRateVariables.Anatomies = {anat};
        CellRateVariables.RatNames = {ratname};
    else
        CellRateVariables.SessionNames{end+1} = c.basename;
        CellRateVariables.Anatomies{end+1} = anat;
        CellRateVariables.RatNames{end+1} = ratname;
    end
    
end
CellRateVariables.NumRats = length(unique(CellRateVariables.RatNames));

CellRateVariables.basename = ['SleepDataset' date];
CellRateVariables.basepath = cd;

%% plotting

h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariables);

%% Output
sp = '/mnt/brendon4/Dropbox/Data/BasicCellRateChangesOverSleep';
n = ['CellRateDstribsAndChanges_On_' date];

CellStringToTextFile(names,fullfile(sp,[n '.txt']))%save names of datasets used on this date
save(fullfile(sp,n),'CellRateVariables')

savethesefigsas(h,'fig',sp)
% ! rm -R CellRateDistributionFigs/