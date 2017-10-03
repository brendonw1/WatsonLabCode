function [AssemblyBasicData,h] = GetAndPlotIntervalRestrictedAssembliesEOnly(S,restrictints,binsecs,intervals)
% specify interval of times to determine components from

binpoints = binsecs*10000;
numtotalcells = size(S,1);

if ~isempty(restrictints)
    iS = CompressSpikeTrainsToIntervals(S,restrictints);%compress to wake spiking only 
else
    iS = S;
end
iSBinned = MakeQfromS(iS,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
iBinnedMatrix = Data(iSBinned);
    
% Find assembly patterns
opts.threshold.method = 'MarcenkoPastur';
opts.Patterns.method = 'PCA';
opts.Patterns.number_of_iterations = 1000;
[Patterns,Threshold] = assembly_patterns_bw(iBinnedMatrix',opts);

% Find and label neurons with significant contributions on to assemblies
[cellnum,assemblynum]=find(abs(Patterns)>Threshold);%find cell,assembly ID's of contributions with abs>Threshold
% shigecellnum = cellinds(cellnum,2);%convert back to shige's number system

% empties = setdiff(1:size(Patterns,2),unique(assemblynum));% for some reason sometimes some "patterns" or assemblies actually have no cells above threshold
% Patterns(:,empties) = [];%if find such assemblies, delete them

% Plot Assembly PatternsPrep for all but final analysis BWRat19... anticipate  

maxproj = max(Patterns(:));%get the max projection of any initial variable onto any PC
minproj = min(Patterns(:));%get the min
numassemblies = size(Patterns,2);

[vert,horiz]=determinenumsubplots(numassemblies);

%Stem plots of assemblies
h = figure;
for a = 1:numassemblies
    subplot(vert,horiz,a);
    hold on
    signifassemblycellinds = cellnum(find(assemblynum==a));
    othercellinds = setdiff((1:numtotalcells),signifassemblycellinds);
    stem(othercellinds,Patterns(othercellinds,a),'color','k');
    if ~isempty(signifassemblycellinds)
        stem(signifassemblycellinds,Patterns(signifassemblycellinds,a),'color','c');
    end
    plot([1 numtotalcells],[Threshold Threshold],'color',[.5 .5 .5])
    plot([1 numtotalcells],[-Threshold -Threshold],'color',[.5 .5 .5])
    xlim([1 numtotalcells])
    ylim([minproj maxproj])
    title(['Assembly ',num2str(a)])
    for b = 1:length(signifassemblycellinds)
        x = signifassemblycellinds(b);
        y = Patterns(signifassemblycellinds(b),a);
        textstr = num2str(signifassemblycellinds(b));
        text(x+1,y,textstr)
    end
    set(h(end),'name','AssemblyCells')
end
% >> highlight connected cells in green or red


%% Get activity of each assembly at each bin
SBinned = MakeQfromS(S,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
BinnedMatrix = Data(SBinned);

AssemblyActivities = assembly_activity(Patterns,BinnedMatrix');
for a = 1:size(AssemblyActivities,1);
    aidxs = find(assemblynum==a);
    AssemblyCells{a} = cellnum(aidxs);
    AssemblyCellActivities(:,a) = sum(BinnedMatrix(:,AssemblyCells{a}),2);
end

for a = 1:size(AssemblyActivities,1);
    h(end+1) = figure;
    set(h(end),'name',['Assembly' num2str(a)])
    subplot(3,1,1);
    plot(AssemblyActivities(a,:)','k')
    title(['Assembly #',num2str(a),' Activity Projection'])
    xlim([1 size(BinnedMatrix,1)])
    yl = get(gca,'ylim');
    ylim([min(AssemblyActivities(a,:)) yl(2)])
    plotIntervalsStrip(gca,intervals,1/binpoints)

    subplot(3,1,2);
    plot(AssemblyCellActivities(:,a),'k')
    xlim([1 size(BinnedMatrix,1)])
    title(['Assembly Cells Summed Activity'])
    
    subplot(3,1,3);
    plot(sum(BinnedMatrix,2),'k')
    xlim([1 size(BinnedMatrix,1)])
    title(['All Cells'])
end


AssemblyBasicData = v2struct(BinnedMatrix,...
    opts,Patterns,Threshold,cellnum,assemblynum,AssemblyCells,...
    AssemblyActivities,AssemblyCellActivities);


    % SumAssemblyActivities = sum(abs(AssemblyActivities),1);
