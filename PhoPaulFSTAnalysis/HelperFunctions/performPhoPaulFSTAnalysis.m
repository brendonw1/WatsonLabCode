function [HighlyMobile, Mobile, Immobile, finalOutputTable, activeHighlyMobile, activeMobile, activeImmobile] = performPhoPaulFSTAnalysis(activeFileName, activeExperimentSheetName, sanatizedOutputFileName)
%PERFORMPHOPAULFSTANALYSIS Summary of this function goes here
%   Detailed explanation goes here
%% Pho Hale
%% 7-26-2019
% "Blocks" refer to the set of 8 rows in excel containing a single "FS{n}" experiment.
addpath('HelperFunctions');
addpath('Data');


% Program Options (Configuration)
stdDevWeightingOption = 0; % Normalize stddev by N-1, where N is the number of observations. If there is only one observation, then the weight is 1.
% stdDevWeightingOption = 1; % Normalize stddev by N.

isPhoExcludeAnimalForAnyOutlierAnalysis = false;
shouldRemoveOutliers = false;
% shouldRemoveOutliers = false;


shouldPerformRandomizationShuffles = true;
%shouldPerformRandomizationShuffles = false;
shouldPerformIndividualAnimalAnalysis = false;

% Import the data
[HighlyMobile, Mobile, Immobile] = importPhoPaulFSTAnalysisFiles(activeFileName, activeExperimentSheetName);

sanatizedOutputExptName = activeExperimentSheetName(~isspace(activeExperimentSheetName));
printf("Performing analysis for %s : %s...", activeFileName, activeExperimentSheetName);

Immobile.table = struct2table(Immobile);
Mobile.table = struct2table(Mobile);
HighlyMobile.table = struct2table(HighlyMobile);

numberOfDrugGroups = 4; % {veh, dpz 0.02, dpz 0.2, dpz 2.0}
blockSize = 8; % Number of animals in a block
numberOfAnimals = blockSize * numberOfDrugGroups; % The number of animals in a drug group, times the number of drug groups
numberOfBlocks = size(HighlyMobile.table,1) / blockSize; % Number of blocks
numberOfSwims = numberOfBlocks; % The number of swims (FST1, FST2, ...) per animal
% numberOfBlocks = 1; % Number of blocks

%% numAnimalsRemoved keeps track of how many outliers have been removed
activeImmobile.numAnimalsRemoved = zeros(numberOfBlocks, 4);
activeMobile.numAnimalsRemoved = zeros(numberOfBlocks, 4);
activeHighlyMobile.numAnimalsRemoved = zeros(numberOfBlocks, 4);


if (shouldPerformRandomizationShuffles)
   numberOfShuffles = 100000;
else
   numberOfShuffles = 0; 
end

%% The .mean field keeps track of the column means for each shuffle
activeImmobile.mean = zeros(numberOfShuffles, 4);
activeMobile.mean = zeros(numberOfShuffles, 4);
activeHighlyMobile.mean = zeros(numberOfShuffles, 4);

%% outputMetric keeps track of the difference of means, of whatever the final p-value metric is supposed to be
activeImmobile.outputMetric = zeros(numberOfShuffles, 1);
activeMobile.outputMetric = zeros(numberOfShuffles, 1);
activeHighlyMobile.outputMetric = zeros(numberOfShuffles, 1);

%% Individual Animal Analysis
if (shouldPerformIndividualAnimalAnalysis)
    %numberOfSwimsPerAnimal = 
    % Each animal has numberOfBlocks
    numberOfConsideredIndividualSwims = min(numberOfSwims, maxBlockIndexForIndividualConsideration); % Consider only the number of swims <= maxBlockIndexForIndivudalConsideration
    %individualAnimalData.immobile = zeros(numberOfConsideredIndividualSwims, numberOfAnimals); 

end
% The drug group the animal is assigned to in a given experiment. Alternates
%individualAnimalData.individualAssignedDrugGroup = zeros(numberOfConsideredIndividualSwims, numberOfAnimals);
standardDrugGroupIndex = [1,2,3,4];
switchedDrugGroupIndex = [2,1,4,3];

numberOfDrugGroups = length(standardDrugGroupIndex);

drugName = 'dpz';

drugDoseGroupDose = [0.0, 0.02, 0.2, 2.0]; % Drug doses in mg/kg
drugDoseGroupDoseStringLabel = {'0.0', '0.02', '0.2', '2.0'}; % Drug doses in mg/kg
drugDoseGroupColors = {'blue', 'yellow', 'orange', 'red'};
drugDoseGroupColorMatrix = [[0 0 1]; [0.9290, 0.6940, 0.1250]; [0.8500, 0.3250, 0.0980]; [1, 0, 0]];


valueIndexes = reshape(1:numberOfAnimals,[],numberOfDrugGroups);
switchedValueIndexes = [valueIndexes(:,2), valueIndexes(:,1), valueIndexes(:,4), valueIndexes(:,3)];
for currIndividualAnimalIndex = 1:numberOfAnimals
    individualAnimalData(currIndividualAnimalIndex).individualAssignedDrugGroupIndex = [];
    
    individualAnimalData(currIndividualAnimalIndex).dose = [];
    %% Get value for appropriate index, assign to individual animals value.
    individualAnimalData(currIndividualAnimalIndex).immobile = [];
end

% figure(1);

% Analyze each block
for blockIndex = 1:numberOfBlocks
   blockStartIndex = (blockSize * (blockIndex-1)) + 1;
   blockEndIndex = blockSize * blockIndex;
   activeImmobile.values = Immobile.table{blockStartIndex:blockEndIndex,:};
   activeMobile.values = Mobile.table{blockStartIndex:blockEndIndex,:};
   activeHighlyMobile.values = HighlyMobile.table{blockStartIndex:blockEndIndex,:};
   
   %% Get individual experimental values:
   if (shouldPerformIndividualAnimalAnalysis)
       if (blockIndex <= maxBlockIndexForIndividualConsideration) %only consider up to FST6 due to an issue Paul described with the experiments

           if (isSwitchedTrial(blockIndex))
               currDrugGroupIndexSet = switchedDrugGroupIndex;
               currValueIndicies = switchedValueIndexes;
           else
               currDrugGroupIndexSet = standardDrugGroupIndex;
               currValueIndicies = valueIndexes;
           end


                      %%TODO: Get the appropriate index from the animal and currDrugGroupIndexSet.
                for currBlockRowIndex = 1:blockSize
                    for currDrugGroupIndex = 1:numberOfDrugGroups
                        % an individual always has the same block index, only the drug group index varies
                        individualAnimalIndex = currValueIndicies(currBlockRowIndex, currDrugGroupIndex);
                        % Each array for each animal grows in size at each block
                        individualAnimalData(individualAnimalIndex).individualAssignedDrugGroupIndex = [individualAnimalData(individualAnimalIndex).individualAssignedDrugGroupIndex, currDrugGroupIndex]; % Set the block drug group for each individual animal. May need to loop.

                        currDrugDose = drugDoseGroupDose(currDrugGroupIndex);
                        individualAnimalData(individualAnimalIndex).dose = [individualAnimalData(individualAnimalIndex).dose, currDrugDose]; % The animals dose for this swim

                        %% Get value for appropriate index, assign to individual animals value.
                        individualAnimalData(individualAnimalIndex).immobile = [individualAnimalData(individualAnimalIndex).immobile, activeImmobile.values(currBlockRowIndex, currDrugGroupIndex)];
                        %% For each FST, the animal should have an individualAssignedDrugGroup and value for immobile, etc, etc.
                    end
                end
       end
   end
   
   %% Compute the experimental means
   activeImmobile.experimentalMeans = mean(activeImmobile.values,1);
   activeMobile.experimentalMeans = mean(activeMobile.values,1);
   activeHighlyMobile.experimentalMeans = mean(activeHighlyMobile.values,1);
   
   % Save
%    Immobile.experimentalMeans = activeImmobile.experimentalMeans;
%    Mobile.experimentalMeans = activeMobile.experimentalMeans;
%    HighlyMobile.experimentalMeans = activeHighlyMobile.experimentalMeans;

%    Immobile.experimentalResults(blockIndex).experimentalMeans = activeImmobile.experimentalMeans;
%    Mobile.experimentalResults(blockIndex).experimentalMeans = activeMobile.experimentalMeans;
%    HighlyMobile.experimentalResults(blockIndex).experimentalMeans = activeHighlyMobile.experimentalMeans;

   %% Compute the experimental standard deviations
   activeImmobile.experimentalStdDevs = std(activeImmobile.values, stdDevWeightingOption,1);
   activeMobile.experimentalStdDevs = std(activeMobile.values, stdDevWeightingOption,1);
   activeHighlyMobile.experimentalStdDevs = std(activeHighlyMobile.values, stdDevWeightingOption,1);
   
%    Immobile.experimentalResults(blockIndex).experimentalStdDevs = activeImmobile.experimentalStdDevs;
%    Mobile.experimentalResults(blockIndex).experimentalStdDevs = activeMobile.experimentalStdDevs;
%    HighlyMobile.experimentalResults(blockIndex).experimentalStdDevs = activeHighlyMobile.experimentalStdDevs;
%    
   %% Exclude values that are outliers:
   % This is done by finding any value within a treatment group on a given experiment that is at least 2 standard deviations away from the mean of that treatment group in that experiment.
   activeImmobile.experimentalOutlierCriteria.UpperBounds = activeImmobile.experimentalMeans + (activeImmobile.experimentalStdDevs * 2.0);
   activeImmobile.experimentalOutlierCriteria.LowerBounds = activeImmobile.experimentalMeans - (activeImmobile.experimentalStdDevs * 2.0);
   activeImmobile.experimentalIsOutlier = ((activeImmobile.values > activeImmobile.experimentalOutlierCriteria.UpperBounds) | (activeImmobile.values < activeImmobile.experimentalOutlierCriteria.LowerBounds));
   
   activeMobile.experimentalOutlierCriteria.UpperBounds = activeMobile.experimentalMeans + (activeMobile.experimentalStdDevs * 2.0);
   activeMobile.experimentalOutlierCriteria.LowerBounds = activeMobile.experimentalMeans - (activeMobile.experimentalStdDevs * 2.0);
   activeMobile.experimentalIsOutlier = ((activeMobile.values > activeMobile.experimentalOutlierCriteria.UpperBounds) | (activeMobile.values < activeMobile.experimentalOutlierCriteria.LowerBounds));
   
   activeHighlyMobile.experimentalOutlierCriteria.UpperBounds = activeHighlyMobile.experimentalMeans + (activeHighlyMobile.experimentalStdDevs * 2.0);
   activeHighlyMobile.experimentalOutlierCriteria.LowerBounds = activeHighlyMobile.experimentalMeans - (activeHighlyMobile.experimentalStdDevs * 2.0);
   activeHighlyMobile.experimentalIsOutlier = ((activeHighlyMobile.values > activeHighlyMobile.experimentalOutlierCriteria.UpperBounds) | (activeHighlyMobile.values < activeHighlyMobile.experimentalOutlierCriteria.LowerBounds));
   
%    Immobile.experimentalResults(blockIndex).experimentalOutlierCriteria = activeImmobile.experimentalOutlierCriteria;
%    Mobile.experimentalResults(blockIndex).experimentalOutlierCriteria = activeMobile.experimentalOutlierCriteria;
%    HighlyMobile.experimentalResults(blockIndex).experimentalOutlierCriteria = activeHighlyMobile.experimentalOutlierCriteria;
%    
%    Immobile.experimentalResults(blockIndex).experimentalIsOutlier = activeImmobile.experimentalIsOutlier;
%    Mobile.experimentalResults(blockIndex).experimentalIsOutlier = activeMobile.experimentalIsOutlier;
%    HighlyMobile.experimentalResults(blockIndex).experimentalIsOutlier = activeHighlyMobile.experimentalIsOutlier;
%    
   % Sum over the rows to see if an animal is an outlier in any of the treatments (Pho style)
   %TODO: This isn't right: I should exclude that same animal across behaviors, not treatments.
   if (shouldRemoveOutliers)
       % Remove the outliers if needed
       if (isPhoExcludeAnimalForAnyOutlierAnalysis)
           % Pho Style Exclusion: removes the whole animal for all behaviors
           %    activeImmobile.experimentalAnimalIsOutlier = (sum(activeImmobile.experimentalIsOutlier,2) > 0);
           activeAnyIsOutlier = ((activeImmobile.experimentalIsOutlier + activeMobile.experimentalIsOutlier + activeHighlyMobile.experimentalIsOutlier) > 0);
           numRemoved = sum(activeAnyIsOutlier,'all');
           activeImmobile.values(activeAnyIsOutlier) = NaN;
           activeMobile.values(activeAnyIsOutlier) = NaN;
           activeHighlyMobile.values(activeAnyIsOutlier) = NaN;

           activeImmobile.numAnimalsRemoved(blockIndex,:) = sum(activeAnyIsOutlier,1);
           activeMobile.numAnimalsRemoved(blockIndex,:) = sum(activeAnyIsOutlier,1);
           activeHighlyMobile.numAnimalsRemoved(blockIndex,:) = sum(activeAnyIsOutlier,1);

       else
           % Paul Style Exclusion: removes the animal from consideration for the behavior in which it is an outlier in
           activeImmobile.values(activeImmobile.experimentalIsOutlier) = NaN; 
           activeMobile.values(activeMobile.experimentalIsOutlier) = NaN; 
           activeHighlyMobile.values(activeHighlyMobile.experimentalIsOutlier) = NaN;

           activeImmobile.numAnimalsRemoved(blockIndex,:) = sum(activeImmobile.experimentalIsOutlier,1);
           activeMobile.numAnimalsRemoved(blockIndex,:) = sum(activeMobile.experimentalIsOutlier,1);
           activeHighlyMobile.numAnimalsRemoved(blockIndex,:) = sum(activeHighlyMobile.experimentalIsOutlier,1);
       end
   else
       % Leave all outliers intact
       numRemoved = 0;
       activeImmobile.numAnimalsRemoved(blockIndex,:) = 0;
       activeMobile.numAnimalsRemoved(blockIndex,:) = 0;
       activeHighlyMobile.numAnimalsRemoved(blockIndex,:) = 0;
   end
   
%    Immobile.experimentalResults(blockIndex).numAnimalsRemoved = activeImmobile.numAnimalsRemoved;
%    Mobile.experimentalResults(blockIndex).numAnimalsRemoved = activeMobile.numAnimalsRemoved;
%    HighlyMobile.experimentalResults(blockIndex).numAnimalsRemoved = activeHighlyMobile.numAnimalsRemoved;
%    
   
   % Exclude the animals based on this criteria:
%    activeImmobile.values(activeImmobile.experimentalAnimalIsOutlier,:) = []; 
   
   %% Recompute the means and std deviations with outliers excluded (by ignoring NaN values):
   activeImmobile.experimentalMeans = nanmean(activeImmobile.values,1);
   activeMobile.experimentalMeans = nanmean(activeMobile.values,1);
   activeHighlyMobile.experimentalMeans = nanmean(activeHighlyMobile.values,1);
   activeImmobile.experimentalStdDevs = nanstd(activeImmobile.values, stdDevWeightingOption,1);
   activeMobile.experimentalStdDevs = nanstd(activeMobile.values, stdDevWeightingOption,1);
   activeHighlyMobile.experimentalStdDevs = nanstd(activeHighlyMobile.values, stdDevWeightingOption,1);
  
%    Immobile.experimentalResults(blockIndex).outlierExcludedExperimentalMeans = activeImmobile.experimentalMeans;
%    Mobile.experimentalResults(blockIndex).outlierExcludedExperimentalMeans = activeMobile.experimentalMeans;
%    HighlyMobile.experimentalResults(blockIndex).outlierExcludedExperimentalMeans = activeHighlyMobile.experimentalMeans;
%    Immobile.experimentalResults(blockIndex).outlierExcludedExperimentalStdDevs = activeImmobile.experimentalStdDevs;
%    Mobile.experimentalResults(blockIndex).outlierExcludedExperimentalStdDevs = activeMobile.experimentalStdDevs;
%    HighlyMobile.experimentalResults(blockIndex).outlierExcludedExperimentalStdDevs = activeHighlyMobile.experimentalStdDevs;
%    
%    
   
   %% Concatenate them all into a single column vector:
   activeImmobile.flatValues = reshape(activeImmobile.values,[],1);
   activeMobile.flatValues = reshape(activeMobile.values,[],1);
   activeHighlyMobile.flatValues = reshape(activeHighlyMobile.values,[],1);
   
   %% Compute the experimental output metric
   % Compute the mean of the outer columns, minus the mean of the inner columns
   tempMeanOuterColumns = mean([activeImmobile.experimentalMeans(1)'; activeImmobile.experimentalMeans(4)']);
   tempMeanInnerColumns = mean([activeImmobile.experimentalMeans(2)'; activeImmobile.experimentalMeans(3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeImmobile.experimentalMeanDifference(blockIndex) = tempMeanDifference;
   
   tempMeanOuterColumns = mean([activeMobile.experimentalMeans(1)'; activeMobile.experimentalMeans(4)']);
   tempMeanInnerColumns = mean([activeMobile.experimentalMeans(2)'; activeMobile.experimentalMeans(3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeMobile.experimentalMeanDifference(blockIndex) = tempMeanDifference;
   
   tempMeanOuterColumns = mean([activeHighlyMobile.experimentalMeans(1)'; activeHighlyMobile.experimentalMeans(4)']);
   tempMeanInnerColumns = mean([activeHighlyMobile.experimentalMeans(2)'; activeHighlyMobile.experimentalMeans(3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeHighlyMobile.experimentalMeanDifference(blockIndex) = tempMeanDifference;
   
   %% Plot if we want:
%    numPreviousSubplots = (3 * (blockIndex - 1));
%    subplot(numberOfBlocks,3,numPreviousSubplots+1);
%    bar(activeImmobile.experimentalMeans)
%    
%    subplot(numberOfBlocks,3,numPreviousSubplots+2);
%    bar(activeMobile.experimentalMeans)
%    
%    subplot(numberOfBlocks,3,numPreviousSubplots+3);
%    bar(activeHighlyMobile.experimentalMeans)
   
   
   
   %% Loop through and perform all shuffles
   % We accumulate all means obtained via the shuffles in the "active*.mean" accumulator arrays.
   for activeShuffleIndex = 1:numberOfShuffles
       %% Generate the permuation of the indicies to reshuffle the flatValues:
       activeImmobile.permIndex = randperm(size(activeImmobile.flatValues,1));
       activeMobile.permIndex = randperm(size(activeMobile.flatValues,1));
       activeHighlyMobile.permIndex = randperm(size(activeHighlyMobile.flatValues,1));

       %% Reshuffle the values using the shuffled indicies
       activeImmobile.shuffledFlatValues = activeImmobile.flatValues(activeImmobile.permIndex);
       activeMobile.shuffledFlatValues = activeMobile.flatValues(activeMobile.permIndex);
       activeHighlyMobile.shuffledFlatValues = activeHighlyMobile.flatValues(activeHighlyMobile.permIndex);

       %% Place them back into the correct data structure
       activeImmobile.shuffledValues = reshape(activeImmobile.shuffledFlatValues,[],4);
       activeMobile.shuffledValues = reshape(activeMobile.shuffledFlatValues,[],4);
       activeHighlyMobile.shuffledValues = reshape(activeHighlyMobile.shuffledFlatValues,[],4);

       %% Re-perform the averaging techniques:
       %% Average over all values of each of the four columns:
       activeImmobile.mean(activeShuffleIndex,:) = nanmean(activeImmobile.shuffledValues,1);
       activeMobile.mean(activeShuffleIndex,:) = nanmean(activeMobile.shuffledValues,1);
       activeHighlyMobile.mean(activeShuffleIndex,:) = nanmean(activeHighlyMobile.shuffledValues,1);
       
   end
   
   %% After the loop is complete, compute the output metrics in a vectorized way.
   % Again, compute the mean of the outer columns minus the mean of the inner columns
   tempMeanOuterColumns = mean([activeImmobile.mean(:,1)'; activeImmobile.mean(:,4)']);
   tempMeanInnerColumns = mean([activeImmobile.mean(:,2)'; activeImmobile.mean(:,3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeImmobile.outputMetric(:,1) = tempMeanDifference;
   
   tempMeanOuterColumns = mean([activeMobile.mean(:,1)'; activeMobile.mean(:,4)']);
   tempMeanInnerColumns = mean([activeMobile.mean(:,2)'; activeMobile.mean(:,3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeMobile.outputMetric(:,1) = tempMeanDifference;
   
   tempMeanOuterColumns = mean([activeHighlyMobile.mean(:,1)'; activeHighlyMobile.mean(:,4)']);
   tempMeanInnerColumns = mean([activeHighlyMobile.mean(:,2)'; activeHighlyMobile.mean(:,3)']);
   tempMeanDifference = tempMeanOuterColumns - tempMeanInnerColumns;
   activeHighlyMobile.outputMetric(:,1) = tempMeanDifference;
   
   %% Compute the p-values:
   activeImmobile.numGreater(blockIndex) = sum(activeImmobile.outputMetric(:,1) >  activeImmobile.experimentalMeanDifference(blockIndex));
   activeImmobile.numLowTail(blockIndex) = sum(activeImmobile.outputMetric(:,1) <  (-activeImmobile.experimentalMeanDifference(blockIndex)));
   activeImmobile.extremeValuesTail(blockIndex) = sum(abs(activeImmobile.outputMetric(:,1)) > abs(activeImmobile.experimentalMeanDifference(blockIndex)));
   activeImmobile.percentGreater(blockIndex) = activeImmobile.numGreater(blockIndex) / double(numberOfShuffles);
   activeImmobile.percentLTE(blockIndex) = 1.0 - activeImmobile.percentGreater(blockIndex);
   
%    activeImmobile.pValue(blockIndex) = (activeImmobile.numGreater(blockIndex) + activeImmobile.numLowTail(blockIndex))/ double(numberOfShuffles);
   activeImmobile.pValue(blockIndex) = (activeImmobile.extremeValuesTail(blockIndex))/ double(numberOfShuffles);
   
   activeMobile.numGreater(blockIndex) = sum(activeMobile.outputMetric(:,1) > activeMobile.experimentalMeanDifference(blockIndex));
   activeMobile.numLowTail(blockIndex) = sum(activeMobile.outputMetric(:,1) <  (-activeMobile.experimentalMeanDifference(blockIndex)));
   activeMobile.extremeValuesTail(blockIndex) = sum(abs(activeMobile.outputMetric(:,1)) > abs(activeMobile.experimentalMeanDifference(blockIndex)));
   activeMobile.percentGreater(blockIndex) = activeMobile.numGreater(blockIndex) / double(numberOfShuffles);
   activeMobile.percentLTE(blockIndex) = 1.0 - activeMobile.percentGreater(blockIndex);
%    activeMobile.pValue(blockIndex) = (activeMobile.numGreater(blockIndex) + activeMobile.numLowTail(blockIndex))/ double(numberOfShuffles);
   activeMobile.pValue(blockIndex) = (activeMobile.extremeValuesTail(blockIndex))/ double(numberOfShuffles);
   
   
   activeHighlyMobile.numGreater(blockIndex) = sum(activeHighlyMobile.outputMetric(:,1) >  activeHighlyMobile.experimentalMeanDifference(blockIndex));
   activeHighlyMobile.numLowTail(blockIndex) = sum(activeHighlyMobile.outputMetric(:,1) <  (-activeHighlyMobile.experimentalMeanDifference(blockIndex)));
   activeHighlyMobile.extremeValuesTail(blockIndex) = sum(abs(activeHighlyMobile.outputMetric(:,1)) > abs(activeHighlyMobile.experimentalMeanDifference(blockIndex)));
   activeHighlyMobile.percentGreater(blockIndex) = activeHighlyMobile.numGreater(blockIndex) / double(numberOfShuffles);
   activeHighlyMobile.percentLTE(blockIndex) = 1.0 - activeHighlyMobile.percentGreater(blockIndex);
%    activeHighlyMobile.pValue(blockIndex) = (activeHighlyMobile.numGreater(blockIndex) + activeHighlyMobile.numLowTail(blockIndex))/ double(numberOfShuffles);
   activeHighlyMobile.pValue(blockIndex) = (activeHighlyMobile.extremeValuesTail(blockIndex))/ double(numberOfShuffles);
   
   Immobile.experimentalResults(blockIndex) = activeImmobile;
   Mobile.experimentalResults(blockIndex) = activeMobile;
   HighlyMobile.experimentalResults(blockIndex) = activeHighlyMobile;
end

% % Plot the histograms:
% figure(1);
% histogram(activeImmobile.outputMetric)
% title('activeImmobile; 100000 shuffles')
% 
% figure(2);
% histogram(activeMobile.outputMetric)
% title('activeMobile; 100000 shuffles')
% 
% figure(3);
% histogram(activeHighlyMobile.outputMetric)
% title('activeHighlyMobile; 100000 shuffles')

finalOutputTable = table(activeImmobile.pValue', activeMobile.pValue', activeHighlyMobile.pValue','VariableNames',{'Immobile','Mobile','HighlyMobile'});
% finalOutputTable.activeImmobile = ;
% finalOutputTable.activeMobile = ;
% finalOutputTable.activeHighlyMobile = ;

% output_file_name = ['results_', '_pValues'];
finalOutputString = sprintf("results/results_%s_%s_pValues.mat", sanatizedOutputFileName, sanatizedOutputExptName);
printf("Saving to %s...", finalOutputString);

% save(finalOutputString,'finalOutputTable','activeHighlyMobile','activeMobile','activeImmobile');
save(finalOutputString,'HighlyMobile','Mobile','Immobile','finalOutputTable','activeHighlyMobile','activeMobile','activeImmobile');

disp('Done!');

if (shouldPerformIndividualAnimalAnalysis)
    % Build Figures:
    figure(12);
    sgtitle('Drug Responses per Individual');
    for currDrugGroupIndex = 1:numberOfDrugGroups
        subplot(2,2,currDrugGroupIndex);
        title([drugName drugDoseGroupDoseStringLabel{currDrugGroupIndex}]);
        ylim([40,220]);
        hold on;
    end

    PhoAnalysisStats.avgOverAllDosesForEachAnimal = zeros(numberOfAnimals,1);
    PhoAnalysisStats.varOverAllDosesForEachAnimal = zeros(numberOfAnimals,1);
    PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal = zeros(numberOfAnimals,1);
    PhoAnalysisStats.errorBarLowOverAllDosesForEachAnimal = zeros(numberOfAnimals,1);
    PhoAnalysisStats.errorBarHighOverAllDosesForEachAnimal = zeros(numberOfAnimals,1);

    %% Loop through animals
    for currIndividualAnimalIndex = 1:numberOfAnimals
        currAnimalDrugGroups = individualAnimalData(currIndividualAnimalIndex).individualAssignedDrugGroupIndex;
        individualColors = [];
        % For each assigned drug group for that animal:
        for i = 1:length(currAnimalDrugGroups)
            individualColors(i,:) = drugDoseGroupColorMatrix(currAnimalDrugGroups(i),:);

            % TODO: Average over the animals' values for that dose.
            currDrugGroupIndex = currAnimalDrugGroups(i);
    %         if (currAnimalDrugGroups(i) == 1)
    %             
    %         end
        end


        %% Compute the individual animal changes for each swim, and look at:
        individualAnimalData(currIndividualAnimalIndex).doseDiff = diff([0 individualAnimalData(currIndividualAnimalIndex).dose]);

        % Individual Initial Variation:
        individualAnimalData(currIndividualAnimalIndex).immobileDiff = [0, diff(individualAnimalData(currIndividualAnimalIndex).immobile)];

        % The average effect of continued swims:

        %% Loop through drug groups
        for currDrugGroupIndex = 1:numberOfDrugGroups
            % Look at repeated trials at the same dose, ignoring intermediate doses.
            individualAnimalMatchingDrugIndicies = find(individualAnimalData(currIndividualAnimalIndex).dose == drugDoseGroupDose(currDrugGroupIndex));
            if (~isempty(individualAnimalMatchingDrugIndicies))
        %         if (individualZeroIndicies(1) == 1)
        %            % Excluding first trial for all animals
        %            individualZeroIndicies(1) = [];
        %         end
                % If we have zero dose instances, plot them.
                figure(12);
                subplot(2,2,currDrugGroupIndex);
                plot(dayOfFSTTrial(individualAnimalMatchingDrugIndicies), individualAnimalData(currIndividualAnimalIndex).immobile(individualAnimalMatchingDrugIndicies),'-x','LineWidth',2.0);
                hold on;
            end
        end


    %     individualZeroIndicies = find(individualAnimalData(currIndividualAnimalIndex).dose == 0.0);
    %     if (~isempty(individualZeroIndicies))
    % %         if (individualZeroIndicies(1) == 1)
    % %            % Excluding first trial for all animals
    % %            individualZeroIndicies(1) = [];
    % %         end
    %         % If we have zero dose instances, plot them.
    %         figure(11);
    %         title('Veh. Only Trials per Individual');
    %         plot(dayOfFSTTrial(individualZeroIndicies), individualAnimalData(currIndividualAnimalIndex).immobile(individualZeroIndicies),'-x','LineWidth',2.0);
    %         hold on;
    %     end


        % The average effect of animal:
        PhoAnalysisStats.avgOverAllDosesForEachAnimal(currIndividualAnimalIndex) = mean(individualAnimalData(currIndividualAnimalIndex).immobile);
        PhoAnalysisStats.varOverAllDosesForEachAnimal(currIndividualAnimalIndex) = var(individualAnimalData(currIndividualAnimalIndex).immobile);

        PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal(currIndividualAnimalIndex) = (std(individualAnimalData(currIndividualAnimalIndex).immobile) / sqrt(length(individualAnimalData(currIndividualAnimalIndex).immobile, stdDevWeightingOption)));
        PhoAnalysisStats.errorBarLowOverAllDosesForEachAnimal(currIndividualAnimalIndex) = PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal(currIndividualAnimalIndex) - PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal(currIndividualAnimalIndex);
        PhoAnalysisStats.errorBarHighOverAllDosesForEachAnimal(currIndividualAnimalIndex) = PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal(currIndividualAnimalIndex) + PhoAnalysisStats.stdErrorOfMeanOverAllDosesForEachAnimal(currIndividualAnimalIndex);

        % The average effect of dose:

        % The average effect of changing drug group:

        % The average effect of "withdrawal":

        % Plot only vehicle trials:


    %     %% Get value for appropriate index, assign to individual animals value.
    %     figure(1);
    %     title('Immobile')
    %     scatter(dayOfFSTTrial, individualAnimalData(currIndividualAnimalIndex).immobile, [], individualColors);
    %     hold on;
    %     % Plot animal specific color
    %     plot(dayOfFSTTrial, individualAnimalData(currIndividualAnimalIndex).immobile,'-','LineWidth',2.0);

    %     figure(2);
    %     title('Imobile Diff')
    %     scatter(dayOfFSTTrial, individualAnimalData(currIndividualAnimalIndex).immobileDiff, [], individualColors);
    %     hold on;
    end

    %% Individual animal immobility averaged over all dosages
    figure(13);
    animalIndicies = 1:numberOfAnimals;
    bar(animalIndicies, PhoAnalysisStats.avgOverAllDosesForEachAnimal);
    hold on;
    % Add error bars
    er = errorbar(animalIndicies, PhoAnalysisStats.avgOverAllDosesForEachAnimal, PhoAnalysisStats.errorBarLowOverAllDosesForEachAnimal, PhoAnalysisStats.errorBarHighOverAllDosesForEachAnimal);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    title('Animal Immobility over all Doses');
    hold off;

end



end

