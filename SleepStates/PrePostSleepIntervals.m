function PrePostSleepMetaData = PrePostSleepIntervals(presleepstartstop,postsleepstartstop,intervals,UPInts,DNInts)

presleepstartstop = presleepstartstop*10000;%convert to tstoolbox timebase
postsleepstartstop = postsleepstartstop*10000;%convert to tstoolbox timebase

presleepInt = intervalSet(presleepstartstop(1),presleepstartstop(2));%temporary manual approx, refined later
preSWSIntSet = intersect(intervals{3},presleepInt);
preREMIntSet = intersect(intervals{5},presleepInt);
preSWSStartStopsAll = [Start(preSWSIntSet) End(preSWSIntSet)];
preREMStartStopsAll = [Start(preREMIntSet) End(preREMIntSet)];
[dummy,presleepSWSlist] = ismember(preSWSStartStopsAll(:,1),Start(intervals{3}));
[dummy,presleepREMlist] = ismember(preREMStartStopsAll(:,1),Start(intervals{5}));
prestart = min(FirstTime(subset(intervals{3},presleepSWSlist)),FirstTime(subset(intervals{5},presleepREMlist)));
prestop = max(LastTime(subset(intervals{3},presleepSWSlist)),LastTime(subset(intervals{5},presleepREMlist)));
presleepInt = intervalSet(prestart,prestop);
preUPStartStopsAll = [Start(intersect(UPInts,presleepInt)) End(intersect(UPInts,presleepInt))];
[dummy,preUPslist] = ismember(preUPStartStopsAll(:,1),Start(UPInts));
preDNStartStopsAll = [Start(intersect(DNInts,presleepInt)) End(intersect(DNInts,presleepInt))];
[dummy,preDNslist] = ismember(preDNStartStopsAll(:,1),Start(DNInts));

postsleepInt = intervalSet(postsleepstartstop(1),postsleepstartstop(2));%temporary manual approx, refined later
postSWSIntSet = intersect(intervals{3},postsleepInt);
postREMIntSet = intersect(intervals{5},postsleepInt);
postSWSStartStopsAll = [Start(postSWSIntSet) End(postSWSIntSet)];
postREMStartStopsAll = [Start(postREMIntSet) End(postREMIntSet)];
[dummy,postsleepSWSlist] = ismember(postSWSStartStopsAll(:,1),Start(intervals{3}));
[dummy,postsleepREMlist] = ismember(postREMStartStopsAll(:,1),Start(intervals{5}));
poststart = min(FirstTime(subset(intervals{3},postsleepSWSlist)),FirstTime(subset(intervals{5},postsleepREMlist)));
poststop = max(LastTime(subset(intervals{3},postsleepSWSlist)),LastTime(subset(intervals{5},postsleepREMlist)));
postsleepInt = intervalSet(poststart,poststop);
postUPStartStopsAll = [Start(intersect(UPInts,postsleepInt)) End(intersect(UPInts,postsleepInt))];
[dummy,postUPslist] = ismember(postUPStartStopsAll(:,1),Start(UPInts));
postDNStartStopsAll = [Start(intersect(DNInts,postsleepInt)) End(intersect(DNInts,postsleepInt))];
[dummy,postDNslist] = ismember(postDNStartStopsAll(:,1),Start(DNInts));

PrePostSleepMetaData = v2struct(presleepSWSlist,presleepREMlist,...
    preSWSIntSet, preREMIntSet, presleepInt,...
    preSWSStartStopsAll, preREMStartStopsAll,...
    preUPslist, preUPStartStopsAll,...
    preDNslist, preDNStartStopsAll,...
    postsleepSWSlist, postsleepREMlist,...
    postSWSIntSet, postREMIntSet, postsleepInt,...
    postSWSStartStopsAll, postREMStartStopsAll,...
    postUPslist, postUPStartStopsAll,...
    postDNslist, postDNStartStopsAll);
% clear presleepSWSlist presleepREMlist presleepInt postsleepSWSlist postsleepREMlist...
%     postsleepInt prestart prestop poststart poststop...
%     preSWSStartStopsAll preREMStartStopsAll postSWSStartStopsAll postREMStartStopsAll...
%     preUPslist preUPStartStopsAll postUPslist postUPStartStopsAll...
%     preDNslist preDNStartStopsAll postDNslist postDNStartStopsAll...
%     preSWSIntSet preREMIntSet postSWSIntSet postREMIntSet