function HAx = plot_nanmediangeoSD_bars(varargin)
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

xvals = 1:length(datatoplot);
for a = 1:length(datatoplot)
    data = datatoplot{a};
    if ismember(1,size(data))
        data = data(:);
    end
    te = nanmedian(data,1);
    if isempty(te)
        te = NaN;
    end
    medians(a) = te;
    
    te = geostd(data,0,1);
    if isempty(te)
        te = NaN;
    end
    SDs(a) = te;
end

Hbar = bar(xvals,medians,'b');
HAx = get(Hbar,'parent');
hold on
if sum(medians>0) == length(medians)%if all positive, set error bars up
    Herr = errorbar(xvals,medians,zeros(size(xvals)),SDs,'Color','k','Marker','none','LineStyle','none');
elseif sum(medians<0) == length(medians)%if all negative, set error bars down
    Herr = errorbar(xvals,medians,SDs,zeros(size(xvals)),'Color','k','Marker','none','LineStyle','none');
else %If pos & neg, do double error bars
    Herr = errorbar(xvals,medians,SDs,SDs,'Color','k','Marker','none','LineStyle','none');
end 

%% Significance testing
siaxh = SignificanceInset(HAx,datatoplot);