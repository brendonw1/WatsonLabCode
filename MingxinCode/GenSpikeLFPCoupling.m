function [freqs,synchcoupling,ratepowercorr,...
    spikephasemag,spikephaseangle,popcellind,cellpopidx,...
    spikephasesig,ratepowersig]...
    = GenSpikeLFPCoupling(spiketimes,LFP,varargin)
% GenSpikeLFPCoupling(spiketimes,LFP)
%
%INPUT
%   spiketimes          {Ncells} cell array of spiketimes for each cell
%                                   or TSObject
%   LFP
%   (optional)
%       'sf_LFP'
%       'frange'
%       'tbin'
%       'waveparms'...
%       'nfreqs'
%       'int'
%       'cellLFPchannel'  The local LFP channel associated with each cell (if
%                       sites are in different electroanatomical regions)
%       'cellsort'        'pca','none','sortf','sortorder','celltype','rate'
%       'controls'        'thinspikes','jitterspikes','shufflespikes'
%       'downsample'
%       'subpop'
%
%OUTPUT
%   f
%   cellpower
%   cellphasemag
%   cellphaseang
%   synchpower
%   synchphasemag
%   synchphaseang
%   spikephasesig
%
%TO DO
%   -Put synch/spikerate in same section
%   -multiple ints - this (along with controls) will require making
%   subfunctions to loop
%
%DLevenstein 2016
%% inputParse for Optional Inputs and Defaults
p = inputParser;

defaultSf = 1250;

defaultInt = [0 Inf];
checkInt = @(x) size(x,2)==2 && isnumeric(x) || isa(x,'intervalSet');

defaultNfreqs = 100;
defaultNcyc = 5;
defaultFrange = [1 64];
%validFranges = {'delta','theta','spindles','gamma','ripples'};
%checkFrange = @(x) any(validatestring(x,validFranges)) || size(x) == [1,2];
checkFrange = @(x) isnumeric(x) && length(x(1,:)) == 2 && length(x(:,1)) == 1;

defaultSynchdt = 0.005;
defaultSynchwin = 0.02;

defaultSorttype = 'rate';
validSorttypes = {'pca','none','sortf','sortorder','celltype','rate'};
checkSorttype = @(x) any(validatestring(x,validFranges)) || size(x) == [1,2];

defaultDOWN = false;

addParameter(p,'sf_LFP',defaultSf,@isnumeric)
addParameter(p,'int',defaultInt,checkInt)
addParameter(p,'frange',defaultFrange,checkFrange)
addParameter(p,'nfreqs',defaultNfreqs,@isnumeric)
addParameter(p,'ncyc',defaultNcyc,@isnumeric)
addParameter(p,'synchdt',defaultSynchdt,@isnumeric)
addParameter(p,'synchwin',defaultSynchwin,@isnumeric)
addParameter(p,'sorttype',defaultSorttype,checkSorttype)
addParameter(p,'DOWNSAMPLE',defaultDOWN,@isnumeric)
addParameter(p,'subpop',0,@isnumeric)

parse(p,varargin{:})
%Clean up this junk...
sf_LFP = p.Results.sf_LFP;
int = p.Results.int;
nfreqs = p.Results.nfreqs;
frange = p.Results.frange;
ncyc = p.Results.ncyc;
synchdt = p.Results.synchdt;
subpop = p.Results.subpop;

%% Deal with input types

%Spiketimes can be: tsdArray of cells, cell array of cells, cell array of
%tsdArrays (multiple populations)
if isa(spiketimes,'tsdArray')
    numcells = length(spiketimes);
    for cc = 1:numcells
        spiketimestemp{cc} = Range(spiketimes{cc},'s');
    end
    spiketimes = spiketimestemp;
    clear spiketimestemp
elseif isa(spiketimes,'cell') && isa(spiketimes{1},'tsdArray')
    numpop = length(spiketimes);
    lastpopnum = 0;
    for pp = 1:numpop
        if length(spiketimes{pp})==0
            spiketimes{pp} = {};
            popcellind{pp} = [];
            continue
        end
        for cc = 1:length(spiketimes{pp})
            spiketimestemp{cc} = Range(spiketimes{pp}{cc},'s');
        end
        spiketimes{pp} = spiketimestemp;
        popcellind{pp} = [1:length(spiketimes{pp})]+lastpopnum;
        lastpopnum = popcellind{pp}(end);
        clear spiketimestemp
    end
    spiketimes = cat(2,spiketimes{:});
    numcells = length(spiketimes);
    subpop = 'done';
elseif isa(spiketimes,'cell')
    numcells = length(spiketimes);
end

if isa(int,'intervalSet')
    int = [Start(int,'s'), End(int,'s')];
end

t_LFP = (1:length(LFP))'/sf_LFP;

%% Subpopulations
switch subpop
    case 0
        numpop = 1;
        popcellind = {1:numcells};
    case 'done'
    otherwise
        pops = unique(subpop);
        numpop = length(pops);
        for pp = 1:numpop
            popcellind{pp} = find(subpop == pops(pp));
        end
end

cellpopidx = zeros(1,numcells);

%% Processing LFP

%Downsampling
if p.Results.DOWNSAMPLE
    downsamplefactor = p.Results.DOWNSAMPLE;
    sf_LFP = sf_LFP/downsamplefactor;
    assert(sf_LFP>2*max(frange),'downsample factor is too big...')
    LFP = downsample(LFP,downsamplefactor);
    t_LFP = downsample(t_LFP,downsamplefactor);%should have time vector to keep track of time...
end


switch nfreqs  
    case 1
        
        [~,LFP_amp,LFP_phase] = FiltNPhase(LFP,frange,sf_LFP,ncyc);
        
        LFP_amp = IsolateEpochs2(LFP_amp,int,0,sf_LFP);
        LFP_phase = IsolateEpochs2(LFP_phase,int,0,sf_LFP);
        t_LFP = IsolateEpochs2(t_LFP,int,0,sf_LFP);
        LFP_phase = cat(1,LFP_phase{:});
        LFP_amp = cat(1,LFP_amp{:});
        %Normalize Power to Mean Power
        LFP_amp = LFP_amp./mean(LFP_amp);
        t_LFP = cat(1,t_LFP{:});
        
        [t_LFP,IA] = unique(t_LFP); %remove doubles from overlapping ints
        LFP_amp = LFP_amp(IA,:);
        LFP_phase = LFP_phase(IA,:);
        
        freqs = [];
        
    otherwise
        %Restrict to intervals of interest
        LFP = IsolateEpochs2(LFP,int,0,sf_LFP);
        t_LFP = IsolateEpochs2(t_LFP,int,0,sf_LFP);

        [freqs,~,LFP_amp] = WaveSpec(LFP,frange,nfreqs,ncyc,1/sf_LFP,'log');
        LFP_amp = cat(2,LFP_amp{:})';
        t_LFP = cat(1,t_LFP{:});
        
        [t_LFP,IA] = unique(t_LFP); %remove doubles from overlapping ints
        LFP_amp = LFP_amp(IA,:);

        LFP_phase = angle(LFP_amp);
        LFP_amp = abs(LFP_amp);
        %Normalize power to mean power for each frequency
        LFP_amp = bsxfun(@(X,Y) X./Y,LFP_amp,nanmean(LFP_amp,1));
end


%% Calculate Population Synchrony Coupling
overlap = p.Results.synchwin/synchdt;
[spikemat,t_synch] = SpktToSpkmat(spiketimes, [t_LFP(end)], synchdt,overlap);

spikemat = IsolateEpochs2(spikemat,int,0,1/synchdt);
t_synch = IsolateEpochs2(t_synch,int,0,1/synchdt);

spikemat = cat(1,spikemat{:});
t_synch = cat(1,t_synch{:});

for pp = 1:numpop
    if length(popcellind{pp}) == 0
        synchcoupling(pp).powercorr = [];
        synchcoupling(pp).phasemag = [];
        synchcoupling(pp).phaseangle = [];
        numpop = numpop-1;
        continue
    end
    cellpopidx(popcellind{pp}) = pp;
    numpopcells = length(popcellind{pp});
    popsynch = sum(spikemat(:,popcellind{pp})>0,2)./numpopcells;
    popsynch = popsynch./mean(popsynch);
    %% Population Synchrony-Power/Phase Coupling and Rate-Power Coupling
    %Find phase and power at the closest LFP timepoint to the synch timepoint. 
    %Deals with different dt issue.
    power4synch = interp1(t_LFP,LFP_amp,t_synch,'nearest');
    phase4synch = interp1(t_LFP,LFP_phase,t_synch,'nearest');

    %Calculate Synchrony-Power Coupling as correlation between synchrony and
    %power
    [synchcoupling(pp).powercorr] = corr(popsynch,power4synch,'type','spearman','rows','complete');

    %Synchrony-Phase Coupling (magnitude/angle of resultant vector)
    resultvect = nanmean(power4synch.*bsxfun(@(popmag,ang) popmag.*exp(1i.*ang),popsynch,phase4synch),1);
    synchcoupling(pp).phasemag = abs(resultvect);
    synchcoupling(pp).phaseangle = angle(resultvect);

    clear power4synch; clear phase4synch   
end

%% Calculate Cell Rate-Power Correlation
ratedt = round(1/min(frange),3);
[spikemat,t_rate] = SpktToSpkmat(spiketimes, [t_LFP(end)], ratedt,2);

spikemat = IsolateEpochs2(spikemat,int,0,1/ratedt);
t_rate = IsolateEpochs2(t_rate,int,0,1/ratedt);
spikemat = cat(1,spikemat{:});
t_rate = cat(1,t_rate{:});

power4rate = interp1(t_LFP,LFP_amp,t_rate,'nearest');

%Spike-Power Coupling
[ratepowercorr,ratepowersig] = corr(spikemat,power4rate,'type','spearman','rows','complete');


%% Spike-Phase Coupling
[spikephasemag,spikephaseangle] = cellfun(@(X) spkphase(X),spiketimes,...
    'UniformOutput',false);
spikephasemag = cat(1,spikephasemag{:});
spikephaseangle = cat(1,spikephaseangle{:});


%Spike-Phase Coupling function - takes spike times from a single cell and
%caluclates phase coupling magnitude/angle
function [phmag,phangle] = spkphase(spktimes_fn)
    %Spike Times have to be column vector
        if isrow(spktimes_fn); spktimes_fn=spktimes_fn'; end
        if isempty(spktimes_fn); phmag=nan;phangle=nan; return; end

    %Take only spike times in intervals
    spktimes_fn = spktimes_fn(InIntervals(spktimes_fn,int));
    %Find phase and power at the closest LFP timepoint to each spike.
    phase4spike = interp1(t_LFP,LFP_phase,spktimes_fn,'nearest');
    power4spikephase = interp1(t_LFP,LFP_amp,spktimes_fn,'nearest');
    %Calculate (power normalized) resultant vector
    rvect = nanmean(power4spikephase.*exp(1i.*phase4spike),1);
    phmag = abs(rvect);
    phangle = angle(rvect);
    
    %% Example Figure : Phase-Coupling
%     if phmag >0.1
%     figure
%             rose(phase4spike)
%            % set(gca,'ytick',[])
%             hold on
%              polar(phase4spike,power4spikephase.*40,'k.')
%             % hold on
%              %compass([0 phangle],[0 phmag],'r')
%              compass(rvect.*700,'r')
%         delete(findall(gcf,'type','text'));
%         % delete the text objects
%     end
   
         
end

%Jitter for Significane
numjitt = 100;
jitterbuffer = zeros(numcells,nfreqs,numjitt);
jitterwin = 2/frange(1);
%tic
for jj = 1:numjitt
    if mod(jj,10) == 1
        display(['Jitter ',num2str(jj),' of ',num2str(numjitt)])
    end
    jitterspikes = JitterSpiketimes(spiketimes,jitterwin);
    phmagjitt = cellfun(@(X) spkphase(X),jitterspikes,'UniformOutput',false);
    jitterbuffer(:,:,jj) = cat(1,phmagjitt{:});
end
%toc
jittermean = mean(jitterbuffer,3);
jitterstd = std(jitterbuffer,[],3);
spikephasesig = (spikephasemag-jittermean)./jitterstd;

%% Example Figure : Phase-Coupling Significance
% cc = 6;
% figure
%     hist(squeeze(jitterbuffer(cc,:,:)),10)
%     hold on
%     plot(spikephasemag(cc).*[1 1],get(gca,'ylim')./4,'r','LineWidth',2)
%     plot(spikephasemag(cc),get(gca,'ylim')./4,'ro','LineWidth',2)
%     xlabel('pMRL')
%     ylabel('Number of Jitters')
%     xlim([0 0.2])


%% Sorting (and other plot-related things)
switch p.Results.sorttype
    case 'pca'
        [~,SCORE,~,~,EXP] = pca(cellpower);
        [~,spikepowersort] = sort(SCORE(:,1));
        
        [~,SCORE,~,~,EXP_phase] = pca(cellphasemag);
        [~,spikephasesort] = sort(SCORE(:,1));
        sortname = 'PC1';
    case 'none'
        spikepowersort = 1:numcells;
    case 'fsort'
        fidx = interp1(freqs,1:nfreqs,sortf,'nearest'); 
        [~,spikepowersort] = sort(cellpower(:,fidx));
        [~,spikephasesort] = sort(cellphasemag(:,fidx));
        sortname = [num2str(sortf) 'Hz Magnitude'];
    case 'rate'
        spkrt = cellfun(@length,spiketimes);
        [~,spikepowersort] = sort(spkrt);
        spikephasesort = spikepowersort;
        sortname = 'Firing Rate';
    otherwise
        spikepowersort = sortidx;
end

%%
switch nfreqs  
    case 1
%% Figure: 1 Freq Band
figure
    subplot(3,2,1)
        hold on
        hist(ratepowercorr)
        for pp = 1:numpop
            plot([synchcoupling(pp).powercorr,synchcoupling(pp).powercorr],...
                get(gca,'ylim'))
        end
        xlabel('Rate-Power Correlation')
        title('Rate-Power Coupling')
        ylabel('# Cells')
    subplot(3,2,[2 4])
        for pp = 1:numpop
            polar(spikephaseangle(popcellind{pp}),(spikephasemag(popcellind{pp})),'o')
            hold on
            polar([0 synchcoupling(pp).phaseangle],[0 synchcoupling(pp).phasemag])
            
        end
        title('Spike-Phase Coupling')
	subplot(3,2,3)
        for pp = 1:numpop
            hold on
            plot(ratepowercorr(popcellind{pp}),(spikephasemag(popcellind{pp})),'o')
            plot(synchcoupling(pp).powercorr,synchcoupling(pp).phasemag,'*')
        end
        %LogScale('y',10)
        xlabel('Rate-Power Correlation')
        ylabel('Spike-Phase Coupling Magnitude')
        
    otherwise
%% Figure: Spectrum
figure
    subplot(3,2,1)
        hold on
        for pp = 1:numpop
            plot(log2(freqs),synchcoupling(pp).powercorr)
        end
        plot(log2(freqs([1 end])),[0 0],'k--')
        LogScale('x',2)
        title('Pop. Synchrony - Power Correlation')
        xlabel('f (Hz)');ylabel('rho')
        
%     subplot(3,2,3)
%         hold on
%             [hAx,hLine1,hLine2] = plotyy(log2(freqs),cat(1,synchcoupling.phasemag),...
%                 log2(freqs),mod(cat(1,synchcoupling.phaseangle),2*pi))
%         LogScale('x',2)
%         hLine1.LineStyle = 'none';
%         hLine2.LineStyle = 'none';
%         hLine1.Marker = 'o';
%         hLine2.Marker = '.';
%         title('Pop. Synchrony - Phase Coupling')
%         xlabel('f (Hz)');
%         ylabel(hAx(1),'Phase Coupling Magnitude')
%         ylabel(hAx(2),'Phase Coupling Angle')

    subplot(3,2,3)
        hold on
        for pp = 1:numpop
            plot(log2(freqs),synchcoupling(pp).phasemag)
        end
        LogScale('x',2)
        title('Pop. Synchrony - Phase Coupling')
        xlabel('f (Hz)');
        ylabel('Phase Coupling Magnitude')
    subplot(3,2,5)
        hold on
        for pp = 1:numpop
            plot(log2(freqs),mod(synchcoupling(pp).phaseangle,2*pi),'o')
        end
        LogScale('x',2)
        title('Pop. Synchrony - Phase Coupling')
        xlabel('f (Hz)');

        ylabel('Phase Coupling Angle')


    subplot(2,2,2)
        imagesc(log2(freqs),1:numcells,ratepowercorr(spikepowersort,:))
        xlabel('f (Hz)');ylabel(['Cell - Sorted by ',sortname])
        LogScale('x',2)
        title('Rate - Power Correlation')
        ColorbarWithAxis([-0.04 0.04],'rho')
    subplot(2,2,4)
        imagesc(log2(freqs),1:numcells,spikephasemag(spikephasesort,:))
        xlabel('f (Hz)');ylabel(['Cell - Sorted by ',sortname])
        title('Spike - Phase Coupling')
        LogScale('x',2)
        caxis([0 0.2])
        colorbar
        
        

end

end



