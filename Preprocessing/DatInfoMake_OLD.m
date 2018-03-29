function DatInfo = DatInfoMake(basepath,basename)
% Store basic info about the original dat files: names and bytes

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;   
end


%% if _DatInfo.mat already exists, leave the function
% if exist(fullfile(basepath,[basename '_DatInfo.mat']),'file')
%     return
% end

%% 
recordingbytes = [];
recordingnames = {};

d = dir(fullfile(basepath,'*.meta'));
if ~isempty(d);%if from an amplipex
    par = bz_getSessionInfo(fullfile(basepath,[basename '.xml']));
    for a = 1:length(d);
%             nchans = ReadMetaAspects(fullfile(basepath,d(a).name),'numchans')
        recordingbytes(end+1) = str2num(ReadMetaAspects(fullfile(basepath,d(a).name),'filebytes'));
        recordingnames{end+1} = d(a).name;
    end
else %if intan, use the length of time.dat, which is 32 bit for each timepoint... divide by 2 to get bytes of 16bit dat
    par = LoadParameters(fullfile(basepath,[basename '.xml']));
%     d = dir([basename(1:end-3) '*/']);%if I record over new year's eve I'll have to handle it :)
    d = dir([basepath,filesep]);%if I record over new year's eve I'll have to handle it :)
    for a = length(d):-1:1
        if ~d(a).isdir
            d(a) = [];
        elseif strcmp(d(a).name,'.') | strcmp(d(a).name,'..')
            d(a) = [];
        end
    end
    for a = 1:length(d)
        td = dir(fullfile(basepath,d(a).name,'time.dat'));
        recordingbytes(end+1) = td.bytes/2*par.nChannels;
        recordingnames{end+1} = d(a).name;
    end
end

recordingseconds = recordingbytes/par.nChannels/2/par.rates.wideband;

save(fullfile(basepath,[basename '_DatInfo.mat']),'recordingbytes','recordingseconds','recordingnames')
DatInfo = v2struct(recordingbytes, recordingseconds, recordingnames);

%                     recordingbytes(end+1) = t.bytes;
%                     recordingnames(end+1) = d(a).name;
%                 end
%             end
%         end
%     end
% end
% if isempty(datpaths)
%     disp('No .dats found in subfolders')
% %             continue
% end
% cs = strjoin(datpaths);
% catstring = ['! cat ', cs, ' > ',fullfile(dirpath,[basename,'.dat'])];
% 
% % for some reason have to cd to supradirectory 
% origdir = cd;
% cd (dirpath)
% eval([catstring])
% cd (origdir)
% t = dir(fullfile(dirpath,[basename,'.dat']));
% if t.bytes ~= sum(recordingbytes)
%     error('dat size not right')
%     return
% end
% 
% save(fullfile(dirpath,[basename '_DatInfo.mat']),'recordingbytes','recordingnames')
% eval(['! neuroscope ' fullfile(dirpath,[basename,'.dat']) ' &'])
