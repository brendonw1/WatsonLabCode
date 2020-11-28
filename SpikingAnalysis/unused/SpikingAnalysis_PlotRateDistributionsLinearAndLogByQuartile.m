function h = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(varargin)

numdistros = nargin;
numbins = 28;

h = figure;
for a=1:numdistros;
    thisset = varargin{a};
%     columncount = (a-1)*2+1;
%     [QuadColors] = GetQuadColors;
%     logquartileidxs = logQuartiles(thisset);

    subplot(2,numdistros,a)
    hist(thisset,numbins)%Total spiking overall

    subplot(2,numdistros,(numdistros+a))
    minbin = log(min(thisset));
    if minbin == -Inf
        minbin = 0;
    end
    
%     linearquartileidxs = linearQuartiles(thisset);
    [edges,counts,histidxs,patches] = semilogxhist_byQuartile(thisset,numbins);
    
%     edges=log(linspace(exp(minbin),max(thisset),numbins));
%     h=histc(x,edges);
%     bar(edges, h);
    
%     binlocations = logspace(minbin,log(max(thisset)),numbins);
%     [y,x] =hist(thisset,binlocations);
%     semilogx(x,y)
%     xlim([min(x) max(x)])
end
