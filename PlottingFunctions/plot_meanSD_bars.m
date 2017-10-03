function [HAx, Hbar, Herr,siaxh,piaxh] = plot_meanSD_bars(varargin)
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

labels = {};

if nargin == 1
    if iscell(varargin{1});%to handle cell inputs... cells with each entry being a vector
        datatoplot = varargin{1};
    else
        if ~ismember(1,size(varargin{1}))%if matrix
            for a = 1:size(varargin{1},2);
                datatoplot{a}=varargin{1}(:,a);
            end
        end
    end
else
    datatoplot = {};
    for a = 1:length(varargin);
        if isstr(varargin{a})
            switch varargin{a}
                case 'color'
                    color = varargin{a+1};
                    datatoplot(a+1) = [];
                    datatoplot(a) = [];
            end
        else
            datatoplot{end+1} = varargin{a};
        end
        labels{end+1} = inputname(a);
    end
end

%defaults
color = 'b';


xvals = 1:length(datatoplot);
for a = 1:length(datatoplot)
    data = datatoplot{a};
    if ismember(1,size(data))
        data = data(:);
    end
    means(a) = mean(data,1);
    SDs(a) = std(data,0,1);
end


hold on
Hbar = bar(xvals,means,'FaceColor',color);
HAx = get(Hbar,'parent');
if sum(means>=0) == length(means)%if all positive, set error bars up
    Herr = errorbar(xvals,means,zeros(size(xvals)),SDs,'Color','k','Marker','none','LineStyle','none');
elseif sum(means<=0) == length(means)%if all negative, set error bars down
    Herr = errorbar(xvals,means,SDs,zeros(size(xvals)),'Color','k','Marker','none','LineStyle','none');
else %If pos & neg, do double error bars
    Herr = errorbar(xvals,means,SDs,SDs,'Color','k','Marker','none','LineStyle','none');
end    
set(gca,'XTick',1:length(labels),'XTickLabel',labels)

%% Significance testing
% signifs = zeros(length(datatoplot));
wps = ones(length(datatoplot));
tps = ones(length(datatoplot));

for a = 1:length(datatoplot)
    data1 = datatoplot{a};
    for b = a+1:length(datatoplot)
        data2 = datatoplot{b};
        try
            wp = ranksum(data1,data2);
            wps(a,b) = wp;
        end
        try
            [~,tp] = ttest2(data1,data2);
            tps(a,b) = tp;
        end
%         if p<0.05
%             signifs(a,b) = 1;
%         end        
    end
end
% Plot significance
% plotmtx = cat(1,signifs,0.5+zeros(1,length(datatoplot)),ps);
hold on
siaxh = AxesInsetImage(HAx,[.2 .1],tps);
set(siaxh,'XTick',[],'YTick',[])
title('TTP')
hold on
piaxh = AxesInsetImage(HAx,[.1 .1],wps);
set(piaxh,'XTick',[],'YTick',[])
title('WxP')
hold on
