function plot_meanSD_bars_xvalsinput(xvals,varargin)
% Plots a bar graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  (To
% put spaces between bars, enter an input vector with a single value of 0).

if iscell(varargin{1});%to handle cell inputs... cells with each entry being a vector
    varargin = varargin{1};
end


for a = 1:length(varargin)
    data = varargin{a};
    if ismember(1,size(data))
        data = data(:);
    end
    means(a) = mean(data,1);
    SDs(a) = std(data,0,1);
end

bar(xvals,means,'b','EdgeColor','b')
hold on
errorbar(xvals,means,zeros(size(xvals)),SDs,'Color','k','Marker','.','LineStyle','none')
