function AboveTitle(txt,f)

%deal with either input figure or current figure
if ~exist('f','var')
    f = gcf;
end

%get axes in this figure
as = findobj('Type','axes','Parent',f);

%find topmost axes
for a  = 1:length(as);
    p = get(as(a),'Position');
    hs(a) = p(2)+p(4);
end
[mh,topax] = max(hs);

% textht = 1-(1-mh)/2;
textht = mh+0.02;

a = axes('Parent',f,'Visible','Off','Position',[0 textht 1 .01]);
t = title(a,txt);
set(t,'Visible','On')
set(t,'FontWeight','bold')