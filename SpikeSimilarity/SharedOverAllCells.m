function m = SharedOverAllCells(bools)
[numints,numcells] = size(bools);
b2 = reshape(bools,[numints 1 numcells]);%flip so cells is in 3rd dimension
b2 = repmat(b2,[1 numints 1]);%replicate over intervals
b3 = permute(b2,[2 1 3]);%make a copy that is flipped so the spindles will cross index
m = b2.*b3;%logical multiply to keep only common/shared cells
m = sum(m,3);%summate to get total cells shared by each pair of spindles... will now be 2d
m = m/numcells;%divide by total num cells
