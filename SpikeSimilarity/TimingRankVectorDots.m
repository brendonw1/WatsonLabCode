function [m,sov] = TimingRankVectorDots(times)
%takes in spike times (event x cell), looks for events where cells are
%shared, then 

minsharedcells = 3;%arbitrary minimum number of co-active cells that must be shared by any two compaired events
chunksz = 300;%semi-arbitrary, based on ram of computer

times(isnan(times)) = 0;
bools = logical(times);
[numints,numcells] = size(bools);

if numints<=chunksz
    [m,sov] = actualrankdots(bools,bools,times,times,numints,numints,numcells,minsharedcells);
else
    % management of chunks/prep
    numchunks = ceil(numints/chunksz);
    m = zeros(numints,numints);
    ov = zeros(numints,numints);
    for a = 1:numchunks
        astartidx = (a-1)*chunksz+1;
        astopidx = min([a*chunksz numints]);
        achunklength = astopidx-astartidx+1;
        for b = 1:numchunks
            bstartidx = (b-1)*chunksz+1;
            bstopidx = min([b*chunksz numints]);
            bchunklength = bstopidx-bstartidx+1;

            % extracting and shaping submatrices for processing
            tb1 = bools(astartidx:astopidx,:);
            tt1 = times(astartidx:astopidx,:);
            tb2 = bools(bstartidx:bstopidx,:);
            tt2 = times(bstartidx:bstopidx,:);

            [tm,tsov] = actualrankdots(tb1,tb2,tt1,tt2,achunklength,bchunklength,numcells,minsharedcells);

            % assigning to output variable
            m(astartidx:astopidx,bstartidx:bstopidx) = tm;
            sov(astartidx:astopidx,bstartidx:bstopidx) = tsov;
        end
    end
end

%set up to clear diagonal
blankout = zeros(numints1,numints2);
diagcoords = 1:min([numints1,numints2]);
inds = sub2ind(size(blankout),diagcoords,diagcoords);
blankout(inds) = 1;
blankout = logical(blankout);
%clear diagonals
m(logical(blankout)) = 0;
sov(blankout) = 0;


function [m,sov] = actualrankdots(bools1,bools2,times1,times2,numints1,numints2,numcells,minsharedcells)
%% ALGORITHM    
% Find cells overlapping between each pair of events... using a logical
% verison of timing array
% repmat the bools to find overlap cells
bools1 = reshape(bools1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
bools1 = repmat(bools1,[1 numints2 1]);%replicate over intervals

bools2 = reshape(bools2,[numints2 1 numcells]);%flip so cells is in 3rd dimension
bools2 = permute(bools2,[2 1 3]);
bools2 = repmat(bools2,[numints1 1 1]);%replicate over intervals

ov = bools1.*bools2;%logical multiply to keep only common/shared cells
sov = sum(ov,3);
nov = sov<minsharedcells;%index by index matrix of pairs NOT meeting criteria
%     nov = sum(ov,3)~=minsharedcells;%index by index matrix of pairs NOT meeting criteria

times1 = reshape(times1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
times1 = repmat(times1,[1 numints2 1]);%replicate over intervals
times1(~ov) = Inf;%keep only interval pairs with minimum number of shared cells (minsharedcells)

times2 = reshape(times2,[numints2 1 numcells]);%flip so cells is in 3rd dimension
times2 = permute(times2,[2 1 3]);
times2 = repmat(times2,[numints1 1 1]);%replicate over intervals
times2(~ov) = Inf;%keep only interval pairs with minimum number of shared cells (minsharedcells)


% Prepare actual timing array for all-to-all comparison
times1(~ov) = Inf;%keep only interval pairs with minimum number of shared cells (minsharedcells)
times2(~ov) = Inf;

%%Long process of ranking cells by when they fired... 
%First sort, which is not ranking: the kept output represents the
%cell index that was drawn to sort
%     tic
[~,q1] = sort(times1,3);
[~,q2] = sort(times2,3);

% Have to now take the cell idxs for sorting to lead to sorted ranked cells
r = 1:numcells;
r = repmat(r,[numints1 1 numints2]);
r = permute(r,[1 3 2]);

%     out1(q1) = r;
%     out2(q2)  = r;
out1 = zeros(size(times1));
out2 = zeros(size(times1));
for a = 1:numints1;%cumbersome and annoying I couldn't do this as above... 
    for b = 1:numints2;%basically putting the rank of each cell for that event and putting into the spot signifying the value for that cell
        out1(a,b,q1(a,b,:)) = 1:numcells;
        out2(a,b,q2(a,b,:)) = 1:numcells;
    end
end
%     toc

%     Equivalent to above ranking, but takes longer
%     tic
%     out1 = zeros(size(b2));
%     out2 = zeros(size(b2));
%     for a = 1:numints
%         for b = 1:numints
%             t = b2(a,b,:);
%             r = tiedrank(t(:));
%             out1(a,b,:) = reshape(r,1,1,numel(r));
%             t = b3(a,b,:);
%             r = tiedrank(t(:));
%             out2(a,b,:) = reshape(r,1,1,numel(r));
%         end
%     end
%     toc

out1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
out2(~ov) = 0;

m = dot(out1,out2,3);%dot product to do event-by-event comparision
m(nov) = 0;%if insufficient overlap in a pair, ie below minsharedcells, blank out score for that pair

% ... ?need to normalize by number of cells
% ... normalize length of vectors?

