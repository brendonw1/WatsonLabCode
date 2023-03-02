function REM_TstampsFromDigitalin
%
% REM_TstampsFromDigitalin
%
% Timestamps from the Intan board of digital inputs.
%
% USAGE
%   - Run from the .dat-containing folder
%   - Dependency: read_Intan_RHD2000_file_MOD_LB (modified from
%                 read_Intan_RHD2000_file, from Intan)
%
% OUTPUT: saved in session folder
%
% Bueno-Junior et al. (2023)

%% Use function from Intan website, with modifications
[DigitalinChannels,SamplFreq] = read_Intan_RHD2000_file_MOD_LB;



%% Also adapted from Intan website
FileInfo   = dir('digitalin.dat');
NumSamples = FileInfo.bytes/2; % uint16 = 2 bytes
FileID     = fopen('digitalin.dat','r');
DigWord    = fread(FileID,NumSamples,'uint16');fclose(FileID);



%% Channel loop
for ChannelIdx = length(DigitalinChannels):-1:1
    
    % Preserve channel names/order from RHD2000 interface
    Timestamps(ChannelIdx).ChannelName = ...
        DigitalinChannels(ChannelIdx).custom_channel_name;
    ChannelOrder = DigitalinChannels(ChannelIdx).native_order;
    
    % Detect shifts using diff
    DigWordShifts = [0;diff(bitand(DigWord,2^ChannelOrder)>0)];
    
    % Event onsets/offsets
    Timestamps(ChannelIdx).EventOnsets  = find(DigWordShifts==1);
    Timestamps(ChannelIdx).EventOffsets = find(DigWordShifts==-1);
end



%% Save
save([bz_BasenameFromBasepath(pwd) '.Timestamps.mat'],...
    'Timestamps','SamplFreq')
disp('saved timestamps')

end
