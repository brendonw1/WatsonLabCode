function voltsperunit = VoltsPerUnit(basename,basepath)

voltsperunit = 0.0000002;%default... for intan

%% Below for cases recorded in amplipex
metas = dir(fullfile(basepath,'*.meta'));
inis = dir(fullfile(basepath,'*.ini'));
if ~isempty(metas) | ~isempty(inis)
    bitdepth = 16;%just default
    bits = 2.^bitdepth;

    rangemax = [];
    rangemin = [];
    gain = [];

    if ~isempty(metas)%prefer to use .meta info, if not use .ini
        for a = 1:length(metas)
            fname = metas(a).name;
            if ~isempty(strfind(fname,basename))
                fname = fullfile(basepath,fname);
                fid=fopen(fname);
                tline= fgetl(fid);
                while ischar(tline)
                    try
                        if strcmp(tline(1:19),'Amplitude range max')
                            tline=tline(23:end);
                            rangemax(end+1)=str2num(tline);
                        end
                    end
                    try
                        if strcmp(tline(1:19),'Amplitude range min')
                            tline=tline(23:end);
                            rangemin(end+1)=str2num(tline);
                        end
                    end
                    try
                        if strcmp(tline(1:7),'Gain = ')
                            tline=tline(8:end);
                            gain(end+1) = str2num(tline);
                        end
                    end

                    tline= fgetl(fid);
                end
                fclose(fid);
            end
        end
    elseif ~isempty(inis)
        for a = 1:length(inis)
            fname = inis(a).name;
            if ~isempty(strfind(fname,basename))
                fname = fullfile(basepath,fname);
                fid=fopen(fname);
                tline= fgetl(fid);
                while ischar(tline)
                    try
                        if strcmp(tline(1:9),'rangeMax=')
                            tline=tline(10:end);
                            rangemax(end+1)=str2num(tline);
                        end
                    end
                    try
                        if strcmp(tline(1:9),'rangeMin=')
                            tline=tline(10:end);
                            rangemin(end+1)=str2num(tline);
                        end
                    end
                    try
                        if strcmp(tline(1:8),'auxGain=')
                            tline=tline(9:end);
                            gain(end+1) = str2num(tline);
                        end
                    end

                    tline= fgetl(fid);
                end
                fclose(fid);
            end
        end
    end

    if sum(abs(diff(rangemax))) | sum(abs(diff(rangemin))) 
        error('Ranges unequal between .ini files in this folder')
        return
    end
    if sum(abs(diff(gain)))
        error('Gains unequal between .ini files in this folder')
        return
    end

    if ~isempty(rangemax) & ~isempty(rangemin) %... if amplipex, otherwise do default which is intan
        totalrange = rangemax(1)-rangemin(1);
        voltsperunit = totalrange / bits / gain(1);
    end
end    