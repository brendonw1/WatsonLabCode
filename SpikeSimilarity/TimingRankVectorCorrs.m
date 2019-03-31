function [corrm,ps] = TimingRankVectorCorrs(times,normbool)

if ~exist('normbool','var')
    normbool = 0;
end

minsharedcells = 3;%arbitrary minimum number of co-active cells that must be shared by any two compaired events
chunksz = 1000;%semi-arbitrary, based on ram of computer
[numints,numcells] = size(times);

times(isnan(times)) = 0;%serves purposes below just getting bools
bools = times;
bools(isnan(bools)) = 0;
bools = logical(bools);

if numints<=chunksz
    [corrm,ps,sov] = corrcalc_fornonsquare(bools,bools,times,times,1,numints,1,numints,numcells,minsharedcells,normbool);
else
    % management of chunks/prep
    numchunks = ceil(numints/chunksz);
%     dotm = zeros(numints,numints);
    corrm = nan(numints,numints);
%     distm = zeros(numints,numints);
%     ov = zeros(numints,numints);
    ps = nan(numints,numints);

    for a = 1:numchunks
        astartidx = (a-1)*chunksz+1;
        astopidx = min([a*chunksz numints]);
%         achunklength = astopidx-astartidx+1;
        for b = 1:numchunks
            bstartidx = (b-1)*chunksz+1;
            bstopidx = min([b*chunksz numints]);
%             bchunklength = bstopidx-bstartidx+1;

            % extracting and shaping submatrices for processing
            tb1 = bools(astartidx:astopidx,:);
            tb2 = bools(bstartidx:bstopidx,:);
            tt1 = times(astartidx:astopidx,:);
            tt2 = times(bstartidx:bstopidx,:);

%             [tcorrm,tsov] = corrcalc(tb1,tb2,ttimes,astartidx,astopidx,bstartidx,bstopidx,numcells,minsharedcells,normbool);
            [tcorrm,tps,~] = corrcalc_fornonsquare(tb1,tb2,tt1,tt2,astartidx,astopidx,bstartidx,bstopidx,numcells,minsharedcells,normbool);

            corrm(astartidx:astopidx,bstartidx:bstopidx) = tcorrm;
            ps(astartidx:astopidx,bstartidx:bstopidx) = tps;
%             sov(astartidx:astopidx,bstartidx:bstopidx) = tsov;
        end
    end
end

%set up to clear diagonal
blankout = logical(bwdiag(numints));
%clear diagonals
corrm(blankout) = 0;

% zcorrm = GenerateSumOfZdScores(corrm,sov,minsharedcells);



function [corrm,ps,sov] = corrcalc_fornonsquare(bools1,bools2,times1,times2,start1,end1,start2,end2,numcells,minsharedcells,normbool)
%% ALGORITHM    
% Find cells overlapping between each pair of events... using a logical
% verison of timing array

% repmat the bools to find overlap cells
numints1 = end1-start1+1;
numints2 = end2-start2+1;

%first just find events that pass test of enough overlap cellsbools1 = reshape(bools1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
bools1 = reshape(bools1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
bools1 = repmat(bools1,[1 numints2 1]);%replicate over intervals

bools2 = reshape(bools2,[numints2 1 numcells]);%flip so cells is in 3rd dimension
bools2 = permute(bools2,[2 1 3]);
bools2 = repmat(bools2,[numints1 1 1]);%replicate over intervals

ov = bools1.*bools2;%logical multiply to keep only common/shared cells
sov = sum(ov,3);
% nov = sov<minsharedcells;%index by index matrix of pairs NOT meeting criteria
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
times2(~ov) = Inf;%... INF because it works for ranking

%% Rank cells within each event by timing 
[ranked1,ranked2] = RankTimingVectors(times1,times2,numints1,numints2,ov);



%% Correlation estimation of similarity, computed independently for each
% collection of pairs with a given number of overlap cells (so vector
% lengths will all be the same).
origsharedinds = intersect(start1:end1,start2:end2);%list rows/columns along diagnoal
if length(origsharedinds) == numints1%if matches, it will always be square from around the diag... delete diag
    blankout = logical(bwdiag(numints1));
    sov(blankout) = 0;
end
overlapcounts = unique(sov(sov>=minsharedcells));%make a list of the observed numbers of pair-to-pair overlaps
%ie each number of cells overlapping, like pairs with 3 overlaps, 4
%overlaps... this gives 3,4,...

corrm = nan(numints1,numints2);
ps = nan(numints1,numints2);
for a = 1:length(overlapcounts)%for each diff size of overlap,etc... this is necessary because of a data extraction/matrix resizing assumption in generating corrcols1/2
    thisovnum = overlapcounts(a);
    [tidxs1,tidxs2] = find(sov==thisovnum);
    tnumpairs = length(tidxs1);
    corrcols1 = zeros(numcells,tnumpairs);
    corrcols2 = zeros(numcells,tnumpairs);
    for b = 1:tnumpairs%for each pair found to have thisovnum number of matches
        %extract and construct a series of columns to correlate
        corrcols1(:,b) = reshape(ranked1(tidxs1(b),tidxs2(b),:),numcells,1);
        corrcols2(:,b) = reshape(ranked2(tidxs1(b),tidxs2(b),:),numcells,1);
    end
    corrcols1(corrcols1==0) = [];%eliminate zeros, keep only values of cells that fired and were shared.  ... now is a big linear vector
    corrcols1 = reshape(corrcols1,thisovnum,tnumpairs);%... this is OK since for each pair the same cells will be kept in batches and will be reshaped into columns of length (thisovnum)
    % ie column per event with values for each cell... by event number...
    % with corresponding event numbers in corrcols2
    corrcols2(corrcols2==0) = [];
    corrcols2 = reshape(corrcols2,thisovnum,tnumpairs);

    % since each event in corrcols1 corresponds to an event in corrcols2,
    % want to only keep the diagnoal after corr.m below
    
    corrchunksz = 200;%optimizes for time (empirical) because of all-to-all in corr vs loop at this level of code
    if tnumpairs<=corrchunksz
        [r,p] = corr(corrcols1,corrcols2);%computes all to all, but we just want pairwise along diagonal
        r = diag(r);
        p = diag(p);
    else
%         tic
        r = zeros(tnumpairs,1);
        p = zeros(tnumpairs,1);
        for b = 1:ceil(tnumpairs/corrchunksz)
            pairsstartidx = (b-1)*corrchunksz+1;
            pairsstopidx = min([b*corrchunksz tnumpairs]);
            [tr,tp] = corr(corrcols1(:,pairsstartidx:pairsstopidx),corrcols2(:,pairsstartidx:pairsstopidx));
            r(pairsstartidx:pairsstopidx) = diag(tr);
            p(pairsstartidx:pairsstopidx) = diag(tp);
            clear tr
        end
%         toc
    end
    
    outputinds = sub2ind(size(corrm),tidxs1,tidxs2);%lets me place these values to the right spots in the output mtx
    
    corrm(outputinds) = r;%placing values in spots signifying proper indices
    ps(outputinds) = p;
end
