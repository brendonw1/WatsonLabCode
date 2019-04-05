function UPstates_PlotUPSpindleTemplateNeighborhoodData

if ~exist('UPSpindleTemplateData','var')
    UPSpindleTemplateData = UPstates_GatherUPSpindleTemplateNeighborhoodData;
end
v2struct(UPSpindleTemplateData)%extracts field names as variables (necessary for labeling in fcns below)

%% Get rid of datasets with out at least 10 SpindleUPs
bad = NumSpindleUPs<10;
NumSpindleUPs(bad) = NaN;
NumNonSpindleUPs(bad) = NaN;
SupNeighRatio(bad) = NaN;
NupNeighRatio(bad) = NaN;

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
    ['N Non-SpindleUPs = ' num2str(nansum(NumNonSpindleUPs))];...
    ['N SpindleUPs = ' num2str(nansum(NumSpindleUPs))];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicCounts')

%% Fig comparing ratios of correlations CORRELATION of events to templates, averaged per session. 
h(end+1) = figure;
hax = subplot(3,1,1);
hist(SupNeighRatio,100)
% xlim([-10 10])
xlabel(hax,'Spindle UP vs Local Nup Ratio Means per session')
hax = subplot(3,1,2);
hist(NupNeighRatio,100)
% xlim([-10 10])
xlabel(hax,'NonSpindle UP vs Local Nup Ratio Means per session')
hax = subplot(3,1,3)
hax = plot_nanmeanSD_bars(SupNeighRatio,NupNeighRatio);
set(hax,'XTick',[1:2])
set(hax,'XTickLabel',{'SupRatios';'NupRatios'})
ylabel(hax,'Mean Ratio to Local Nups (Mean of means +-SD)')

AboveTitle({'Ratios of [(Corrs of events to UP template) / (Corrs of Local Non-Spindle UP Neighbors to template)]';...
    ['Only for sessions with greater than 10 Spindle UPs,n = ' num2str(sum(~isnan(NumSpindleUPs)))]})

set(h(end),'name','SpUPandNSpUPLocalNeighborratios')

%% save figures
od = cd;
savedir = '/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateNeighborhood';
if ~exist(savedir,'dir')
    mkdir(savedir)
end
cd(savedir)
savefigsasname(h,'fig');
% close(h)
cd(od)