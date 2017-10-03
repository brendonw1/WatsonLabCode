function totalfilesecs = GetFileSecsFromDir(basename)
% assumes you are in a work folder... gets total session duration from one
% of a number of files.  Have yet to add .meta functionality.

if exist([basename '-sessOrder.mat'],'file')
    t = load([basename '-SessOrder.mat']);
    totalfilesecs = t.sessOrder.times(end);
elseif exist([basename '-metaInfo.mat'],'file')
    t = load([basename '-metaInfo.mat']);
    t = t.metaInfo.durationInSec;
    totalfilesecs = 0;
    for a = 1:length(t)
        totalfilesecs = totalfilesecs + t{a};
    end
elseif exist([basename '.eeg'],'file')
    totalfilesecs = dir([basename '.eeg']);
    totalfilesecs = totalfilesecs.bytes/2/1250/par.nChannels;
elseif exist([basename '.dat'],'file')
    totalfilesecs = dir([basename '.dat']);
    totalfilesecs = totalfilesecs.bytes/2/20000/par.nChannels;
elseif exist([basename '-statesl.mat'],'file')
    t = load([basename '-states.mat']);
    totalfilesecs = length(t.states);
elseif ~isempty(dir('*.fet.*'))
    d = dir('*.fet*');
    for a = 1:length(d);
        [~,out] = system(['tail -1 ' d(a).name]);
        out = str2num(out);
        t(a) = out(end);
    end
    totalfilesecs = max(t)/20000;
end
