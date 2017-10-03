function siaxh = SignificanceInset(HAx,datatoplot)


%% Significance testing
% signifs = zeros(length(datatoplot));
wps = ones(length(datatoplot));
tps = ones(length(datatoplot));
wsignifs = zeros(length(datatoplot));
tsignifs = zeros(length(datatoplot));

for a = 1:length(datatoplot)
    data1 = datatoplot{a};
    for b = a+1:length(datatoplot)
        data2 = datatoplot{b};
        try
            wp = ranksum(data1,data2);
            wps(a,b) = wp;
            if wp<0.05
                wsignifs(a,b) = 1;
            end        
        end
        try
            [~,tp] = ttest2(data1,data2);
            tps(a,b) = tp;
            if tp<0.05
                tsignifs(a,b) = 1;
            end        
        end
    end
end
% Plot significance
% plotmtx = cat(1,signifs,0.5+zeros(1,length(datatoplot)),ps);
siaxh = [];
% siaxh(end+1) = AxesInsetImage_In(HAx,.8,.9,.9,1,tsignifs);
% set(siaxh(end),'XTick',[],'YTick',[])
% title('TT')
% siaxh(end+1) = AxesInsetImage_In(HAx,.8,.9,.8,.9,tps);
% set(siaxh(end),'XTick',[],'YTick',[])

siaxh(end+1) = AxesInsetImage_In(HAx,.9,1,.9,1,wsignifs);
set(siaxh(end),'XTick',[],'YTick',[])
% title('Wx')
siaxh(end+1) = AxesInsetImage_In(HAx,.9,1,.8,.9,wps);
set(siaxh(end),'XTick',[],'YTick',[])


function axh = AxesInsetImage_In(h,xstart,xstop,ystart,ystop,mtxdata)
% function axh = AxesInsetImage(h,ratio,mxtdata)
% Puts an inset image (axes) into the upper right of the given axes.  
%  INPUTS
%  h = handle of reference axes
%  ratio = Size of inset relative to original plot
%  mtxdata = data to plot, 2d matrix or colormatrix that will plot with
%  imagesc
% 
%  OUTPUTS
%  axh = handle of inset axes

figpos = get(h,'Position');

newpos = [figpos(1)+xstart*figpos(3) figpos(2)+ystart*figpos(4) (xstop-xstart)*figpos(3) (ystop-ystart)*figpos(4)];
% if length(ratio) == 1;
%     newpos = [figpos(1)+(1-ratio)*figpos(3) figpos(2)+(1-ratio)*figpos(4) ratio*figpos(3) ratio*figpos(4)];
% elseif length(ratio) == 2;
%     newpos = [figpos(1)+(1-ratio(1))*figpos(3) figpos(2)+(1-ratio(1))*figpos(4) ratio(2)*figpos(3) ratio(2)*figpos(4)];
% end

axh = axes('Position',newpos);

imagesc(mtxdata,[0 1]);