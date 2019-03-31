function SWSREMSWSEpisode_PopRates = SpikingAnalysis_GetTripletEpisodeSpikeRates(basename,basepath,intervals,restrictingint,Se,Si);

% Get necessary triplet episodes... see function below for details
SleepTripletEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,restrictingint);

%assess E in pre-sleep using BW detection of S-R-S episodes
h = figure;
[SWSEAvgRates,SWSEIndividRates] = SpikingAnalysis_TripletEpisodeRatePlotting(SleepTripletEpisodes,Se);
title({[basename '-SWSREMSWS-PreSleep-ERateChanges'];...
    ['n=' num2str(size(SleepTripletEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-ERateChanges'])
%assess I in pre-sleep using BW detection of S-R-S episodes
h = figure;
[SWSIAvgRates,SWSIIndividRates] = SpikingAnalysis_TripletEpisodeRatePlotting(SleepTripletEpisodes,Si);
title({[basename '-SWSREMSWS-PreSleep-IRateChanges'];...
    ['n=' num2str(size(SleepTripletEpisodes,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-IRateChanges'])

%save figs
if ~exist(fullfile(basepath,'SWSREMSWSEpisodeFigs'),'dir')
    mkdir(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
end
cd(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
saveallfigsas('fig')
cd(basepath)


SWSREMSWSEpisode_PopRates = v2struct(SleepTripletEpisodes,...
    SWSEAvgRates, SWSIAvgRates, SWSEIndividRates, SWSIIndividRates...
    );











% %%%%%%%%%%%%%% OLD %%%%%%%%%%%%%%%%%%.... PREPOSTSLEEP %%%%%%%%%%%%%%%%%%%%
% 
% 
% % Get necessary triplet episodes... see function below for details
% PreSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.presleepInt);
% PreSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.presleepInt);
% 
% % PostSleepAndresEpisodes = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.postsleepInt);
% % PostSleepBWEpisodes = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.postsleepInt);
% 
% %assess E in pre-sleep using BW detection of S-R-S episodes
% h = figure;
% PreleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,Se);
% title({[basename '-SWSREMSWS-PreSleep-ERateChanges-BWLenientDetection'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ERateChanges-BWLenientDetection'])
% %assess I in pre-sleep using BW detection of S-R-S episodes
% h = figure;
% PreleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepBWEpisodes,Si);
% title({[basename '-SWSREMSWS-PreSleep-IRateChanges-BWLenientDetection'];...
%     ['n=' num2str(size(PreSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-IRateChanges-BWLenientDetection'])
% 
% %assess E in pre-sleep using Andres detection
% h = figure;
% PresleepERatesAndres = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepAndresEpisodes,Se);
% title({[basename '-SWSREMSWS-Preleep-ERateChanges-AndresDetection'];...
%     ['n=' num2str(size(PreSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-ERateChanges-AndresDetection'])
% %assess I in pre-sleep using Andres detection
% h = figure;
% PresleepIRatesAndres = SpikingAnalysis_TripletEpisodeRatePlotting(PreSleepAndresEpisodes,Si);
% title({[basename '-SWSREMSWS-Preleep-IRateChanges-AndresDetection'];...
%     ['n=' num2str(size(PreSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPresleep-IRateChanges-AndresDetection'])
% 
% %assess E in post-sleep using BW detection of S-R-S episodes
% h = figure;
% PostsleepERatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,Se);
% title({[basename '-SWSREMSWS-PostSleep-ERateChanges-BWLenientDetection'];...
%     ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-ERateChanges-BWLenientDetection'])
% %assess I in post-sleep uSpikingAnalysis_TripletEpisodePlottingsing BW detection of S-R-S episodes
% h = figure;
% PostsleepIRatesBW = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepBWEpisodes,Si);
% title({[basename '-SWSREMSWS-PostSleep-IRateChanges-BWLenientDetection'];...
%     ['n=' num2str(size(PostSleepBWEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-IRateChanges-BWLenientDetection'])
% 
% %assess E in post-sleep using Andres detection
% h = figure;
% PostsleepERatesAndres = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepAndresEpisodes,Se);
% title({[basename '-SWSREMSWS-PostSleep-ERateChanges-AndresDetection'];...
%     ['n=' num2str(size(PostSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-ERateChanges-AndresDetection'])
% %assess I in post-sleep using Andres detection
% h = figure;
% PostsleepIRatesAndres = SpikingAnalysis_TripletEpisodeRatePlotting(PostSleepAndresEpisodes,Si);
% title({[basename '-SWSREMSWS-PostSleep-IRateChanges-AndresDetection'];...
%     ['n=' num2str(size(PostSleepAndresEpisodes,2)) ' Episodes']})
% set(h,'name',[basename '-SWSREMSWSPostsleep-IRateChanges-AndresDetection'])
% 
% 
% %save figs
% if ~exist(fullfile(basepath,'SWSREMSWSEpisodeFigs'),'dir')
%     mkdir(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
% end
% cd(fullfile(basepath,'SWSREMSWSEpisodeFigs'))
% saveallfigsas('fig')
% cd(basepath)
% 
% 
% SWSREMSWSEpisode_PopRates = v2struct(PreSleepAndresEpisodes,PreSleepBWEpisodes,...
%     PostSleepAndresEpisodes, PostSleepBWEpisodes,...
%     PreleepERatesBW, PreleepIRatesBW,...
%     PresleepERatesAndres, PresleepIRatesAndres,...
%     PostsleepERatesBW, PostsleepIRatesBW,...
%     PostsleepERatesAndres, PostsleepIRatesAndres);
% 
% 
% % clear PreSleepAndresEpisodes PreSleepBWEpisodes ...
% %     PostSleepAndresEpisodes PostSleepBWEpisodes ...
% %     PreleepERatesBW PreleepIRatesBW ...
% %     PresleepERatesAndres PresleepIRatesAndres ...
% %     PostsleepERatesBW PostsleepIRatesBW ...
% %     PostsleepERatesAndres  PostsleepIRatesAndres