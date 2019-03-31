function [AssemblyBasicData,h] = ProjectAssembliesOntoBinnedMatrix(AssemblyBasicData,BinnedMatrix,h)

v2struct(AssemblyBasicData)

%% Get activity of each assembly at each bin
% SBinned = MakeQfromS(S,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
% BinnedMatrix = Data(SBinned);

AssemblyActivities = assembly_activity(Patterns,BinnedMatrix');
for a = 1:size(AssemblyActivities,1);
    aidxs = find(assemblynum==a);
    AssemblyCells{a} = cellnum(aidxs);
    AssemblyCellActivities(:,a) = sum(BinnedMatrix(:,AssemblyCells{a}),2);
%     EC = length(intersect(AssemblyCells{a},CellIDs.EAll));
%     IC = length(intersect(AssemblyCells{a},CellIDs.IAll));
%     EIRatios(a) = EC/(EC+IC);
end


for a = 1:size(AssemblyActivities,1);
    h(end+1) = figure;
    subplot(3,1,1);
    plot(AssemblyActivities(a,:)','k')
    title(['Assembly #',num2str(a),' Activity Projection'])
    xlim([1 size(BinnedMatrix,1)])
    yl = get(gca,'ylim');
    ylim([min(AssemblyActivities(a,:)) yl(2)])

    subplot(3,1,2);
    plot(AssemblyCellActivities(:,a),'k')
    xlim([1 size(BinnedMatrix,1)])
    title(['Assembly Cells Summed Activity'])
    
    subplot(3,1,3);
    plot(sum(BinnedMatrix,2),'k')
    xlim([1 size(BinnedMatrix,1)])
    title(['All Cells'])
end
% 
% h(end+1) = figure;
% subplot(1,3,1);
% barbyei(EIRatios)
% title('E/(E+I) rates by Assembly Num')
% 
% subplot(1,3,2);
% sEIR = sort(EIRatios);
% barbyei(sEIR)
% title('Sorted.')
% 
% subplot(1,3,3);
% [counts,bins] = hist(EIRatios,10); %# get counts and bin locations
% barh(bins,counts,'k')
% title('Frequency Histogram')


AssemblyBasicData.BinnedMatrix = BinnedMatrix;
AssemblyBasicData.AssemblyCells = AssemblyCells;
AssemblyBasicData.AssemblyActivities = AssemblyActivities;
AssemblyBasicData.AssemblyCellActivities = AssemblyCellActivities;

    % SumAssemblyActivities = sum(abs(AssemblyActivities),1);

% Plot activity of each assembly
% figure 
% subplot(3,1,1) 
% imagesc(binnedEachCellData')
% xlim([1 size(AssemblyActivities,2)])
% 
% subplot(3,1,2) 
% hold on;
% plot(SumAssemblyActivities,'k')
% plot(AssemblyActivities')
% xlim([1 size(AssemblyActivities,2)])
% title('Activities of assemblies found by PCA: Erepmat(sum(ccg,1),size(ccg,1),1)ach color is 1 assembly, Black is sum of all others')
% 
% subplot(3,1,3)s
% hold on
% plot(sum(binnedEachCellData,2),'k')
% % plotIntervalsStrip(gca,intervals,1)
% % plot(binnedTrains.EAll,'g')
% % plot(binnedTrains.IAll,'r')
% plotIntervalsStrip(gca,intervals,.1)

% title({['Spikes from All cells (black), all ECells (green) and all ICells (red)'];['Bottom state indicator: Dark blue-wake, Cyan-SWS, Magenta-REM']})

function barbyei(EIR)
eEIR = find(EIR>0.5);%Ecell dominated
iEIR = find(EIR<0.5);%Icell dominated
nEIR = find(EIR==0.5);%neutral
if ~isempty(eEIR)
    barh(eEIR,EIR(eEIR),'g');
end
hold on;
if ~isempty(iEIR)
    barh(iEIR,EIR(iEIR),'r');
end
if ~isempty(nEIR)
    barh(nEIR,EIR(nEIR),'k');
end
