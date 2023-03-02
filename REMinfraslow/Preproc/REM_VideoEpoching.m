function REM_VideoEpoching(InVidFile,OutVidFile,VidFrameTstamps,EpochInt)
%
% REM_VideoEpoching(InVidFile,OutVidFile,VidFrameTstamps,EpochInt)
%
% REM-containing video epoch.
%
% USAGE
%   - InVidFile:  file name or path of existing pre-epoching video
%   - OutVidFile: file name or path of new epoched video
%   - VidFrameTstamps: in seconds. From Intan digitalin
%                      (see REM_TstampsFromDigitalin)
%   - EpochInt: REM or WAKE delimiting times, in seconds (single epoch),
%               e.g., [7200 7320]
%   - This function is intended to allow flexible folder management. Hence
%     the possibility of using paths to localize videos and the necessity
%     of loading VidFrameTstamps and EpochInt externally using other
%     functions (e.g., with loops through a custom folder system).
%
% SUGGESTION
%   - EpochInts may be obtained directly from TheStateEditor, prior to
%     epoch trimming. With this, epoched videos will contain REM margins,
%     showing pupil and whisker states in preceding NREM and subsequent
%     NREM or WAKE periods. These videos can be used for quality control
%     or demonstration. Deeplabcut data can then be trimmed as in
%     REM_EpisodeTrimmer.
%
% Bueno-Junior et al. (2023)

%% Read
VidReaderObj = VideoReader(InVidFile);

[~,FirstFrameIdx] = min(abs(VidFrameTstamps-EpochInt(1)));
[~,LastFrameIdx]  = min(abs(VidFrameTstamps-EpochInt(2)));

EpochedVid = read(VidReaderObj,[FirstFrameIdx LastFrameIdx]); %#ok<*VIDREAD>



%% Write
VidWriterObj = VideoWriter(OutVidFile);
VidWriterObj.FrameRate = VidReaderObj.FrameRate;

open(VidWriterObj)
writeVideo(VidWriterObj,EpochedVid)
close(VidWriterObj)

end