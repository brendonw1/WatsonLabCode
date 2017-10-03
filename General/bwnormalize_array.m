function normalized=bwnormalize_array(array)
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself


mn=min(array,[],2);
mx=max(array,[],2);

mn = repmat(mn,1,size(array,2));
mx = repmat(mx,1,size(array,2));

normalized=(array-mn)./(mx-mn);