function BWPreprocessing(basepath)

if ~exist('basepath','var')
    basepath = cd;
elseif isempty(basepath)
    basepath = cd;
    1;
end
basename = bz_BasenameFromBasepath(basepath);

%% Optional: don't do it if already preprocessed... can comment this out
if exist(fullfile(basepath,[basename,'.SleepState.states.mat']),'file');
    disp([basename ' already done, skipping'])
    return
end

%% Assuming one already did bz_SetAnimalMetadata
% if both the .mat and the Text.m files already exist in the basepath
tmat = fullfile(basepath,[basename,'.SessionMetadata.mat']);
ttext = fullfile(basepath,[basename,'_SessionMetadataText.m']);
if exist(tmat,'file') && exist(ttext,'file')
    disp([basename ': SessionMetadata already exists, not changing']);
elseif ~exist(tmat,'file') && exist(ttext,'file') %if just the Text.m exists, just run it.
    run(ttext);
%     bz_RunSessionMetadata(basepath)
else %if not all set up
    % find sessionmetadata in animal folder - use as template
%     basepath = cd;
    [animalpath] = fileparts(basepath);
    d = dir(fullfile(animalpath,'*SessionMetadataText.m'));
    if ~isempty(d);
        copyfile(fullfile(animalpath,d(1).name),ttext);
        disp(['NOTE: Autorunning SessionMetadataText.m for ' basename ' based on default session metadata values.  Session metadata has not been specifically edited for this session and may need to be edited and re-run']) 
        run(ttext);
    else
        disp([basename ': must provide either a local SessionMetadataText.m or a default one in Animal folder above'])
        return
    end
%     bz_RunSessionMetadata(basepath);%this will default to the currently present _SessionMetadata.mat file if it's present.
    
end

%% making an xml if needed
basename = bz_BasenameFromBasepath(basepath);
txmlname = fullfile(basepath,[basename '.xml']);
d = dir(fullfile(basepath,txmlname));
load(fullfile(basepath,[basename '.SessionMetadata.mat']))
if isempty(d);%if no basename.xml already
    if isempty(SessionMetadata.ExtracellEphys.ParametersDivergentFromAnimalMetadata)%if not different from animal xml, copy the animal xml here
        ax = fullfile(SessionMetadata.AnimalMetadata.AnimalBasepath,[SessionMetadata.AnimalMetadata.AnimalName, '.xml']);
        copyfile(ax,txmlname);
        disp([basename ': XML copied from animal folder']);
    else    %if changes, make new xml for this session
        bz_MakeXML(basepath)
        disp([basename ': XML made from Metadata files']);
    end
end

%% Handling dat and lfp
disp('Concatenating .dat files')
bz_ConcatenateDats(basepath);
disp('Converting .dat to .lfp')
bz_LFPFromDat(basepath);

%% Sleep Scoring
disp('Starting Sleep Scoring')
SleepScoreMaster(basepath);

%% Spike sorting
% disp('Starting KiloSort')
% KiloSortWrapper(basepath);







% %manually: make a folder with fbasename
% %have all files in it
% %generate xml with name fbasename
% %navigate to that folder
% 
% %% get basename, assume the current directory is named basename
% dirname = cd;
% f = filesep;
% r = regexp(dirname,f);%find the slash
% basename = dirname(r(end)+1:end);%take from after the last slash to the end
% 
% %%
% RemoveDCfromDat_AllDat
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