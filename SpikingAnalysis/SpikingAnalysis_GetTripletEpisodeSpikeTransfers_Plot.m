function SWSREMSWSEpisode_Transfers = SpikingAnalysis_GetTripletEpisodeSpikeTransfers_Plot(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses,percell,normalize)

if ~exist('percell','var')
    percell = 0;
end
if ~exist('normalize','var')
    normalize = 0;
end

% Get necessary triplet episodes... see function below for details
% PreSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.presleepInt);
PreSleepEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.presleepInt);

% PostSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.postsleepInt);
PostSleepEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.postsleepInt);


%% PRESLEEP
%assess EConnections in pre-sleep using  detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PreSleepETransfers = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepEpisodes,S,funcsynapses.ConnectionsE,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PreSleep-ETransferChanges-LenientDetection'];...
    ['n=' num2str(size(PreSleepEpisodes,2)) ' Episodes. Error bars are SEM.']})
set(h,'name',[basename '-SWSREMSWSPresleep-ETransferChanges-LenientDetection'])
subplot(2,1,2)
PreSleepERates = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepEpisodes,S(funcsynapses.ConnectionsE));
title({[basename '-SWSREMSWS-PreSleep-ECellRates-LenientDetection'];...
    ['n=' num2str(size(PreSleepEpisodes,2)) ' Episodes']})

%assess I in pre-sleep using  detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PreSleepITransfers = SpikingAnalysis_TripletEpisodeTransferPlotting(PreSleepEpisodes,S,funcsynapses.ConnectionsI,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PreSleep-ITransferChanges-LenientDetection'];...
    ['n=' num2str(size(PreSleepEpisodes,2)) ' Episodes. Error bars are SEM.']})
set(h,'name',[basename '-SWSREMSWSPresleep-ITransferChanges-LenientDetection'])
subplot(2,1,2)
PreSleepIRates = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepEpisodes,S(funcsynapses.ConnectionsI));
title({[basename '-SWSREMSWS-PreSleep-ICellRates-LenientDetection'];...
    ['n=' num2str(size(PreSleepEpisodes,2)) ' Episodes']})

%% EE transfers
Episodes = PreSleepEpisodes;
str = 'EE';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% EI transfers
Episodes = PreSleepEpisodes;
str = 'EI';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% IE transfers
Episodes = PreSleepEpisodes;
str = 'IE';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% II transfers
Episodes = PreSleepEpisodes;
str = 'II';
pp = 'Pre';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PreSleepZLTransfers = SpikingAnalysis_TripletEpisodeZLTransferPlotting(PreSleepEpisodes,S,thesepairs,funcsynapses,percell,normalize);
    title({[basename '-SWSREMSWS-PreSleep-ZLTransferChanges-LenientDetection'];...
        ['n=' num2str(size(PreSleepEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs. Error bars are SEM.']})
    subplot(2,1,2)
    PreSleepZLCellRates = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepEpisodes,S(unique(thesepairs)));
    title({[basename '-SWSREMSWS-PreSleep-ZeroLag-CellRates'];...
        ['n=' num2str(length(unique(thesepairs))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPresleep-ZLTransferChanges-LenientDetection'])


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
PostSleepETransfers = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepEpisodes,S,funcsynapses.ConnectionsE,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PostSleep-ETransferChanges-LenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ETransferChanges-LenientDetection'])
subplot(2,1,2)
PostSleepERates = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepEpisodes,S(funcsynapses.ConnectionsE));
title({[basename '-SWSREMSWS-PostSleep-ECellRates-LenientDetection'];...
    ['n=' num2str(size(PostSleepEpisodes,2)) ' Episodes']})

%assess I in pre-sleep using  detection of S-R-S episodes
h = figure;
subplot(2,1,1)
PostSleepITransfers = SpikingAnalysis_TripletEpisodeTransferPlotting(PostSleepEpisodes,S,funcsynapses.ConnectionsI,funcsynapses,percell,normalize);
title({[basename '-SWSREMSWS-PostSleep-ITransferChanges-LenientDetection. Error bars are SEM.'];...
    ['n=' num2str(size(PostSleepEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ITransferChanges-LenientDetection'])
subplot(2,1,2)
PostSleepIRates = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepEpisodes,S(funcsynapses.ConnectionsI));
title({[basename '-SWSREMSWS-PostSleep-ICellRates-LenientDetection'];...
    ['n=' num2str(size(PostSleepEpisodes,2)) ' Episodes']})


%% EE transfers
Episodes = PostSleepEpisodes;
str = 'EE';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% EI transfers
Episodes = PostSleepEpisodes;
str = 'EI';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% IE transfers
Episodes = PostSleepEpisodes;
str = 'IE';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% II transfers
Episodes = PostSleepEpisodes;
str = 'II';
pp = 'Post';
eval(['[',pp,'Sleep',str,'Transfers,',pp,'Sleep',str,'PresynRates,',pp,'Sleep',str,'PostsynRates]',...
    '= PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize);'])

%% Zerolag pairs (but for now not "wide")
% thesepairs = unique(cat(1,funcsynapses.WideConnections,funcsynapses.ZeroLag.EPairs),'rows');
thesepairs = funcsynapses.ZeroLag.EPairs;
h = figure;
subplot(2,1,1)
if ~isempty(thesepairs)
    PostSleepZLTransfers = SpikingAnalysis_TripletEpisodeZLTransferPlotting(PostSleepEpisodes,S,thesepairs,funcsynapses,percell,normalize);
    title({[basename '-SWSREMSWS-PostSleep-ZLTransferChanges-LenientDetection'];...
        ['n=' num2str(size(PostSleepEpisodes,2)) ' Episodes.  n = ' num2str(size(thesepairs,1)) ' Pairs. Error bars are SEM.']})
    subplot(2,1,2)
    PostSleepZLCellRates = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepEpisodes,S(unique(thesepairs)));
    title({[basename '-SWSREMSWS-PostSleep-ZeroLag-CellRates'];...
        ['n=' num2str(length(unique(thesepairs))) ' Cells']})
else
    text(1,1,'no pairs')
    set(gca,'XLim',[0 2],'YLim',[0 2])
end
set(h,'name',[basename '-SWSREMSWSPostsleep-ZLTransferChanges-LenientDetection'])
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

% SWSREMSWSEpisode_Transfers = v2struct(PreSleepAndresEpisodes,PreSleepEpisodes,...
%     PostSleepAndresEpisodes, PostSleepEpisodes,...
%     PreleepETransfers, PreleepITransfers,...
%     PresleepETransfersAndres, PresleepITransfersAndres,...
%     PostsleepETransfers, PostsleepITransfers,...
%     PostsleepETransfersAndres, PostsleepITransfersAndres);


% clear PreSleepAndresEpisodes PreSleepEpisodes ...
%     PostSleepAndresEpisodes PostSleepEpisodes ...
%     PreleepERates PreleepIRates ...
%     PresleepERatesAndres PresleepIRatesAndres ...
%     PostsleepERates PostsleepIRates ...
%     PostsleepERatesAndres  PostsleepIRatesAndres


function [Transfers,PresynRates,PostsynRates] = PlotTranfersVsPrePostRates(Episodes,S,funcsynapses,basename,str,pp,percell,normalize)

eval(['thesepairs = funcsynapses.Connections',str,';']);
h = figure;
subplot(3,1,1)
if ~isempty(thesepairs)
    eval(['Transfers = SpikingAnalysis_TripletEpisodeTransferPlotting(Episodes,S,thesepairs,funcsynapses,percell,normalize);'])
    eval(['title({[basename ''-SWSREMSWS-',pp,'Sleep-',str,'TransferChanges-LenientDetection''];',...
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
    Transfers = [];
    PresynRates = [];
    PostsynRates = [];
end
eval(['set(h,''name'',[basename ''-SWSREMSWS',pp,'sleep-',str,'TransferChanges-LenientDetection''])'])
