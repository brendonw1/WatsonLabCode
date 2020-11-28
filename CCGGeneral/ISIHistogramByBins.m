function ISIH = ISIHistogramByBins(S,binbounds)
% halfwidth and binwidth in seconds

ISIH = [];
for a = 1:size(S,1)%for each cell
   s = Range(S{a},'s');
   if length(s)>1
       isis = diff(s);
       isih = histc(isis,binbounds);
       isih = isih(:)';
   else
       isih = zeros(1,size(binbounds,2));
   end
   ISIH = cat(1,ISIH,isih);
end