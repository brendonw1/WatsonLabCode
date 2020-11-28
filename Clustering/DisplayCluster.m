function DisplayCluster(basename,spikegrpnum,clunum)

wavestoplot = 100;

% get basic parameters info
Par = LoadPar([basename '.xml']);

% Load clu 
clu = load([basename,'.clu.',num2str(spikegrpnum)]);
clu(1) = [];

%get relvant spike indices


for a = 1:length(clunum);
    figure;
    
    tnum = clunum(a);
    tspks = find(clu==tnum);
    nspks = length(tspks);
    
    nchans = length(Par.SpkGrps(spikegrpnum).Channels);
    sampperspk = Par.SpkGrps(spikegrpnum).nSamples;
    
    %% Get and plot waveforms
    randspks = randperm(nspks);
    randspks = randspks(1:min([wavestoplot nspks]));    
    wav = LoadSpikeWaveforms_BW([basename,'.spk.',num2str(spikegrpnum)],nchans,sampperspk,randspks);

    axes;hold on
    for b = 1:nchans;
        thesewavs = squeeze(wav(:,b,:))';
%         thesewavs = thesewavs-min(min(thesewavs));
%         thesewavs = thesewavs/max(max(thesewavs));
        offset = 300*(nchans-b);
        plot(thesewavs+offset,'color','r')
    end

    %% Get and plot fets
    fet = LoadFetSubset([basename,'.fet.',num2str(spikegrpnum)]);%actually faster to not specify spks
    tfet = fet(tspks,:);
    origfets = 1:3:size(fet,2)-5;
    primfets = tfet(:,origfets);
    [~,primdim] = max(abs(mean(primfets,1)));
    primdim = origfets(primdim);
    axes
    plot(tfet(:,end),tfet(:,primdim),'k.')
    
    %% CCG
    res = load([basename,'.clu.',num2str(spikegrpnum)])/20;
end