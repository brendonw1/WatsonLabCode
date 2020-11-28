function UPstates_PlotUPSpindleEvenOddRestrictedData(UPSpindleEvenOddRestrictedData)

if ~exist('UPSpindleHalfData','var')
    UPSpindleEvenOddRestrictedData = UPstates_GatherUPSpindleEvenOddRestrictedData;
end
v2struct(UPSpindleEvenOddRestrictedData)%extracts field names as variables (necessary for labeling in fcns below)

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicCounts')


%% Fig comparing RAW CORRELATION COEFFS OF SEQUENCE TIMING VECTORS from different classes of events 
h(end+1) = figure;
hax = plot_nanmeanSD_bars(r_ue_seq_meanvpeak,r_nue_seq_meanvpeak,r_sue_seq_meanvpeak,...
    r_pue_seq_meanvpeak,r_eue_seq_meanvpeak,r_lue_seq_meanvpeak,r_se_seq_meanvpeak);
title(hax,'Raw')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
set(h(end),'name','UPSpindleEvenOddCorrelationsRestrictedToNumEventsAsSUPerSess')

%% Save figs 
od = cd;
savedir = '/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOddRestricted';
if ~exist(savedir,'dir')
    mkdir(savedir)
end
cd(savedir)
savefigsasname(h,'fig');
% close(h)
cd(od)

