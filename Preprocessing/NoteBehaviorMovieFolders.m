function NoteBehaviorMovieFolders

recordingpaths = {'/mnt/Amplipex7D/BW/';'/mnt/Amplipex7G/BW/'};
animalname = 'c3po';
overwrite = 0;

for a = 1:length(recordingpaths);
    toprecdir = fullfile(recordingpaths{a},animalname);
    d = getdir(toprecdir);
    for b = 1:length(d);
        BehaviorMovieRecordings = {};
        sessionname = d(b).name;
        daydir = fullfile(toprecdir,sessionname);
        dd = getdir(daydir);
        for c = 1:length(dd)
            if dd(c).isdir
                recordingdir = fullfile(daydir,dd(c).name);
                ddd = dir(fullfile(recordingdir,'*.avi'));
                if ~isempty(ddd)
                    for i = 1:length(ddd)
                        BehaviorMovieRecordings{end+1} = dd(c).name;
                    end
                end
            end
        end
        
        destdir = [];
        if exist(fullfile('/mnt/RawData/',animalname,sessionname),'dir');
            destdir = fullfile('/mnt/RawData/',animalname,sessionname);
        elseif exist(fullfile('/mnt/RawData2/',animalname,sessionname),'dir');
            destdir = fullfile('/mnt/RawData2/',animalname,sessionname);
        elseif exist(fullfile('/mnt/RawData3/',animalname,sessionname),'dir');
            destdir = fullfile('/mnt/RawData3/',animalname,sessionname);
        end
        if isempty(destdir);
            disp(['no destination directory called: ' sessionname])
        else
        % write .txt with those foldernames into rawdata location
            bool = exist(fullfile(destdir,'BehaviorMovieList.txt'));
            if bool & ~overwrite
                disp(['Did not overwrite ' sessionname])
                continue
            else
                CellStringToTextFile(BehaviorMovieRecordings,fullfile(destdir,'BehaviorMovieList.txt'));
                disp(['Wrote file for ' sessionname])
            end
        end
    end
end    
    