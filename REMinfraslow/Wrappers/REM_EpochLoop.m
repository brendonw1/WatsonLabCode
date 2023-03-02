function [ConcatEpochs,SamplFreqs] = ...
    REM_EpochLoop(SessionPath,ThetaChn,varargin)
%
% [ConcatEpochs,SamplFreqs] = REM_EpochLoop(SessionPath,ThetaChn,varargin)
%
% This wrapper function loops through REM and WAKE epochs of a given
% session, performs analyses using other functions of this repository, and
% concatenates analyzed data into a table (ConcatEpochs). This table can
% then be further concatenated with other tables from other sessions,
% for example using REM_SessionLoop.
%
% This wrapper function can be used as a template.
%
% USAGE
%   - SessionPath: string (e.g., 'data/user/...').
%   - ThetaChn: LFP channel index, independent on remapping
%   - varargin: please see input parser section
%   - Dependencies: other functions in this repository, which in turn
%                   have their own dependencies (see their instructions)
%
% OUTPUTS
%   - ConcatEpochs: a table with epochs in rows and variables in columns.
%                   Rows can be sorted based on brain states, epoch
%                   durations, etc.
%   - SamplFreqs: a structure with sampling rates in Hz, from physiology
%                 to video data (when present).
%
% The outputs are also saved in the session folder for later use
% (for example, with REM_SessionLoop).
%                   
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

% for theta analysis
addParameter(p,'FreqLims',[5 10],@isnumeric) % Hz
addParameter(p,'FreqBinSize',0.05,@isnumeric) % Hz
addParameter(p,'NumCycles',40,@isnumeric)
addParameter(p,'SamplFreq',125,@isnumeric) % Hz
addParameter(p,'TimeSmth',5,@isnumeric) % seconds
addParameter(p,'ShowWaitBar',false,@islogical)

parse(p,varargin{:})
FreqLims    = p.Results.FreqLims;
FreqBinSize = p.Results.FreqBinSize;
NumCycles   = p.Results.NumCycles;
SamplFreq   = p.Results.SamplFreq;
TimeSmth    = p.Results.TimeSmth;
ShowWaitBar = p.Results.ShowWaitBar;

EphysParams.ThetaChn    = ThetaChn;
EphysParams.FreqLims    = FreqLims;
EphysParams.FreqBinSize = FreqBinSize;
EphysParams.NumCycles   = NumCycles;
EphysParams.SamplFreq   = SamplFreq;



%% Other parameters
InitPath = pwd; % Go back to this path once finished.
cd(SessionPath)
SessionName = bz_BasenameFromBasepath(SessionPath);
load([SessionName '.sessionInfo.mat'],'sessionInfo')
DefSamplFreq   = sessionInfo.rates.lfp;
DwnSamplFactor = DefSamplFreq/SamplFreq;
REMints        = sessionInfo.TrimmedREM;
WAKEints       = sessionInfo.TrimmedWAKE;
NumEpochs      = size(REMints,1);
EpochDurSec    = diff(REMints,1,2);

if NumEpochs ~= size(WAKEints,1)
    error('Inconsistent number of epochs between states. Check ephys epochs.')
elseif ...
        NumEpochs == size(WAKEints,1) && ...
        ~isequal(EpochDurSec,diff(WAKEints,1,2))
    error('Inconsistent epoch durations between states. Check ephys epochs.')
end

load([SessionName '.SleepState.states.mat'],'SleepState')
UntrimREMints  = SleepState.ints.REMstate;



%% Get LFP, start the tables
REMephys = bz_GetLFP(EphysParams.ThetaChn,...
    'intervals',REMints,'downsample',DwnSamplFactor);
REMephys = struct2cell(REMephys);
REMephys = [repmat({SessionName},NumEpochs,1) ...
    repmat({'REM'},NumEpochs,1) num2cell(EpochDurSec) ...
    permute(REMephys(4,1,:),[3 2 1])];

WAKEephys = bz_GetLFP(EphysParams.ThetaChn,...
    'intervals',WAKEints,'downsample',DwnSamplFactor);
WAKEephys = struct2cell(WAKEephys);
WAKEephys = [repmat({SessionName},NumEpochs,1) ...
    repmat({'WAKE'},NumEpochs,1) num2cell(EpochDurSec) ...
    permute(WAKEephys(4,1,:),[3 2 1])];



%% Load high-sampling EMG. This one will be epoched in the loop.
load([SessionName '.HighSamplEMG.mat'],'HighSamplEMG')



%% Epoch loop: electrophysiology
for EpIdx = 1:NumEpochs
    
    if ShowWaitBar
        h = waitbar(EpIdx/(NumEpochs+1),'processing theta/EMG');
    end
    
    % Spectrograms (not saved in the table) _______________________________
    REMspectr = REM_WavelSpectr(REMephys{EpIdx,4},EphysParams);
    [WAKEspectr,EphysParams.FreqList] = REM_WavelSpectr(...
        WAKEephys{EpIdx,4},EphysParams);
    
    % Theta fluctuations (pre Z scoring, not saved in the table) __________
    REMtheta       = REM_ThetaFreqAndPower(REMspectr,EphysParams);
    REMthetaFreq   = detrend(mean(REMtheta.RidgeFreqs)/REMtheta.RidgeVar);
    REMthetaPower  = detrend(REMtheta.MeanPower);
    WAKEtheta      = REM_ThetaFreqAndPower(WAKEspectr,EphysParams);
    WAKEthetaFreq  = detrend(mean(WAKEtheta.RidgeFreqs)/WAKEtheta.RidgeVar);
    WAKEthetaPower = detrend(WAKEtheta.MeanPower);
    
    % Theta fluctuations (post Z scoring, saved in the table) _____________
    [REMthetaFreq,WAKEthetaFreq] = REM_JointZscNorm(...
        REMthetaFreq',WAKEthetaFreq','z');
    [REMthetaPower,WAKEthetaPower] = REM_JointZscNorm(...
        REMthetaPower',WAKEthetaPower','z');
    
    REMephys{EpIdx,4}  = REMthetaFreq; % Overwrite raw LFP
    REMephys{EpIdx,5}  = REMthetaPower;
    WAKEephys{EpIdx,4} = WAKEthetaFreq; % Overwrite raw LFP
    WAKEephys{EpIdx,5} = WAKEthetaPower;
    
    % Indices for EMG epoching (not saved in the table) ___________________
    REMidx  = (REMints(EpIdx,1)*SamplFreq)+1:REMints(EpIdx,2)*SamplFreq;
    WAKEidx = (REMints(EpIdx,1)*SamplFreq)+1:REMints(EpIdx,2)*SamplFreq;
    
    % Epoched EMG (saved in the table) ____________________________________
    REMemg  = detrend(smoothdata(movmean(HighSamplEMG(REMidx),...
        SamplFreq*TimeSmth),'gaussian',SamplFreq));
    WAKEemg = detrend(smoothdata(movmean(HighSamplEMG(WAKEidx),...
        SamplFreq*TimeSmth),'gaussian',SamplFreq));
    [REMemg,WAKEemg]  = REM_JointZscNorm(REMemg,WAKEemg,'z');
    REMephys{EpIdx,6}  = REMemg;
    WAKEephys{EpIdx,6} = WAKEemg;
    
    if ShowWaitBar
        close(h)
    end
end



%% Manage facial movement data. Due to the deeplabcut pipeline, the user
% may decide to store CSV files and related MAT files alongside the epoched
% videos in their subfolders, unlike the buzcode system. Hence the proposal
% below, of creating dir subsets based on custom subfolder names. This can
% be modified to match your subfolder system.
FacMovFiles = table2cell(struct2table(dir([SessionPath filesep '**/*.mat'])));
FacMovFiles = FacMovFiles(:,1:2);
WhereSubF   = false(size(FacMovFiles,1),5); % five-column logical
for FileIdx = 1:size(FacMovFiles,1)
    
    % Column 1: identify DLC coordinate files _____________________________
    if contains(FacMovFiles{FileIdx,1},'DLCcoords')
        WhereSubF(FileIdx,1) = true;
    end
    
    % Columns 2 and 3: eye/pupil vs. whisking subfolders __________________
    if contains(FacMovFiles{FileIdx,2},'Eye')
        WhereSubF(FileIdx,2) = true;
    elseif contains(FacMovFiles{FileIdx,2},'Whisking')
        WhereSubF(FileIdx,3) = true;
    end
    
    % Columns 4 and 5: REM vs. WAKE subfolders ____________________________
    if contains(FacMovFiles{FileIdx,2},['REM' filesep 'Episode'])
        WhereSubF(FileIdx,4) = true;
    elseif contains(FacMovFiles{FileIdx,2},['WAKE' filesep 'Episode'])
        WhereSubF(FileIdx,5) = true;
    end
end
REMeye   = FacMovFiles(sum(WhereSubF(:,[1 2 4]),2)==3,:);
WAKEeye  = FacMovFiles(sum(WhereSubF(:,[1 2 5]),2)==3,:);
REMwhsk  = FacMovFiles(sum(WhereSubF(:,[1 3 4]),2)==3,:);
WAKEwhsk = FacMovFiles(sum(WhereSubF(:,[1 3 5]),2)==3,:);

if ~isequal(size(REMeye),size(WAKEeye),size(REMwhsk),size(WAKEwhsk))
    error('Inconsistent number of epochs in facial movement data.')
end



%% Epoch loop: facial movements (if existent)
if ~isempty(REMwhsk)
    for EpIdx = 1:NumEpochs
        
        % Separate try/catch to avoid cross-contamination of missing data
        try
            load([REMeye{EpIdx,2} filesep 'EyePupilData.mat'],...
                'EyePupilData','Params');
            EyePupilData = table2cell(EyePupilData);
            EyeFrameRate = Params.VidFrameRate;
            % Pupil speed and eyeblink envelopes (REM_EyeDataSingleEpoch)
            REMeye(EpIdx,3:4) = EyePupilData(:,[8 4]);
        catch % if no data
            REMeye(EpIdx,3:4) = cell(1,2);
        end
        
        try
            load([WAKEeye{EpIdx,2} filesep 'EyePupilData.mat'],...
                'EyePupilData');
            EyePupilData = table2cell(EyePupilData);
            % Pupil speed and eyeblink envelopes (REM_EyeDataSingleEpoch)
            WAKEeye(EpIdx,3:4) = EyePupilData(:,[8 4]);
        catch % if no data
            WAKEeye(EpIdx,3:4) = cell(1,2);
        end
        
        try
            load([REMwhsk{EpIdx,2} filesep 'WhiskerData.mat'],...
                'WhiskerData','Params');
            WhiskerFrameRate = Params.VidFrameRate;
            WhiskerData = table2cell(WhiskerData);
            % Whisker speed envelope (REM_WhiskerDataSingleEpoch)
            REMwhsk(EpIdx,3) = WhiskerData(:,5);
        catch % if no data
            REMwhsk(EpIdx,3) = cell(1);
        end
        
        try
            load([WAKEwhsk{EpIdx,2} filesep 'WhiskerData.mat'],...
                'WhiskerData');
            WhiskerData = table2cell(WhiskerData);
            % Whisker speed envelope (REM_WhiskerDataSingleEpoch)
            WAKEwhsk(EpIdx,3) = WhiskerData(:,5);
        catch % if no data
            WAKEwhsk(EpIdx,3)  = cell(1);
        end
    end
    
    REMdata  = [REMephys REMeye(:,end-1:end) REMwhsk(:,end)];
    WAKEdata = [WAKEephys WAKEeye(:,end-1:end) WAKEwhsk(:,end)];
    
    % Trim facial movement epochs _________________________________________
    for EpIdx = 1:NumEpochs
        for VarIdx = 7:9
            
            if VarIdx ~= 9
                VidFrameRate = EyeFrameRate;
            else
                VidFrameRate = WhiskerFrameRate;
            end
            
            % REM only. WAKE epochs assumed to be from post-trimming
            % epoch sizes
            REMleftMargin = (REMints(EpIdx,1)-UntrimREMints(EpIdx,1))*...
                VidFrameRate;
            REMdata{EpIdx,VarIdx} = REMdata{EpIdx,VarIdx}(...
                REMleftMargin+1:end);
            REMdata{EpIdx,VarIdx} = REMdata{EpIdx,VarIdx}(...
                1:diff(REMints(EpIdx,:))*VidFrameRate);
        end
    end
    
    % Output with facial movement data ____________________________________
    ConcatEpochs = cell2table([REMdata;WAKEdata],...
        'VariableNames',{'Session','State','EpochDurSec',...
        'ThetaFreq','ThetaPower','EMGfromLFP',...
        'SaccadingEnvel','BlinkingEnvel','WhiskingEnvel'});
else
    % Output without facial movement data _________________________________
    ConcatEpochs = cell2table([REMephys;WAKEephys],...
        'VariableNames',{'Session','State','EpochDurSec',...
        'ThetaFreq','ThetaPower','EMGfromLFP'});
end



%% Save
SamplFreqs.ThetaEMG = SamplFreq;
try % if no facial movement data, skip
    SamplFreqs.EyeMovem = EyeFrameRate;
    SamplFreqs.Whisking = WhiskerFrameRate;
catch
end
save([SessionName '.ConcatEpochs.mat'],'ConcatEpochs','SamplFreqs')
disp('saved ConcatEpochs in session folder')
cd(InitPath) % Back to initial path
    
end