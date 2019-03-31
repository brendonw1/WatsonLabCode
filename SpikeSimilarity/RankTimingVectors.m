function [ranked1,ranked2] = RankTimingVectors(times1,times2,numints1,numints2,ov,normbool)
% Ranking cells by when they fired.  Assumes inf is the default state 
% First sort, which is not ranking: the kept output represents the
% cell index that was drawn to sort
%     tic

if ~exist('normbool','var')
    normbool = 0;
end

numcells = size(times1,3);

[~,q1] = sort(times1,3);
[~,q2] = sort(times2,3);

% Have to now take the cell idxs for sorting to lead to sorted ranked cells
r = 1:numcells;
r = repmat(r,[numints1 1 numints2]);
r = permute(r,[1 3 2]);

%     out1(q1) = r;
%     out2(q2)  = r;
%cumbersome and annoying I couldn't do this as above... 
ranked1 = zeros(size(times1));
ranked2 = zeros(size(times1));
for a = 1:numints1;
    for b = 1:numints2;%basically putting the rank of each cell for that event and putting into the spot signifying the value for that cell
        ranked1(a,b,q1(a,b,:)) = 1:numcells;
        ranked2(a,b,q2(a,b,:)) = 1:numcells;
    end
end

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

ranked1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
ranked2(~ov) = 0;

if normbool
    n1 = 1./sqrt(sum(ranked1.^2,2));%calc norms
    ranked1 = ranked1.*repmat(n1,[1 numints2 1]);%multiply by 1/norm
    n2 = 1./sqrt(sum(ranked2.^2,2));%calc norms
    ranked2 = ranked2.*repmat(n2,[1 numints2 1]);%multiply by 1/norm
    ranked1(~ov) = 0;%zero out ranking of cells that never actually fired (were called 0 sec and ranked accordingly)
    ranked2(~ov) = 0;
end
