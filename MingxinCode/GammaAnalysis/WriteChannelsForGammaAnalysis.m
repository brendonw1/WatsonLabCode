function [Shanks,Channels] = WriteChannelsForGammaAnalysis(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

prompt = 'LFP Shanks:';
Shanks = input(prompt);

prompt = 'LFP Channels (in Neuroscope):';
Channels = input(prompt);
Channels = Channels + 1;
save(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Shanks','Channels');
end