function BatchProcessMovieMotionOct2014

origpath = cd;

% batch processing of all moviemovement for all recording directories in a
% supradirectory
d = dir;
for a = 1:length(d);
    try
        if d(a).isdir
            if ~strcmp(d(a).name,'..') && ~strcmp(d(a).name,'.') && ~strcmp(d(a).name,'OriginalClus') && ~strcmp(d(a).name,'Sammy_081814') && ~strcmp(d(a).name,'Sammy_081914') && ~strcmp(d(a).name,'Sammy_082014') && ~strcmp(d(a).name,'UnmergedData')
                basename = d(a).name;
                disp(['Starting ',basename])

                thispath = fullfile(cd,basename);
                cd(thispath) %just easier than fixing a bunch of subfunctions

                atv = [];
                ft = [];

                db = dir(fullfile(thispath,'*.tsp'));
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
                end
                save([basename,'_MovieMotion.mat'],'atv')

                cd(origpath)

            end
        end
    catch 
        cd(origpath)
        continue
    end
end