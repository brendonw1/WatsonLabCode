function ConvertBaslerAviNames_PerAnimalFolder(thissessionfolder)

if ~exist('thisanimalfolder','var')
    thissessionfolder = cd;
end

allrecordingfolders = getsubdirs(thissessionfolder);
for ridx = 1:length(allrecordingfolders)
    thisrecordingfolder = fullfile(thissessionfolder,allrecordingfolders(ridx).name);
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
        
        
function subs = getsubdirs(supra)
subs = dir(supra);
subs(1:2) = [];
for sidx = length(subs):-1:1
    if ~subs(sidx).isdir;
        subs(sidx) = [];
    end
end
