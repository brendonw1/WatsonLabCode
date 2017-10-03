function [datatoplot,labels,central,variance] = plot_inputhandling(argsin,vnames)

central = 'nanmean';
variance = 'std';
labels = {};

if length(argsin) == 1
    if iscell(argsin{1});%to handle cell inputs... cells with each entry being a vector
        datatoplot = argsin{1};
    else
        if ~ismember(1,size(argsin{1}))%if matrix
            for a = 1:size(argsin{1},2);
                datatoplot{a}=argsin{1}(:,a);
            end
        end
    end
else
    datatoplot = {};
    for a = 1:length(argsin);
        if isstr(argsin{a})
            switch lower(argsin{a})
                case 'central'%these must be at end
                    central = argsin{a+1};
                case 'variance'
                    variance = argsin{a+1};
                case 'color'
                    color = argsin{a+1};
%                     datatoplot(a+1) = [];
%                     datatoplot(a) = [];
            end
        else
            if iscell(argsin{a});%to handle cell inputs... cells with each entry being a vector
                datatoplot = argsin{a};
                labels{end+1} = vnames{a};
            else
                if ~ismember(1,size(argsin{a}))%if matrix
                    for b = 1:size(argsin{a},2);
                        datatoplot{end+1}=argsin{a}(:,b);
%                         datatoplot{b}=argsin{a}(:,b);
                        labels{end+1} = num2str(b);
                    end
                else%if a vector
                    datatoplot{end+1}=argsin{a};
                end
            end
        end
    end
end