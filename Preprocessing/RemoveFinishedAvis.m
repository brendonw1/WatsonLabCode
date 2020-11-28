function RemoveFinishedAvis

% dirs = {'/mnt/RawData/c3po';'/mnt/RawData2/c3po';'/mnt/RawData3/c3po'};
dirs = {'/mnt/RawData/c3po';'/mnt/RawData2/c3po'};
animalname = 'c3po';

for a = 1:length(dirs);
    sd = dirs{a};
    d = getdir(sd);
    for b = 1:length(d);
        if d(b).isdir
            sessiondir = fullfile(dirs{a},d(b).name);
            if exist(fullfile(sessiondir,'BehaviorMovieList.txt'),'file')
                keep = textreadtocharcell(fullfile(sessiondir,'BehaviorMovieList.txt'));
            else 
                keep = [];
            end
            dd = getdir(sessiondir);
            for c = 1:length(dd);
                if isempty(strmatch(dd(c).name,keep))
                    if dd(c).isdir & length(dd(c).name)>length(animalname)
                        recordingdir = fullfile(sessiondir,dd(c).name);
                        x = dir(fullfile(recordingdir,'*.avi'));
                        if ~isempty(x)
                            bool = exist(fullfile(recordingdir,'moviemotion.mat'),'file');
                            if ~bool
                                disp([x(1).name ' not cleared due to no moviemotion.mat file'])
                                continue
                            else
                                rmstr = ['! rm ' recordingdir '/*.avi'];
                                eval(rmstr);
                            end
                        end
                    end
                end
            end
        end
    end
end
