function [HAx, Hbar, Herr,siaxh,centers,variances] = plot_stats_bars(varargin)
% Plots a bar graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  (To
% put spaces between bars, enter an input vector with a single value of 0).
% 
% INPUTS
% Data to Plot: series of vectors entered in series to the function, each
%                 of which will be plotted as its own bar+SD.  Example:
%                 plot_meanSD_bars(dataseries1,dataseries2, dataseries3) will give 3 bars,
%                 one for each dataseries
% Data to Plot (ALTERNATIVE): if the first input is a cell array, each
%                  element of the cell array will be treated as a separate vector to plot a
%                  bar for
% OPTIONAL INPUTS
% 'color', [colorspecification]: The string 'color' should be entered followed by a
%                     string or an RGB triplet that indicates the color of the bars.  Will be
%                     parsed as a pair of inputs
%
% OUTPUTS: Graphical, and
% Hbar: axis handle for bar graph output
% Herr: axis handle for error bars
% siaxh: axis handle for t-test significance inset
% piaxh: axis handle for rank-sum significance inset

central = 'nanmean';
variance = 'std';

for a = 1:nargin;
    vnames{a} = inputname(a);
end
[datatoplot,labels,central,variance] = plot_inputhandling(varargin,vnames);

color = 'b';


xvals = 1:length(datatoplot);
for a = 1:length(datatoplot)
    data = datatoplot{a};
    if ismember(1,size(data))
        data = data(:);
        data(data==Inf) = max(data(data<Inf));
        data(data==-Inf) = min(data(data>-Inf));
    end
    switch lower(central)
        case {'mean','nanmean'}
            t = nanmean(data,1);
        case {'median','nanmedian'}
            t = nanmedian(data,1);
        case 'geomean'
            t = geomean(data,1);
    end
    if isempty(t)
        t = NaN;
    end
    centers(a) = t;
    
    switch lower(variance)
        case {'sd','std'}
            t = nanstd(data,1);
        case {'logsd','logstd'}
            d = log10(data);
            d(d==-inf) = min(d>-inf);
            t = 10.^nanstd(d,1);
        case 'sem'
            t = nanstd(data,1);
            t = t/sum(~isnan(data));
        case {'geosd','geostd'}
            t = geostd(data,1);
        case 'geosem'
            t = geostd(data,1);
            t = t/size(data,1);
    end
    variances(a) = t;
end


hold on
Hbar = bar(xvals,centers,'FaceColor',color);
HAx = get(Hbar,'parent');
if sum(centers>=0) == length(centers)%if all positive, set error bars up
    Herr = errorbar(xvals,centers,zeros(size(xvals)),variances,'Color','k','Marker','none','LineStyle','none');
elseif sum(centers<=0) == length(centers)%if all negative, set error bars down
    Herr = errorbar(xvals,centers,variances,zeros(size(xvals)),'Color','k','Marker','none','LineStyle','none');
else %If pos & neg, do double error bars
    Herr = errorbar(xvals,centers,variances,variances,'Color','k','Marker','none','LineStyle','none');
end    
set(gca,'XTick',1:length(labels),'XTickLabel',labels)
title([central ' +- ' variance])

%% Significance testing
siaxh = SignificanceInset(HAx,datatoplot);

% axes(HAx)

% % signifs = zeros(length(datatoplot));
% wps = ones(length(datatoplot));
% tps = ones(length(datatoplot));
% 
% for a = 1:length(datatoplot)
%     data1 = datatoplot{a};
%     for b = a+1:length(datatoplot)
%         data2 = datatoplot{b};
%         try
%             wp = ranksum(data1,data2);
%             wps(a,b) = wp;
%         end
%         try
%             [~,tp] = ttest2(data1,data2);
%             tps(a,b) = tp;
%         end
% %         if p<0.05
% %             signifs(a,b) = 1;
% %         end        
%     end
% end
% % Plot significance
% % plotmtx = cat(1,signifs,0.5+zeros(1,length(datatoplot)),ps);
% hold on
% siaxh = AxesInsetImage(HAx,[.2 .1],tps);
% set(siaxh,'XTick',[],'YTick',[])
% title('TTP')
% hold on
% piaxh = AxesInsetImage(HAx,[.1 .1],wps);
% set(piaxh,'XTick',[],'YTick',[])
% title('WxP')
% hold on
