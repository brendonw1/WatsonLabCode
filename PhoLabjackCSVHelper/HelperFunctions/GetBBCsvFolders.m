function BBFolders = GetBBCsvFolders(bbIDs,inputPathRoot, curr_experiment,curr_cohort)

for i=1:length(bbIDs)
	curr_bbID = bbIDs{i};
	BBFolders{i} = fullfile([inputPathRoot, curr_bbID, ['\experiment_' curr_experiment '\cohort_' curr_cohort '\animal_'], curr_bbID]);
end