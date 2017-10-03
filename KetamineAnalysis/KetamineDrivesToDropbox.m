function KetamineDrivesToDropbox(basepath,basename)
%copies specific files from ketamine basepaths to corresponding paths in
%Dropbox/Data/KetamineDataset
% B Watson September 2016

strs = {'_DatInfo.mat'};
% strs = {'-states.mat';
%     '.eegstates.mat';
%     '.xml';
%     '_BasicMetaData.mat';
%     '_CellClassificationOutput.mat';
%     '_CellIDs.mat';
%     '_ChannelAnatomy.mat';
%     '_ClusteringNotes.mat';
%     '_DatInfo.mat';
%     '_EIRatio.mat';
%     '_funcsynapsesMoreStringent.mat';
%     '_Header.m';
%     '_HighLowFRRatio.mat';
%     '_Instabilities.mat';
%     '_InstabilityGui.fig';
%     '_Motion.mat';
%     '_SecondsFromLightsOn.mat';
%     '_SpikeTransferPer1MinuteAll.mat';
%     '_SpikeTransferPer1MinuteE.mat';
%     '_SpikeTransferPer1MinuteI.mat';
%     '_SSubtypes.mat'
%     '_StateRates.mat'};
if ~exist(basepath,'dir')
    disp(['Cannot find ' basepath])
else
    %% copy files specified above in strs
    dr = getdropbox;
    destdir = fullfile(dr,'/Data/KetamineDataset/',basename);
    if ~exist(destdir,'dir')
        mkdir(destdir)
    end
    for a = 1:length(strs)
        sfname = fullfile(basepath,[basename,strs{a}]);
        if exist(sfname,'file')
            dfname = fullfile(destdir,[basename,strs{a}]);
            cpstring = ['! rsync -avr ' sfname ' ' dfname];
            eval(cpstring);
        end
    end

    %% copy spiking data
%     sfname = fullfile(basepath,[basename,'_SStable.mat']);
%     if exist(sfname,'file')
%         dfname = fullfile(destdir,[basename,'_SStable.mat']);
%         cpstring = ['! rsync -avr ' sfname ' ' dfname];
%         eval(cpstring);
%     else
%         sfname = fullfile(basepath,[basename,'.clu.1']);
%         if exist(sfname,'file')
%             sfname = fullfile(basepath,[basename,'.{clu,res,fet,spk}.*']);
%             dfname = fullfile(destdir);
%             cpstring = ['! rsync -avr ' sfname ' ' dfname];
%             eval(cpstring);
%         end
%     end
% 
%     %% Copy .txt files
%     sfname = fullfile(basepath,['*.txt']);
%     dfname = fullfile(destdir);
%     cpstring = ['! rsync -avr ' sfname ' ' dfname];
%     eval(cpstring);
end    