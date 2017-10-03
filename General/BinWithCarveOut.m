function [carvedbincounts,bigbincounts,smallbincounts]=BinWithCarveOut(s1,s2,binwidth,carveoutwidth,numbins)
% Making bins including only bins that are withing widewidth seconds, but
% not those within carveoutwidth secs.  S1 and S2 are vectors of spike
% times in seconds.
% Brendon Watson 2015

s1 = s1(:);
s2 = s2(:);

maxsecs = max([s1;s2]);
if ~exist('numbins','var')
    numbins = ceil(maxsecs/binwidth);
end

bigbincounts = zeros(numbins,1);
smallbincounts = zeros(numbins,1);
carvedbincounts = zeros(numbins,1);

% for a = 1:length(S1);
%     s1 =  Range(S1{a});
%     for b = length(S2);
%         s2 =  Range(S2{b});
        for c = 1:numbins
            tstart = binwidth*(c-1);
            tend = max(binwidth*(c));
            if c == numbins;
                tend = maxsecs;
            end
            t1 = s1(s1>=tstart & s1<tend);
            t2 = s2(s2>=tstart & s2<tend);
            if length(t1)*length(t2)>0

                basicbincounts = length(t1) * length(t2);

                [x,y] = meshgrid(t1,t2);
                diffs = abs(x-y);
                tooclosecounts = sum(sum(diffs<=carveoutwidth));

                carvedcounts = basicbincounts - tooclosecounts;

                bigbincounts(c) = basicbincounts;
                smallbincounts(c) = tooclosecounts;
                carvedbincounts(c) = carvedcounts;
            end
        end
%     end
% end