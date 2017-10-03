function SingleFolderProcessMovieMotionJuly2015


[~,basename,~] = fileparts(cd);

thispath = fullfile(cd,basename);

atv = [];
ft = [];

db = dir('*.tsp');
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
    save([basename,'_MovieMotion' num2str(b) '.mat'],'allthreshvect','frametimes')
    atv = cat(1,atv,allthreshvect);
    ft = cat(2,ft,frametimes);
end
save([basename,'_MovieMotion.mat'],'atv')
