function plotInts(intervals,colorwheel)
% plot collections of intervalSets in a cell (ie like sleep state
% intervals)

if ~exist('colorwheel','var')
    colorwheel = RainbowColors(length(intervals));
end

for a = 1:length(intervals)
    plot(intervals{a},colorwheel(a,:))
    hold on;
end