function [ax,t1,t2] = PlotPETHNormAxesData(epaligned,ax,col,usesd,xlimwide,adddots)
% aligned data, axes, color

if ~exist('ax','var')
    ax = gca;
end
if ~exist('col','var')
    col = 'k';
end
if ~exist('usesd','var')
    usesd = 1;
end
if ~exist('xlimwide','var')
    xlimwide = 1;
end
if ~exist('adddots','var')
    adddots = 0;
end

% v2struct(PETH)
v2struct(epaligned)
if exist('align_norm','var')
    norm = align_norm;
end

normmean = nanmean(norm,2);
normstd = nanstd(norm,[],2);

dataformaxmin = [];
u = get(ax,'UserData');
if ~isempty(u)
    dataformaxmin = u;
end

if xlimwide 
    xl = [-0.1 1.1];
else
    xl = [0 1];
end

hold on
% plot([0 0],[-100 100],'color',col,'parent',ax)
% plot([1 1],[-100 100],'color',col)
plot(t_norm,normmean,'color',col,'parent',ax);
if adddots
    plot(t_norm,normmean,'color',col,'marker','.','parent',ax);
end

% xlabel('t, normalized (s)')

okforlimidxs = t_norm>xl(1) & t_norm<xl(2);
okforlim = normmean(okforlimidxs);
dataformaxmin = cat(1,dataformaxmin,okforlim);

if usesd
    sdtop = normmean+normstd;
    sdbottom = normmean-normstd;
    plot(t_norm,sdtop,'color',col,'linestyle',':')
    plot(t_norm,sdbottom,'color',col,'linestyle',':')
    dataformaxmin = cat(1,dataformaxmin,sdtop(okforlimidxs),sdbottom(okforlimidxs));
end

dataformaxmin(isinf(dataformaxmin)) = nan;
ma = nanmax(dataformaxmin);
mi = nanmin(dataformaxmin);
yla = 0.0*(ma-mi);
yl = [mi-yla ma+yla];
if sum(~isnan(yl))==2 & yl(1)~=yl(2)
    ylim([mi-yla ma+yla])
else
    axis tight
end


plot([0 0],[mi-yla ma+yla],'k','parent',ax)
plot([1 1],[mi-yla ma+yla],'k','parent',ax)
xlim(xl)

set(ax,'UserData',dataformaxmin);


%% Get correlation of value vs time
%correlation vs full normalized time
idxs = t_norm>=0 & t_norm < 1;
times = t_norm(idxs);
tvals = [];
ttimes = [];
for a = 1:size(norm,2)
    tvals = cat(1,tvals,norm(idxs,a));
    ttimes = cat(1,ttimes,times(:));
end
[yfit100,r100,p100,coeffs100,CI100] =  RegressAndFindR(ttimes,tvals);
if p100<0.05
    col = 'r';
else
    col = 'k';
end
t1 = text(times(1),mi+0.95*(ma-mi),['0to1.0: r=' num2str(r100) '. p=' num2str(p100)],'FontSize',8,'color',col,'tag','ptext');

%correlation vs 0-85% normalized time
idxs = t_norm>0 & t_norm <= .85+eps;
times = t_norm(idxs);
tvals = [];
ttimes = [];
for a = 1:size(norm,2)
    tvals = cat(1,tvals,norm(idxs,a));
    ttimes = cat(1,ttimes,times(:));
end
[yfit85,r85,p85,coeffs85,CI85] =  RegressAndFindR(ttimes,tvals);
if p85<0.05
    col = 'r';
else
    col = 'k';
end
t2 = text(times(1),mi+0.875*(ma-mi),['0to0.85: r=' num2str(r85) '. p=' num2str(p85)],'FontSize',8,'color',col,'tag','ptext');
