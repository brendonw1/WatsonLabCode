function [outeps1,outeps2] = PrePostIntervalTimes(WSEpisodes,ints,ep1,ep2,basepath,basename)
% function [tempeps1,tempeps2,cateps1,cateps2] = PrePostIntervalTimes(WSEpisodes,intervals,ep1,ep2)
% Gives intervals specifying ep1 and ep2 respectively.  WARNING: Uses tsobjects toolbox.
%
% INPUTS
% ep1 - may be 
% %     - an intervalSet
% %     - two column array of [start stop], in seconds;
%     - string - will describe a special case to act upon a WSEpisode
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeB' - Look at wake before (after not possible with
%                    WSEpisodes)... both outeps1&2 are identical
%         - 'WakeAllB' - NOTE this is ALL wake before, not just in the WS episode  
%         - 'WakeAllA' - NOTE this is ALL wake after, not exactly related to the WS episode  
%         - 'WSWake' - Wake in each WS episode
%         - 'FL5WSWake'  - first and last 5min of each wake
%         - 'WSSleep' - Look at all of sleep in a given WS episode
%         - 'WSSWS' - Look at all SWS in a given WS episode
%         - 'WWSREM' - Look at all REM in a given WS episode
%         - 'WakeTFirstSWS' - 
%         - 'OtherTSecondSWS' - Looking for the second SWS epoch in a WS episode and preceeded by whatever is between the prior SWS and it         
% ep2 - [same as ep1, or blank]
% ints - structure containing contents from WSRestrictedIntervals
% WSEpisodes - DefineWakeSleepWakeEpisodes
% 
% OUTPUTS
% outeps1  - Cell array of intervalSets one for each WSEpisode. 
% outeps2  - as outeps1
% % outeps1  - intervalSet of ep1 types for each WSEpisode.  If there some
% %           WSEpisodes have multiple sub-intervals per episode, catEps will list
% %           which intervals go with the ep1's for each WSEpisode
% % outeps2  - as outeps1
% % cateps1 - cell array of length equal to number of WS episodes, in
% %           each container is a vector list of which intervals go into the
% %           corresponding episode
% % cateps2 - same as outeps2, but for 2nd interval per episode
%
% Brendon Watson July 2015

warning off

if ~exist('ep1','var')%default
    ep1 = '5minsws';
end

outeps1 = [];
outeps2 = [];
% cateps1 = []; %keep track of which eps1 to put together 
% cateps2 = []; %keep track of which eps2 to put together 

numWSEpisodes = size(WSEpisodes,2);

switch(lower(ep1))
    case '5min' %- gather first 5min IN sleep vs last 5 IN sleep
        for a = 1:numWSEpisodes;
            t1 = [Start(subset(WSEpisodes{a},2)) Start(subset(WSEpisodes{a},2))+300*10000];
            t2 = [End(subset(WSEpisodes{a},2))-300*10000,End(subset(WSEpisodes{a},2))];

            outeps1 = cat(1,outeps1,t1);
            outeps2 = cat(1,outeps2,t2);
        end                    
    case '5minsws' %- gather first 5min of SWS in sleep vs last 5 of SWS sleep
        for a = 1:numWSEpisodes;
            SWSeps = intersect(subset(WSEpisodes{a},2),ints.SWSEpisodeInts);
            SWSlengths = Data(length(SWSeps,'s')); 
            SWSstarts = Start(intersect(subset(WSEpisodes{a},2),ints.SWSEpisodeInts),'s'); 
            SWSends = End(intersect(subset(WSEpisodes{a},2),ints.SWSEpisodeInts),'s'); 
            cumSWSf = cumsum(SWSlengths);
            cumSWSb = flipud(cumsum(flipud(SWSlengths)));

            last = find(cumSWSf>300,1,'first');%find first ep greater than 300
            extrasec = cumSWSf(last)-300;
            is2 = intervalSet(Start(subset(WSEpisodes{a},2)),10000*[SWSends(last)-extrasec]);
            t1 = intersect(SWSeps,is2);
            t1 = [Start(t1) End(t1)];

            first = find(cumSWSb>300,1,'last');
            extrasec = cumSWSb(first)-300;
            is2 = intervalSet(10000*[SWSstarts(first)+extrasec],End(subset(WSEpisodes{a},2)));
            t2 = intersect(SWSeps,is2);
            t2 = [Start(t2) End(t2)];

%             cateps1{a} = size(outeps1,1)+1:size(outeps1,1)+size(t1,1);
%             cateps2{a} = size(outeps2,1)+1:size(outeps2,1)+size(t2,1);
% 
%             outeps1 = cat(1,outeps1,t1);
%             outeps2 = cat(1,outeps2,t2);
            
            outeps1{a} = intervalSet(t1(:,1),t1(:,2));
            outeps2{a} = intervalSet(t2(:,1),t2(:,2));
        end                    
    case '5mout' %- gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
        for a = 1:numWSEpisodes;
            t1 = [End(subset(WSEpisodes{a},1))-300*10000 End(subset(WSEpisodes{a},1))];
            t2 = [End(subset(WSEpisodes{a},2)) End(subset(WSEpisodes{a},2))+300*10000];

            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end                    
    case 'flsws' %- gather first vs last SWS episodes
        for a = 1:numWSEpisodes;
            thissleep = subset(WSEpisodes{a},2);
            theseswss = intersect(ints.SWSPacketInts,thissleep);

            t1 = subset(theseswss,1);
            t2 = subset(theseswss,length(length(theseswss)));

            outeps1{a} = t1;
            outeps2{a} = t2;
        end
    case 'flswsep' %- gather first vs last SWS episodes
        for a = 1:numWSEpisodes;
            thissleep = subset(WSEpisodes{a},2);
            theseswss = intersect(ints.SWSEpisodeInts,thissleep);

            t1 = subset(theseswss,1);
            t2 = subset(theseswss,length(length(theseswss)));

            outeps1{a} = t1;
            outeps2{a} = t2;
        end
    case '13sws' %- gather SWS from vs vs last third of sleep
        for a = 1:numWSEpisodes;
            sleepthirds = regIntervals(subset(WSEpisodes{a},2),3);

            t1 = [Start(intersect(sleepthirds{1},ints.SWSPacketInts)) End(intersect(sleepthirds{1},ints.SWSPacketInts))];
            t2 = [Start(intersect(sleepthirds{3},ints.SWSPacketInts)) End(intersect(sleepthirds{3},ints.SWSPacketInts))];

            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end
    case 'sws13thirds' %third of individual sws intervals
        for a = 1:numWSEpisodes;
            t = intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2));
            t1 = intervalSet(-1,0);
            t2 = intervalSet(-1,0);
            for b = 1:length(length(t));
                thirds = regIntervals(subset(t,b),3);
                t1 = cat(t1,thirds{1});
                t2 = cat(t2,thirds{3});
            end
            t1 = subset(t1,2:length(length(t1)));
            t2 = subset(t2,2:length(length(t2)));
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end                    
        
    case 'wakeb' % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        for a = 1:numWSEpisodes;
            outeps1{a} = intersect(subset(WSEpisodes{a},1),stateintervals{1});%find the wake parts in the specified interval
            outeps2{a} = outeps1{a};
        end 
    case 'wake13thirds' %third of individual sws intervals
        for a = 1:numWSEpisodes;
            t = subset(WSEpisodes{a},1);
            t1 = intervalSet(-1,0);
            t2 = intervalSet(-1,0);
            for b = 1:length(length(t));
                thirds = regIntervals(subset(t,b),3);
                t1 = cat(t1,thirds{1});
                t2 = cat(t2,thirds{3});
            end
            t1 = subset(t1,2:length(length(t1)));
            t2 = subset(t2,2:length(length(t2)));
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end                    
    case 'wakeb1quarter' % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        for a = 1:numWSEpisodes;
            wakequarters = regIntervals(subset(WSEpisodes{a},1),4);
            outeps1{a} = intersect(wakequarters{1},stateintervals{1});%find the wake parts in the specified interval
            outeps2{a} = outeps1{a};
        end 
    case 'wakeb2quarter' % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        for a = 1:numWSEpisodes;
            wakequarters = regIntervals(subset(WSEpisodes{a},1),4);
            outeps1{a} = intersect(wakequarters{2},stateintervals{1});%find the wake parts in the specified interval
            outeps2{a} = outeps1{a};
        end 
    case 'wakeb3quarter' % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        for a = 1:numWSEpisodes;
            wakequarters = regIntervals(subset(WSEpisodes{a},1),4);
            outeps1{a} = intersect(wakequarters{3},stateintervals{1});%find the wake parts in the specified interval
            outeps2{a} = outeps1{a};
        end 
    case 'wakeb4quarter' % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        for a = 1:numWSEpisodes;
            wakequarters = regIntervals(subset(WSEpisodes{a},1),4);
            outeps1{a} = intersect(wakequarters{4},stateintervals{1});%find the wake parts in the specified interval
            outeps2{a} = outeps1{a};
        end 
    case {'wakea','wakea1quarter','wakea2quarter','wakea3quarter','wakea4quarter'} % - Look at the wake immediately before sleep in the ws interval
        load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
        load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval')
        for a = 1:length(stateintervals)%convert to intervalsets
            stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
        end
        WS = DefineWakeSleepWakeEpisodes(basepath,basename,stateintervals,GoodSleepInterval);
        wakestarts = Start(WS.WEpisodes,'s');%find official wake episodes
        wakeends = End(WS.WEpisodes,'s');
        for a = 1:numWSEpisodes;
            % just look for WSW overlapping with this WS... take the W from
            % there
            sleepend = End(subset(WSEpisodes{a},2),'s');
            good = find((wakestarts-sleepend)<1*60 & wakeends-sleepend>7*60);%find wakes taht start within 1min of sleep and end more than 7 min after
            if ~isempty(good)
                if length(good)>1
                    [~,good] = max(Data(length(subset(WS.WEpisodes,good))));
                end
                goodint = intervalSet(sleepend*10000,wakeends(good)*10000);%make sure the candidate starts after sleep ends
                outeps1{a} = intersect(goodint,stateintervals{1});%find the wake parts in the specified interval    
                wakequarters = regIntervals(outeps1{a},4);%in case
                switch (lower(ep1))
                    case 'wakea1quarter'
                        outeps1{a} = wakequarters{1};
                    case 'wakea2quarter'
                        outeps1{a} = wakequarters{2};
                    case 'wakea3quarter'
                        outeps1{a} = wakequarters{3};
                    case 'wakea4quarter'
                        outeps1{a} = wakequarters{4};
                end
            else
                outeps1{a}= intervalSet([],[]);
            end
        end
        outeps2 = outeps1;
        
%     case 'wakeallb' % - Look at all/any wake before the start of the sleep epoch
%         for a = 1:numWSEpisodes;
%             beforeint = intervalSet(0,Start(subset(WSEpisodes{a},2)));
%             wakebefore = intersect(ints{1},beforeint);
%            
%             t1 = [Start(wakebefore) End(wakebefore)];
%             t2 = t1;
%             outeps1{a} = intervalSet(t1(:,1), t1(:,2));
%             outeps2{a} = intervalSet(t2(:,1), t2(:,2));
%         end                    
%     case 'wakealla' % - Look at all/any wake following the end of the sleep epoch
%         for a = 1:numWSEpisodes;
%             afterint = intervalSet(End(subset(WSEpisodes{a},2)),inf);
%             wakeafter = intersect(ints{1},afterint);
%            
%             t1 = [Start(wakeafter) End(wakeafter)];
%             t2 = t1;
%             
%             outeps1{a} = intervalSet(t1(:,1), t1(:,2));
%             outeps2{a} = intervalSet(t2(:,1), t2(:,2));
%         end                    
    case 'wswake' % - Look at wake before vs wake after
        for a = 1:numWSEpisodes;
            t1 = StartEnd(subset(WSEpisodes{a},1));
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = outeps1{a};
        end
    case 'wswake' % - Look at wake in each WS Episode
        for a = 1:numWSEpisodes;
            t1 = StartEnd(subset(WSEpisodes{a},1));
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = outeps1{a};
        end        
    case 'fl5wswake' % - First and Last 5 min of wake in each WS Episode
        for a = 1:numWSEpisodes;
            t = StartEnd(subset(WSEpisodes{a},1),'s');
            outeps1{a} = intersect(subset(WSEpisodes{a},1),intervalSet(10000*t(1),10000*(t(1)+300)));
            outeps2{a} = intersect(subset(WSEpisodes{a},1),intervalSet(10000*(t(2)-300),10000*t(2)));
        end
    case 'wssleep' % - Look at wake before vs wake after
        for a = 1:numWSEpisodes;
            t1 = [Start(subset(WSEpisodes{a},2)) End(subset(WSEpisodes{a},2))];
            t2 = [Start(subset(WSEpisodes{a},2)) End(subset(WSEpisodes{a},2))];
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end
    case 'wssleep1quarter' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            t1 = StartEnd(sleepquarters{1},'s');
            t2 = t1;
            
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end 
    case 'wssleep2quarter' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            t1 = StartEnd(sleepquarters{2},'s');
            t2 = t1;
            
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end 
    case 'wssleep3quarter' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            t1 = StartEnd(sleepquarters{3},'s');
            t2 = t1;
            
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end 
    case 'wssleep4quarter' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            t1 = StartEnd(sleepquarters{4},'s');
            t2 = t1;
            
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end 
    
        
    case 'wssws' % - Look at wake before vs wake after
        for a = 1:numWSEpisodes;
            t1 = [Start(intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2))) End(intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2)))];
            t2 = [Start(intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2))) End(intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2)))];

            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));
        end
    case 'wssws1quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.SWSPacketInts,sleepquarters{1});
            outeps2{a} = outeps1{a};
        end 
    case 'wssws2quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.SWSPacketInts,sleepquarters{2});
            outeps2{a} = outeps1{a};
        end 
    case 'wssws3quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.SWSPacketInts,sleepquarters{3});
            outeps2{a} = outeps1{a};
        end 
    case 'wssws4quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.SWSPacketInts,sleepquarters{4});
            outeps2{a} = outeps1{a};
        end 
    
    case 'flrem' %- gather first vs last REM episodes
        for a = 1:numWSEpisodes;
            thissleep = subset(WSEpisodes{a},2);
            theserems = intersect(ints.REMInts,thissleep);

            t1 = [];
            t2 = [];
            if ~isempty(theserems)
                if length(length(theserems))>1
                    t1 = subset(theserems,1);
                    t2 = subset(theserems,length(length(theserems)));
                end
            end
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end
    case 'wsrem' 
        for a = 1:numWSEpisodes;
            t1 = [Start(intersect(ints.REMInts,subset(WSEpisodes{a},2))) End(intersect(ints.REMInts,subset(WSEpisodes{a},2)))];
            t2 = [Start(intersect(ints.REMInts,subset(WSEpisodes{a},2))) End(intersect(ints.REMInts,subset(WSEpisodes{a},2)))];
            outeps1{a} = intervalSet(t1(:,1), t1(:,2));
            outeps2{a} = intervalSet(t2(:,1), t2(:,2));

        end                    
    case 'rem13thirds' %third of individual rem intervals
        for a = 1:numWSEpisodes;
            t = intersect(ints.REMInts,subset(WSEpisodes{a},2));
            t1 = intervalSet(-1,0);
            t2 = intervalSet(-1,0);
            for b = 1:length(length(t));
                remthirds = regIntervals(subset(t,b),3);
                t1 = cat(t1,remthirds{1});
                t2 = cat(t2,remthirds{3});
            end
            t1 = subset(t1,2:length(length(t1)));
            t2 = subset(t2,2:length(length(t2)));
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end                    
    case 'wsrem1quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.REMInts,sleepquarters{1});
            outeps2{a} = outeps1{a};
        end
    case 'wsrem2quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.REMInts,sleepquarters{2});
            outeps2{a} = outeps1{a};
        end
    case 'wsrem3quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.REMInts,sleepquarters{3});
            outeps2{a} = outeps1{a};
        end
    case 'wsrem4quartersleep' % - Look at the wake immediately before sleep in the ws interval
        for a = 1:numWSEpisodes;
            sleepquarters = regIntervals(subset(WSEpisodes{a},2),4);
            outeps1{a} = intersect(ints.REMInts,sleepquarters{4});
            outeps2{a} = outeps1{a};
        end
    case 'waketfirstsws'
        for a = 1:numWSEpisodes;
            swss = intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2));
            sws = subset(swss,1);
            pre = intervalSet(subset(WSEpisodes{a},1));
            
            outeps1{a} = pre;
            outeps2{a} = sws;
        end
    case 'othertsecondsws'
        for a = 1:numWSEpisodes;
            swss = intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2));
            nsws = length(length(swss));
            if nsws>1
               sws = subset(swss,2);
               pre = intervalSet(End(subset(swss,1)),Start(sws)-1/10000);
            else
               sws = intervalSet(nan,nan);
               pre = intervalSet(nan,nan);
            end
            
            outeps1{a} = pre;
            outeps2{a} = sws;
        end
    case 'flma' %- gather first vs last REM episodes
        for a = 1:numWSEpisodes;
            thissleep = subset(WSEpisodes{a},2);
            thesemas = intersect(ints.MAInts,thissleep);

            t1 = [];
            t2 = [];
            if ~isempty(thesemas)
                if length(length(thesemas))>1
                    t1 = subset(thesemas,1);
                    t2 = subset(thesemas,length(length(thesemas)));
                end
            end
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end
    case 'ma13thirds' %third of individual sws intervals
        for a = 1:numWSEpisodes;
            t = intersect(ints.SWSPacketInts,subset(WSEpisodes{a},2));
            t1 = intervalSet(-1,0);
            t2 = intervalSet(-1,0);
            for b = 1:length(length(t));
                thirds = regIntervals(subset(t,b),3);
                t1 = cat(t1,thirds{1});
                t2 = cat(t2,thirds{3});
            end
            t1 = subset(t1,2:length(length(t1)));
            t2 = subset(t2,2:length(length(t2)));
            
            outeps1{a} = t1;
            outeps2{a} = t2;
        end                    
    otherwise 
        error('Incorrect string input')
end
% outeps1 = intervalSet(outeps1(:,1),outeps1(:,2));    
% outeps2 = intervalSet(outeps2(:,1),outeps2(:,2));    