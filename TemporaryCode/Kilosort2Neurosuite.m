function Kilosort2Neurosuite(rez)
% Converts KiloSort output (.rez structure) to Neurosuite files: fet,res,clu,spk files.
% 
% Inputs:
%   rez -  rez structure from Kilosort
%
% By Peter Petersen 2018
% Based on the GPU enable filter from Kilosort and fractions from Brendon
% Watson's code for saving Neurosuite files.
% 
% 1) Waveforms are extracted from the dat file in fractions via GPU enabled
% filters. 
% 2) Features are calculated in parfor loops.
% 

tic
spikeTimes = uint64(rez.st3(:,1)); % uint64
spikeTemplates = uint32(rez.st3(:,2)); % uint32 % template id for each spike
kcoords = rez.ops.kcoords;
basename = rez.ops.basename;

Nchan = rez.ops.Nchan;
samples = rez.ops.nt0;

templates = zeros(Nchan, size(rez.W,1), rez.ops.Nfilt, 'single');
for iNN = 1:rez.ops.Nfilt
   templates(:,:,iNN) = squeeze(rez.U(:,iNN,:)) * squeeze(rez.W(:,iNN,:))'; 
end
amplitude_max_channel = [];
for i = 1:size(templates,3)
    [~,amplitude_max_channel(i)] = max(range(templates(:,:,i)'));
end

template_kcoords = kcoords(amplitude_max_channel);
kcoords2 = unique(template_kcoords);
ia = [];
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    disp(['-Loading data for spike group ', num2str(kcoords3)])
    template_index = find(template_kcoords == kcoords3);
    ia{i} = find(ismember(spikeTemplates,template_index));
end

rez.ia = ia;
toc
disp('Saving .clu files to disk (cluster indexes)')
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    disp(['-Saving .clu file for group ', num2str(kcoords3)])
    tclu = spikeTemplates(ia{i});
    tclu = cat(1,length(unique(tclu)),double(tclu));
    cluname = fullfile([basename '.clu.' num2str(kcoords3)]);
    fid=fopen(cluname,'w');
    fprintf(fid,'%.0f\n',tclu);
    fclose(fid);
    clear fid
end
toc

disp('Saving .res files to disk (spike times)')
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    tspktimes = spikeTimes(ia{i});
    disp(['-Saving .res file for group ', num2str(kcoords3)])
    resname = fullfile([basename '.res.' num2str(kcoords3)]);
    fid=fopen(resname,'w');
    fprintf(fid,'%.0f\n',tspktimes);
    fclose(fid);
    clear fid
end
toc

disp('Extracting waveforms')
waveforms_all = Kilosort_ExtractingWaveforms(rez);
toc

disp('Saving .spk files to disk (waveforms)')
for i = 1:length(kcoords2)
    disp(['-Saving .spk for group ', num2str(kcoords2(i))])
    fid=fopen([basename,'.spk.',num2str(kcoords2(i))],'w'); 
    fwrite(fid,waveforms_all{i}(:),'int16');
    fclose(fid);
end
toc

disp('Computing PCAs')
% Starting parpool if stated in the Kilosort settings
if (rez.ops.parfor & isempty(gcp('nocreate'))); parpool; end

for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    disp(['-Computing PCAs for group ', num2str(kcoords3)])
    PCAs_global = zeros(3,sum(kcoords==kcoords3),length(ia{i}));
    waveforms = waveforms_all{i};
    
    waveforms2 = reshape(waveforms,[size(waveforms,1)*size(waveforms,2),size(waveforms,3)]);
    wranges = int64(range(waveforms2,1));
    wpowers = int64(sum(waveforms2.^2,1)/size(waveforms2,1)/100);
    
    % Calculating PCAs in parallel if stated in ops.parfor
    if isempty(gcp('nocreate'))
        for k = 1:size(waveforms,1)
            PCAs_global(:,k,:) = pca(zscore(permute(waveforms(k,:,:),[2,3,1]),[],2),'NumComponents',3)';
        end
    else
        parfor k = 1:size(waveforms,1)
            PCAs_global(:,k,:) = pca(zscore(permute(waveforms(k,:,:),[2,3,1]),[],2),'NumComponents',3)';
        end
    end
    disp(['-Saving .fet files for group ', num2str(kcoords3)])
    PCAs_global2 = reshape(PCAs_global,size(PCAs_global,1)*size(PCAs_global,2),size(PCAs_global,3));
    factor = (2^15)./max(abs(PCAs_global2'));
    PCAs_global2 = int64(PCAs_global2 .* factor');
    % SaveFetIn([basename,'.fet.',num2str(kcoords3)], double([PCAs_global,wranges,wpowers,spikeTimes(ia{i})]));
    
    fid=fopen([basename,'.fet.',num2str(kcoords3)],'w');
    Fet = double([PCAs_global2;wranges;wpowers;spikeTimes(ia{i})']);
    nFeatures = size(Fet, 1);
    formatstring = '%d';
    for ii=2:nFeatures
        formatstring = [formatstring,'\t%d'];
    end
    formatstring = [formatstring,'\n'];

    fprintf(fid, '%d\n', nFeatures);
    fprintf(fid,formatstring,Fet);
    fclose(fid);
end
toc
disp('Complete!')
