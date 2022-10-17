%The one hour bin based on index and not times

function [newdata] = binbasedonindex(data,startbinlength,finalbinlength)
    % how long is each bin?
    %startbinlength = 10; %seconds

    % how long you want each bin to be?
    %finalbinlength = 3600; %seconds

    numbins = round((length(data)*startbinlength)/finalbinlength);
    indicesperbin = finalbinlength / startbinlength;
    newdata = {};


    for k = 1:numbins
        if k == 1; newdata{k} = data(1:k*(indicesperbin));
        elseif k == numbins; newdata{k} = data((k-1)*indicesperbin:end);
        else
            newdata{k} = data( (k-1)*indicesperbin  :  k*indicesperbin  );
        end
    end

end
