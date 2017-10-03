function ConvertBaslerAviNames_PerAnimalFolder(thisanimalfolder)

if ~exist('thisanimalfolder','var')
    thisanimalfolder = cd;
end

t = dir(thisanimalfolder);
if isempty(t)
    return
end

allsessionfolders = getsubdirs(thisanimalfolder);
for sidx = 1:length(allsessionfolders)
    allrecordingfolders = getsubdirs(fullfile(thisanimalfolder,allsessionfolders(sidx).name));
    for ridx = 1:length(allrecordingfolders)
        thisrecordingfolder = fullfile(thisanimalfolder,allsessionfolders(sidx).name,allrecordingfolders(ridx).name);
        [~,thisbase] = fileparts(thisrecordingfolder);
        tavi = dir(fullfile(thisrecordingfolder,'Basler *.avi'));
        if ~isempty(tavi)
            tavi = tavi(1).name;
            oldpath = fullfile(thisrecordingfolder,tavi);
            newpath = fullfile(thisrecordingfolder,[thisbase '.avi']);
            movefile(oldpath,newpath);
            disp([thisbase ' .avi filename changed'])
        end
    end
end
        
        
function subs = getsubdirs(supra)
subs = dir(supra);
subs(1:2) = [];
for sidx = length(subs):-1:1
    if ~subs(sidx).isdir;
        subs(sidx) = [];
    end
end
