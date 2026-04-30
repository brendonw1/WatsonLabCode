function EBB_Reshaping()
    %%run it where all the data folders are.
    %%it will loop over all the present folders and create a new dat per animal for all available hours.
    %%new dats are craeted in Animal_Split_Output/Animal_A :example
    %%A,B,C,D are read from signal_groups from xml
    basePath = pwd;

    folders = dir(basePath);
    folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));
    folders = folders(~strcmp({folders.name}, 'Animal_Split_Output'));

    [~, idx] = sort({folders.name});
    folders = folders(idx);

    fs = 20000;
    bytesPerSample = 2; % int16

    outputBase = fullfile(basePath, 'Animal_Split_Output');
    if ~exist(outputBase, 'dir')
        mkdir(outputBase);
    end

    %% Find first folder with amplifier.dat and XML
    firstFolderIdx = [];

    for i = 1:length(folders)
        folderPath = fullfile(basePath, folders(i).name);
        ampFile = fullfile(folderPath, 'amplifier.dat');
        xmlFiles = dir(fullfile(folderPath, 'settings.xml'));

        if exist(ampFile, 'file') && ~isempty(xmlFiles)
            firstFolderIdx = i;
            xmlname = fullfile(folderPath, xmlFiles(1).name);
            break;
        end
    end

    if isempty(firstFolderIdx)
        error('No folder found with both amplifier.dat and XML.');
    end

    fprintf('Using XML from folder: %s\n', folders(firstFolderIdx).name);
    fprintf('XML file: %s\n', xmlname);

    %% Parse Intan XML by SignalGroup
    xDoc = xmlread(xmlname);
    signalGroups = xDoc.getElementsByTagName('SignalGroup');

    animalGroups = {};
    animalPrefixes = {};
    channelCounter = 0;

    for g = 0:signalGroups.getLength-1

        groupNode = signalGroups.item(g);
        prefix = char(groupNode.getAttribute('Prefix'));

        % Use only animal ports A-D
        if ~ismember(prefix, {'A','B','C','D'})
            continue
        end

        channelNodes = groupNode.getElementsByTagName('Channel');

        thisAnimalChans = [];
        thisAnimalNames = {};

        for c = 0:channelNodes.getLength-1

            chNode = channelNodes.item(c);

            nativeName = char(chNode.getAttribute('NativeChannelName'));
            enabledVal = char(chNode.getAttribute('Enabled'));

            % Include ALL enabled channels inside A/B/C/D SignalGroup
            % This includes A-008:A-023 plus A-AUX1:A-AUX3
            if strcmpi(enabledVal, 'True')

                channelCounter = channelCounter + 1;
                thisAnimalChans(end+1) = channelCounter;
                thisAnimalNames{end+1} = nativeName;

            end
        end

        if ~isempty(thisAnimalChans)

            animalGroups{end+1} = thisAnimalChans;
            animalPrefixes{end+1} = prefix;

            fprintf('Animal %d / SignalGroup %s: %d channels / channel numbers: %s\n', ...
                length(animalGroups), prefix, length(thisAnimalChans), mat2str(thisAnimalChans));

            fprintf('Channel names: ');
            fprintf('%s ', thisAnimalNames{:});
            fprintf('\n');
        end
    end
    nAnimals = length(animalGroups);
    nChannels = channelCounter;

    fprintf('\nTotal animals detected: %d\n', nAnimals);
    fprintf('Total enabled amplifier channels: %d\n\n', nChannels);

    %% Reshape and concatenate DATs
    for animal = 1:nAnimals

        animalFolder = fullfile(outputBase, sprintf('Animal_%s', ...
        animalPrefixes{animal}));

        if ~exist(animalFolder, 'dir')
            mkdir(animalFolder);
        end

        outFile = fullfile(animalFolder, 'amplifier.dat');
        fidOut = fopen(outFile, 'w');

        if fidOut == -1
            error('Could not open output file: %s', outFile);
        end

        animalChans = animalGroups{animal};
        nAnimalChannels = length(animalChans);

        fprintf('\nCreating Animal %d (%s), %d channels\n', ...
            animal, animalPrefixes{animal}, nAnimalChannels);

        totalSamples = 0;
        concatLog = table();   % initialize empty table

        for i = 1:length(folders)

            folderPath = fullfile(basePath, folders(i).name);
            ampFile = fullfile(folderPath, 'amplifier.dat');
            info = dir(ampFile);
            fprintf('amplifier.dat exists, size = %.2f GB\n', info.bytes/1e9);

            if ~exist(ampFile, 'file')
                fprintf('%s -> amplifier.dat NOT FOUND\n', folders(i).name);
                continue;
            end

            fidIn = fopen(ampFile, 'r');

            if fidIn == -1
                fprintf('%s -> could not open amplifier.dat\n', folders(i).name);
                continue;
            end

            data = fread(fidIn, [nChannels, Inf], 'int16');
            fclose(fidIn);

            animalData = data(animalChans, :);

            fwrite(fidOut, animalData, 'int16');      
            %% poxis time and exporting csv for every animal group
            thisSamples = size(animalData, 2);

            sampleStart = totalSamples + 1;
            sampleEnd   = totalSamples + thisSamples;

            % Parse actual start time from folder name, e.g. exp06_260127_204641
            tokens = regexp(folders(i).name, '\d+_(\d{6})_(\d{6})', 'tokens');

            if ~isempty(tokens)
                dateStr = tokens{1}{1}; % 260127
                timeStr = tokens{1}{2}; % 204641

                actualStart = datetime([dateStr timeStr], ...
                'InputFormat','yyMMddHHmmss');

                actualEnd = actualStart + seconds(thisSamples/fs);

                posixStart = posixtime(actualStart);
                posixEnd   = posixtime(actualEnd);
            else
                actualStart = NaT;
                actualEnd = NaT;
                posixStart = NaN;
                posixEnd = NaN;
            end
            channelRangeStr = sprintf('%d-%d', animalChans(1), animalChans(end));% channel range
            newRow = table( ...
                string(folders(i).name), ...
                string(animalPrefixes{animal}), ...
                nAnimalChannels, ...
                string(channelRangeStr), ...
                sampleStart, ...
                sampleEnd, ...
                thisSamples, ...
                thisSamples/fs, ...
                actualStart, ...
                actualEnd, ...
                posixStart, ...
                posixEnd, ...
                fs, ...
                'VariableNames', { ...
                    'OriginalFolder', ...
                    'SignalGroup', ...
                    'NumChannels', ...
                    'ChannelIDs', ...
                    'ConcatSampleStart', ...
                    'ConcatSampleEnd', ...
                    'NumSamples', ...
                    'DurationSeconds', ...
                    'ActualStartTime', ...
                    'ActualEndTime', ...
                    'PosixStartTime', ...
                    'PosixEndTime', ...
                    'RecordingFrequency(KHz)'});

            concatLog = [concatLog; newRow];



            totalSamples = totalSamples + thisSamples;

            fprintf('Added %s: %.2f hrs\n', ...
                folders(i).name, thisSamples/fs/3600);
        end

        fclose(fidOut);


        fileInfo = dir(outFile);

        finalDuration_hr = fileInfo.bytes / ...
            (nAnimalChannels * bytesPerSample * fs) / 3600;

        fprintf('\nFINAL Animal(%s)\n', animalPrefixes{animal});
        fprintf('Saved: %s\n', outFile);
        fprintf('Channels: %d\n', nAnimalChannels);
        fprintf('Size: %.2f GB\n', fileInfo.bytes/1e9);
        fprintf('Duration: %.2f hrs\n\n', finalDuration_hr);

        %saving the log for the animal group
        csvFile = fullfile(animalFolder, ...
        sprintf('Animal_%s_concat_log.csv', animalPrefixes{animal}));

        writetable(concatLog, csvFile);

        fprintf('Saved concat log CSV: %s\n', csvFile);
    end
end    