function [ttable,badidxs] = ExcludeTimeEpochsFromTimeTable(ttable,badepochstarts,badepochstops)

if size(badepochstarts,1) ~= size(badepochstops,1)
    disp('badepochstarts and badepochstops have different lengths.  Quitting')
    return
end


for a = 1:size(badepochstarts,1)
    badidxs = ttable>badepochstarts(a) & ttable<badepochstops(a);
    ttable(badidxs) = [];
end

