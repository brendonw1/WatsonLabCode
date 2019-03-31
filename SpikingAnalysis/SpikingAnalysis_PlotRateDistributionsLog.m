function h = SpikingAnalysis_PlotRateDistributionsLog(varargin)


distros = varargin;
numbins = 25;

for a = 1:length(varargin);
    if isstr(varargin{a})
        switch varargin{a}
            case 'numbins'
                numbins = varargin{a+1};
                distros(a+1) = [];
                distros(a) = [];
        end
    end
end

numdistros = length(distros);


for a=1:numdistros;
    thisset = distros{a};
% %     columncount = (a-1)*2+1;
%     
%     subplot(2,numdistros,a)
%     hist(thisset,numbins)%Total spiking overall
% 
%     subplot(2,numdistros,(numdistros+a))
    minbin = log10(min(thisset));
    if minbin == -Inf || ~isreal(minbin)
        minbin = log10(min(thisset(thisset>0)));
    end
    
    binlocations = logspace(minbin,log10(max(thisset)),numbins);
    [y,x] =hist(thisset,binlocations);
%     semilogx(x,y)
    bar(log10(x),y);
    set(gca,'Xticklabel',10.^get(gca,'Xtick'))
    if min(x) == max(x);
        xlim([min(x)-1 min(x)+1])
    else
        xlim(log10([min(x)/1.4 max(x)*1.4]))
    end
    goodymax = max(y(2:end));
    ylim([0 goodymax*1.2])
end
