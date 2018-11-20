<<<<<<< HEAD
function DeleteBadClustersNeurosuite(basepath,shanknum,clunum)
% Reads spk/res/fet/clu and deletes from all of those the spike data from
% the cluster with id of clunum in the spike group specified shanknum.  If
% shanknum=10 and clunum=15 - Cluster15 in basename.clu.10 is deleted.
%% Prepare
basename = bz_BasenameFromBasepath(basepath);

cluname = fullfile(basepath,[basename,'.clu.',num2str(shanknum)]);
% resname = fullfile(basepath,[basename,'.res.',num2str(shanknum)]);
% fetname = fullfile(basepath,[basename,'.fet.',num2str(shanknum)]);
% spkname = fullfile(basepath,[basename,'.spk.',num2str(shanknum)]);
% 
% sessionInfo = bz_getSessionInfo(basepath, 'noPrompts', true);
% nSamples = sessionInfo.spikeGroups.nSamples(shanknum);
% chansPerSpikeGrp = length(sessionInfo.spikeGroups.groups{shanknum});

%% Load stuff
clu = load(cluname);
clu = clu(2:end); % toss the first sample to match res/spk files
% res = load(resname);
% fet = LoadFeatures(fetname);
% %spk
% fid = fopen(spkname,'r');
% wav = fread(fid,[1 inf],'int16=>int16');
% fclose(fid);
% try %bug in some spk files... wrong number of samples?
%     wav = reshape(wav,chansPerSpikeGrp,nSamples,[]);
% catch
%     error(['something is wrong with your .spk file, no waveforms.',...
%         ' Use ''getWaveforms'', false while you get that figured out.'])
% end
% wav = permute(wav,[3 1 2]);

%% Save old ones for safety
% newdirname = fullfile(basepath,['Cluster' num2str(shanknum) 'BeforeRemovalOf' num2str(clunum)]);
% mkdir(newdirname)
% movefile(cluname,fullfile(newdirname,[basename,'.clu.',num2str(shanknum)]));
% movefile(resname,fullfile(newdirname,[basename,'.res.',num2str(shanknum)]));
% movefile(fetname,fullfile(newdirname,[basename,'.fet.',num2str(shanknum)]));
% movefile(spkname,fullfile(newdirname,[basename,'.spk.',num2str(shanknum)]));
copyfile(cluname,[cluname '_Orig'])

%% Delete spikes from bad clusters
for idx = 1:length(clunum)
    badidxs = clu==clunum(idx);
    clu(badidxs) = 0;
% res(badidxs) = [];
% fet(badidxs,:) = [];
% wav(badidxs,:,:) = [];
% wav = permute(wav,[2 3 1]);
end

%% Write new versions
%clu
clu = cat(1,length(unique(clu)),double(clu));
fid=fopen(cluname,'w'); 
fprintf(fid,'%.0f\n',clu);
fclose(fid);
clear fid
% 
% %res
% fid=fopen(resname,'w'); 
% fprintf(fid,'%.0f\n',res);
% fclose(fid);
% clear fid
% 
% %fet
% SaveFetIn(fetname,fet);
% 
% %spk
% fid=fopen(spkname,'w'); 
% fwrite(fid,wav(:),'int16');
% fclose(fid);
% clear fid 

function SaveFetIn(FileName, Fet, BufSize);

if nargin<3 | isempty(BufSize)
    BufSize = inf;
end

nFeatures = size(Fet, 2);
formatstring = '%d';
for ii=2:nFeatures
  formatstring = [formatstring,'\t%d'];
end
formatstring = [formatstring,'\n'];

outputfile = fopen(FileName,'w');
fprintf(outputfile, '%d\n', nFeatures);

if isinf(BufSize)
    fprintf(outputfile,formatstring,round(Fet'));
else
    nBuf = floor(size(Fet,1)/BufSize)+1;
    
    for i=1:nBuf 
        BufInd = [(i-1)*nBuf+1:min(i*nBuf,size(Fet,1))];
        fprintf(outputfile,formatstring,round(Fet(BufInd,:)'));
    end
end
=======
max_zscored_val = 5;

lfp = bz_GetLFP([4,174]);
wavespec = bz_WaveSpec(lfp,'frange',[0.5 200],'nfreqs',50,'roundfreqs',true,'saveMatPath',cd,'MatNameExtraText','4&174');

dz = zscore(real(wavespec.data(:,:,1))',[],2);

% cap extreme values
dz(dz>max_zscored_val) = max_zscored_val;
dz(dz<-max_zscored_val) = -max_zscored_val;

figure;imagesc('XData',wavespec.timestamps,'YData',wavespec.freqs,'CData',dz);
axis xy tight
colorbar

>>>>>>> master
