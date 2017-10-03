function [names,dirs] = SleepDataset_GetDatasetsDirs_UI
% Gets directory paths and names of analyzed datasets, puts them in cell
% arrays

[dummy,cname]=system('hostname');

if strcmp(cname(1:9),'MAC157688')%if I'm on my laptop
    bmdd = '/Users/brendon/Dropbox/Data/SleepDatasetAnalysis/';
else %if at lab
    bmdd = '/mnt/brendon4/Dropbox/Data/SleepDatasetAnalysis/';
end

bmdd = uigetdir(bmdd,'Choose Directory with Datasets of Interest');

dperm = getdir(bmdd);
ld = length(dperm);
for a = 1:ld;
    n = dperm(a).name;
    fp = fullfile(bmdd,n);
    t = load(fp);
    dirs{a} = t.basepath;
    names{a} = t.basename;
end
