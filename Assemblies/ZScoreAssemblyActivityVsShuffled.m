function [AssemblyZs,meanSurrAssActs] = ZScoreAssemblyActivityVsShuffled(AssemblyBasicData,RateMatrix,AssemblyActivities,nsurrogates)

if isempty(AssemblyBasicData.Patterns)
    AssemblyZs = [];
    meanSurrAssActs = [];
else

    Surr_Binned = BinShufflingAlone(RateMatrix,nsurrogates);%Make a surrogate set of spike bins/rate matrices

    Surr_AssemblyActivities = zeros(size(AssemblyActivities,1),size(Surr_Binned,1),nsurrogates);%

    for a = 1:nsurrogates;
        [asd] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyBasicData,Surr_Binned(:,:,a));
        Surr_AssemblyActivities(:,:,a) = asd.AssemblyActivities;
    %     if rem(a,10) == 0
    %         disp(a)
    %     end
    end


    meanSurrAssActs = squeeze(mean(Surr_AssemblyActivities,2));
    if size(meanSurrAssActs,2) == 1;
        meanSurrAssActs = meanSurrAssActs';
    end
    for a = 1:size(meanSurrAssActs,1);%for each assembly
        AssemblyZs(a) = (AssemblyActivities(a)- mean(meanSurrAssActs(a,:,:)))/std(meanSurrAssActs(a,:,:));
    end
end