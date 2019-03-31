function SaveDirectoryImagesToSinglePDF(dirpath,pdfname,imgext,include,exclude)

if ~exist('dirpath','var')
    dirpath = cd;
end
if ~exist('pdfname','var')
    pdfname = 'BatchOut.pdf';
end
if ~exist('imgext','var')
    imgext = 'png';
end
if ~exist('include','var')
    include = [];
end
if ~exist('exclude','var')
    exclude = [];
end

if strcmp(imgext(1),'.')
    imgext = imgext(2:end);
end
if length(pdfname)<5  
    pdfname = [pdfname '.pdf'];
elseif ~strcmp(pdfname(end-3:end),'.pdf')
    pdfname = [pdfname '.pdf'];
end
if ~iscell(include);
    t = include;
    clear include
    include{1} = t;
end
if ~iscell(exclude);
    t = exclude;
    clear exclude
    exclude{1} = t;
end

%% get files
cd(dirpath)
searchstring = ['*.' imgext];
d = dir(searchstring);

%% include/exclude text strings
% for include you must meet all include criteria
% for exclude you must meet any exclude criteria
if ~isempty(include{1})
    for a = length(d):-1:1
        keep = [];
        for b = 1:length(include)
           if findstr(include{b},d(a).name)
               keep(b) = 1;
           else
               keep(b) = 0;
           end
        end
        if sum(keep) ~= length(keep)
            d(a) = [];
        end
    end
end

if ~isempty(exclude{1})
    for a = length(d):-1:1
        toss = 0;
        for b = 1:length(exclude)
           if findstr(exclude{b},d(a).name)
                toss(b) = 1;
           end
        end
        if sum(toss)
            d(a) = [];
        end
    end
end

%% copy to temporary new directory, convert to pdf using linux, then move pdf back and delete temp directory
td = fullfile(dirpath,'temppdfmakingfolder');
mkdir(td)
for a = 1:length(d)
   copyfile(d(a).name,td) 
end
origpath = cd;
cd(td);
eval(['!convert * ' pdfname])

movefile(pdfname,'../')
cd(origpath)
rmdir(td,'s')
