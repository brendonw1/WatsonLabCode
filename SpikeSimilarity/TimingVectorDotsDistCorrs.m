function [dotm,corrm,distm,zdotm,zcorrm,zdistm,sov] = TimingVectorDotsDistCorrs(times,normbool)
%takes in spike times (event x cell), looks for events where cells are
%shared, then 
%normbool determines whether normalization of dot and dist vectors happens

if ~exist('normbool','var')
    normbool = 0;
end

minsharedcells = 3;%arbitrary minimum number of co-active cells that must be shared by any two compaired events
chunksz = 1000;%semi-arbitrary, based on ram of computer

times(isnan(times)) = 0;
bools = logical(times);
[numints,numcells] = size(bools);


%% This top section is just a wrapper to take care of chunking too-big datasets
if numints<=chunksz
    [dotm,corrm,distm,sov] = rankcalcs(bools,bools,times,times,1,numints,1,numints,numcells,minsharedcells,normbool);
else
    % management of chunks/prep
    numchunks = ceil(numints/chunksz);
    dotm = zeros(numints,numints);
    corrm = zeros(numints,numints);
    distm = zeros(numints,numints);
    ov = zeros(numints,numints);
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
            tt1 = times(astartidx:astopidx,:);
            tb2 = bools(bstartidx:bstopidx,:);
            tt2 = times(bstartidx:bstopidx,:);

            [tdotm,tcorrm,tdistm,tsov] = rankcalcs(tb1,tb2,tt1,tt2,astartidx,astopidx,bstartidx,bstopidx,numcells,minsharedcells,normbool);

            % assigning to output variable
            dotm(astartidx:astopidx,bstartidx:bstopidx) = tdotm;
            corrm(astartidx:astopidx,bstartidx:bstopidx) = tcorrm;
            distm(astartidx:astopidx,bstartidx:bstopidx) = tdistm;
            sov(astartidx:astopidx,bstartidx:bstopidx) = tsov;
        end
    end
end

%set up to clear diagonal
blankout = logical(bwdiag(numints));
%clear diagonals
dotm(blankout) = 0;
corrm(blankout) = 0;
distm(blankout) = 0;
sov(blankout) = 0;

zdotm = GenerateSumOfZdScores(dotm,sov,minsharedcells);
zcorrm = GenerateSumOfZdScores(corrm,sov,minsharedcells);
zdistm = GenerateSumOfZdScores(distm,sov,minsharedcells);


function [dotm,corrm,distm,sov] = rankcalcs(bools1,bools2,times1,times2,start1,end1,start2,end2,numcells,minsharedcells,normbool)
%% ALGORITHM    
% Find cells overlapping between each pair of events... using a logical
% verison of timing array
% repmat the bools to find overlap cells
numints1 = end1-start1+1;
numints2 = end2-start2+1;

%first just find events that pass test of enough overlap cells
bools1 = reshape(bools1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
bools1 = repmat(bools1,[1 numints2 1]);%replicate over intervals

bools2 = reshape(bools2,[numints2 1 numcells]);%flip so cells is in 3rd dimension
bools2 = permute(bools2,[2 1 3]);
bools2 = repmat(bools2,[numints1 1 1]);%replicate over intervals

ov = bools1.*bools2;%logical multiply to keep only overalp/shared event cells
sov = sum(ov,3);
nov = sov<minsharedcells;%index by index matrix of pairs NOT meeting criteria
%     nov = sum(ov,3)~=minsharedcells;%index by index matrix of pairs NOT meeting criteria

clear bools1 bools2

times1 = reshape(times1,[numints1 1 numcells]);%flip so cells is in 3rd dimension
times1 = repmat(times1,[1 numints2 1]);%replicate over intervals
times1(~ov) = nan;%keep only interval pairs with minimum number of shared cells (minsharedcells)

times2 = reshape(times2,[numints2 1 numcells]);%flip so cells is in 3rd dimension
times2 = permute(times2,[2 1 3]);
times2 = repmat(times2,[numints1 1 1]);%replicate over intervals
times2(~ov) = nan;%keep only interval pairs with minimum number of shared cells (minsharedcells)

% Prepare actual timing array for all-to-all comparison
times1(~ov) = nan;%keep only interval pairs with minimum number of shared cells (minsharedcells)
times2(~ov) = nan;

% 
% %%Long process of ranking cells by when they fired... 
% %First sort, which is not ranking: the kept output represents the
% %cell index that was drawn to sort
% %     tic
% [~,q1] = sort(times1,3);
% [~,q2] = sort(times2,3);
% 
% % Have to now take the cell idxs for sorting to lead to sorted ranked cells
% r = 1:numcells;
% r = repmat(r,[numints1 1 numints2]);
% r = permute(r,[1 3 2]);
% 
% %     out1(q1) = r;
% %     out2(q2)  = r;
% ranked1 = zeros(size(times1));
% ranked2 = zeros(size(times1));
% for a = 1:numints1;%cumbersome and annoying I couldn't do this as above... 
%     for b = 1:numints2;%basically putting the rank of each cell for that event and putting into the spot signifying the value for that cell
%         ranked1(a,b,q1(a,b,:)) = 1:numcells;
%         ranked2(a,b,q2(a,b,:)) = 1:numcells;
%     end
% end
% 
% %     Equivalent to above ranking, but takes longer
% %     tic
% %     out1 = zeros(size(b2));
% %     out2 = zeros(size(b2));
% %     for a = 1:numints
% %         for b = 1:numints
% %             t = b2(a,b,:);
% %             r = tiedrank(t(:));
% %             out1(a,b,:) = reshape(r,1,1,numel(r));
% %             t = b3(a,b,:);
% %             r = tiedrank(t(:));
% %             out2(a,b,:) = reshape(r,1,1,numel(r));
% %         end
% %     end
% %     toc
% 
% ranked1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
% ranked2(~ov) = 0;
% 
% if normbool
%     n1 = 1./sqrt(sum(ranked1.^2,2));%calc norms
%     ranked1 = ranked1.*repmat(n1,[1 numints2 1]);%multiply by 1/norm
%     n2 = 1./sqrt(sum(ranked2.^2,2));%calc norms
%     ranked2 = ranked2.*repmat(n2,[1 numints2 1]);%multiply by 1/norm
%     ranked1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
%     ranked2(~ov) = 0;
% end

%% Dot product estimation of similarity... computed at once for all
% % comparisons
% % dotm = dot(ranked1,ranked2,3);%dot product to do event-by-event comparision
% dotm = dot(times1,times2,3);%dot product to do event-by-event comparision
% 
% dotm(nov) = 0;%if insufficient overlap in a pair, ie below minsharedcells, blank out score for that pair

%% Correlation estimation of similarity, computed independently for each
% collection of pairs with a given number of overlap cells (so vector
% lengths will all be the same).
origsharedinds = intersect(start1:end1,start2:end2);%list rows/columns along diagnoal
if length(origsharedinds) == numints1%if matches, it will always be square from around the diag... delete diag
    blankout = logical(bwdiag(numints1));
    sov(blankout) = 0;
end
overlapcounts = unique(sov(sov>minsharedcells));%make a list of the observed numbers of pair-to-pair overlaps

corrm = zeros(numints1,numints2);
for a = 1:length(overlapcounts)
    thisovnum = overlapcounts(a);
    [tidxs1,tidxs2] = find(sov==thisovnum);
    tnumpairs = length(tidxs1);
    corrcols1 = zeros(numcells,tnumpairs);
    corrcols2 = zeros(numcells,tnumpairs);
    for b = 1:tnumpairs%for each pair found to have thisovnum number of matches
        %extract and construct a series of columns to correlate
        corrcols1(:,b) = reshape(times1(tidxs1(b),tidxs2(b),:),numcells,1);
        corrcols2(:,b) = reshape(times2(tidxs1(b),tidxs2(b),:),numcells,1);
    end
    corrcols1(corrcols1==0) = [];%eliminate zeros, keep only ranks of cells that fired and were shared.  
    corrcols1 = reshape(corrcols1,thisovnum,tnumpairs);%... this is OK since for each pair the same cells will be kept.
    corrcols2(corrcols2==0) = [];
    corrcols2 = reshape(corrcols2,thisovnum,tnumpairs);

    corrchunksz = 200;%optimizes for time (empirical) because of all-to-all in corr vs loop at this level of code
    if tnumpairs<=corrchunksz
        r = corr(corrcols1,corrcols2);%computes all to all, but we just want pairwise along diagonal
        r = diag(r);
    else
%         tic
        r = zeros(tnumpairs,1);
        for b = 1:ceil(tnumpairs/corrchunksz)
            pairsstartidx = (b-1)*corrchunksz+1;
            pairsstopidx = min([b*corrchunksz tnumpairs]);
            tr = corr(corrcols1(:,pairsstartidx:pairsstopidx),corrcols2(:,pairsstartidx:pairsstopidx));
            r(pairsstartidx:pairsstopidx) = diag(tr);
            clear tr
        end
%         toc
    end
    
    outputinds = sub2ind(size(corrm),tidxs1,tidxs2);%lets me place these values to the right spots in the output mtx
    corrm(outputinds) = r;%placing values in spots signifying proper indices

end

clear corrcols1 corrcols2 r

%% Euclidian distance metric    
%normalize by length so comparisons of pairs with different num shared
%cells will be legit (?)
distm = zeros(numints1,numints2);

n1 = 1./sqrt(sum(ranked1.^2,2));%calc norms
nr1 = ranked1.*repmat(n1,[1 numints2 1]);%multiply by 1/norm
n2 = 1./sqrt(sum(ranked2.^2,2));%calc norms
nr2 = ranked2.*repmat(n2,[1 numints2 1]);%multiply by 1/norm
nr1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
nr2(~ov) = 0;

[tidxs1,tidxs2] = find(sov>=minsharedcells);
outputinds = sub2ind(size(corrm),tidxs1,tidxs2);%lets me place these values to the right spots in the output mtx
tnumpairs = length(tidxs1);
distcols1 = zeros(numcells,tnumpairs);
distcols2 = zeros(numcells,tnumpairs);
for b = 1:tnumpairs%for each pair found to have at least min number of matches
    %extract and construct a series of columns to correlate
    distcols1(:,b) = reshape(nr1(tidxs1(b),tidxs2(b),:),numcells,1);
    distcols2(:,b) = reshape(nr2(tidxs1(b),tidxs2(b),:),numcells,1);
end

distchunksz = 100;%optimizes for time (empirical) because of all-to-all in corr vs loop at this level of code
if tnumpairs<=distchunksz
    r = dist(distcols1,distcols2);%computes all to all, but we just want pairwise along diagonal
    r = diag(r);
else
%     tic
    r = zeros(tnumpairs,1);
    for b = 1:ceil(tnumpairs/distchunksz)
        pairsstartidx = (b-1)*distchunksz+1;
        pairsstopidx = min([b*distchunksz tnumpairs]);
        tr = dist2(distcols1(:,pairsstartidx:pairsstopidx)',distcols2(:,pairsstartidx:pairsstopidx)');
        r(pairsstartidx:pairsstopidx) = diag(tr);
        clear tr
    end
%     toc
end
distm(outputinds) = r;%placing values in spots signifying proper indices


function [zm,profile] = GenerateSumOfZdScores(m,sov,minsharedcells)
% somewhat takes care of fact that metrics... not perfect, based on mean &
% sd of each group of ov-pairs that have each given number of ov cells
availoverlaps = unique(sov);
availoverlaps(availoverlaps<minsharedcells) = [];

for a = 1:length(availoverlaps)
    tnov = availoverlaps(a);
    tm = m;
    tm0 = m;
    tgood = sov==tnov;

    tm(~tgood) = NaN;
    tm0(~tgood) = 0;
    
    overallmeans(a) = mean(tm(~isnan(tm)));
    overallsds(a) = std(tm(~isnan(tm)));    
    meanscorepertimeperovnum(a,:) = sum(tm0,2)./sum(tgood,2);    
    meanscorepertimeperovnumZ(a,:) = (meanscorepertimeperovnum(a,:)-overallmeans(a))/overallsds(a);
    
    tm0 = (tm0-overallmeans(a))/overallsds(a);
    tm0(~tgood) = 0;
    zms(:,:,a) = tm0;
end

meanscorepertimeperovnumZ(isnan(meanscorepertimeperovnum)) = 0;
profile = sum(meanscorepertimeperovnumZ,1)./sum(isnan(meanscorepertimeperovnum),1);

zm = sum(zms,3);