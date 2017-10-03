function [prestops,poststops,intervalidxs] = getIntervalStopsWithinBounds(intervalstouse,beforesample,aftersample,goodinterval,tssampfreq,intervalsToTransitionTo)

intervalstops = End(intersect(intervalstouse,goodinterval))/tssampfreq;%episode start time in sec

%find cases where intervalstotransitionto are met... ie if want to make
%sure rem offsets are only kept if go into SWS
if exist('intervalsToTransitionTo','var')
    itttstarts = Start(intervalsToTransitionTo)/tssampfreq;
    for a = length(intervalstops):-1:1
        tracker = 0;%logical
        for b=0:2 %give a buffer or error time up to 2 secs for the transition to the desired state
            thisstart = intervalstops(a)+b;%try out different start times up to the buffer time
            if ismember(thisstart,itttstarts)%if state stop is followed by proper subsequent interval
                tracker=1;%keep that interval
            end
        end
        if tracker == 0%if no overlap, with proper subsequent state, dump this interval
            intervalstops(a)=[];
        end
    end
end

prestops = intervalstops - beforesample;%get pre-start time
poststops = intervalstops + aftersample;% and post

% get rid of events that will run off the end of the useable period
tooearly = prestops < Start(goodinterval);
toolate = poststops > End(goodinterval);
toobad = tooearly | toolate;
prestops(toobad) = [];
poststops(toobad) = [];
intervalstops(toobad) = [];

%get indices of used intervals
[s, e] = intervalSetToVectors(intervalstouse);
e = e/tssampfreq;
[dummy,dummy,intervalidxs] = intersect(intervalstops,e);