function [r,p] = SequenceVsTemplateCorr(sequences,template)
% Calculates correlations (pearson) of all sequences in the matrix
% "sequences" against a template (template).  (Uses the matlab corr function
% which can do multiple all-to-all corelations, feeds that function chunks
% at a time, then extracts only the relevant correlation).
%
% INPUTS
% sequences - 2d matrix where d1 indexes events, d2 is cells (nevents x
%          ncells)
% template - vector of some template to compare against (ie spike
%          timings)... must be of length = ncells
%
% OUTPUTS
% r = pearson r for each correlation (comparision num x 1), outputs indexes
%          are based on the order of input sequences in sequences (ie
%          r(1) corresponds to correlation for first row of sequence).
% p = p value of each correlation, order as above.
%
% Brendon Watson 2015


template = template(:)';
chunksz = 100;
nseqs = size(sequences,1);

if nseqs>chunksz
    numchunks = ceil(nseqs/chunksz);
    p = [];
    r = [];
    for a = 1:numchunks
        tstart = (a-1)*chunksz +1;
        tstop = min([a*chunksz nseqs]);
    
        tchunk = sequences(tstart:tstop,:);
        mtx = cat(1,template,tchunk);
        [tr,tp] = corr(mtx','rows','pairwise');
        r = cat(1,r,tr(2:end,1));
        p = cat(1,p,tp(2:end,1));
    end        
else
    mtx = cat(1,template,sequences);
    [tr,tp] = corr(mtx','rows','pairwise');
    r = tr(2:end,1);
    p = tp(2:end,1);
end