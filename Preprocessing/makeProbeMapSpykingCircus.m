function [] = makeProbeMapSpykingCircus(VerticalUmBetweenSites,HorizontalUmBetweenSites,HorizontalUmBetweenShanks,InteractionUms,basepath, basename)
%% this function takes an xml file with spike groups already assigned and 
%% generates *.prb files for each shank for spike detection/masking/clustering

% IMPORTANT: this function ASSUMES that the order of the channels for each shank
% in the spike groups map onto a specific geometrical arrangement of channels on the shank
% starting from the top left recording site, and moving right then downward to make the 
% nearest neighbor graph
% based on Buzsaki5 shank/64 site probe with 17.32 um distance
% horizontally between sites, 20mm vertically, shanks separated by 200um
% https://drive.google.com/file/d/0B0WCzFWl7GCXSE9NVWUyN1ZPN1NhU0dkZUNDR3JVY1Ayamdn/view?usp=sharing
%
% The geometry details matter here since there is a radius set for
% interaction
%
% Brendon Watson 2016

if ~exist('VerticalUmBetweenSites','var')
    VerticalUmBetweenSites = 20;
end
if ~exist('HorizontalUmBetweenSites','var')
    HorizontalUmBetweenSites = 17.32;
end
if ~exist('HorizontalUmBetweenShanks','var')
    HorizontalUmBetweenShanks = 200;
end
if ~exist('InteractionUms','var')
    InteractionUms = 150;
end
if ~exist('basepath','var')
    basepath = cd;
end
if ~exist('basename','var')
    d = dir([basepath,'/*.xml']);
    basename = d(1).name(1:end-4);
end



parameters = LoadParameters(fullfile(basepath,[basename '.xml']));
warning off
if exist(fullfile(basepath,'bad_channels.txt'),'file')
    badchannels = ReadBadChannels(basepath);
else
    badchannels = [];
end
spkgroupnums = matchSpkGroupsToAnatGroups(parameters);

%note, not skipping bad channels here
channels = 0:parameters.nChannels-1;%bad channels: could do setdiff here

s=['total_nb_channels = ' num2str(length(channels)) '\n',...
    'radius = ' num2str(InteractionUms) ' \n',...%radius 150 for exclusion of interaction between electrodes
    '\n',...
    'channel_groups = {\n',...
    '\t' num2str(1) ': {\n',...%just one spike group, separated by shanks exceeding radius
    '\t\t''channels'': list(range(total_nb_channels)), \n',... %could do num2str(channels?)
    '\t\t''graph'' : [], \n',...
    '\t\t\t''geometry'': { \n'];

x_add = -HorizontalUmBetweenShanks;%for 200um shank spacing
for shi = 1:length(parameters.SpkGrps)
    x_add = x_add+HorizontalUmBetweenShanks;
    s_channels = parameters.SpkGrps(shi).Channels;
    for chi = 1:length(s_channels);
        tchan = s_channels(chi);
        %if not badchannel here
        if mod(chi,2)
            x = x_add - HorizontalUmBetweenSites/2; %based on buzsaki 5 shank
        else
            x = x_add + HorizontalUmBetweenSites/2;
        end
        y = (chi-1) * VerticalUmBetweenSites;
        
        s = [s, '\t\t\t\t' num2str(tchan) ' : [' num2str(x) ', ' num2str(y) '],\n'];
    end
end

s = [s, '\t\t\t}\n',...
    '\t\t}\n',...
    '\t}'];

fid = fopen(fullfile(basepath,[basename '.prb']),'wt');
fprintf(fid,s);
fclose(fid); 

%% Params
copyfile(fullfile(getdropbox,'MATLABwork','SpykingCircusDefaultParams.params'),fullfile(basepath,[basename,'.params']))
