function plot_meanSEM(varargin)
% Plots points signifying mean with error bars of SEM, based on various number
% of inputs.  Each input should be an independent vector of values and mean
% & SEM are calculated independently for each one of those vectors in a row.  (To
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
    means(a) = mean(data,1);
    SEMs(a) = std(data,0,1)/length(data);
end

h = plot(xvals,means,'k')
HAx = get(h,'parent');
hold on
errorbar(xvals,means,SEMs,SEMs,'Color','k','Marker','none','LineStyle','none')


%% Significance testing
siaxh = SignificanceInset(HAx,datatoplot);