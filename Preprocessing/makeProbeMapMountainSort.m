function [] = makeProbeMapMountainSort(basepath, basename)
%% this function takes an xml file with spike groups already assigned and 
%% generates *.prb files for each shank for spike detection/masking/clustering

% IMPORTANT: this function ASSUMES that the order of the channels for each shank
% in the spike groups map onto a specific geometrical arrangement of channels on the shank
% starting from the top left recording site, and moving right then downward to make the 
% nearest neighbor graph
% based on Buzsaki5 shank/64 site probe with 17.32 mm distance
% horizontally between sites, 20mm vertically, shanks separated by 200um
% https://drive.google.com/file/d/0B0WCzFWl7GCXSE9NVWUyN1ZPN1NhU0dkZUNDR3JVY1Ayamdn/view?usp=sharing
%
% The geometry details matter here since there is a radius set for
% interaction
%
% Brendon Watson 2016

if ~exist('basepath','var')
    basepath = cd;
end
if ~exist('basename','var')
    d = dir([basepath,'/*.xml']);
    basename = d(1).name(1:end-4);
end

%% Change based on probe type!!
% Buzsaki5shank
% verticalspacing = 20;
% horizontalspacing = 17.32;
% intershankspacing = 200;

% Buzsaki256
% verticalspacing = 50;
% horizontalspacing = 0;
% intershankspacing = 200;

% Linear32Site w juxta
% verticalspacing = 25;
% horizontalspacing = 50;
% intershankspacing = 100;

% Buzsaki32/64-type spacing
verticalspacing = 20;
horizontalspacing = 20;%this is approximate
intershankspacing = 200;


%%
parameters = LoadPar(fullfile(basepath,[basename '.xml']));
warning off
if exist(fullfile(basepath,'bad_channels.txt'),'file')
    badchannels = ReadBadChannels(basepath);
else
    badchannels = [];
end
spkgroupnums = matchSpkGroupsToAnatGroups(parameters);

%note, not skipping bad channels here
channels = 0:parameters.nChannels-1;%bad channels: could do setdiff here

x_add = -intershankspacing;%for 200um shank spacing
chcoords = nan(length(channels),2);
for shi = 1:length(parameters.SpkGrps)
    x_add = x_add+intershankspacing;
    s_channels = parameters.SpkGrps(shi).Channels;
    for chi = 1:length(s_channels);
        tchan = s_channels(chi);
        %if not badchannel here
        if mod(chi,2)
            x = x_add - horizontalspacing/2; %based on buzsaki 5 shank
        else
            x = x_add + horizontalspacing/2;
        end
        y = (chi-1) * verticalspacing;
        
        chcoords(tchan+1,1) = x;
        chcoords(tchan+1,2) = y;
    end
end

csvwrite(fullfile(basepath,[basename '_ChannnelOrderMS.csv']),chcoords)
% disp([basename '_ChannnelOrderMS.csv'] ' created')
1;
