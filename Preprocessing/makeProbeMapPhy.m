function [] = makeProbeMapPhy(basename)
%% this function takes an xml file with spike groups already assigned and 
%% generates *.prb files for each shank for spike detection/masking/clustering

%% IMPORTANT: this function ASSUMES that the order of the channels for each shank
%% in the spike groups map onto a specific geometrical arrangement of channels on the shank
%% starting from the top left recording site, and moving right then downward to make the 
%% nearest neighbor graph
% basename can be basename or a fullpath to a basename

if strcmp(basename(end-3),'.')% in case basename was given as a full file path to a specific file, like an .xml or .dat
    basename = basename(1:end-4);
end

parameters = LoadPar([basename '.xml']);
warning off

for shank = 1:length(parameters.SpkGrps)
% for shank = 1:1
    
    % make a folder for each directory
%     mkdir(num2str(shank));
    
    channels = parameters.SpkGrps(shank).Channels;
    c=1;
    for i=1:length(channels)-1
        for j=1
        l(c,:) = [channels(i),channels(i+j)];
        c=1+c;
        end
    end
    for i=1:length(channels)-2
        for j=2 
        l(c,:) = [channels(i),channels(i+j)];
        c=1+c;
        end
    end
    for i=1:length(channels)-3
        for j=3
        l(c,:) = [channels(i),channels(i+j)];
        c=1+c;
        end
    end
    list = l;

    if shank == 1;
        s=['channel_groups = {\n' num2str(shank) ': {\n'];
    else
        s=[s,'\n' num2str(shank) ': {\n'];
    end
    
    s=[s, '\t"channels": [\n' ];
    for i =1:length(channels)-1
        s=[s, '' num2str(channels(i)) ', ' ];
    end
    s=[s, '' num2str(channels(i+1))];
    s=[s, '],\n' ];

    s=[s, '\t"graph": [\n' ];
    for i =1:length(list)-1
        s=[s, '\t(' num2str(list(i,1)) ', ' num2str(list(i,2)) '),\n'];
    end
    s=[s, '\t(' num2str(list(i+1,1)) ', ' num2str(list(i+1,2)) ')\n'];
    s=[s, '\t],\n' ];
 
    s=[s, '\t"geometry": {\n' ];
    for i =1:length(channels)
        if mod(i,2)
           pn = -1;
        else
           pn = 1;
        end
    s=[s, '\t' num2str(channels(i)) ': [' num2str(pn*(-(20+1-i)*2)) ', ' num2str(-i*10) '], \n'];
    end
    s=[s, '\t},\n},\n' ];
    
end
s=[s, '}\n' ];

fid = fopen([basename '.prb'],'wt');
fprintf(fid,s);
fclose(fid); 
%     fid = fopen([num2str(shank) '/' num2str(shank) '.prb'],'wt');
%     fprintf(fid,s);
%     fclose(fid); 

% write .prm file as well
% fid = fopen('generic_phy.prm');
% i = 1;
% tline = fgetl(fid);
% generic{i} = tline;
% while ischar(tline)
%     i = i+1;
%     tline = fgetl(fid);
%     generic{i} = tline;
% end
% fclose(fid);
% % change the location of the *.dat file in the *.prm file
% %     generic{4} = ;
% fid = fopen([folder '/' num2str(shank) '/' xmlfile(1:end-4) '_sh' num2str(shank) '.prm'],'wt');
% ss = ['EXPERIMENT_NAME = ''' folder '_sh' num2str(shank) '''\n',...
%     'RAW_DATA_FILES=[''' pwd '/' xmlfile(1:end-4) '.dat'  ''']\n',...
%     'PRB_FILE = ''' num2str(shank) '.prb''\n'];
% fprintf(fid,ss);
% for i = 1:numel(generic)
% if generic{i+1} == -1
%     fprintf(fid,'%s', generic{i});
%     break
% else
%     fprintf(fid,'%s\n', generic{i});
% end
% end
% clear s l list c ss
% % end
% 
% 
