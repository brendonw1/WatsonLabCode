function m = SharedOverUnion(bools)
bools = logical(bools);

chunksz = 1000;
[numints,numcells] = size(bools);

if numints<=chunksz
    b2 = reshape(bools,[numints 1 numcells]);%flip so cells is in 3rd dimension
%     clear bools

    b2 = repmat(b2,[1 numints 1]);%replicate over intervals
    b3 = permute(b2,[2 1 3]);%make a copy that is flipped so the events will cross index
    m = b2.*b3;%logical multiply to keep only common/shared cells
    m = sum(m,3);%summate to get total cells shared by each pair of events... will now be 2d
    m = m./sum(logical(b2+b3),3);%divide by any cells active in either.
else%chunk-based version of above
    % management of chunks/prep
    numchunks = ceil(numints/chunksz);
    m = zeros(numints,numints);
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
            tb1 = reshape(tb1,[achunklength 1 numcells]);%flip so cells is in 3rd dimension
            tb1 = repmat(tb1,[1 bchunklength 1]);%replicate over intervals

            tb2 = bools(bstartidx:bstopidx,:);
            tb2 = reshape(tb2,[bchunklength 1 numcells]);%flip so cells is in 3rd dimension
            tb2 = permute(tb2,[2 1 3]);
            tb2 = repmat(tb2,[achunklength 1 1]);%replicate over intervals

            % actual algorithm
            tm = tb1.*tb2;%logical multiply to keep only common/shared cells
            tm = sum(tm,3);%summate to get total cells shared by each pair of spindles... will now be 2d
            tm = tm./sum(logical(tb1+tb2),3);%divide by any cells active in either.

            % assigning to output variable
            m(astartidx:astopidx,bstartidx:bstopidx) = tm;
        end
    end
end
