function [names,dirs] = SleepDataset_GetDatasetsDirs_SleepCellsSynapses
% Gets directory paths and names of analyzed datasets, puts them in cell
% arrays

[dummy,cname]=system('hostname');

if strcmp(cname(1:9),'MAC157688')%if I'm on my laptop
    bmdd = '/Users/brendon/Dropbox/Data/SleepDatasetAnalysis/BasicMetaData_SleepCellsSynapses';
    d = getdir(bmdd);
    ld = length(d);
    for a = 1:ld;
        n = d(a).name;
        fp = fullfile(bmdd,n);
        t.load(fp);
        names{a} = t.basename;
        dirs{a} = ['/Users/brendon/Dropbox/Data/' basename];%note this change as well
    end
else %if at lab
    bmdd = '/mnt/brendon4/Dropbox/Data/SleepDatasetAnalysis/BasicMetaData_SleepCellsSynapses/';
    d = getdir(bmdd);
    ld = length(d);
    for a = 1:ld;
        n = d(a).name;
        fp = fullfile(bmdd,n);
        t.load(fp);
        dirs{a} = t.basepath;
        names{a} = t.basename;
    end
end