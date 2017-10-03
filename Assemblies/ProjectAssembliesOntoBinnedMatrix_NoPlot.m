function [AssemblyBasicData] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyBasicData,iBinnedMatrix)

v2struct(AssemblyBasicData)

AssemblyActivities = assembly_activity(Patterns,iBinnedMatrix');
if isempty(AssemblyActivities)
    AssemblyCells = [];
    AssemblyCellActivities = [];
else
    for a = 1:size(AssemblyActivities,1);
        aidxs = find(assemblynum==a);
        AssemblyCells{a} = cellnum(aidxs);
        AssemblyCellActivities(:,a) = sum(iBinnedMatrix(:,AssemblyCells{a}),2);
    end
end

AssemblyBasicData.BinnedMatrix = iBinnedMatrix;
AssemblyBasicData.AssemblyCells = AssemblyCells;
AssemblyBasicData.AssemblyActivities = AssemblyActivities;
AssemblyBasicData.AssemblyCellActivities = AssemblyCellActivities;