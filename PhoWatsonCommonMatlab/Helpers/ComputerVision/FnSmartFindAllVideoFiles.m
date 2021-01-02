function [all_videos_output_data, totalCombinedVideoCount, totalBoxFolderCount] = FnSmartFindAllVideoFiles(bbIDs, activeTranscodedVideosPathRoot, output_found_videos_file_name)
%FnSmartFindAllVideoFiles Finds all .mp4 video files in the BB subfolders under the activeTranscodedVideosPathRoot. Produces a merged output file containing the video files and their metadata.
%   Detailed explanation goes here

	totalBoxFolderCount = 0;
	totalCombinedVideoCount = 0;

	if ~exist('output_found_videos_file_name', 'var')
		output_found_videos_file_name = 'FoundVideoFiles.mat';
	end

	has_previous_results = false;
	perform_file_search = true;
	perform_output_file_save = false;


		
	if exist(output_found_videos_file_name, 'file')
		disp('    WARNING: The file already exists and we will not overwrite it! Delete it or change the filename to re-search for videos. Continuing with existing file!');
		% Load the existing video files
		LoadedS = load(output_found_videos_file_name, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount');
		has_previous_results = true;
		fprintf('Loaded %s: contains %i total videos spanning %i folders.\n', output_found_videos_file_name, LoadedS.totalCombinedVideoCount, LoadedS.totalBoxFolderCount);

		% Test for any new bbIDs to include:
% 		[loadedOnly_BBIDs, commonBBIDs, new_BBIDs, phoDiffOutput] = fnDiffCellArrays(LoadedS.bbIDs, bbIDs);

		% Merge bbIDs with new BBIDs and get the unique ones:
		bbIDs = unique([LoadedS.bbIDs, bbIDs]);

		% We merge the rest of the variables later, after we search the filesystem for any new video files.
		perform_file_search = true;

	else
		disp('FoundVideoFiles.mat does not exist. Finding video files and creating...');
		has_previous_results = false;
		perform_file_search = true;
		perform_output_file_save = true; % Allow saving if there isn't a file to overwrite.
	end

	if strcmp(activeTranscodedVideosPathRoot, '')
		perform_file_search = false;
		if ~has_previous_results
			fprintf('Previous file not found and activeTranscodedVideosPathRoot == '', skipping search and returning with no results.\n');
			return
		else
			fprintf('Previous file was found but ActiveTranscodedVideosPathRoot == '', so search will be skipped. Resultant file should be unchanged.\n');
			% Don't return just in case?
		end

	end

	% If 
	if perform_file_search
		% Search for videos (or additional videos) in the folders:
		fprintf('Searching for additional videos...\n');
		%% Loop through the bbIDs:
		for i=1:length(bbIDs)
			curr_bbID = bbIDs{i};
			curr_folder = [activeTranscodedVideosPathRoot, curr_bbID];

			curr_box_output_data.curr_bbID = curr_bbID;
			curr_box_output_data.curr_folder = curr_folder;
			curr_box_output_data.videoFilesData = FnFindVideoFiles(curr_folder);
			num_video_files = length(curr_box_output_data.videoFilesData);


			curr_box_output_data.is_actigraphy_processed = zeros([num_video_files, 1]);
			curr_box_output_data.actigraphy_file_output_path = cell([num_video_files, 1]);
			curr_box_output_data.actigraphy_file_output_path(:) = {''};

			all_videos_output_data{i} = curr_box_output_data;

			totalBoxFolderCount = totalBoxFolderCount + 1;
			totalCombinedVideoCount = totalCombinedVideoCount + num_video_files;
		end
		fprintf('Found %i total videos spanning %i folders.\n', totalCombinedVideoCount, totalBoxFolderCount);
	end % end perform file search

	% Merge with loaded results if they exist:
	if has_previous_results
		% Collected the videoFilesData for both the loaded and new files:
		fprintf('Merging results...\n');
		numNewVideos = 0;
		numExtantLoadedVideos = 0;

		numNewBBIDs = 0;


		%% Loop through the bbIDs:
		for i=1:length(bbIDs)
			curr_bbID = bbIDs{i};
			curr_folder = [activeTranscodedVideosPathRoot, curr_bbID];
			
			% The new results will have all of the old files (hopefully), the only thing we're interested in transfering is the pre-compueted information (like actigraphy processing state) from the loaded files.
			curr_box_output_data = all_videos_output_data{i};
			
			% Need to find corresponding index in loaded data for this bbID:
			found_corresponding_loaded_all_videos_index = false;
			corresponding_loaded_all_videos_index = -1;
			for loadedIndex = 1:length(LoadedS.bbIDs)
				if strcmp(curr_bbID, LoadedS.bbIDs{loadedIndex})
					corresponding_loaded_all_videos_index = loadedIndex;
					found_corresponding_loaded_all_videos_index = true;
				end
			end

			%% TODO: would greatly enhance efficiency if I made a temporary list of names and indicies from the loaded data and removed them as they were found. Currently n! performance I believe, but there are so few video files it probably doesn't matter.
			if found_corresponding_loaded_all_videos_index
				% If there is a correspodning bbID in the loaded data:
				loaded_box_output_data = LoadedS.all_videos_output_data{corresponding_loaded_all_videos_index};
				% Loop through the recently found video files and figure out if anything needs to be updated
				for fileIndex = 1:length(curr_box_output_data.videoFilesData)
					was_video_file_found = false;
					for loadedFileIndex = 1:length(loaded_box_output_data.videoFilesData)
						if strcmpi(curr_box_output_data.videoFilesData(fileIndex).name, loaded_box_output_data.videoFilesData(loadedFileIndex).name)
							% Found matching entry in the loaded data.
							% Set the current actigraphy status and file output path from the loaded file:
							all_videos_output_data{i}.is_actigraphy_processed(fileIndex) = loaded_box_output_data.is_actigraphy_processed(loadedFileIndex);
							all_videos_output_data{i}.actigraphy_file_output_path{fileIndex} = loaded_box_output_data.actigraphy_file_output_path{loadedFileIndex}; 
							%% TODO: are there any other computed fields that need to be loaded, like the parsed video time, etc?
							was_video_file_found = true;
							break;
						end
					end % end inner loaded file loop:
					
					if was_video_file_found
						numExtantLoadedVideos = numExtantLoadedVideos + 1;
					else
						numNewVideos = numNewVideos + 1;
					end

				end % end for curr_box_output_data.videoFilesData

			else
				numNewBBIDs = numNewBBIDs + 1;
				numNewVideos = numNewVideos + length(curr_box_output_data.videoFilesData);
			end % end if found_corresponding_loaded_all_videos_index

		end % end for
		fprintf('Merging Complete.\n'); % TODO: display total merged counts
		fprintf('    Found %i new videos spanning %i new folders.\n', numNewVideos, numNewBBIDs);

		% Make backup of existing file:
		[backup_file_fullpath, status] = MakeBackup(output_found_videos_file_name, 'backup', '', true, 'backups');
		if status
			%% TODO: allow saving:
			perform_output_file_save = true;
		end
		
	end % end if

	if perform_output_file_save
		% Save the result to a .mat file:
		save(output_found_videos_file_name, 'activeTranscodedVideosPathRoot', 'bbIDs', 'all_videos_output_data', 'totalCombinedVideoCount', 'totalBoxFolderCount', '-v7.3');
		fprintf('    Result saved to %s\n', output_found_videos_file_name);
	end

end

