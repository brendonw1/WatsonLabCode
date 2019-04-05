function BrendonToDan(fileend,subpath)

[names,dirs]=GetDefaultDataset;

dandir = '/mnt/brendon4/Dropbox/BWData';

for a = 1:length(names);
    basename = names{a};
    basepath = dirs{a};
    if exist('subpath','var')
        searchpath = fullfile(basepath,subpath);
    else
        searchpath = basepath;
    end
    
    d = dir(searchpath);
    anymatch = 0;
    for b = 1:length(d);
        if length(d(b).name) >= length(fileend)
            if strcmp(fileend,d(b).name(end-(length(fileend))+1 : end))
                fromname = fullfile(searchpath,d(b).name);
                toname = fullfile(dandir,basename,d(b).name);
                copyfile(fromname,toname)
                disp([fromname ' > ' toname])
                anymatch = 1;
            end
        end
    end
    if anymatch==0
        disp(['no match in ' basename])
    end
end
