function MovieMotionOneSession(basepath,basename)

cd basepath

atv = [];
ft = [];

db = dir(fullfile(basepath,'*.tsp'));
db = length(db);

for b = 1:db
    if b<10
        filler = '-0';
    else
        filler = '-';
    end
    thisfile = [basename filler num2str(b)];
    disp(thisfile);
    [allthreshvect,frametimes] = GetMovieMovementVector(thisfile,1);
    atv = cat(1,atv,allthreshvect);
    ft = cat(2,ft,frametimes);
    save(fullfile(thispath,[basename,'_MovieMotion' num2str(b) '.mat']),'atv','ft')
end
save(fullfile(thispath,[basename,'_MovieMotion.mat']),'atv')
