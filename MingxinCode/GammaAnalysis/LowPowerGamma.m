basepath = cd;
[~,basename] = fileparts(cd);
load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Channels');
zthreshold = 0;
AllSpkPhases = cell(length(Channels),50,79);
load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_zthresh' num2str(zthreshold) '.mat']),'spkphases');
ZthreshSpkPhases = spkphases;
for ii = 1:length(Channels)
    load(fullfile(basepath,[basename '_PhaseLockingData1-625Hz_lfp' num2str(Channels(ii)) '_EachFreq.mat']),'spkphases');
    for jj = 1:size(spkphases,1)
        for kk = 1:size(spkphases,2)
            AllSpkPhases{ii,jj,kk} = spkphases{jj,kk};
            LowPowerSpkPhases{ii,jj,kk} = 
        end
    end
end


