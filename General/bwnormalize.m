function normalized=bwnormalize(vect);
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself


mn=min(vect);
mx=max(vect);

normalized=(vect-mn)./(mx-mn);