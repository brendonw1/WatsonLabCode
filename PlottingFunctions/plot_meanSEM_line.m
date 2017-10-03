function plot_meanSEM_line(varargin)
% Plots a line graph of mean with error bars of SD, based on various number
% of inputs.  Each input should be an independent vector of values and mean & SD
% are calculated independently for each one of those vectors in a row.  

% xvals = 1:size(varargin,2);
for a = 1:length(varargin)
    data = varargin{a};
    means(a,:) = mean(data,1);
    SEMs(a,:) = std(data,0,1)/length(data);
end

plot(means','marker','.')
hold on
errorbar(means',SEMs','Marker','none','LineStyle','none')
