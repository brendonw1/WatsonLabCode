function normalized=bwnormalizebysum_array(array)
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself


su=nansum(array,2);

su = repmat(su,1,size(array,2));

normalized=array./su;