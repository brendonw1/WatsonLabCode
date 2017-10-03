function HAx = plot_geomeanSEM_bars(varargin)
% Plots a bar graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  (To
% put spaces between bars, enter an input vector with a single value of 0).
%
% Also plots a signficance matrix in upper right, based on wilcoxan rank 
% sum test.  This is split into two halves: top half is 1's for significant
% difference, 0 for non-different.  A middle horizontal bar of 0.5s.
% Bottom part is matrix of p values (1 is default)


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

xvals = 1:length(varargin);
for a = 1:length(varargin)
    data = varargin{a};
    if ismember(1,size(data))
        data = data(:);
    end
    if sum(data<=0) ~= length(data)
        means(a) = geomean(data,1);
        SEMs(a) = geostd(data,0,1)/length(data);
    else
        means(a) = nan;
        SEMs(a) = nan;
    end
end

Hbar = bar(xvals,means,'b');
HAx = get(Hbar,'parent');
hold on
if sum(means>0) == length(means)%if all positive, set error bars up
    Herr = errorbar(xvals,means,zeros(size(xvals)),SEMs,'Color','k','Marker','none','LineStyle','none');
elseif sum(means<0) == length(means)%if all negative, set error bars down
    Herr = errorbar(xvals,means,SEMs,zeros(size(xvals)),'Color','k','Marker','none','LineStyle','none');
else %If pos & neg, do double error bars
    Herr = errorbar(xvals,means,SEMs,SEMs,'Color','k','Marker','none','LineStyle','none');
end 

%% Significance testing
siaxh = SignificanceInset(HAx,datatoplot);


