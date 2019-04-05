function out = threshimage(im,thresh)
%takes in an image, then returns a binary of pixels above that
%threshold
% Brendon Watson 2015

im = double(im);

out = zeros(size(im));

goodpix = im>thresh;
out(goodpix) = 1;

% out(goodpix) = im(goodpix);
