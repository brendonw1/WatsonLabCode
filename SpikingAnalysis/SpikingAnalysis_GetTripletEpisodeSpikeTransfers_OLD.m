function SWSREMSWSEpisode_Transfers = SpikingAnalysis_GetTripletEpisodeSpikeTransfers(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses)

% Get necessary triplet episodes... see function below for details
% PreSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.presleepInt);
PreSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.presleepInt);

% PostSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.postsleepInt);
PostSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.postsleepInt);


% %% PRESLEEP
% %assess EConnections in pre-sleep using BW detection of S-R-S episodes
% h = figure;
% subplot(2,1,1)
% PreleepETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,funcsynapses.ConnectionsE,funcsynapses);
% title({[basename '-SWSREMSWS-PreSleep-ETransferChanges-BWLenientDetection.  Error bars are SEM.'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ETransferChanges-BWLenientDetection'])
% subplot(2,1,2)
% PreleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(funcsynapses.ConnectionsE));
% title({[basename '-SWSREMSWS-PreSleep-ECellRates-BWLenientDetection'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})
% 
% %assess I in pre-sleep using BW detection of S-R-S episodes
% h = figure;
% subplot(2,1,1)
% PreleepITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,funcsynapses.ConnectionsI,funcsynapses);
% title({[basename '-SWSREMSWS-PreSleep-ITransferChanges-BWLenientDetection. Error bars are SEM.'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ITransferChanges-BWLenientDetection'])
% subplot(2,1,2)
% PreleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(funcsynapses.ConnectionsI));
% title({[basename '-SWSREMSWS-PreSleep-ICellRates-BWLenientDetection'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})

%% EE transfers
Episodes = PreSleepBWEpisodes;
str = 'EE';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

thesepairs = funcsynapses.ConnectionsEE;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PreleepEETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PreSleep-EETransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PreleepEEPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PreSleep-EE-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PreleepEEPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PreSleep-EE-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-EETransferChanges-BWLenientDetection'])

%% EI transfers
thesepairs = funcsynapses.ConnectionsEI;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PreleepEITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PreSleep-EITransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PreleepEIPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PreSleep-EI-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PreleepEIPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PreSleep-EI-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-EITransferChanges-BWLenientDetection'])

%% IE transfers
thesepairs = funcsynapses.ConnectionsIE;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PreleepIETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PreSleep-IETransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PreleepIEPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PreSleep-IE-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PreleepIEPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PreSleep-IE-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-IETransferChanges-BWLenientDetection'])

%% II transfers
thesepairs = funcsynapses.ConnectionsII;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PreleepIITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PreSleep-IITransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PreleepIIPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PreSleep-II-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PreleepIIPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PreSleep-II-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-IITransferChanges-BWLenientDetection'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PreleepZLTransfersBW = SpikingAnalysis_TripletEpisodeZLTransferPlotting(PreSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PreSleep-ZLTransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(2,1,2)
    PreleepZLCellRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs)));
    title({[basename '-SWSREMSWS-PreSleep-ZeroLag-CellRates'];...
        ['n=' num2str(length(unique(thesepairs))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-ZLTransferChanges-BWLenientDetection'])


% %assess E in pre-sleep using Andres detection
% h = figure;
% PresleepETransfersAndres = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepAndresEpisodes,S,funcsynapses.ConnectionsE,funcsynapses);
% title({[basename '-SWSREMSWS-Preleep-ETransferChanges-AndresDetection'];...
%     ['n=' num2str(size(PreSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ETransferChanges-AndresDetection'])
% %assess I in pre-sleep using Andres detection
% h = figure;
% PresleepITransfersAndres = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepAndresEpisodes,S,funcsynapses.ConnectionsI,funcsynapses);
% title({[basename '-SWSREMSWS-Preleep-ITransferChanges-AndresDetection'];...
%     ['n=' num2str(size(PreSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ITransferChanges-AndresDetection'])

%% POSTSLEEP
h = figure;
subplot(2,1,1)
PostleepETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,funcsynapses.ConnectionsE,funcsynapses);
title({[basename '-SWSREMSWS-PostSleep-ETransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ETransferChanges-BWLenientDetection'])
subplot(2,1,2)
PostleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(funcsynapses.ConnectionsE));
title({[basename '-SWSREMSWS-PostSleep-ECellRates-BWLenientDetection'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})

%assess I in pre-sleep using BW detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PostleepITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,funcsynapses.ConnectionsI,funcsynapses);
title({[basename '-SWSREMSWS-PostSleep-ITransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ITransferChanges-BWLenientDetection'])
subplot(2,1,2)
PostleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(funcsynapses.ConnectionsI));
title({[basename '-SWSREMSWS-PostSleep-ICellRates-BWLenientDetection'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})

%% EE transfers
thesepairs = funcsynapses.ConnectionsEE;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PostleepEETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PostSleep-EETransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PostleepEEPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PostSleep-EE-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PostleepEEPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PostSleep-EE-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-EETransferChanges-BWLenientDetection'])

%% EI transfers
thesepairs = funcsynapses.ConnectionsEI;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PostleepEITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PostSleep-EITransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PostleepEIPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PostSleep-EI-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PostleepEIPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PostSleep-EI-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-EITransferChanges-BWLenientDetection'])

%% IE transfers
thesepairs = funcsynapses.ConnectionsIE;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PostleepIETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PostSleep-IETransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PostleepIEPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PostSleep-IE-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PostleepIEPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PostSleep-IE-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-IETransferChanges-BWLenientDetection'])

%% II transfers
thesepairs = funcsynapses.ConnectionsII;
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    PostleepIITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PostSleep-IITransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(3,1,2)
    PostleepIIPresynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,1))));
    title({[basename '-SWSREMSWS-PostSleep-II-PresynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,1)))) ' Cells']})
    subplot(3,1,3)
    PostleepIIPostsynRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs(:,2))));
    title({[basename '-SWSREMSWS-PostSleep-II-PostsynapticRates'];...
        ['n=' num2str(length(unique(thesepairs(:,2)))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-IITransferChanges-BWLenientDetection'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PostleepZLTransfersBW = SpikingAnalysis_TripletEpisodeZLTransferPlotting(PostSleepBWEpisodes,S,thesepairs,funcsynapses);
    title({[basename '-SWSREMSWS-PostSleep-ZLTransferChanges-BWLenientDetection. Error bars are SEM.'];...
        ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs']})
    subplot(2,1,2)
    PostleepZLCellRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs)));
    title({[basename '-SWSREMSWS-PostSleep-ZeroLag-CellRates'];...
        ['n=' num2str(length(unique(thesepairs))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-ZLTransferChanges-BWLenientDetection'])
% %assess E in post-sleep using Andres detection
% h = figure;
% PostsleepETransfersAndres = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepAndresEpisodes,S,funcsynapses.ConnectionsE,funcsynapses);
% title({[basename '-SWSREMSWS-PostSleep-ETransferChanges-AndresDetection'];...
%     ['n=' num2str(size(PostSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-ETransferChanges-AndresDetection'])
% %assess I in post-sleep using Andres detection
% h = figure;
% PostsleepITransfersAndres = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepAndresEpisodes,S,funcsynapses.ConnectionsI,funcsynapses);
% title({[basename '-SWSREMSWS-PostSleep-ITransferChanges-AndresDetection'];...
%     ['n=' num2str(size(PostSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-ITransferChanges-AndresDetection'])




%save figs
if ~exist(fullfile(basepath,'SWSREMSWSEpisodeFigs'),'dir')
    mkdir(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
end
cd(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
saveallfigsas('fig')
cd(basepath)
% 

% set up for output
clear basename basepath intervals PrePostSleepMetaData S funcsynapses a h
workspace2struct %script that always makes a variable called workspacestruct
SWSREMSWSEpisode_Transfers = workspacestruct;

% SWSREMSWSEpisode_Transfers = v2struct(PreSleepAndresEpisodes,PreSleepBWEpisodes,...
%     PostSleepAndresEpisodes, PostSleepBWEpisodes,...
%     PreleepETransfersBW, PreleepITransfersBW,...
%     PresleepETransfersAndres, PresleepITransfersAndres,...
%     PostsleepETransfersBW, PostsleepITransfersBW,...
%     PostsleepETransfersAndres, PostsleepITransfersAndres);


% clear PreSleepAndresEpisodes PreSleepBWEpisodes ...
%     PostSleepAndresEpisodes PostSleepBWEpisodes ...
%     PreleepERatesBW PreleepIRatesBW ...
%     PresleepERatesAndres PresleepIRatesAndres ...
%     PostsleepERatesBW PostsleepIRatesBW ...
%     PostsleepERatesAndres  PostsleepIRatesAndres


function [Transfers,PresynRates,PostsynRates] = PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp)

eval(['thesepairs = funcsynapses.Connections',str,';']);
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    eval(['Transfers = SpikingAnalysis_TripletEpisodeTransferPlotting(Episodes,S,thesepairs,funcsynapses);'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'TransferChanges-BWLenientDetection''];',...
    '[''n='' num2str(size(Episodes,2)) '' Episodes.  n = '' num2str(size(thesepairs,1)) '' Pairs. Error bars are SEM.'']})'])
    subplot(3,1,2)
    eval(['PresynRates = SpikingAnalysis_TripletEpisodeRatePlotting(Episodes,S(unique(thesepairs(:,1))));'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'-PresynapticRates''];',...
        '[''n='' num2str(length(unique(thesepairs(:,1)))) '' Cells'']})'])
    subplot(3,1,3)
    eval(['PostsynRates = SpikingAnalysis_TripletEpisodeRatePlotting(Episodes,S(unique(thesepairs(:,2))));'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'-PostsynapticRates''];',...
        '[''n='' num2str(length(unique(thesepairs(:,2)))) '' Cells'']})'])
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
eval(['set(h,''name'',[basename ''-SWSREMSWS',pp,'sleep-',str,'TransferChanges-BWLenientDetection''])'])
