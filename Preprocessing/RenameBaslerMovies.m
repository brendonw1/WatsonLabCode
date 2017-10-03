function RenameBaslerMovies(basepath,basename)


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

ms = dir(fullfile(basepath,'*.avi'));
ds = dir(fullfile(basepath,'*.dat'));
%>> or can use .metas

%% THIS WON'T WORK - USE BASLER NAME AND .meta

%for each recording file, find a matching movie file
for a = 1:length(ds);
    spaces = strfind(ds(a).date,' ');
    recdate = ds(a).date(1:spaces(1)-1);
    recdateday = num2str(recdate(1:2));
    rectime = ds(a).date(spaces(1)+1:end);
    rectimemin=str2num(rectime(1:2))*60+str2num(rectime(4:5));

    goodmovs = [];
    for b = 1:length(ms);
        spacesm = strfind(ds(a).date,' ');
        movdate = ds(a).date(1:spacesm(1)-1);
        movdateday = num2str(movdate(1:2));
        if movdateday == recdateday%could be more precise, but whatever
            movtime = ds(a).date(spacesm(1)+1:end);
            movtimemin=str2num(movtime(1:2))*60+str2num(movtime(4:5));
            if [movtimemin-rectimemin] < 1
                goodmovs(end+1) = b;
            end
        end
    end
    
    if length(goodmovs) == 1;
        movefile(fullfile(basepath,ms(goodmovs).name),fullfile(basepath,[ds(a).name(1:end-5) '.avi']))
    elseif length(goodmovs) == 0;
        disp(['Alert: no movie started within 1min of ' ds(a).name])
    elseif length(goodmovs)>1
        for b = 1:length(goodmovs)
            list{b} = ms(goodmovs(b)).name;
        end
        promptstr = ['Which movie should be renamed to ' ds(a).name(1:end-5) '.avi'];
        [sel,ok] = listdlg('ListString',list,'PromptString',promptstr);
        if length(sel) == 1
            rename = list{sel};
            movefile(fullfile(basepath,rename),fullfile(basepath,[ds(a).name(1:end-5) '.avi']))
        else
            disp(['Skipping movie for ' ds(a).name]) 
        end
    end
end