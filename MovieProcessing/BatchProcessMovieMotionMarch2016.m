function BatchProcessMovieMotionMarch2016

dirs = {'/mnt/RawData/c3po';'/mnt/RawData2/c3po';'/mnt/RawData3/c3po'};

for a = 1:length(dirs);
    sd = dirs{a};
    d = getdir(sd);
    for b = 1:length(d);
        if d(b).isdir
            disp(fullfile(dirs{a},d(b).name))
            MovieMotionOneSessionBaslerHomecage(fullfile(dirs{a},d(b).name))
        end
    end
end
 