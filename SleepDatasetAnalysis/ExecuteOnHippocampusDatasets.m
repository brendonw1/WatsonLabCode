function ExecuteOnHippocampusDatasets(executestring,varargin)
% Executes some command over a group of datasets.
% INPUTS
%    executestring = string to execute on each individual dataset (using
%                    eval command)
%    varstograb = variables to load from within each dataset - formatted as
%                    a cell of character strings
%    datasets = family of datasets in dropbox/data/sleepdatasetanalysis/...
%                ie "WSW" or "WSWandSynapses"
% OUTPUT
%    >> Determined by execute string
%
% Brendon Watson 2014

%% Get list of datasets
% determine whether want to require only sessions with below > 1 means
% require each condition be met, 0 means don't worry (all zeros means just 
% acquire sleep and spikes recordings)
[names,dirs]=GetDefaultDataset('hippocampus');
% [names,dirs]=GetDefaultDataset('new');


%old system
% if exist('datasets','var')
%     [names,dirs] = SleepDataset_GetDatasetsDirs(datasets);
% else
%     [names,dirs] = SleepDataset_GetDatasetsDirs_UI;
% end
varstograb = varargin;

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
     
    if exist('varstograb','var')
        for b = 1:length(varstograb)
           tv = varstograb{b};
           switch lower(tv)
               case 'cellids'
                    t = load(fullfile(dirs{a},[names{a} '_CellIDs.mat']));
                    CellIDs = t.CellIDs;
               case 'funcsynapses'
                    t = load(fullfile(dirs{a},[names{a} '_funcsynapsesMoreStringent.mat']));
                    funcsynapses = t.funcsynapses;
               case 'goodsleepinterval'
                    t = load(fullfile(dirs{a},[names{a} '_GoodSleepInterval.mat']));
                    GoodSleepInterval = t.GoodSleepInterval;
               case 'intervals'
                    t = load(fullfile(dirs{a},[names{a} '_Intervals.mat']));
                    intervals = t.intervals;
               case 'mastername'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    if isfield(t,'mastername')
                        mastername = t.mastername;
                    else
                        mastername = [];
                    end
               case 'masterpath'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    if isfield(t,'masterpath')
                        masterpath = t.masterpath;
                    else
                        masterpath = [];
                    end
               case 'motion'
                    t = load(fullfile(dirs{a},[names{a} '_Motion.mat']));
                    motion = t.motiondata.motion;
               case 'numchans'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    numchans = t.Par.nChannels;
               case 'recordingfileintervals'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    RecordingFileIntervals = t.RecordingFileIntervals;
               case 'recordingfilesforsleep'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    RecordingFilesForSleep = t.RecordingFilesForSleep;
               case 's'
                    t = load(fullfile(dirs{a},[names{a} '_SStable.mat']));
                    S = t.S;
                    cellIx = t.cellIx;
                    shank = t.shank;
               case 'sbf'
                    t = load(fullfile(dirs{a},[names{a} '_SBurstFiltered.mat']));
                    Sbf = t.Sbf;
               case 'se'
                    t = load(fullfile(dirs{a},[names{a} '_SSubtypes.mat']));
                    Se = t.Se;
               case 'si'
                    t = load(fullfile(dirs{a},[names{a} '_SSubtypes.mat']));
                    Si = t.Si;
               case 'spindlechannel'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    spindlechannel = t.Spindlechannel;
               case 'swepisodes'
                    t = load(fullfile(dirs{a},[names{a} '_WSWEpisodes.mat']));
                    SWEpisodes = t.SWEpisodes;
                    SWBestIdx = t.SWBestIdx;
               case 'voltsperunit'
                    t = load(fullfile(dirs{a},[names{a} '_BasicMetaData.mat']));
                    voltsperunit = t.voltsperunit;
               case 'wswepisodes'
                    t = load(fullfile(dirs{a},[names{a} '_WSWEpisodes.mat']));
                    WSWEpisodes = t.WSWEpisodes;
                    WSWBestIdx = t.WSWBestIdx;
               case 'wswprewakeabove200'
                    t = load(fullfile(dirs{a},[names{a} '_WSWEpisodes2.mat']));
                    WSWPreWakeAbove200 = t.WSWPreWakeAbove200;
               case 'wsepisodes'
                    t = load(fullfile(dirs{a},[names{a} '_WSWEpisodes.mat']));
                    WSEpisodes = t.WSEpisodes;
                    WSBestIdx = t.WSBestIdx;
            end
        end
    end
    clear t
    %% Execute
    eval(executestring)
    
end