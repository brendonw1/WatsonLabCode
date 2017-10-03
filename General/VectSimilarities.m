function dists = VectSimilarities(vects)
% vects is a matrix.  Dimension1 encodes episode/measurement num.
% Dimension2 encodes dimension values.  Gets distance between each
% columnn (dimension1) across each other column.

dists = nan(size(vects,1),size(vects,1));
for a = 1:size(vects,1)
    for b = a+1:size(vects,1);
        dists(a,b) = pdist2(vects(a,:),vects(b,:));
    end
end