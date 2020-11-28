function d = getdropbox

[~,cname]=system('hostname');

if length(cname) >= 9 %sometimes there are spaces at the end of cname
    if strcmp(cname(1:9),'Mac176698')%if I'm on my laptop
        d = '/Users/brendon/Dropbox';
    end
end
if length(cname) >= 5 
    if strcmp(cname(1:5),'chemo')
        d = '/borderlineDropbox';
    end
end
if ~exist('d','var')
    if length(cname) >= 6
        if strcmp(cname(1:6),'balrog')
            d = '/home/brendonw/Dropbox/';
        end
    end
end
if ~exist('d','var')
    if length(cname) >= 10
        if strcmp(cname(1:10),'borderline')
            d = '/mnt/brendon4/Dropbox';
        end
    end
end
