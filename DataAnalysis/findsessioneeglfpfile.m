function eeglfppath = findsessioneeglfpfile(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
if isfield(t,'masterpath');
    thispath = t.masterpath;
    thisname = t.mastername;
else
    thispath = basepath;
    thisname = basename;
end

if exist(fullfile(thispath,[thisname,'.eeg']),'file')
    eeglfppath = fullfile(thispath,[thisname,'.eeg']);
elseif exist(fullfile(thispath,[thisname,'.lfp']),'file')
    eeglfppath = fullfile(thispath,[thisname,'.lfp']);
else
    error('Could not find eeg or lfp on appropriate path.')
end
