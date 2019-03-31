function [ISIH,Times]= ISIHistogram(S,halfwidth,binwidth)
% halfwidth and binwidth in seconds

ISIH = [];
binminimums = -binwidth/2 : binwidth : halfwidth+binwidth/2;%bin timing same as CCGs this way
for a = 1:size(S,1)%for each cell
   s = Range(S{a},'s');
   if length(s)>1
       isis = diff(s);
       isih = histc(isis,binminimums);
       isih = isih(1:end-1);
       isih = isih(:)';
   else
       isih = zeros(1,size(binminimums,2)-1);
   end
   ISIH = cat(1,ISIH,isih);
end

Times = [binminimums(1:end-1)+binminimums(2:end)]/2;