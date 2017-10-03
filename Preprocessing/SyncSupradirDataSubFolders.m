function [destpathscopied, basenamescopied] = SyncSupradirDataSubFolders(sourcedir,destdir)
% Iteratively calls rsync to synchronize all recordings in a directory to
% a target directory.  
% Goes item by item in the source session directory.  Looks at each item in
% that directory: 
%    if it's a file, copy it to target session directory
%    if it's a directory, copy only if the same name doesn't exist in the
%       target (ie doesn't double copy folders or folder contents in cases
%       where copied subfolders have been emptied or manipulated for
%       analysis reasons)
%
% Output 
% destpathscopied - charactercell of basepaths of recordings copied during
%                   this run of SyncSupradirDataSubFolders
% basenamescopied - charactercell of basenames of recordings copied during
%                   this run of SyncSupradirDataSubFolders
%
% Brendon Watson 2016, 2017

if ~exist('sourcedir','var')
    sourcedir = cd;
end

if strcmp(sourcedir(end),filesep)
    [~,animalname] = fileparts(sourcedir(1:end-1));
else
    [~,animalname] = fileparts(sourcedir);
end

if ~exist('destdir','var')
    destdir = [fullfile('/balrog_zpool',animalname)];
end
if ~exist(destdir,'dir')
    eval(['! mkdir ' destdir])
end

sd = getdir(sourcedir);
dd = getdir(destdir);

destpathscopied = {};
basenamescopied = {};

disp(['SYNCING ' sourcedir ' TO ' destdir])
for a = 1:length(sd)%check everything in the source directory
    if sd(a).isdir%for directories (ie sessions) in the larger source/animal directory
        if length(sd(a).name)>=length(animalname)
            if strcmp(sd(a).name(1:length(animalname)),animalname)%if it starts with animalname, if it's a session folder
                existsindestdir = 0;
                existsinsubdir = 0;
                tsessionsource = fullfile(sourcedir,sd(a).name);%define source session folder
                tsessiondest = fullfile(destdir,sd(a).name);%define default destination to save session

                %if the data is one level away however in the animal folder at
                %the distantion drive we don't want to copy it... that'd make
                %2 copies.
                %below are rule-outs to not copy bc already exists at one level
                %or another
                if exist(tsessiondest,'dir')% if the destination dir for session is present, great
                    existsindestdir = 1;
                else %but if can't find it double check whether we 
                    for b = 1:length(dd)%testing to see if it's in a subdirectory like ReadyToCluster for instance... if so don't copy it again
                        if(dd(b).isdir)
                            if exist(fullfile(destdir,dd(b).name,sd(a).name),'dir')
                                existsinsubdir = 1;
    %                             tsessiondest = fullfile(destdir,dd(b).name,sd(a).name);
                                        %could save this and use it if want to sync here
                            end
                        end
                    end
                end

                if existsinsubdir% if directory is in a subdirectory of the animal dest, don't copy 
                    disp([tsessiondest ' already exists in a subdirectory, not copying that recording'])
                else%if not already in a destination subfolder we'll go ahead and sync
                    if ~exist(tsessiondest,'dir')
                        eval(['mkdir ' tsessiondest])
                    end
                    %Will copy by folder based on whether the folder exists.  If it exists at the destination don't do anything
                    %Since we do that and can't use a larger rsync on the whole session folder, we copy also everything at the top level of the session

                    %go item by item in the source session directory.
                      % if it's a file, copy it to target session directory
                      % if it's a directory, copy only if the same name doesn't exist
                    sdc = dir(tsessionsource);%source directory contents
                    for sdcidx = 1:length(sdc);%ie for file or for each time "record" was hit on intan
                        tsi = fullfile(tsessionsource,sdc(sdcidx).name);%this source item
                        tti = fullfile(tsessiondest,sdc(sdcidx).name);%this target item (putative)
                        if ~isdir(tsi)
                            copyfile(tsi,tti)
                        elseif isdir(tsi)
                            if ~strcmp(sdc(sdcidx).name,'.') && ~strcmp(sdc(sdcidx).name,'..')%rule out pointers to local folders
                                if ~exist(tti,'dir')%if folder doesn't exist yet
                                    mkdir(tti)
    % %                                 rsyncstr = ['! rsync -ar ' tsi '/ ' tti];%prep command to copy it
    %                                 rsyncstr = ['! cp -ar ' tsi '/* ' tti];%prep command to copy it
    %                                 disp(rsyncstr)%show command
    %                                 eval(rsyncstr)%execute copy
    %                                 disp(' ')                               
                                    disp(['Copying ' tsi ' to ' tti])
                                    %for outputs
                                    destpathscopied{end+1} = tsessiondest;
                                    [~,basenamescopied{end+1}] = fileparts(destpathscopied{end});
                                    
%%                                  copy and then check each file one at a time
                                    tds = dir(tsi);
                                    for xidx = 1:length(tds)
                                        if ~strcmp(tds(xidx).name,'.') && ~strcmp(tds(xidx).name,'..')%rule out pointers to local folders
                                            txs = fullfile(tsi,tds(xidx).name);
                                            txt = fullfile(tti,tds(xidx).name);
                                            %sometimes connection errors lead
                                            %to flaky copying, will keep
                                            %checking sizes of files and trying
                                            %to copy until the source file and
                                            %dest file are the same size...
                                            %except only this checking for
                                            %files not directories
                                            xbytes = 1;
                                            ybytes = 0;
                                            cycle = 0;
                                            while xbytes ~= ybytes
                                                if cycle
                                                    disp([tds(xidx).name ' not copied properly, trying again'])
                                                end
                                                cpstr = ['! cp -ar ' txs ' ' txt];%prep command to copy it
                                                eval(cpstr)%execute copy
                                                if tds(xidx).isdir
                                                    xbytes = 1;
                                                    ybytes = 1;
                                                else %check that copy worked
                                                    xd = dir(txs);
                                                    yd = dir(txt);
                                                    xbytes = xd(1).bytes;
                                                    if ~isempty(yd)
                                                        ybytes = yd(1).bytes;
                                                    else
                                                        ybytes = 0;
                                                    end
                                                    cycle = cycle+1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end