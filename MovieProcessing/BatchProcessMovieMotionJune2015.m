function BatchProcessMovieMotionJune2015

origpath = cd;

% batch processing of all moviemovement for all recording directories in a
% supradirectory
d = dir;
for a = 1:length(d);
    try
        if d(a).isdir
            if ~strcmp(d(a).name,'..') && ~strcmp(d(a).name,'.') && ~strcmp(d(a).name,'OriginalClus') && ~strcmp(d(a).name,'Sammy_081814') && ~strcmp(d(a).name,'Sammy_081914') && ~strcmp(d(a).name,'Sammy_082014')
                basename = d(a).name;
                disp(['Starting ',basename])

                thispath = fullfile(cd,basename);
                cd(thispath) %just easier than fixing a bunch of subfunctions

                MovieMotionOneSession(thispath,basename)

                cd(origpath)

            end
        end
    catch 
        disp('Error on folder')
        cd(origpath)
        continue
    end
end