function [reMapped,baseMap] = channelReMapping(data,probeType)

% Re-maps channels from 64-electrode linear shank recordings
% (Cambridge NeuroTech H3 or NeuroNexus H64LP).
%
%
%
% INPUT ___________________________________________________________________
% - data: voltage samples and channels in dimensions 1 and 2 respectively.
% - probeType: 'CambridgeH3' or 'NeuroNexusH64LP'.
%
%
%
% OUTPUT __________________________________________________________________
% - reMapped. Same dimensions of data. Channels now follow the actual
%   anatomy (channel 1: dorsal; channel 64: ventral).
% - baseMap (optional). Cell array describing
%   probeElectrode/IntanConnector relationships. Column 1 sorts
%   electrodes in the proximal-distal order given by the manufacturer.
%   Column 2 is the map from which the main output (reMapped) is obtained.
%
%
%
% LSBuenoJr _______________________________________________________________



%% Electrode/connector table for internal use in this script (also an
% optional output).
switch probeType
    case 'CambridgeH3'
        CambrElectr = [26;35;33;24;37;28;41;39;27;40;23;36;38;25;34;21;...
                       22;43;30;20;45;29;17;50;48;47;18;32;46;19;42;44;...
                       12;53;4;14;51;3;15;1;31;49;16;2;52;13;56;54;...
                       8;61;63;10;59;6;55;57;5;58;9;62;60;7;64;11];

        IntanConn   = [22;13;15;24;11;20;7;9;21;8;25;12;10;23;14;27;...
                       26;5;18;28;3;19;31;62;0;1;30;16;2;29;6;4;...
                       36;59;44;34;61;45;33;47;17;63;32;46;60;35;56;58;...
                       40;51;49;38;53;42;57;55;43;54;39;50;52;41;48;37];

        baseMap     = [{'CambrElectr'};...
            num2cell(CambrElectr)];

        baseMap     = [baseMap [{'IntanConn'};...
            num2cell(IntanConn)]];

    case 'NeuroNexusH64LP'
        NexusElectr = (64:-1:1)';
        
        IntanConn   = [15;14;13;12;11;10;9;8;7;6;5;4;3;2;1;0;...
                       30;31;28;26;27;24;22;23;20;18;19;16;17;21;25;29;...
                       35;39;43;47;46;45;44;42;41;40;38;37;36;34;33;32;...
                       62;63;60;61;58;59;56;57;54;55;52;53;50;51;48;49];

        baseMap     = [{'NexusElectr'};...
            num2cell(NexusElectr)];

        baseMap     = [baseMap [{'IntanConn'};...
            num2cell(IntanConn)]];
end



%% Main output
reMapped          = zeros(size(data));
for i             = 1:length(IntanConn)
    reMapped(:,i) = data(:,IntanConn(i)+1);
end

end