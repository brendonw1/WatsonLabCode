function [bbva_actigraphyFile] = parseActigraphyOutputFileName(actigraphyFilePath)
%PARSEACTIGRAPHYOUTPUTFILENAME Parses filepath like 'processed_output_BehavioralBox_B02_T20200312-1129190317_frames_1-431976_.mat'
%   Processes file like 'processed_output_BehavioralBox_B02_T20200312-1129190317_frames_1-431976_.mat'

%%%+S- bbva_actigraphyFile
	%- video_basename_string - video_basename_string is string containing the video basename that produced this actigrpahy file
	%- startFrameIndex - startFrameIndex is the starting frame in the processed segment
	%- endFrameIndex - startFrameIndex is the last frame in the processed segment
%

[bbva_actigraphyFile.folder, bbva_actigraphyFile.baseFileName, bbva_actigraphyFile.fileExtension] = fileparts(actigraphyFilePath);

regex.prefix = 'processed_output_';
regex.videoBasenameString = '(?<video_name_string>.+)_';
regex.frameString = 'frames_(?<startFrameIndex>\d+)-(?<endFrameIndex>\d+)_';
regex.allExpressions = [regex.prefix, regex.videoBasenameString, regex.frameString];

tokenNames = regexp(bbva_actigraphyFile.baseFileName, regex.allExpressions, 'names');

bbva_actigraphyFile.video_basename_string = tokenNames.video_name_string;
bbva_actigraphyFile.startFrameIndex = tokenNames.startFrameIndex;
bbva_actigraphyFile.endFrameIndex = tokenNames.endFrameIndex;


end

