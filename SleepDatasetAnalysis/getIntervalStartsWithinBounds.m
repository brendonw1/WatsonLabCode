function [prestarts,poststarts,intervalidxs] = getIntervalStartsWithinBounds(intervalstouse,beforesample,aftersample,goodinterval,tssampfreq)

intervalstarts = Start(intersect(intervalstouse,goodinterval))/tssampfreq;%episode start time in sec
prestarts = intervalstarts - beforesample;%get pre-start time
poststarts = intervalstarts + aftersample;% and post

% get rid of events that will run off the end of the useable period
tooearly = prestarts < Start(goodinterval);
toolate = poststarts > End(goodinterval);
toobad = tooearly | toolate;
prestarts(toobad) = [];
poststarts(toobad) = [];
intervalstarts(toobad) = [];

%get indices of used intervals
[s, e] = intervalSetToVectors(intervalstouse);
s = s/tssampfreq;
[dummy,dummy,intervalidxs] = intersect(intervalstarts,s);