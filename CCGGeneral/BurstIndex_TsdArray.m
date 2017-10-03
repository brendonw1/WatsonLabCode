function BurstIndex = BurstIndex_TsdArray(S,cutoff);

if ~exist('cutoff','var')
    cutoff = 0.015;%15ms default
end

BurstIndex = nan(1,length(S));

for a = 1:length(S);
    s = Range(S{a},'s');
    d = diff(s);
    b = sum(d<=cutoff);
    BurstIndex(a) = b/length(d);
%     if isinf(BurstIndex(a))
%         BurstIndex(a) = 0;
%     end
end 