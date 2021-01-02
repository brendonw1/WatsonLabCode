function [pbeExtractedFrame, fallback_resultIndex, fallback_BBID, pbeExtractedFrameParseResults] = parseExtractedFrameOutputName(output_name_or_path)
%parseExtractedFrameOutputName Builds an output filename without extension for extracted video frames.
%   Detailed explanation goes here

% Example file names:
% Version 1: extractedFrame_Frame_299_BehavioralBox_B02_T20200221-1129190334_SAMPLED_SHORT.bmp
% Version 2: extractedFrame_BB02_i1.bmp

%%%+S- pbeExtractedFrame
	%- image - image is the greyscale image extracted
	%- frameIndex - frameIndex contains the integer frame number it was extracted from, or -1 if it doesn't have one
	%- sourceName - sourceName contains the basename of the video it was extracted from, or '' otherwise.
%

%%%+S- pbeExtractedFrameParseResults
	% fullPath - fullPath is the full path of the file that was parsed, if available.
	%- folder - folder is
	%- baseFileName - baseFileName is
	%- fileExtension - fileExtension is
	%- isVersion1 - isVersion1 is a boolean value that if true, indicates the parsed file was of the 'version 1' (see above) format.
	
	%% Version 1 Only:
	%-~ frameIndex - frameIndex contains the integer frame number it was extracted from, or -1 if it doesn't have one
	%-~ sourceName - sourceName contains the basename of the video it was extracted from, or '' otherwise.
	
	%% Version 2 Only:
	%-~ bbidString - bbidString is the pre-parsed string version of bbid with a 2-character fixed width format like '02'
	%-~ resultIndexString - resultIndexString is the pre-parsed string version of resultIndex
	
	%-~ bbid - bbid is the integer numeric box id
	%-~ resultIndex - resultIndex is the integer numeric result id
	
%

%% Prepare output results:

pbeExtractedFrameParseResults.isVersion1 = false;

% Version 1 Outputs:
pbeExtractedFrame.image = [];
pbeExtractedFrame.sourceName = '';
pbeExtractedFrame.frameIndex = -1;

% Version 2 Outputs
fallback_BBID = '';
fallback_resultIndex = -1;

pbeExtractedFrameParseResults.fullPath = output_name_or_path;
[pbeExtractedFrameParseResults.folder, pbeExtractedFrameParseResults.baseFileName, pbeExtractedFrameParseResults.fileExtension] = fileparts(pbeExtractedFrameParseResults.fullPath);

%% Common to both versions:
regex.prefix = 'extractedFrame';

%% Version: 1
regex.frameIndexString = 'Frame_(?<frameIndex>\d+)';
regex.sourceNameString = '(?<sourceName>.+)';

%% Version: 2
regex.bbidString = 'BB(?<bbid>\d{2})';
regex.resultIndexString = 'i(?<resultIndex>\d+)';


%% Version: 1
regex.allExpressions = join({regex.prefix, regex.frameIndexString, regex.sourceNameString}, '_');
regex.allExpressions = regex.allExpressions{1};
tokenNames = regexp(pbeExtractedFrameParseResults.baseFileName, regex.allExpressions, 'names');

% foundTokenNames = fieldnames(tokenNames);
if isempty(tokenNames)
	
	pbeExtractedFrameParseResults.sourceName = '';
	pbeExtractedFrameParseResults.frameIndex = -1;
	pbeExtractedFrame.frameIndex = -1;
	pbeExtractedFrame.sourceName = '';
	pbeExtractedFrameParseResults.isVersion1 = false;
	
else

	if isfield(tokenNames, 'frameIndex')
		pbeExtractedFrameParseResults.frameIndex = tokenNames.frameIndex;
	else
		pbeExtractedFrameParseResults.frameIndex = '';
	end

	if isfield(tokenNames, 'sourceName')
		pbeExtractedFrameParseResults.sourceName = tokenNames.sourceName;
	else
		pbeExtractedFrameParseResults.sourceName = '';
	end

	if ~isempty(pbeExtractedFrameParseResults.frameIndex)
		pbeExtractedFrame.frameIndex = num2str(pbeExtractedFrameParseResults.frameIndex);
		pbeExtractedFrameParseResults.isVersion1 = true;
	else
		pbeExtractedFrame.frameIndex = -1;
		pbeExtractedFrameParseResults.isVersion1 = false;
	end

	if ~isempty(pbeExtractedFrameParseResults.sourceName)
		pbeExtractedFrame.sourceName = pbeExtractedFrameParseResults.sourceName;
		pbeExtractedFrameParseResults.isVersion1 = pbeExtractedFrameParseResults.isVersion1 & true;
	else
		pbeExtractedFrame.sourceName = '';
		pbeExtractedFrameParseResults.isVersion1 = false;
	end

end
% Only try for version 2 if it isn't Version 1. Otherwise, just return the version 1 results.
if ~pbeExtractedFrameParseResults.isVersion1
	%% Version: 2
	regex.allExpressionsV2 = join({regex.prefix, regex.bbidString, regex.resultIndexString}, '_');
	regex.allExpressionsV2 = regex.allExpressionsV2{1};
	
	tokenNamesV2 = regexp(pbeExtractedFrameParseResults.baseFileName, regex.allExpressionsV2, 'names');
	
	if isempty(tokenNamesV2)
	
		pbeExtractedFrameParseResults.bbidString = '';
		pbeExtractedFrameParseResults.resultIndexString = '';
		pbeExtractedFrameParseResults.bbid = -1;
		pbeExtractedFrameParseResults.resultIndex = -1;
	
	else
	
		if isfield(tokenNamesV2, 'bbidString')
			pbeExtractedFrameParseResults.bbidString = tokenNamesV2.bbidString;
		else
			pbeExtractedFrameParseResults.bbidString = '';
		end

		if isfield(tokenNamesV2, 'resultIndexString')
			pbeExtractedFrameParseResults.resultIndexString = tokenNamesV2.resultIndexString;
		else
			pbeExtractedFrameParseResults.resultIndexString = '';
		end

		if ~isempty(pbeExtractedFrameParseResults.bbidString)
			pbeExtractedFrameParseResults.bbid = num2str(pbeExtractedFrameParseResults.bbidString);
			fallback_BBID = pbeExtractedFrameParseResults.bbid;
		else
			pbeExtractedFrameParseResults.bbid = -1;
		end

		if ~isempty(pbeExtractedFrameParseResults.resultIndexString)
			pbeExtractedFrameParseResults.resultIndex = num2str(pbeExtractedFrameParseResults.resultIndexString);
			fallback_resultIndex = num2str(pbeExtractedFrameParseResults.resultIndex);
		else
			pbeExtractedFrameParseResults.resultIndex = -1;
		end

	end
end


			
end

