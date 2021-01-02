function [outputAbsoluteUniqueVideoIDString] = GenerateAbsoluteVideoIdentifier(curr_video_file, numRootPartsToRemove)
%GENERATEABSOLUTEVIDEOIDENTIFIER Generates a unique and identifying name from a video given the path
%   Detailed explanation goes here
% numRootPartsToRemove: the number of path parts to remove from the start.
% Does not include the drive root (which only matters for Windows-style paths).
% of the video file path
 
if ~exist('numRootPartsToRemove','var')
   numRootPartsToRemove = 2; % rewmove /data/Lezio 
end
% curr_video_file.full_parent_path:
% 'Z:\data\Lezio\LB_13\LB_13_190610\LB_13_190610_082833\EyePupil\PreSleep'
 
% curr_video_file.full_path:
% 'Z:\data\Lezio\LB_13\LB_13_190610\LB_13_190610_082833\EyePupil\PreSleep\video.avi'
 
% curr_video_file.basename
% 'video'
 
% Want: 'LB_13_190610_082833_EyePupil_PreSleep_video'
 
% curr_input_root = '/data/Lezio'; % Local Linux on Balrog
%curr_input_root = 'Z:/data/Lezio'; % Windows Mounted to drive Z:/
 
 
filesep % path separator for the current platform to split on


if isWindowsStylePath(curr_video_file.full_parent_path)
    % Get drive root
    [DriveRootPart, RemainingPath, ~] = SplitWindowsDriveRoot(curr_video_file.full_parent_path);
    RemainingPath = strrep(RemainingPath,'\','/'); % Make it into a unix-style path (with forward slashes)
else
    % Unix-style path
    RemainingPath = curr_video_file.full_parent_path{2:end}; % omitting the first forward slash indicating root.
end


foundPathParts = split(RemainingPath, '/');
% remove the path roots
foundPathParts(1:numRootPartsToRemove) = '';
 
% Iterate backwards through the path parts to remove any redundant ones.
for i = length(foundPathParts):-1:1
   currPathPart = foundPathParts(i);
   if exist('lastPathPart','var')
       % see if the last path part already contains the current path part
%        if contains(lastPathPart, currPathPart, 'IgnoreCase',true)
        if startsWith(lastPathPart, currPathPart, 'IgnoreCase',true)
%           newStr = replace(currPathPart,"mary","anne")
          foundPathParts(i) = ''; % Clear the rendundant current path part.
       end
   end
   lastPathPart = currPathPart;
end
 
 
foundPathParts{end+1} = curr_video_file.basename;

% num_frames_string = sprintf("%d_frames", curr_video_file.endFrameIndex);
num_frames_string = sprintf("%d", curr_video_file.endFrameIndex);
foundPathParts{end+1} = num_frames_string;

joined_string = join(string(foundPathParts), '_');

% settings.curr_output_root
% "Z:/analysis/Pho/Lezio Pupil 2-21-2020/"
 
outputAbsoluteUniqueVideoIDString = joined_string;
 
end