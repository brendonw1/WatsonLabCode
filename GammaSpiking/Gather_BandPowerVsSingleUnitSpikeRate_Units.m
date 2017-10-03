function Gather_BandPowerVsSingleUnitSpikeRate_Units(folderpath)


if ~exist('folderpath','var')
    folderpath = fullfile('/','proraid','GammaDataset');
end

%% Get list of datasets
d = getdir(folderpath);
names = {};
dirs = {};
for count = 1:length(d);
    if d(count).isdir
        names{end+1} = d(count).name;
        dirs{end+1} = fullfile(folderpath,d(count).name);
    end
end

%% Variable setup
celltypes = {'E','I'};
out.WakeRates = [];
out.rankidxs = [];
out.numEcells = [];
out.numIcells = [];

%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};
    
    load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData']))
    t = BandPowerVsSingleUnitSpikeRateData;
    clear BandPowerVsSingleUnitSpikeRateData
    if isfield(t,'stateslist')
        stateslist = t.stateslist;
    else
        stateslist = {'AllT','Wake','Nrem','Rem','Ma'};
    end
    
    out.WakeRates = cat(1,out.WakeRates,t.rankbasis);
    out.rankidxs = cat(1,out.rankidxs,t.rankidxs);
    out.numEcells = cat(1,out.numEcells,t.numEcells);
    out.numIcells = cat(1,out.numIcells,t.numIcells);
    for sidx = 1:length(stateslist)%state index
        tst = stateslist{sidx};
        for cidx = 1:2;%celltypes
            tct = celltypes{cidx};
            %% Cell-wise data
            eval(['tname = ''r_Cells' tct tst ''';'])
            if fidx == 1;
                eval(['out.' tname ' = [];'])
            end
            try
                eval(['out.' tname ' = cat(2,out.' tname ',t.' tname ');'])
            catch
                eval(['tt = nan(length(t.bandmeans)+1,t.num' tct 'cells,length(t.binwidthseclist));'])
                eval([tname ' = cat(2, out.' tname ',tt);'])
            end
            %% Combined pop data (not single cell)
            eval(['tname = ''r_All' tct tst ''';'])
            if fidx == 1;
                eval(['out.' tname ' = [];'])
            end
            try
                eval(['out.' tname ' = cat(3,out.' tname ',t.' tname ');'])
            catch
                tt = nan(length(t.bandmeans)+1,length(t.binwidthseclist));
                eval([tname ' = cat(3, out.' tname ',tt);'])
            end

        end
    end
    disp([basename ' done'])
    1;
end

%% Separate broadband from individual bands
for sidx = 1:length(stateslist)%state index
    tst = stateslist{sidx};
    for cidx = 1:2;%celltypes
        tct = celltypes{cidx};
        
        eval(['out.r_Cells' tct tst 'ToBroad = squeeze(out.r_Cells' tct tst '(end,:,:));']);
        eval(['out.r_Cells' tct tst ' = out.r_Cells' tct tst '(1:end-1,:,:);'])
        
        eval(['out.r_All' tct tst 'ToBroad = squeeze(out.r_All' tct tst '(end,:,:));']);
        eval(['out.r_All' tct tst ' = out.r_All' tct tst '(1:end-1,:,:);'])
    end
end

%% Get some basic params
out.binwidthseclist = t.binwidthseclist;
out.bandmeans = t.bandmeans;
out.plotbinwidth = t.plotbinwidth;
out.stateslist = t.stateslist;
out.Basenames = names;
out.Basepaths = dirs;

UnitRateVsBandPowerGathered = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','UnitRateVsBandPowerGathered.mat'),'UnitRateVsBandPowerGathered')
1;


