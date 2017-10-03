function [vects1,vects2,endeps1,endeps2] = GatherVectorsFromEpochPairs(data,ep1,ep2,timeperbin)
% function [vects1,vects2,endeps1,endeps2] = GatherVectorsFromEpochPairs(data,ep1,ep2)
% Input a vector and return subvectors with values falling into ep1 and ep2
% respectively.  WARNING: Uses tsobjects toolbox.
%
% INPUTS
% data - May be:
%     - tsd
%     - tsdarray, 
%     - bins x 2 vector of value;time pairs, or a
%     - simple 1d vector where bins will be assumed to be in seconds
%     - things x bins matrix where each bin is assumed to be 1 second
%             "things" refers to things each being measured (ie a thing could be
%             firing from one cell)
% ep1 - may be 
%     - an intervalSet
%     - two column array of [start stop], in seconds;
%     - string - will describe a special case to act upon a WSEpisode
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
% ep2 - [same as ep1]
%
% OPTIONAL INPUTS (in varargin)
% timeperbin - seconds separating data elements of any vector or matrix
%         input (except two-column input)
% 
% 
% OUTPUTS
% d1  - cell array of tsdArrays from data in ep1
% d2  - cell array of tsdArrays in vector form, from data in ep2
% endeps1 - cell array of separate intervalSets for each episode as finally
%             used in end of function
% endeps2 - cell array of separate intervalSets for each episode as finally
%             used in end of function
% 
% Brendon Watson June 2015

PerSecMatrixOutput = 0;
cateps1 = []; %keep track of which eps1 to put together 
cateps2 = []; %keep track of which eps2 to put together 

if ~exist('timeperbin','var')
    timeperbin = 1;
end

switch class(data)
    case 'tsd'
    case 'tsdArray'
    case 'double'
        if numel(data) == length(data)%if a single row or column, assume each bin is from one sec
            data = tsd(10000*[0:numel(data)-1]*timeperbin,data(:));
        elseif size(data,2)==2%if bin x 2, assume first column is data, second is timestamp in seconds
            data = tsd(10000*data(:,2),data(:,1));
        else %if any other shape matrix, assume dim1 is units, dim2 is bins
            for a = 1:size(data,1)
                t{a} = tsd(10000*[0:size(data,2)-1]'*timeperbin,data(a,:)');
            end
            data = tsdArray(t');
        end
    otherwise
        error('data input must either be a tsd, a tsdArray or a double matrix')
        return
end

switch class(ep1)
    case 'char'
        basepath = cd;
        [~,basename,~] = fileparts(cd);
        wsw = load(fullfile(basepath,[basename '_WSWEpisodes2']));
        WSEpisodes = wsw.WSEpisodes;
        numWSEpisodes = size(WSEpisodes,2);
        GoodSleepInterval = wsw.GoodSleepInterval;

        t = load(fullfile(basepath,[basename '_Intervals']));
        intervals = t.intervals;

        [tempeps1,tempeps2,cateps1,cateps2] = PrePostIntervalTimes(WSEpisodes,intervals);
        
%         tempeps1 = [];
%         tempeps2 = [];
%         
%         switch(lower(ep1))
%             case '5min' %- gather first 5min IN sleep vs last 5 IN sleep
%                 for a = 1:numWSEpisodes;
%                     t1 = [Start(subset(WSEpisodes{a},2)) Start(subset(WSEpisodes{a},2))+300*10000];
%                     t2 = [End(subset(WSEpisodes{a},2))-300*10000,End(subset(WSEpisodes{a},2))];
%                     
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end                    
%             case '5minsws' %- gather first 5min of SWS in sleep vs last 5 of SWS sleep
%                 for a = 1:numWSEpisodes;
%                     SWSeps = intersect(subset(WSEpisodes{a},2),intervals{3});
%                     SWSlengths = Data(length(SWSeps,'s')); 
%                     SWSstarts = Start(intersect(subset(WSEpisodes{a},2),intervals{3}),'s'); 
%                     SWSends = End(intersect(subset(WSEpisodes{a},2),intervals{3}),'s'); 
%                     cumSWSf = cumsum(SWSlengths);
%                     cumSWSb = flipud(cumsum(flipud(SWSlengths)));
%                     
%                     last = find(cumSWSf>300,1,'first');%find first ep greater than 300
%                     extrasec = cumSWSf(last)-300;
%                     is2 = intervalSet(Start(subset(WSEpisodes{a},2)),10000*[SWSends(last)-extrasec]);
%                     t1 = intersect(SWSeps,is2);
%                     t1 = [Start(t1) End(t1)];
% 
%                     first = find(cumSWSb>300,1,'last');
%                     extrasec = cumSWSb(first)-300;
%                     is2 = intervalSet(10000*[SWSstarts(first)+extrasec],End(subset(WSEpisodes{a},2)));
%                     t2 = intersect(SWSeps,is2);
%                     t2 = [Start(t2) End(t2)];
%                                         
%                     catEps1{a} = size(tempeps1,1)+1:size(tempeps1,1)+size(t1,1);
%                     catEps2{a} = size(tempeps2,1)+1:size(tempeps2,1)+size(t2,1);
% 
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end                    
%             case '5mout' %- gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%                 for a = 1:numWSEpisodes;
%                     t1 = [End(subset(WSEpisodes{a},1))-300*10000 End(subset(WSEpisodes{a},1))];
%                     t2 = [Start(subset(WSEpisodes{a},3)) Start(subset(WSEpisodes{a},3))+300*10000];
%                     
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end                    
%             case 'flsws' %- gather first vs last SWS episodes
%                 for a = 1:numWSEpisodes;
%                     thissleep = subset(WSEpisodes{a},2);
%                     theseswss = intersect(intervals{3},thissleep);
%     
%                     t1 = subset(theseswss,1);
%                     t2 = subset(theseswss,length(length(theseswss)));
%                     
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end
%             case '13sws' %- gather SWS from vs vs last third of sleep
%                 for a = 1:numWSEpisodes;
%                     sleepthirds = regIntervals(subset(WSEpisodes{a},2),3);
% 
%                     t1 = [Start(intersect(sleepthirds{1},intervals{3})) End(intersect(sleepthirds{1},intervals{3}))];
%                     t2 = [Start(intersect(sleepthirds{3},intervals{3})) End(intersect(sleepthirds{3},intervals{3}))];
%                     
%                     catEps1{a} = size(tempeps1,1)+1:size(tempeps1,1)+size(t1,1);
%                     catEps2{a} = size(tempeps2,1)+1:size(tempeps2,1)+size(t2,1);
% 
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end
%             case 'wakeba' % - Look at wake before vs wake after
%                 for a = 1:numWSEpisodes;
%                     t1 = [Start(subset(WSEpisodes{a},1)) End(subset(WSEpisodes{a},1))];
%                     t2 = [Start(subset(WSEpisodes{a},3)) End(subset(WSEpisodes{a},3))];
%                     
%                     tempeps1 = cat(1,tempeps1,t1);
%                     tempeps2 = cat(1,tempeps2,t2);
%                 end                    
%             otherwise 
%                 error('Incorrect string input')
%         end
%         ep1 = intervalSet(tempeps1(:,1),tempeps1(:,2));    
%         ep2 = intervalSet(tempeps2(:,1),tempeps2(:,2));    
    case 'intervalSet'
    case 'double'
        if size(ep1,2) ~= 2
            error('ep1 input must either be an intervalSet, a 2 column vector or a specific string')
            return
        else
            ep1 = intervalSet(ep1(:,1),ep1(:,2));
        end
        % handle ep2 if not handled under string case
end

if ~isa(ep2,'intervalSet')
    switch class(ep2)
        case 'double'
            if size(ep2,2) ~= 2
                error('ep1 input must either be an intervalSet, a 2 column vector or a specific string')
                return
            else
                ep2 = intervalSet(ep1(:,2),ep2(:,2));
            end
    end
end

%% Finally, getting data (note check above for 
% if length(length(ep1))~=length(length(ep2))
%     error('Each episode in ep1 must be paired with an episode in ep2')
%     return
% end

if ~isempty(cateps1) | ~isempty(cateps2)% handle cases where each episodes include multiple sub-intervals (ie first third of sleep SWS with multiple SWS intervals in the first third)
    for a = 1:length(cateps1)
        theseeps = cateps1{a};
        for b = 1:length(theseeps)
            tint = subset(ep1,theseeps(b));%intervalSet (1x1)
            if b == 1;
                tempep = tint;
            else
                tempep = cat(tempep,tint);
            end
        end
        vects1{a} = CompressSpikeTrainsToIntervals(data,tempep); %this way can do things like rate calcs etc... will lose time info tho
        endeps1{a} = tempep;
    end
    for a = 1:length(cateps2)
        theseeps = cateps2{a};
        for b = 1:length(theseeps)
            tint = subset(ep2,theseeps(b));%intervalSet (1x1)
            if b == 1;
                tempep = tint;
            else
                tempep = cat(tempep,tint);
            end
        end
        vects2{a} = CompressSpikeTrainsToIntervals(data,tempep);
        endeps2{a} = tempep;
    end

    
%     for a = 1:length(catEps1)
%         theseeps = catEps1{a};
%         for b = 1:length(theseeps)
%             tdat = Restrict(data,subset(ep1,theseeps(b)));%tsdarray
%             if b == 1;
%                 tempep = tdat;
%             else
%                 tempep = catTsdArray(tempep,tdat);
%             end
%         end
%         vects1{a} = tempep;
%     end
%     for a = 1:length(catEps2)
%         theseeps = catEps2{a};
%         for b = 1:length(theseeps)
%             tdat = Restrict(data,subset(ep2,theseeps(b)));%tsdarray
%             if b == 1;
%                 tempep = tdat;
%             else
%                 tempep = catTsdArray(tempep,tdat);
%             end
%         end
%         vects2{a} = tempep;
%     end
else
    for a = 1:length(length(ep1))
        vects1{a} = Restrict(data,subset(ep1,a));
        vects2{a} = Restrict(data,subset(ep2,a));
        endeps1{a} = subset(ep1,a);
        endeps2{a} = subset(ep2,a);
    end
end

1;

%     if PerSecMatrixOutput
%        vects1{a} = MakeQfromS(vects1{a},10000);
%        vects2{a} = MakeQfromS(vects2{a},10000);
%     end
   