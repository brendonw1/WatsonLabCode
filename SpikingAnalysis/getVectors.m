function [rowsOut,proj,numHours,inj] = getVectors(SessionPath,plotMe)

cd(SessionPath);
a=dir('*spikes.cellinfo.mat');
load(a.name);
c=dir('goodUnitsCurated.mat');
load(c.name);
% Remove bad units from spikes.times
badUnits=[1:length(spikes.times)];
for i=length(spikes.times):-1:1
    if ismember(badUnits(i),goodUnits)
        badUnits(i)=[];
    end
end
for i=length(badUnits):-1:1
    spikes.times(badUnits(i))=[];
end

try
    b=dir('*InjectionComparisonIntervals.mat');
    load(b.name);
catch
    b=dir('*InjectionComparisionIntervals.mat');
    load(b.name);
end

numHours=floor(InjectionComparisionIntervals.BaselineP24EndRecordingSeconds/60/60);
rowsOut=zeros(numHours,length(spikes.times));

for whichHour=1:numHours
    for whichUnit=1:length(spikes.times)
        FR=length(find((whichHour)*60*60>spikes.times{whichUnit} &...
            spikes.times{whichUnit}>(whichHour-1)*60*60))/60/60;
        rowsOut(whichHour,whichUnit)=FR;
    end
end

baseline=mean(rowsOut(1:6,:));
baseMag=norm(baseline);
baseline=baseline/baseMag;

proj=zeros(numHours,1);
for whichHour=1:numHours
    eigen=rowsOut(whichHour,:)/norm(rowsOut(whichHour,:));
    proj(whichHour)=dot(baseline,eigen);
end

inj=InjectionComparisionIntervals.BaselineEndRecordingSeconds/60/60;
if plotMe
    plot([1:numHours],proj)
    xline(inj)
    xlabel('Hour')
    ylabel('Similarity to baseline FR vector')
    ylim([.5 1])
end
