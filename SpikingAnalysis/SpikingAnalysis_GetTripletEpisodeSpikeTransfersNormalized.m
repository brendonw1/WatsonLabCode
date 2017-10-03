function SWSREMSWSEpisode_Transfers = SpikingAnalysis_GetTripletEpisodeSpikeTransfersNormalized(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses)

percell = 0;
normalize = 1;

% Get necessary triplet episodes... see function below for details
% PreSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.presleepInt);
PreSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.presleepInt);

% PostSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.postsleepInt);
PostSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.postsleepInt);


%% PRESLEEP
%assess EConnections in pre-sleep using BW detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PreSleepETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,funcsynapses.ConnectionsE,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PreSleep-ETransferChanges-BWLenientDetection'];...
    ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes. Error bars are SEM.']})
set(h,'name',[basename '-SWSREMSWSPresleep-ETransferChanges-BWLenientDetection'])
subplot(2,1,2)
PreSleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(funcsynapses.ConnectionsE));
title({[basename '-SWSREMSWS-PreSleep-ECellRates-BWLenientDetection'];...
    ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})

%assess I in pre-sleep using BW detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PreSleepITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepBWEpisodes,S,funcsynapses.ConnectionsI,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PreSleep-ITransferChanges-BWLenientDetection'];...
    ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes. Error bars are SEM.']})
set(h,'name',[basename '-SWSREMSWSPresleep-ITransferChanges-BWLenientDetection'])
subplot(2,1,2)
PreSleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(funcsynapses.ConnectionsI));
title({[basename '-SWSREMSWS-PreSleep-ICellRates-BWLenientDetection'];...
    ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})

%% EE transfers
Episodes = PreSleepBWEpisodes;
str = 'EE';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% EI transfers
Episodes = PreSleepBWEpisodes;
str = 'EI';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% IE transfers
Episodes = PreSleepBWEpisodes;
str = 'IE';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% II transfers
Episodes = PreSleepBWEpisodes;
str = 'II';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PreSleepZLTransfersBW = SpikingAnalysis_TripletEpisodeZLTransferPlottingNormalized(PreSleepBWEpisodes,S,thesepairs,funcsynapses,percell,normalize);
    title({[basename '-SWSREMSWS-PreSleep-ZLTransferChanges-BWLenientDetection'];...
        ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs. Error bars are SEM.']})
    subplot(2,1,2)
    PreSleepZLCellRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,S(unique(thesepairs)));
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
PostSleepETransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,funcsynapses.ConnectionsE,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PostSleep-ETransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ETransferChanges-BWLenientDetection'])
subplot(2,1,2)
PostSleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(funcsynapses.ConnectionsE));
title({[basename '-SWSREMSWS-PostSleep-ECellRates-BWLenientDetection'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})

%assess I in pre-sleep using BW detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PostSleepITransfersBW = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepBWEpisodes,S,funcsynapses.ConnectionsI,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PostSleep-ITransferChanges-BWLenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ITransferChanges-BWLenientDetection'])
subplot(2,1,2)
PostSleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(funcsynapses.ConnectionsI));
title({[basename '-SWSREMSWS-PostSleep-ICellRates-BWLenientDetection'];...
    ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})


%% EE transfers
Episodes = PreSleepBWEpisodes;
str = 'EE';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% EI transfers
Episodes = PreSleepBWEpisodes;
str = 'EI';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% IE transfers
Episodes = PreSleepBWEpisodes;
str = 'IE';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% II transfers
Episodes = PreSleepBWEpisodes;
str = 'II';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp);'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PostSleepZLTransfersBW = SpikingAnalysis_TripletEpisodeZLTransferPlottingNormalized(PostSleepBWEpisodes,S,thesepairs,funcsynapses,percell,normalize);
    title({[basename '-SWSREMSWS-PostSleep-ZLTransferChanges-BWLenientDetection'];...
        ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs. Error bars are SEM.']})
    subplot(2,1,2)
    PostSleepZLCellRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,S(unique(thesepairs)));
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
clear basename basepath intervals PrePostSleepMetaData S funcsynapses a h pp str thesepairs Episodes
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


function [Transfers,PresynRates,PostsynRates] = PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize)

eval(['thesepairs = funcsynapses.Connections',str,';']);
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    eval(['Transfers = SpikingAnalysis_TripletEpisodeTransferPlotting(Episodes,S,thesepairs,funcsynapses,percell,normalize);'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'TransferChanges-BWLenientDetection''];',...
    '[''n='' num2str(size(Episodes,2)) '' Episodes.  n = '' num2str(size(thesepairs,1)) '' Pairs. Error bars are SEM.'']})'])
    subplot(3,1,2)
    eval(['PresynRates = SpikingAnalysis_TripletEpisodeRatePlotting(Episodes,S(unique(thesepairs(:,1))),percell,normalize);'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'-PresynapticRates''];',...
        '[''n='' num2str(length(unique(thesepairs(:,1)))) '' Cells'']})'])
    subplot(3,1,3)
    eval(['PostsynRates = SpikingAnalysis_TripletEpisodeRatePlotting(Episodes,S(unique(thesepairs(:,2))),percell,normalize);'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'-PostsynapticRates''];',...
        '[''n='' num2str(length(unique(thesepairs(:,2)))) '' Cells'']})'])
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
    Transfers = [];
    PresynRates = [];
    PostsynRates = [];
end
eval(['set(h,''name'',[basename ''-SWSREMSWS',pp,'sleep-',str,'TransferChanges-BWLenientDetection''])'])
