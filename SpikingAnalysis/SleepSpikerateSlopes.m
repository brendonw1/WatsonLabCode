function Slopes = SleepSpikerateSlopes(basepath,basename)


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeSleep');
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Se');
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Si');

for a  = 1:length(WakeSleep)
    tpack = intersect(WakeSleep{a},SWSPacketInts);
    bins = FirstTime(tpack,'s'):LastTime(tpack,'s');
    bins = intervalSet(bins(1:end-1)*10000,bins(2:end)*10000);
    bins = intersect(bins,tpack);
    times = mean(StartEnd(bins,'s'),2);
    times = times - Start(subset(WakeSleep{a},2),'s');
    normtimes = times/Data(length(subset(WakeSleep{a},2),'s'));
    q = Data(MakeQfromS(Se,bins));
    for b = 1:length(Se)
        t = q(:,b);
        t = t/mean(t);
        p = polyfit(times,t,1);
%         figure;plot(times,t);hold on;plot(times,polyval(p,times));title([num2str(b) 'Rate:' num2str(mean(q(:,b)))])
        SlopesAbsE(b,a) = p(1);
        p = polyfit(normtimes,t,1);
        SlopesNormE(b,a) = p(1);
    end
    if prod(size(Si))>0;
        q = Data(MakeQfromS(Si,bins));
        for b = 1:length(Si)
            t = q(:,b);
            t = t/mean(t);
            p = polyfit(times,t,1);
            SlopesAbsI(b,a) = p(1);
            p = polyfit(normtimes,t,1);
            SlopesNormI(b,a) = p(1);
        end
    else
       SlopesAbsI = [];
       SlopesNormI = [];
    end
end

Slopes.MedianOfNormE = median(SlopesNormE,2);
Slopes.MedianOfAbsE = median(SlopesAbsE,2);
if prod(size(Si))>0;
    Slopes.MedianOfNormI = median(SlopesNormI,2);
    Slopes.MedianOfAbsI = median(SlopesAbsI,2);
else
    Slopes.MedianOfNormI = [];
    Slopes.MedianOfAbsI = [];
end    
1;

save(fullfile(basepath,[basename '_SpikeRateSlopes.mat']),'Slopes')
