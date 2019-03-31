function [Hbar, Herr] = plot_geomeanoflogofratiosSD_bars(varargin)
% Plots a bar graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  (To
% put spaces between bars, enter an input vector with a single value of 0).
% 
% It is assumed that inputs are logs of ratios and so mean is taken in the
% log domain, then the mean is converted to linear space for geometric
% averaging & SD.
% 
% INPUTS
% Data to Plot: series of vectors entered in series to the function, each
%                 of which will be plotted as it's own bar+SD.  Example:
%                 plot_meanSD_bars(dataseries1,dataseries2, dataseries3) will give 3 bars,
%                 one for each dataseries
% Data to Plot (ALTERNATIVE): if the first input is a cell array, each
%                  element of the cell array will be treated as a separate vector to plot a
%                  bar for
% OPTIONAL INPUTS
% 'Color', [colorspecification]: The string 'color' should be entered followed by a
%                     string or an RGB triplet that indicates the color of the bars.  Will be
%                     parsed as a pair of inputs
%
% OUTPUTS: Graphical, and
% Hbar: axis handle for bar graph output
% Herr: axis handle for error bars

if iscell(varargin{1})
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
    data = 10.^data;%accounts for input as log10 values
    means(a) = geomean(data,1);
    if std(data) == 0
        SEMs(a) = 0;%otherwise geometric mean gives SD=1 for distributions with no variance... for now don't want that
    else
        SEMs(a) = geostd(data,[],1);
    end
    SEMs(a) = SEMs(a)/length(data);
end

% means = log10(means);
% SDs = log10(SDs);

hold on
Hbar = bar(xvals,means,color);
Herr = errorbar(xvals,means,zeros(size(xvals)),SEMs,'Color','k','Marker','none','LineStyle','none');

% ylim([min(means-SDs)*1.2 max(means+SDs)*1.2])

siaxh = SignificanceInset(HAx,datatoplot);
