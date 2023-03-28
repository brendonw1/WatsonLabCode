function REM_EpisodeTrimmer(varargin)
%
% REM_EpisodeTrimmer(varargin)
%
% GUI-based manual trimming of REM epochs based on theta activity and EMG 
% from LFP.  Make sure REM epochs from TheStateEditor have 30-60 s margins 
% on both sides prior to running this.
%
% USAGE
%   - Run from MOUSE_YYMMDD folder containing saved MAT files (see
%     REM_Preproc).
%   - varargin: please see input parser section
%   - Dependency: buzcode (https://github.com/buzsakilab/buzcode).
%
% An interactive figure will appear, showing a REM episode. The first and
% second mouse clicks indicate the onset and offset of that REM episode,
% respectively. Click anywhere on the figures, only x-axis indices are
% collected. After determining the onset and offset time points, press any
% key to close the figure and proceed to the next REM episode. After
% trimming the last REM episode, a list of REM onset/offset timestamps is
% saved in sessionInfo.mat. Timestamps are in seconds, relative to session
% start.
% 
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% Spectrogram parameters
addParameter(p,'WideFreqLims',[1 15],@isnumeric) % Hz, theta surroundings
addParameter(p,'NarrowFreqLims',[5 10],@isnumeric) % Hz, theta proper
addParameter(p,'FreqBinSize',0.05,@isnumeric) % Hz
addParameter(p,'NumCycles',40,@isnumeric)
addParameter(p,'FreqSmth',1,@isnumeric) % Hz
addParameter(p,'TimeSmth',5,@isnumeric) % seconds

parse(p,varargin{:})
WideFreqLims   = p.Results.WideFreqLims;
NarrowFreqLims = p.Results.NarrowFreqLims;
FreqBinSize    = p.Results.FreqBinSize;
NumCycles      = p.Results.NumCycles;
FreqSmth       = p.Results.FreqSmth;
TimeSmth       = p.Results.FreqSmth;

load([bz_BasenameFromBasepath(pwd) '.sessionInfo.mat'],'sessionInfo');
DefSamplFreq  = sessionInfo.rates.lfp;
REMsamplFreq  = sessionInfo.REMsamplFreq;
DnSamplFactor = DefSamplFreq/REMsamplFreq;

Params.FreqLims    = WideFreqLims;
Params.FreqBinSize = FreqBinSize;
Params.NumCycles   = NumCycles;
Params.SamplFreq   = REMsamplFreq;

FreqSmth = FreqSmth/FreqBinSize;



%% Index for theta frequencies
WideFreqList  = WideFreqLims(1)+FreqBinSize:FreqBinSize:WideFreqLims(2);
NarrowFreqIdx = ...
    WideFreqList >= NarrowFreqLims(1)+FreqBinSize & ...
    WideFreqList <= NarrowFreqLims(2);



%% Custom Y axes for spectrograms
WideYtickLabels = unique(round(WideFreqList));
WideYtickLabels = WideYtickLabels(mod(WideYtickLabels,2) == 0);
WideYtickLabels = WideYtickLabels(2:end);
WideYticks = find(ismember(...
    WideFreqList,WideYtickLabels));



%% Load data
load([bz_BasenameFromBasepath(pwd) '.HighSamplEMG.mat'],'HighSamplEMG')
load([bz_BasenameFromBasepath(pwd) '.SleepState.states.mat'],'SleepState');
REMints  = SleepState.ints.REMstate;
NumEpis  = size(REMints,1);
ThetaChn = ...
    SleepState.detectorinfo.detectionparms.SleepScoreMetrics.THchanID;
LFP = bz_GetLFP(ThetaChn,'intervals',REMints,'downsample',DnSamplFactor);
LFP = table2cell(struct2table(LFP));
LFP = LFP(:,4);



%% Episode loop
TrimmedREMints = REMints;
for EpisIdx = 1%:NumEpis
    
    disp(['episode #' num2str(EpisIdx) ' of ' num2str(NumEpis)])
    EpisLength = length(LFP{EpisIdx});
    
    % Theta-surrounding spectrogram _______________________________________
    ThetaSpectr = REM_WavelSpectr(LFP{EpisIdx},Params);
    ThetaSpectr = smoothdata(smoothdata(ThetaSpectr,...
        1,'movmean',FreqSmth),2,'movmean',REMsamplFreq*TimeSmth);
    ZscThetaSpectr = zscore(ThetaSpectr);
    
    % Theta ratio _________________________________________________________
    ThetaRatio = zscore(...
        mean(ThetaSpectr(NarrowFreqIdx,:))./...
        mean(ThetaSpectr(~NarrowFreqIdx,:)));
        
    % EMG from LFP ________________________________________________________
    EpochIdx = (...
        REMints(EpisIdx,1)*REMsamplFreq)+1:...
        REMints(EpisIdx,2)*REMsamplFreq;
    EMGfromLFP = zscore(smoothdata(movmean(HighSamplEMG(EpochIdx)',...
        REMsamplFreq*TimeSmth),'gaussian',REMsamplFreq));
    
    % Figure ______________________________________________________________
    figure('units','normalized','outerposition',[0 0 1 1])
    set(gcf,'color','w')
    colormap(jet)
    if EpisLength/REMsamplFreq <= 60 % short epochs
        XtickSpacing = 15; % s
    else % long epochs
        XtickSpacing = 30; % s
    end
    
    subplot(2,1,1)
    imagesc(ZscThetaSpectr)
    set(gca,'YDir','normal')
    title([bz_BasenameFromBasepath(pwd) ', episode # ' ...
        num2str(EpisIdx) ' of ' num2str(NumEpis)],...
        'interpreter','none','FontWeight','normal');
    xticks(0:REMsamplFreq*XtickSpacing:EpisLength)
    xticklabels([])
    yticks(WideYticks)
    yticklabels(WideYtickLabels)
    REM_ColorbarEdits
    REM_FigEdits;box on
    
    subplot(2,1,2);hold on
    plot(ThetaRatio,'color',[0 0.6 0.6],'LineWidth',2)
    plot(EMGfromLFP,'color','k','LineWidth',2)
    xticks(0:REMsamplFreq*XtickSpacing:EpisLength)
    xticklabels(0:XtickSpacing:EpisLength/REMsamplFreq)
    xlim([0 EpisLength])
    xlabel('time (s)')
    ylabel('Z score');
    legend({'theta ratio','EMG'},'box','off','FontSize',14,...
        'location','northwest')
    REM_FigEdits
    
    % Trimming ____________________________________________________________
    [REMonset,~] = ginput(1);
    [REMoffset,~] = ginput(1);
    NewREMints = round([REMonset REMoffset]/REMsamplFreq);
    TrimmedREMints(EpisIdx,1) = TrimmedREMints(EpisIdx,1)+NewREMints(1);
    TrimmedREMints(EpisIdx,2) = TrimmedREMints(EpisIdx,1)+diff(NewREMints);
    pause
    close
end



%% Save new timestamps
sessionInfo.TrimmedREM = TrimmedREMints;
save([bz_BasenameFromBasepath(pwd) '.sessionInfo.mat'],'sessionInfo');
disp('saved trimmed REM timestamps in sessionInfo')

end