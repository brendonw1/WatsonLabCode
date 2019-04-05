function out = mergemissing(originalvect,missing)
% merge numbers from "missing" into their spots in original vect, with
% missing coming first and pushing the equivalent value of orignal back...
% ie if originalvect = 1 2 3 and missing = 2 then out will be 1 1 2 1 since
% in the new siquence of 1 2 3 4, the third value comes from missing and
% all others were form the originalvect.  

out = [];
% origok = 1;
% missingok = 1;
% while origok || missingok

while length(originalvect)>0 || length(missing>0);
    if length(missing)==0
        a = inf;
    else
        a = missing(1);
    end
    if length(originalvect)==0
        b = inf;
    else
        b = originalvect(1);
    end
    
    [~,val] = min([a b]);
    out(end+1) = val;
    if val == 1
        missing(1) = [];
        originalvect = originalvect+1;
    elseif val == 2
        originalvect(1) = [];
    end
end
out = 3-out;
% 
% while a < length(originalvect)+length(missing)
% 
% 
% 
%     if ismember(originalvect(a),missing);
%        out(end+1) = 2;
%        out(end+1) = 1;
%        originalvect = originalvect+1;
%    else
%        out(a) = 1;
%    end
% end