function FSTAnalysis(path,dates)

Names = ls(path);
cell(length(Names), 1);

for i = 1:length(Names)
    for j = 1:length(dates)
        sppath = strcat(Name(i), '_', dates(j));
        filename = dir(fullfile(Names(i), sppath, '*FSTScoring.mat'));
        load(Filename, 'BehaviorChunkCounts');
        Animal

