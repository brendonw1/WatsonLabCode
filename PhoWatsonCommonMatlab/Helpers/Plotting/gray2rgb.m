function [rgbImage] = gray2rgb(grayscaleImage)
%GRAY2RGB Inverse of rgb2gray. Takes a grayscale image and returns an RGB representation of that grayscale (obviously not colorizing it or anything).
%   Visually the image is unchanged by this operation
	rgbImage = cat(3, grayscaleImage, grayscaleImage, grayscaleImage);
end

