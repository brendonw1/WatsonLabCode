function spans = FindSettleBack(hightimes,signal,belowthresh)
% Take list of times (hightimes), find when they settle back below the
% value belowthresh both before and after the individual times nominated

if size(hightimes,2) == 2%if given pairwise inputs
    hightimes = hightimes(:,1);
end
hightimes = hightimes(:);

spans = nan(length(hightimes),2);
for a = 1:length(hightimes) 
    spans(a,1) = find(signal(1:hightimes(a))<belowthresh,1,'last');
    spans(a,2) = hightimes(a)+find(signal(hightimes(a):end)<belowthresh,1,'first');
end

