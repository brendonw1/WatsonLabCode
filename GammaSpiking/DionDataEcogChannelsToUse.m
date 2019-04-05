function DionDataEcogChannelsToUse(basepath,basename)

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

bc = ReadBadChannels(basepath);

par = LoadPar(fullfile(basepath,[basename '.xml']));

UseChannels = [];
for a = 1:length(par.SpkGrps);
    tc = par.SpkGrps(a).Channels;
    tc(find(ismember(tc,bc))) = [];%exclude bad channels
    if length(tc)>4
        tuc = tc;
    else
        tuc = tc(1);
    end
    UseChannels = cat(2,UseChannels,tuc);
end

VectorToText(UseChannels,fullfile(basepath,'EEGChannelsToUse.txt'));
