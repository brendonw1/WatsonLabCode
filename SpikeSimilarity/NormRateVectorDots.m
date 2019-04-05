function m = NormRateVectorDots(rates)
[numints,numcells] = size(rates);
chunksz = 1000;

if numints<=chunksz
    %normalize
    n = 1./sqrt(sum(rates.^2,2));%calc norms
    nr = rates.*repmat(n,[1 size(rates,2)]);%multiply

    %prep 2 matrices to dot each vector against every other
    r2 = reshape(nr,[numints 1 numcells]);%flip so cells is in 3rd dimension
    r2 = repmat(r2,[1 numints 1]);%replicate over intervals
    r3 = permute(r2,[2 1 3]);%make a copy that is flipped so the spindles will cross index

    %calculate
    m = dot(r2,r3,3);
else
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
            tr1 = rates(astartidx:astopidx,:);
            n = 1./sqrt(sum(tr1.^2,2));%calc norms
            tr1 = tr1.*repmat(n,[1 size(tr1,2)]);%multiply rates mtx * norm factors
            tr1 = reshape(tr1,[achunklength 1 numcells]);%flip so cells is in 3rd dimension
            tr1 = repmat(tr1,[1 bchunklength 1]);%replicate over intervals

            tr2 = rates(bstartidx:bstopidx,:);
            n = 1./sqrt(sum(tr2.^2,2));%calc norms
            tr2 = tr2.*repmat(n,[1 size(tr2,2)]);%multiply rates mtx * norm factors
            tr2 = reshape(tr2,[bchunklength 1 numcells]);%flip so cells is in 3rd dimension
            tr2 = permute(tr2,[2 1 3]);
            tr2 = repmat(tr2,[achunklength 1 1]);%replicate over intervals

            % actual algorithm
            tm = dot(tr1,tr2,3);
            
            % assigning to output variable
            m(astartidx:astopidx,bstartidx:bstopidx) = tm;
        end
    end
end