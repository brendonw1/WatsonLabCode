function REM_EphysPreproc(varargin)
%
% REM_EphysPreproc(varargin)
%
% Electrophysiology preprocessing pipeline. This will save several MAT
% files in the session folder: session information, EMG (at two
% different sampling rates), LFP and sleep scoring.
%
% USAGE
%   - Dependency: buzcode (https://github.com/buzsakilab/buzcode).
%   - Run from folder containing DAT, NRS and XML files.
%   - Rename such files to the session name prior to running.
%     For example: MOUSE_YYMMDD.dat, MOUSE_YYMMDD.nrs, MOUSE_YYMMDD.xml
%   - varargin: please see input parser section
%
% After running this, use TheStateEditor to adjust WAKE, NREM and
% REM epochs. It is recommended to include 30-60 s margins per
% episode for later trimming (see REM_EpisodeTrimmer).
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% Sampling rate
addParameter(p,'REMsamplFreq',125,@isnumeric) % Hz

parse(p,varargin{:})
REMsamplFreq = p.Results.REMsamplFreq;



%% Session information and LFP
bz_getSessionInfo(pwd,'editGUI',true); % GUI to indicate bad channels
bz_LFPfromDat;
load([bz_BasenameFromBasepath(pwd) '.sessionInfo.mat'],'sessionInfo')



%% EMG from LFP. This is separate from sleep scoring, to obtain EMG curves
% at higher sampling frequency.
if isfield(sessionInfo,'badchannels') % with bad channels
    HighSamplEMG = bz_EMGFromLFP(pwd,...
        'rejectChannels',sessionInfo.badchannels,...
        'saveMat',false,...
        'samplingFrequency',REMsamplFreq,... % higher than sleep scoring
        'noPrompts',true);
else % no bad channels
    HighSamplEMG = bz_EMGFromLFP(pwd,...
        'saveMat',false,...
        'samplingFrequency',REMsamplFreq,... % higher than sleep scoring
        'noPrompts',true);
end
HighSamplEMG = HighSamplEMG.data;



%% Save EMG data along with sampling rate. Include sampling rate in
% the sessionInfo structure for redundancy.
save([bz_BasenameFromBasepath(pwd) '.HighSamplEMG.mat'],...
    'HighSamplEMG','REMsamplFreq')

sessionInfo.REMsamplFreq = REMsamplFreq;
save([bz_BasenameFromBasepath(pwd) '.sessionInfo.mat'],...
    'sessionInfo')



%% Default buzcode sleep scoring. Low-sampling EMG is saved separately
% from the high-sampling EMG data above.
SleepScoreMaster(pwd,'noPrompts',true);

end
