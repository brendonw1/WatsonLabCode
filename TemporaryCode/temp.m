function temp(basepath)

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist(fullfile(basepath,'StatesFromWatson2016'),'dir')
    disp('making dir')
    mkdir(fullfile(basepath,'StatesFromWatson2016'));
end
copyfile(fullfile(basepath,[basename,'-states.mat']),fullfile(basepath,'StatesFromWatson2016',[basename,'-states.mat']))
copyfile(fullfile(basepath,[basename,'.SleepState.states.mat']),fullfile(basepath,'StatesFromWatson2016',[basename,'.SleepState.states.mat']))
copyfile(fullfile(basepath,[basename,'.SleepStateEpisodes.states.mat']),fullfile(basepath,'StatesFromWatson2016',[basename,'.SleepStateEpisodes.states.mat']))
