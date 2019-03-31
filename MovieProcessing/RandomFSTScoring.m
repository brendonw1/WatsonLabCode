function RandomFSTScoring(dates)
if isempty(dates)
    dates = [];
end
basepath = cd;
namesdir = dir;
folder = [];
names = [];

for i = 1:length(namesdir)
    for j = 1:length(dates(:,1))
        foldername = strcat(namesdir(i).name,'_',dates(j,:));
        if exist(foldername)
            folder{end+1} = strcat(foldername);
            names{end+1} = strcat(namesdir(i).name);
        else
            break
        end
    end
end
r = randperm(length(folder));
for i = 1:length(folder)
    file = dir(fullfile(names{r(i)},folder{r(i)},'*.avi'));
    ForcedSwimMovieScoring(file.name);
end


