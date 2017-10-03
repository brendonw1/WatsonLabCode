function episodes = SWSREMSleepEpisodes(intervals,REMmin,SWSmin,REMmerge,SWSmerge,restrictinginterval)
% episodes = GetTripletSleepEpisodes(varargin)GetTripletSleepEpisodes
%
% Tries to create triplets of SWS-REM-SWS as in Grosmark et al.  Looks for
% SWS-REM and REM-SWS transitions within 2sec of each other.  Excludes
% SWS < SWSmin sec, excludes REM < REMmin sec long (the SWS can be concatenated if there
% was a SWS stop followed by a start less than SWSmin sec separated, as long as
% no REM was in between, also merges REM within REMmerge seconds).  

% if ~exist('intervals','var')
%     intervals = ConvertStatesVectorToIntervalSets;%propts user to help grab states file
% end

SWSintervals = intervals{3};
REMintervals = intervals{5};

if exist('restrictinginterval','var')
   SWSintervals = intersect(SWSintervals,restrictinginterval);
   REMintervals = intersect(REMintervals,restrictinginterval);
   offset = Start(restrictinginterval);
else
    offset = 0;
end

% REMintervals = MergeCloseAIfBNotBetween(REMintervals,union(SWSintervals,intervals{4}),10);%Merge REM episodes within 10sec of each other as long as SWS or IntSleep are not between
SWSintervals = MergeCloseAIfBNotBetween(SWSintervals,REMintervals,SWSmerge);%Merge SWS episodes within 30sec of each other as long as REM is not between
REMintervals = mergeCloseIntervals(REMintervals,REMmerge*10000);%merge any REMs within 30sec of each other

SWSintervals = dropShortIntervals(SWSintervals,SWSmin*10000);%keep SWS >=n 100sec
REMintervals = dropShortIntervals(REMintervals,REMmin*10000);%keep rem >=n 50sec

REMStarts = Start(REMintervals);
REMStops = End(REMintervals);
SWSStarts = Start(SWSintervals);
SWSStops = End(SWSintervals);

%look for REMs with adjacent SWSs 
episodes = {};
for a=1:length(length(REMintervals))
	SWSRightBefore = [];%to clear out from prior runs of this loop
% 	SWSRightAfter = [];
	SWSRightBefore = find(SWSStops<=REMStarts(a) & SWSStops>=(REMStarts(a)-20000));%find SWS ending 0 to 2sec before this rem
% 	SWSRightAfter = find(SWSStarts>=REMStops(a) & SWSStarts<=(REMStops(a)+20000));%find SWS starting 0 to 2sec after this rem
% 	if ~isempty(SWSRightBefore) && ~isempty(SWSRightAfter)%if have both, store as an "episode"
	if ~isempty(SWSRightBefore)%if have both, store as an "episode"
        thispreSWS = subset(SWSintervals,SWSRightBefore);
        thisREM = subset(REMintervals,a);
%         thispostSWS = subset(SWSintervals,SWSRightAfter);

        episodes{end+1} = cat(thispreSWS,thisREM);
	end
end
1;


% - Make document of how I do this, for record
% - REMS - if broken…30sec ok? - check my subjective opinion… store as interrupted… can analyze REM before and after… esp as these are often the largest REMs
% - SWS - if broken … ? see if Intermediate or not
% - toss/combine REM <50sec (mean was ~500sec)
% - needs SWS before and after REM
% - Cannot contain waking of more than 120sec (?)… 
% - Begins with?
% - Ends with?




function newAIntervals = MergeCloseAIfBNotBetween(AIntervals, BIntervals, timecutoff)
% Merges pairs of intervals of type A if they are both close enough and no
% episodes of type B is in between (ie don't merge REM if SWS not between).
% Inputs: AIntervals = intervals to be potentially merged
%         BIntervals = intervals to make sure are not between A intervals
%         timecutoff = timespan (in seconds) below which close intervals
%         can putatively be merged
%
% Outputs: newAIntervals = properly merged intervals from A
% Code by Adrien Peyrache, commented, cleaned and generalized by Brendon
% Watson
% Jan 2014

timecutoff = timecutoff*10000;%correcting to timebase of tstoolbox

AStarts = Start(AIntervals);
AStops = End(AIntervals);
BStarts = Start(BIntervals);

betweenA = intervalSet(AStops(1:end-1),AStarts(2:end));%make intervals of the between-REM periods
betweenA = dropLongIntervals(betweenA,(timecutoff+1));%drop intervalSet that are too long (under your criteria, here 10 sec)

stB = ts(BStarts);%make a tsd of the starts of sws's
BInA = Data(intervalCount(stB,betweenA)); %list how many sws's start between REMs (betweens that are short enough)
betweenA = subset(betweenA,BInA==0);%keep only between periods where no SWS started... ie ones we can merge across
newAIntervals = union(AIntervals,betweenA);%put the good inbetweens into the same set as the rest of the REMs
newAIntervals = mergeCloseIntervals(newAIntervals,2);%now merge adjacent ones (allow gap of 1 sec in case)

    
