function BWPreprocessing(basepath,noPrompts)
% Inputs optional
% 

warning off

if ~exist('basepath','var')
    basepath = cd;
elseif isempty(basepath)
    basepath = cd;
    1;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('noPrompts','var')
    noPrompts = (1);
end
noPrompts = logical(noPrompts);

%% Optional: don't do it if already preprocessed... can comment this out
% if exist(fullfile(basepath,[basename,'.SleepState.states.mat']),'file');
%     disp([basename ' already done, skipping'])
%     return
% end

%% Assuming one already did bz_SetAnimalMetadata
% % if both the .mat and the Text.m files already exist in the basepath
% tmat = fullfile(basepath,[basename,'.SessionMetadata.mat']);
% ttext = fullfile(basepath,[basename,'_SessionMetadataText.m']);
% if exist(tmat,'file') && exist(ttext,'file')
%     disp([basename ': SessionMetadata already exists, not changing']);
% elseif ~exist(tmat,'file') && exist(ttext,'file') %if just the Text.m exists, just run it.
%     run(ttext);
% %     bz_RunSessionMetadata(basepath)
% else %if not all set up
%     % find sessionmetadata in animal folder - use as template
% %     basepath = cd;
%     [animalpath] = fileparts(basepath);
%     d = dir(fullfile(animalpath,'*SessionMetadataText.m'));
%     if ~isempty(d);
%         copyfile(fullfile(animalpath,d(1).name),ttext);
%         disp(['NOTE: Autorunning SessionMetadataText.m for ' basename ' based on default session metadata values.  Session metadata has not been specifically edited for this session and may need to be edited and re-run']) 
%         run(ttext);
%     else
%         disp([basename ': must provide either a local SessionMetadataText.m or a default one in Animal folder above'])
%         return
%     end
% %     bz_RunSessionMetadata(basepath);%this will default to the currently present _SessionMetadata.mat file if it's present.
%     
% end

%% copying xml if needed
% !How to set htis up for now?
% !copy from above or amplifier.xml?
txmlname = fullfile(basepath,[basename '.xml']);
d = dir(txmlname);
if isempty(d)%if no basename.xml already in this folder
%     d3 = dir(fullfile(basepath,'amplifier.xml'));% or amplifier.xml
%     if length(d2) == 1%if one and only one found, assume it and copy it to basepath
%         copyfile (fullfile(suprapath,d2(1).name),txmlname)
%     else%otherwise get user input
%         [uifile,uipath] = uigetfile('.xml','Select Xml to copy into this folder for this recording')
%         copyfile (fullfile(uipath,uifile),txmlname)
%     end
% 
%     [suprapath,~] = fileparts(basepath);%... look in the folder above 
%     underscores = findstr(basename,'_');
%     animalname = basename(1:underscores(1)-1);
%     d2 = dir(fullfile(suprapath,[animalname '.xml']));%for either animalname.xml
%     d3 = dir(fullfile(suprapath,'amplifier.xml'));% or amplifier.xml
%     d2 = cat(1,d2,d3);
%     if length(d2) == 1%if one and only one found, assume it and copy it to basepath
%         copyfile (fullfile(suprapath,d2(1).name),txmlname)
%     else%otherwise get user input
        [uifile,uipath] = uigetfile('.xml','Select Xml to copy into this folder for this recording');
        copyfile (fullfile(uipath,uifile),txmlname)
%     end
end


% basename = bz_BasenameFromBasepath(basepath);
% txmlname = fullfile(basepath,[basename '.xml']);
% d = dir(fullfile(basepath,txmlname));
% load(fullfile(basepath,[basename '.SessionMetadata.mat']))
% if isempty(d);%if no basename.xml already
%     if isempty(SessionMetadata.ExtracellEphys.ParametersDivergentFromAnimalMetadata)%if not different from animal xml, copy the animal xml here
%         ax = fullfile(SessionMetadata.AnimalMetadata.AnimalBasepath,[SessionMetadata.AnimalMetadata.AnimalName, '.xml']);
%         copyfile(ax,txmlname);
%         disp([basename ': XML copied from animal folder']);
%     else    %if changes, make new xml for this session
%         bz_MakeXML(basepath)
%         disp([basename ': XML made from Metadata files']);
%     end
% end



%% Get sessioninfo... sort of partial metadata
% eval(['! neuroscope ' fullfile(basepath,[basename '.dat']) ' &'])
% if noPrompts
%     sessionInfo = bz_getSessionInfo(basepath,'editGUI',false,'noPrompts',noPrompts);
% else
%     sessionInfo = bz_getSessionInfo(basepath,'editGUI',true,'noPrompts',noPrompts);
% end
% filename = fullfile(basepath,[basename,'.sessionInfo.mat']);
% save(filename,'sessionInfo'); 
sessionInfo = bz_getSessionInfo(basepath,'editGUI',true);


%% Handling dat 
disp('Concatenating .dat files')
% MakeConcatDats_OneSession(basepath) 
deleteoriginaldatsboolean = 0;
bz_ConcatenateDats(basepath,deleteoriginaldatsboolean);

%% Handling some dat metadata
bz_DatFileMetadata(basepath);
try
    TimeFromLightCycleStart(basepath);% Zeitgeber times of recording files
    RecordingSecondsToTimeSeconds(basepath,basename)
catch e
    disp(['Received error: "' e.message '" during timestamping.  SKIPPING STEP and Continuing on'])
end


%% Make LFP file 
if ~exist(fullfile(basepath,[basename '.lfp']),'file')
    disp('Converting .dat to .lfp')
%datname = fullfile(basepath,[basename '.dat']);
%lfpname = fullfile(basepath,[basename '.lfp']);
%nchannels = length(sessionInfo.channels);
%widebandsampfreq = sessionInfo.rates.wideband;
%desiredLfpFreq = 1250;%user choice, 1250 is buzsakilab convention
%ResampleBinary(datname,lfpname,nchannels,widebandsampfreq,desiredLfpFreq);
    bz_LFPFromDat(basepath)
else
    disp('Not converting .lfp file, since it already exists')
end

%% Sleep Scoring
disp('Starting Sleep Scoring')
SleepScoreMaster(basepath,'noPrompts',noPrompts);

%% Spike sorting
try %figure out if gpu is present
    gpuArray(1);
    goodGPU = 1;
catch
    goodGPU = 0;
end

if goodGPU
    try
        disp('Starting KiloSort')
        KiloSortWrapper('basepath',basepath);

        % To Klusters
        % Kilosort2Neurosuite(rez);
        % Save original clus if clu's prsent
        t = dir (fullfile(basepath,'*.clu.*'));
        if ~isempty(t)
            mkdir(fullfile(basepath,'OriginalClus'));
            for idx = 1:length(t)
                copyfile(fullfile(basepath,t(idx).name),fullfile(basepath,'OriginalClus'));
            end
        end
    catch(e)
        rethrow(e)
    end
else
    disp('No GPU, not running kilosort')
end

% 
% %% put all .dats in a subfolder called basename or to isis
% % mkdir(basename);
% % movefile('*.dat',basename)
% newfolder = ['/mnt/isis3/brendon/',basename];
% mkdir(newfolder);
% eval(['! cp *.dat ',newfolder]);
% eval(['! ',basename,'.xml mnt/isis3/brendon');
% 
% %% 
% cd (newfolder)
% cd ..
% 
% % eval(['!ndm_start ',basename,'.xml ',basename,'/'])
% eval(['!ndmscript ',basename,'.xml ',basename,'/'])
% 
% %% 
% 
% cd(dirname)
% mkdir('OrignalTsps')
% d = dir('*.tsp');
% answer = inputdlg('Enter number of movie that should be used as map of animal behavior');
% goodmovie = str2num(answer{1});%do first movie first, to get coordinates
% allbutgoodmovie = 1:length(d);
% allbutgoodmovie(goodmovie) = [];
% sequence = [goodmovie allbutgoodmovie];
% for a = sequence;
%     thisfile = d(a).name;
%     thisfilenotsp = thisfile(1:end-4);
%     origtspname = [thisfilenotsp,'_original.tsp'];
%     movefile(thisfile,origtspname);
%     if a == goodmovie;
%         LEDbounds = ConfineTspOutput(origtspname,thisfile);
%     else
%         ConfineTspOutput(origtspname,thisfile,LEDbounds)
%     end
%     movefile(origtspname,'OriginalTsps')
% end
% 
% %%
% answer = inputdlg('Enter color channels you want to use: 1 thru 3','Color Channel Selection',1,{'1 3'});
% colorix = str2num(answer{1});
% AlignTsp2Whl_All('colorix',colorix);
