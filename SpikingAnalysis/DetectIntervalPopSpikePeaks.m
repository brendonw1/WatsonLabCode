function [PeaksFromUPStart,PeaksFromFileStart] = DetectIntervalPopSpikePeaks(ints,S,meanvsmax)

if ~exist('meanvsmax','var')
    meanvsmax = 1;
end

switch meanvsmax
    case 1
    S = oneSeries(S);
    % PeaksFromUPStart = zeros(1,length(length(ints)));
    PeaksFromFileStart = zeros(1,length(length(ints)));

    for a = 1:length(Start(ints))
        t = Restrict(S,subset(ints,a));
        PeaksFromFileStart(a) = mean(TimePoints(t)); 
    end
    case 2
    %%
    binms = 5;%ms
    binsamps = binms*10;%# of 10000hz samples
    smoothing = 10;%num bins

    S = oneSeries(S);
    % PeaksFromUPStart = zeros(1,length(length(ints)));
    PeaksFromFileStart = zeros(1,length(length(ints)));

    for a = 1:length(Start(ints))
        t = Restrict(S,subset(ints,a));
        t = tsdArray(t);
        t = MakeQfromS(t,binsamps);%timepoints in samples of 10000Hz

        times = TimePoints(t);
        t = Data(t);
        t = smooth(t,smoothing);%moving average by #smoothing bins

        [~,tix]=max(t);
        PeaksFromFileStart(a) = times(tix); 
    end
end

PeaksFromFileStart = PeaksFromFileStart/10000;
PeaksFromUPStart = PeaksFromFileStart(:)' - Start(ints,'s')';
