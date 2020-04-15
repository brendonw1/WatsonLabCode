function KilosortChannelShnanksWrite(basepath,clustering_path)

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);
if ~exist('clustering_path','var')
    clustering_path = fullfile(basepath,'Kilosort');
end


metadataname = fullfile(basepath,[basename, '.SessionMetadata.mat']);
sessinfoname = fullfile(basepath,[basename, '.sessionInfo.mat']);

if exist(metadataname,'file')
    load(metadataname)
    ChannelShankLUT = SessionMetadata.AnimalMetadata.ExtracellEphys.Channels.ChannelToGroupLookupTable.Table;
    ChannelShankLUT = ChannelShankLUT(:,2);
else
    ChannelShankLUT = [];
    load(sessinfoname)
    for ch = 1:sessionInfo.nChannels
        for a = 1:length(sessionInfo.spikeGroups.groups)
            if ismember(ch,sessionInfo.spikeGroups.groups{a})
                ChannelShankLUT(ch) = a;
            end
        end
    end
end
writeNPY(ChannelShankLUT, fullfile(clustering_path, 'channel_shanks.npy'));

    
    
    
    
    
    
% % disp('Converting to Klusters format')
% load('rez.mat')
% rez.ops.root = pwd;
% clustering_path = pwd;
% %     basename = rez.ops.basename;
% % [~,basename] = fileparts(rez.ops.fbinary);
% % rez.ops.fbinary = fullfile(pwd, [basename,'.dat']);
% % Kilosort2Neurosuite(rez)
% 
% writeNPY(rez.ops.kcoords, fullfile(clustering_path, 'channel_shanks.npy'));
% 
% % phy_export_units(clustering_path,basename);
    