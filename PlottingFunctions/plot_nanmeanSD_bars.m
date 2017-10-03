function [HAx, Hbar, Herr,siaxh,piaxh] = plot_nanmeanSD_bars(varargin)
% Plots a bar graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  (To
% put spaces between bars, enter an input vector with a single value of 0).
%
% Also plots a signficance matrix in upper right, based on wilcoxan rank 
% sum test.  This is split into two halves: top half is 1's for significant
% difference, 0 for non-different.  A middle horizontal bar of 0.5s.
% Bottom part is matrix of p values (1 is default)
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
    for a = 1:length(varargin);
        if isstr(varargin{a})
            switch varargin{a}
                case 'color'
                    color = varargin{a+1};
                    datatoplot(a+1) = [];
                    datatoplot(a) = [];
            end
        end
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
    means(a) = nanmean(data,1);
    SDs(a) = nanstd(data,0,1);
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

%% Significance testing
siaxh = SignificanceInset(HAx,datatoplot);