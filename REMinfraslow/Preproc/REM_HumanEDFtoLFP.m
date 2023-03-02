function REM_HumanEDFtoLFP(varargin)
%
% REM_HumanEDFtoLFP(varargin)
%
% Expanded from EDFtoLFP by Dr. Brendon O. Watson. Reads human EEG
% EDF file into buzcode-compliant LFP file with 1250 Hz sampling.
% Requires XML file to run bz_getSessionInfo (see EDF_XML_template.xml).
%
% USAGE
%   - Run from EDF and XML-containing folder
%   - varargin: please see input parser section
%   - Dependencies: buzcode (https://github.com/buzsakilab/buzcode)
%                   edfread.m
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;
addParameter(p,'ShowWaitBar',false,@islogical)

parse(p,varargin{:})
ShowWaitBar = p.Results.ShowWaitBar;



%% File naming
d = dir('*.edf');
FileName    = d(1).name;
FileName    = FileName(1:end-4);
InFileName  = [FileName '.edf'];
OutFileName = [FileName '.lfp'];



%% Upsampling
[Header,OrigData] = edfread(InFileName);
EEGsamplFreq      = Header.frequency(1);
LFPsamplFreq      = 1250; % Hz, buzcode convention
UpSamplFactor     = LFPsamplFreq/EEGsamplFreq;
UpSamplLength     = round(size(OrigData,2)*UpSamplFactor);
NumChannels       = Header.ns;

UpSamplChn = cell(NumChannels,1);
for ChnIdx = 1:NumChannels
    
    if ShowWaitBar
        h = waitbar(ChnIdx/(NumChannels+1),'upsampling channels');
    end
    
    UpSamplChn{ChnIdx} = REM_InterpToNewLength(...
        OrigData(ChnIdx,:),UpSamplLength);
    
    if ShowWaitBar
        close(h)
    end
end
UpSamplChn = cell2mat(UpSamplChn);



%% Bring to buzcode convention and save. Save also the header file.
% Make sure there's an XML file with the same name as the subfolder.
% Check if XML has same number of channels shown in the EDF header.
disp('Converting to buzcode-compliant LFP')
ConvertedData = UpSamplChn(:);
OutFileID = fopen(OutFileName,'w');
fwrite(OutFileID,ConvertedData,'int16');
fclose(OutFileID);
save([FileName '_EDFheader'],'Header')
sessionInfo = bz_getSessionInfo(pwd,'noPrompts',true);
save([FileName '.sessionInfo.mat'],'sessionInfo')
disp('Done')

end