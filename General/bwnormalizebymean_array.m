function normalized=bwnormalizebymean_array(array)
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself


me=nanmean(array,2);

me = repmat(me,1,size(array,2));

normalized=array./me;