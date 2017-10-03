function [vects1,vects2,endeps1,endeps2] = VectorsFromEpochPairs(data,ep1,ep2,timeperbin)
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
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min -
%         DEFAULT
%         - see PrePostIntervalTimes.m for other options
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
        ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals']));
        WSEpisodes = ints.WakeSleep;

%% Get intervalSets
%         [ep1,ep2,cateps1,cateps2] = PrePostIntervalTimes(WSEpisodes,intervals,ep1,ep2);
        [ep1,ep2] = PrePostIntervalTimes(WSEpisodes,ints,ep1,ep2,basepath,basename);
          
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

    
if ~isempty(ep1) | ~isempty(ep2)%
    empties = zeros(1,length(ep1));
    for a = 1:length(ep1)
        if isempty(ep1{a}) | isempty(ep2{a})
            empties(a) = 1;
        end
    end
    if any(empties);
        ep1(find(empties)) = [];
        ep2(find(empties)) = [];
    end
end

if ~isempty(ep1) | ~isempty(ep2)% handle cases where each episode includes multiple sub-intervals (ie first third of sleep SWS with multiple SWS intervals in the first third)
    for a = 1:length(ep1)
        if ~isempty(ep1{a})
            vects1{a} = CompressSpikeTrainsToIntervals(data,ep1{a}); %this way can do things like rate calcs etc... will lose time info tho
%             endeps1{a} = tempep;
        else
            vects1{a}=tsdArray;
%             endeps1{a} = theseeps;
        end
    end
    for a = 1:length(ep2)
        if ~isempty(ep2{a})
            vects2{a} = CompressSpikeTrainsToIntervals(data,ep2{a}); %this way can do things like rate calcs etc... will lose time info tho
%             endeps2{a} = tempep;
        else
            vects2{a}=tsdArray;
%             endeps2{a} = theseeps;
        end
    end
else
    vects1{a}=tsdArray;
    vects2{a}=tsdArray;
end

endeps1 = ep1;
endeps2 = ep2;

% if ~isempty(cateps1) | ~isempty(cateps2)% handle cases where each episodes include multiple sub-intervals (ie first third of sleep SWS with multiple SWS intervals in the first third)
%     for a = 1:length(cateps1)
%         theseeps = cateps1{a};
%         if ~isempty(theseeps)
%             for b = 1:length(theseeps)
%                 tint = subset(ep1,theseeps(b));%intervalSet (1x1)
%                 if b == 1;
%                     tempep = tint;
%                 else
%                     tempep = cat(tempep,tint);
%                 end
%             end
%             vects1{a} = CompressSpikeTrainsToIntervals(data,tempep); %this way can do things like rate calcs etc... will lose time info tho
%             endeps1{a} = tempep;
%         else
%             vects1{a}=tsdArray;
%             endeps1{a} = theseeps;
%         end
%     end
%     for a = 1:length(cateps2)
%         theseeps = cateps2{a};
%         if ~isempty(theseeps)
%             for b = 1:length(theseeps)
%                 tint = subset(ep2,theseeps(b));%intervalSet (1x1)
%                 if b == 1;
%                     tempep = tint;
%                 else
%                     tempep = cat(tempep,tint);
%                 end
%             end
%             vects2{a} = CompressSpikeTrainsToIntervals(data,tempep);
%             endeps2{a} = tempep;
%         else
%             vects2{a}=tsdArray;
%             endeps2{a} = theseeps;
%         end
%     end
% else
%     for a = 1:length(length(ep1))
%         vects1{a} = Restrict(data,subset(ep1,a));
%         vects2{a} = Restrict(data,subset(ep2,a));
%         endeps1{a} = subset(ep1,a);
%         endeps2{a} = subset(ep2,a);
%     end
% end

if prod(size(data))==0
    for a = 1:length(length(ep1))
        vects1{a} = tsdArray(tsd(NaN,NaN));
        vects2{a} = tsdArray(tsd(NaN,NaN));
    end
end


   