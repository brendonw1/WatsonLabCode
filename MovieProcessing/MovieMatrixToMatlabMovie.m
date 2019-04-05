function F = MovieMatrixToMatlabMovie(mtx);
% Takes a 4D color movie matrix and converts it into a matlab "movie"
% object.
% mtx should be 4d: color1 x color2 x color3 x frames
% output F is a struct array that has frame information and can be played
% with the command movie(F,2) 
% copied from matlab2015b doc
% Brendon Watson 2016

figure
imagesc(mtx(:,:,:,1));
axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';


nloops = size(mtx,4);
F(nloops) = struct('cdata',[],'colormap',[]);
for a = 1:nloops
    imagesc(mtx(:,:,:,a));
    drawnow
    F(a) = getframe;
end
