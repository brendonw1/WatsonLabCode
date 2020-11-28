function SleepDataset_SRSEpisodeRates

%% get dataset info from directory
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;

%% gather actual data
e = [];
i = [];
for a = 1:length(dirs);
    p = fullfile(dirs{a},[names{a} '_SWSREMSWSEpisode_PopRates.mat']);
    t = load(p);

    tei = t.SWSREMSWSEpisode_PopRates.SWSEIndividRates;
%     tea = t.SWSREMSWSEpisode_PopRates.SWSEAvgRates;
    tei2 = [];
    for b = 1:size(tei,1);%make each cell-episode a single trial in a big series of rows
       tei2 = cat(1,tei2,squeeze(tei(b,:,:))');
    end
    e = cat(1,e,tei2);
    
    tii = t.SWSREMSWSEpisode_PopRates.SWSIIndividRates;
%     tea = t.SWSREMSWSEpisode_PopRates.SWSEAvgRates;
    tii2 = [];
    for b = 1:size(tii,1);%make each cell-episode a single trial in a big series of rows
       tii2 = cat(1,tii2,squeeze(tii(b,:,:))');
    end
    i= cat(1,i,tii2);
end

%% plotting

h = [];

%% Output
n = ['SleepPopulation_SRSEpisodeRates_On_' date];

CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
save(n,'SleepDataset_SRSEpisodeRates')

for a = 1:length(h)
    th = h(a);
    saveas(th,get(th,'name'),'fig')
    epswrite(th,get(th,'name'))
end