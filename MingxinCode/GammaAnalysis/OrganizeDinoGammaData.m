% function OrganizeDinoGammaData
% folders = dir('Dino*');
% for i=1:length(folders)
%     ChannelAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_ChannelAnatomy.csv']));
%     SpikeGroupAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_SpikeGroupAnatomy.csv']));
%     SplitName = strsplit(folders(i).name,'_');
%     CortexRegion = SplitName(3);
%     save(fullfile(folders(i).name,[folders(i).name '_BasicMetaData.mat']),'CortexRegion','-append');
%
%     GoodGammaChannels = ChannelAnatomy(ismember(ChannelAnatomy(:,2),CortexRegion),1);
%     GoodGammaShanks = SpikeGroupAnatomy(ismember(SpikeGroupAnatomy(:,2),CortexRegion),1);
%
%     save(fullfile(folders(i).name,[folders(i).name '_GoodGammaChannels.mat']),'GoodGammaChannels','GoodGammaShanks');
% end
% end



function OrganizeOtherGammaData
% CortexRegionSummary = [];
folders = dir;
folders = folders(3:29);
% for i=1:length(folders)
%     if ~strcmp(folders(i).name,'.') || ~strcmp(folders(i).name,'..')
%         ChannelAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_ChannelAnatomy.csv']));
%         Regions = unique(ChannelAnatomy(:,2));
%         disp(Regions);
%         prompt = 'Which is the cortex region? Number:';
%         CtxNum = input(prompt);
%         CortexRegion = Regions(CtxNum);
%         SpikeGroupAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_SpikeGroupAnatomy.csv']));
% %         SplitName = strsplit(folders(i).name,'_');
%         %     CortexRegion = SplitName(3);
%         save(fullfile(folders(i).name,[folders(i).name '_BasicMetaData.mat']),'CortexRegion','-append');
%
%         GoodGammaChannels = ChannelAnatomy(ismember(ChannelAnatomy(:,2),CortexRegion),1);
%         GoodGammaShanks = SpikeGroupAnatomy(ismember(SpikeGroupAnatomy(:,2),CortexRegion),1);
%
%         save(fullfile(folders(i).name,[folders(i).name '_GoodGammaChannels.mat']),'GoodGammaChannels','GoodGammaShanks');
%
%         CortexRegionSummary{end+1} = [folders(i).name CortexRegion];
%     end
% end
% end



%% Change Channel/SpikeGroup Anatomy
% for i = 1:3
%     ChannelAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_ChannelAnatomy.csv']));
%     SpikeGroupAnatomy = read_mixed_csv(fullfile(folders(i).name,[folders(i).name '_SpikeGroupAnatomy.csv']));
%     for j = 1:length(ChannelAnatomy(:,2))
%         if strcmp(ChannelAnatomy{j,2},'mPFC')
%             ChannelAnatomy{j,2} = 'OFC';
%         end
%     end
%     cell2csv(fullfile(folders(i).name,[folders(i).name '_ChannelAnatomy.csv']),ChannelAnatomy);
%     for j = 1:length(SpikeGroupAnatomy(:,2))
%         if strcmp(SpikeGroupAnatomy{j,2},'mPFC')
%             SpikeGroupAnatomy{j,2} = 'OFC';
%         end
%     end
%     cell2csv(fullfile(folders(i).name,[folders(i).name '_SpikeGroupAnatomy.csv']),SpikeGroupAnatomy);
% end


%% Check if lfp is restricted to GoodSleepInterval

% for i = 4:length(folders)
%     load(fullfile(folders(i).name,[folders(i).name '_BasicMetaData.mat']),'bmd');
%     load(fullfile(folders(i).name,[folders(i).name '_GoodSleepInterval.mat']),'GoodSleepInterval');
%     gend = GoodSleepInterval.intervalSetFormat.stop;
%     gsibytes = gend*bmd.Par.nChannels*2*1250;
%     lfpdir = dir(fullfile(folders(i).name,[folders(i).name '.lfp']));
%     if round(lfpdir.bytes) ~= round(gsibytes)
%         disp([folders(i).name '  ' num2str(lfpdir.bytes) '  ' num2str(gsibytes)]);
%     end
% end
% 
% 
% 
% 
% eegpath = findsessioneeglfpfile(obasepath,obasename);
% % eval(['! cp ' eegpath ' /mnt/brendon4/ForCRCNS/Data/' basename '/'])
% gsibytes = gend*Par.nChannels*2*1250;
% eval(['! head -c ' num2str(gsibytes) ' ' eegpath ' > /proraid/Bogey/Bogey_012615/' obasename '/' obasename '.eeg'])
% clear gsibytes bmd
% 
% eval(['! cp ' eegpath(1:end-3) 'xml /proraid/Bogey/Bogey_012615/' obasename '/' obasename '.xml'])



%% cut res,clu,fet,spk files according to GoodSleepInterval for Dino [15 16 18 20 21 22]
% for i = 20; % 23:length(folders)
%     basename = folders(i).name;
%     Par = LoadPar(fullfile(basename,[basename '.xml']));
%     load(fullfile(basename,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');
%     gstart = GoodSleepInterval.intervalSetFormat.start;
%     gend = GoodSleepInterval.intervalSetFormat.stop;
%     for j = [1:Par.nElecGps]
%         resfile = fopen(fullfile(basename,[basename(1:11) '.res.' num2str(j)]),'r');
%         res = fscanf(resfile,'%d');
%         fclose(resfile);
%         res_new_index = (res<=gend*Par.SampleRate).*(res>=gstart*Par.SampleRate);
%         res_new = res(res_new_index == 1);
%         
%         clu = LoadClu(fullfile(basename,[basename(1:11) '.clu.' num2str(j)]));
%         clu_new = clu(res_new_index==1);
%         nClusters_new = max(clu_new);
%         
%         fet = LoadFeatures(fullfile(basename,[basename(1:11) '.fet.' num2str(j)]));
%         fet_new = fet(res_new_index==1,:);
%         
%         spk = LoadSpikeWaveforms(fullfile(basename,[basename(1:11) '.' num2str(j)]),length(Par.SpkGrps(j).Channels),Par.SpkGrps(j).nSamples);
%         spk_new = spk(res_new_index==1,:,:);
%         
%         if length(res_new)<length(res)
%             movefile(fullfile(basename,[basename(1:11) '.res.' num2str(j)]), fullfile(basename,[basename(1:11) '.res.' num2str(j) '_old']));            
%             resfile_new=fopen(fullfile(basename,[basename(1:11) '.res.' num2str(j)]),'w');
%             fprintf(resfile_new,'%.0f\n',res_new);
%             fclose(resfile_new);            
%         end
%         
%         if length(clu_new)<length(clu)
%             movefile(fullfile(basename,[basename(1:11) '.clu.' num2str(j)]), fullfile(basename,[basename(1:11) '.clu.' num2str(j) '_old']));
%             clufile_new=fopen(fullfile(basename,[basename(1:11) '.clu.' num2str(j)]),'w');
%             fprintf(clufile_new,'%.0f\n',[nClusters_new;clu_new]);
%             fclose(clufile_new);
%         end
%         
%         if length(fet_new(:,1))<length(fet(:,1))
%             movefile(fullfile(basename,[basename(1:11) '.fet.' num2str(j)]), fullfile(basename,[basename(1:11) '.fet.' num2str(j) '_old']));
%             SaveFeatures(fullfile(basename,[basename(1:11) '.fet.' num2str(j)]),fet_new);
%         end
%         
%         if size(spk_new,1)<size(spk,1)
%             movefile(fullfile(basename,[basename(1:11) '.spk.' num2str(j)]), fullfile(basename,[basename(1:11) '.spk.' num2str(j) '_old']));
%             spkfile_new=fopen(fullfile(basename,[basename(1:11) '.spk.' num2str(j)]),'w');
%             fwrite(spkfile_new,spk_new,'int16');
%             fclose(spkfile_new);
%         end
%         clear res resfile res_new resfile_new res_new_index clu clu_new clufile_new nClusters_new fet fet_new spk spk_new spkfile_new
%     end
%     delete(fullfile(basename,'*_old'));
% end

%     [T,G,Map,Par] = LoadCluRes(folders(i).name);

%% fix spk files
for i = [16,20:22];
    basename = folders(i).name;
    load(fullfile(basename,[basename '_BasicMetaData.mat']),'bmd');
    Par = bmd.Par;
    for j = 1:length(Par.SpkGrps)
        movefile(fullfile(basename,[basename(1:11) '.spk.' num2str(j)]), fullfile(basename,[basename(1:11) '.spk.' num2str(j) '_old']));
        waveformG = LoadBinary(fullfile(basename,[basename(1:11) '.spk.' num2str(j) '_old']));
        waveformG = reshape(waveformG, [],length(Par.SpkGrps(j).Channels),Par.SpkGrps(j).nSamples);
        waveformG = permute(waveformG, [2,3,1]);
        spkfile_new=fopen(fullfile(basename,[basename(1:11) '.spk.' num2str(j)]),'w');
        fwrite(spkfile_new,waveformG,'int16');
        fclose(spkfile_new);
    end
    delete(fullfile(basename,'*_old'));
end

%%
for i = [4:13,25];
    basename = folders(i).name;
    load(fullfile(basename,[basename '_BasicMetaData.mat']),'bmd');
    Par = bmd.Par;
    for j = 1:length(Par.SpkGrps)
        movefile(fullfile(basename,[basename '.spk.' num2str(j)]), fullfile(basename,[basename '.spk.' num2str(j) '_old']));
        waveformG = LoadBinary(fullfile(basename,[basename '.spk.' num2str(j) '_old']));
        waveformG = reshape(waveformG, [],length(Par.SpkGrps(j).Channels),Par.SpkGrps(j).nSamples);
        waveformG = permute(waveformG, [2,3,1]);
        spkfile_new=fopen(fullfile(basename,[basename '.spk.' num2str(j)]),'w');
        fwrite(spkfile_new,waveformG,'int16');
        fclose(spkfile_new);
    end
    delete(fullfile(basename,'*_old'));
end

