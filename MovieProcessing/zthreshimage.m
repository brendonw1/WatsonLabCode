function out = zthreshimage(im,zthresh)
%takes in an image, zscores it then returns a binary of pixels above that
%threshold
% Brendon Watson 2015

im = double(im);
noninf = ~isinf(im);

im(im == -Inf) = min(im(noninf));
im(im == Inf) = max(im(noninf));

zim = (im-nanmean(im(:)))/nanstd(im(:));

out = zeros(size(im));

goodpix = zim>zthresh;
out(goodpix) = 1;

% out(goodpix) = im(goodpix);
