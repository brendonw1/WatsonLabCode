function DanToBrendon(fileend)

[names,dirs]=GetDefaultDataset;

dandir = '/mnt/brendon4/Dropbox/BWData (1)';

for a = 1:length(names);
    basename = names{a};
    basepath = dirs{a};
    
    tdandir = fullfile(dandir,basename);    
    d = dir(tdandir);
    
    for b = 1:length(d);
        if length(d(b).name) >= length(fileend)
            if strcmp(fileend,d(b).name(end-(length(fileend)-1) : end))
                fromname = fullfile(dandir,basename,d(b).name);
                toname = fullfile(basepath,d(b).name);
%                 toname = fullfile(basepath,[d(b).name(1:end-4) '_ForOldSextiles.mat']);
                copyfile(fromname,toname)
                disp([fromname ' > ' toname])
            end
        end
    end
end
