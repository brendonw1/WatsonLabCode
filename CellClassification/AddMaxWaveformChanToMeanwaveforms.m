function AddMaxWaveformChanToMeanwaveforms(basepath,basename)
% takes out output of BWCellClassificaiton and appends the channel index
% numbers of the max channels for each unit.
% Brendon Watson 2016

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

load(fullfile(basepath,[basename,'_MeanWaveforms.mat']),'MeanWaveforms')
par = LoadPar(fullfile(basepath,[basename '.xml']));

sOld = 0;
for a = 1:length(MeanWaveforms.shanks);%for each cell
    s = MeanWaveforms.shanks(a);
    if s ~= sOld
        shankcellidx = 1;
    else
        shankcellidx = shankcellidx + 1;
    end
    twaves = MeanWaveforms.AllWaves{s}(:,:,shankcellidx);
    [~,tmaxwaveidx] = max(abs(max(twaves,[],2)-min(twaves,[],2)));%this is the channel within the shank
    tshankchans = par.SpkGrps(s).Channels;
    
    MaxWaveChannelIdxsB0(a) = tshankchans(tmaxwaveidx);
    
    % manual verification by plotting
    plotting = 0;
    if plotting
        if ~isempty(twaves)
            figure;plot(twaves(1,:)');hold on;
            legendstr = {num2str(tshankchans(1))};

            for b = 2:size(twaves,1);
                plot(twaves(b,:)');
                legendstr{end+1} = num2str(tshankchans(b));
            end
            legend(legendstr)
            title([num2str(tmaxwaveidx) ': ' num2str(tshankchans(tmaxwaveidx))]);
        %     disp(tshankchans)
        end
    end
    
    sOld = s;
end

MeanWaveforms.MaxWaveChannelIdxsB0 = MaxWaveChannelIdxsB0;

save(fullfile(basepath,[basename,'_MeanWaveforms.mat']),'MeanWaveforms')
