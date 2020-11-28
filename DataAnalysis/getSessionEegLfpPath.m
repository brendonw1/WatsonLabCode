function eegpath = getSessionEegLfpPath(bmd)

if ~exist('bmd','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
end

if isfield(bmd,'masterpath')
    eegpath = fullfile(bmd.masterpath,[bmd.mastername '.eeg']);
    if ~exist(eegpath,'file')
        eegpath = fullfile(bmd.masterpath,[bmd.mastername '.lfp']);
    end
else
    eegpath = fullfile(bmd.basepath,[bmd.basename '.eeg']);
    if ~exist(eegpath,'file')
        eegpath = fullfile(bmd.basepath,[bmd.basename '.lfp']);
    end
end