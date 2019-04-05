function Slopes = SleepSpikerateSlopesByPacket(basepath,basename)


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeSleep');
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Se');
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Si');

for a  = 1:length(WakeSleep)
    Re = [];
    Ri = [];
    
    tpack = intersect(SWSPacketInts,WakeSleep{a});%get the packets for each WakeSleep
    packtimes = StartEnd(tpack,'s');
    packtimes = mean(packtimes,2);
    packtimes = packtimes - Start(subset(WakeSleep{a},2),'s');
    normtimes = packtimes/Data(length(subset(WakeSleep{a},2),'s'));
    for b = 1:length(length(tpack))%grab per cell rates for each packet
        Re(:,b,a) = Rate(Se,subset(tpack,b));
        Ri(:,b,a) = Rate(Si,subset(tpack,b));
    end
    for c = 1:length(Se);%for each cell take the slope over packets
       t = Re(c,:,a)';
       p = polyfit(packtimes,t,1);
       pabsE(c,1,a) = p(1)/mean(t);
       p = polyfit(normtimes,t,1);
       pnormE(c,1,a) = p(1)/mean(t);
    end
    if prod(size(Si))>0;
        for c = 1:length(Si);%for each cell take the slope over packets
           t = Ri(c,:,a)';
           p = polyfit(packtimes,t,1);
           pabsI(c,1,a) = p(1)/mean(t);
           p = polyfit(normtimes,t,1);
           pnormI(c,1,a) = p(1)/mean(t);
        end
    else
       pabsI = [];
       pnormI = [];
    end
end

Slopes.MedianOfNormE = (median(pnormE(:,1,:),3));
Slopes.MedianOfAbsE = (median(pabsE(:,1,:),3));
if prod(size(Si))>0;
    Slopes.MedianOfNormI = (median(pnormI(:,1,:),3));
    Slopes.MedianOfAbsI = (median(pabsI(:,1,:),3));
else
    Slopes.MedianOfNormI = [];
    Slopes.MedianOfAbsI = [];
end    
1;

save(fullfile(basepath,[basename '_SpikeRateSlopesByPacket.mat']),'Slopes')
