function threshdiffmovie = BinaryThresholdDiffMovie(diffmovie)
% Takes in an RGB movie with dimensions height, width, 3 colors, framenum
% (ie from DiffResampledMovie), then converts to grayscale, thresholds to
% finds significantly bright areas and thresholds by size, outputs a binary
% 3D movie.

% disp('Finding movie-wide threshold for significant movement')
for a = 1:size(diffmovie,4);
    level(a) = graythresh(rgb2gray(diffmovie(:,:,:,a)));
    if rem(a,500)==0
%         disp(['Frame #',num2str(a),' done']);
    end
end
   
level = level(level>0.02);%remove thresholds relating to tiny movements
level = median(level);%make levels the same for all frames in movie... ?good?

% disp('Thresholding each image')
for a = 1:size(diffmovie,4);
    tempimage = rgb2gray(diffmovie(:,:,:,a));
    tempimage = im2bw(tempimage,level);
    threshdiffmovie(:,:,a) = bwareaopen(tempimage,15);
    if rem(a,500)==0
%         disp(['Frame #',num2str(a),' done']);
    end
end
1;