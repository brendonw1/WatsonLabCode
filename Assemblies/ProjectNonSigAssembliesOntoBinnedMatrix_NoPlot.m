function [AssemblyBasicData] = ProjectNonSigAssembliesOntoBinnedMatrix_NoPlot(AssemblyBasicData,BinnedMatrix)

v2struct(AssemblyBasicData)

NSAssemblyActivities = assembly_activity(NonSignifPatterns,BinnedMatrix');

AssemblyBasicData.BinnedMatrix = BinnedMatrix;
AssemblyBasicData.NSAssemblyActivities = NSAssemblyActivities;
