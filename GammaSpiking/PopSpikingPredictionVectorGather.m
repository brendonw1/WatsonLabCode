function PopSpikingPredictionVectorGather(basepath)
% Outcomes to predict: Want to predict pE pop rate, pI pop rate, and also 
% average Zs of pE and pI.  
% Inputs to use to predict: 50-180, Miller's whole band (What exactly is
% that?), full whole band, dot projection of plot of freq vs pE, EIR.

%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('plotting','var')
    plotting_ip = 0;
end

%% Loading and prepping loaded variables
load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','UnitRateVsBandPowerGathered.mat'))
v = UnitRateVsBandPowerGathered;
clear UnitRateVsBandPowerGathered

load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData']),'BandPowerVsSingleUnitSpikeRateData')
u = BandPowerVsSingleUnitSpikeRateData;
clear BandPowerVsSingleUnitSpikeRateData

load(fullfile(basepath,[basename '_WaveletForGamma']))
amp = amp.*(repmat(u.bandmeans,size(amp,1),1));

load(fullfile(basepath,[basename '_SSubtypes.mat']))
if exist('Se_TsdArrayFormat','var')
    Se = Se_TsdArrayFormat;
    Si = Si_TsdArrayFormat;
end

load(fullfile(basepath,[basename '_EIRatio_Bin1Smooth1.mat']))
EI = EIRatioData.ZPCEI;
EI = tsd(EIRatioData.bincentertimes,EI);
EI = tsdArray(EI);
%if smaller bins I guess interpolate or just sample over full seconds using floor

load(fullfile(basepath,[basename '_WaveletSpectrumByState']))
w = WaveletSpectrumByState;
clear WaveletSpectrumByState


%% Set bands of interest
bands.FullBroad.Range = [1 600];
bands.LfpBroad.Range = [1 200];
bands.Delta.Range = [1 4];
bands.Theta.Range = [6 10];
bands.Sigma.Range = [11 18];
bands.Beta.Range = [21 35];
bands.LowGamma.Range = [36 49];
bands.BroadbandGamma.Range = [50 180];
bands.HighghighGamma.Range = [200 600];
fn = fieldnames(bands);
for fidx = 1:length(fn);
    tfn = fn{fidx};
    eval(['tr = bands. ' tfn '.Range;'])
    tmin = find(u.bandmeans>=tr(1),1,'first');
    tmax = find(u.bandmeans<=tr(2),1,'last');
    tbands = tmin:tmax;
    eval(['bands.' tfn '.Bins = tbands;'])
end

%% Set bins of interest
goalbinsecs = 1;
tbidx = (u.binwidthseclist==goalbinsecs);
binwidthseclist = goalbinsecs;%overwriting other binning

%% Get dot product projection... project all timepoints against the correlation "spectrum" for each cell type for each state

%! add diffs between each state's spectrum and the mean of the rest of the time
%  ... project against that

for stidx = 1:length(u.stateslist)
    tst = u.stateslist{stidx};
    if isfield(w,['SpectrumFor' tst])
        eval(['allspects (stidx,:) = w.SpectrumFor' tst ';'])
    else
        allspects(stidx,:) = nan(1,length(bandmeans));
    end
end


%% Gather spike train vectors and Bandwise power vectors
% for binidx = 1:length(binwidthseclist)
binidx = 1;
    binwidthsecs = binwidthseclist(binidx);
    %% Restrict to a series of bins and use those same bins for all timing ops thereafter so correlations can be done
    %all
    for stidx = 1:length(u.stateslist)
        tst = u.stateslist{stidx};
        starts = [];
        ends = [];
        eval(['tSecsIN = u.' tst 'SecsIN;'])
%         tSecsIN = StartEnd(tSecsIS);
        for sgidx = 1:size(tSecsIN,1)
            t = tSecsIN(sgidx,:);
            ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
            te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
            starts = cat(1,starts,ts);
            ends = cat(1,ends,te);
        end
        eval([tst 'bins = intervalSet(starts,ends);'])
%         tbins = intervalSet(starts,ends);


        %% Get per-bin (per-second) spike rates
        eval([tst 'PopSeTsd = MakeQfromTsd(oneSeries(Se),' tst 'bins);'])
        eval([tst 'PopSeBinData = Data(' tst 'PopSeTsd);'])
        eval([tst 'PopSiTsd = MakeQfromTsd(oneSeries(Si),' tst 'bins);'])
        eval([tst 'PopSiBinData = Data(' tst 'PopSiTsd);'])

        eval(['PopSpikes. ' tst 'PopSe = ' tst 'PopSeBinData;'])
        eval(['PopSpikes. ' tst 'PopSi = ' tst 'PopSiBinData;'])
        
        % Could zscore each train as well
        
        %% Get EIRatio
        eval(['EIRatios.' tst 'EI = Data(MakeSummedValQfromS(EI,' tst 'bins));'])
        
        %% Gather per-bin wavelet band powers
        fn = fieldnames(bands);
        
        for fidx = 1:length(fn)
            tfname = fn{fidx};
            tband = getfield(bands,tfname);
            trange = tband.Range;
            
            minbin = find(bandmeans>trange(1),1,'first');
            maxbin = find(bandmeans<trange(2),1,'last');
            bandpower = mean(amp(:,minbin:maxbin),2);
            tbandpower = bandpower;
            bandpowertsd = tsd((1:length(tbandpower))/sampfreq,tbandpower);
            bandpowertsdArray = tsdArray(bandpowertsd);

            eval(['PowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,' tst 'bins);'])

            eval(['PowerbandAmplitudes. ' tst tfname ' = Data(PowerbandTsd);'])

%                 % make final matrices for correlations
%                 eval(['E' tst 'GeneralMatrix = cat(2,' tst 'PowerbandData,' tst 'PopSeBinData,EUnit' tst 'Rates{binidx}'');'])
%                 eval(['I' tst 'GeneralMatrix = cat(2,' tst 'PowerbandData,' tst 'PopSiBinData,IUnit' tst 'Rates{binidx}'');'])
        end
    end
% end

%% Predictors based on dot products of each bin against spectra
%first put the lfp wavelet matrix into the timebins used above
for idx = 1:size(amp,2);
    tsdaamp{idx} = tsd((1:size(amp,1))/sampfreq,amp(:,idx));
end
clear amp
tsdaamp = tsdArray(tsdaamp);

%make wavelet amp matrices for each state to project onto later
for stidx = 1:length(u.stateslist)
    tst = u.stateslist{stidx};
    eval(['tIS = ' tst 'bins;'])%calculated above
    tsdaamp2 = MakeSummedValQfromS(tsdaamp,tIS);
    eval([tst 'binamp = Data(tsdaamp2);'])
    eval(['StateWaveletAmps.' tst '= ' tst 'binamp;'])
end
clear tsdaamp

%gather projections
for stidx = 1:length(u.stateslist)
    tst = u.stateslist{stidx};
    % Raw state-wise spectrum
    if isfield(w,['SpectrumFor' tst])
        eval(['trawspect  = w.SpectrumFor' tst ';'])
    else
        trawspect = nan(1,length(bandmeans));
    end
    trawspect = trawspect.*u.bandmeans;
%     thisproj = dot(repmat(trawspect,size(binamp,1),1),binamp,2);
    eval(['Spectra.Raw.' tst ' = trawspect;'])
    for stidx2 = 1:length(u.stateslist)
        tst2 = u.stateslist{stidx2};
        eval(['thisbinamp = ' tst2 'binamp;'])
        thisproj = dot(repmat(trawspect,size(thisbinamp,1),1),thisbinamp,2);
        eval(['SpectralProjections.Raw.' tst 'Onto' tst2 ' = thisproj;'])
    end

    
    % Statewise spectrum vs mean of other states
%     tantispect = allspects;
%     tantispect(stidx,:) = [];
%     tantispect = mean(tantispect,1);
%     tantispect = tantispect.*u.bandmeans;
% 
%     tspectVMeanOthers = trawspect-tantispect;
%     thisproj = dot(repmat(tspectVMeanOthers,size(binamp,1),1),binamp,2);
%     eval(['Spectra.VsMeanOthers.' tst ' = tspectVMeanOthers;'])
%     eval(['SpectralProjections.VsMeanOthers.' tst ' = thisproj;'])

    % Statewise spectrum vs mean of other times
        % NO too messy and unrelaiable and variable     
        
    % Special case: Wake Vs Nrem
    if strcmp(tst,'Wake');
        ix = find(~cellfun(@isempty,strfind(u.stateslist,'Nrem')),1,'first');
        tantispect = allspects(ix,:);
        tantispect = tantispect.*u.bandmeans;
    
        tspect = trawspect - tantispect;
        Spectra.WakeVNrem.RawWakeMinusNrem = tspect;
        Spectra.WakeVNrem.RawNremMinusWake = -tspect;
        
        for stidx2 = 1:length(u.stateslist)
            tst2 = u.stateslist{stidx2};
            eval(['thisbinamp = ' tst2 'binamp;'])
            thisproj = dot(repmat(tspect,size(thisbinamp,1),1),thisbinamp,2);
            eval(['SpectralProjections.WakeVNrem.WakeMinusNremOnto' tst2 ' = thisproj;'])
            eval(['SpectralProjections.WakeVNrem.NremMinusWakeOnto' tst2 ' = -thisproj;'])
        end
% 
%         thisproj = dot(repmat(tspect,size(binamp,1),1),binamp,2);
%         SpectralProjections.WakeVNonRem.Wake = thisproj';
%         SpectralProjections.WakeVNonRem.Nrem = -thisproj';
    end

    %get dot prods of projection against the correlation-weighted spectrum
    %for each state/cell type combo
    for iidx = 1:2
        if iidx == 1;
            celltype = 'E';
        elseif iidx == 2
            celltype = 'I';
        end
        
        %per-recording correlation spectrum, not good
%         % Spect of correlation v spike rate
%         eval(['thiss = u.r_All' celltype tst ';'])
%         tcorrspect = squeeze(nanmean(thiss(:,tbidx,:),3));
%         tcorrspect = tcorrspect(1:end-1);%get rid of broadband
%         tcorrspect = tcorrspect';        
%         for stidx2 = 1:length(u.stateslist)
%             tst2 = u.stateslist{stidx2};
%             eval(['thisbinamp = ' tst2 'binamp;'])
%             thisproj = dot(repmat(tcorrspect,size(thisbinamp,1),1),thisbinamp,2);
%             eval(['SpectralProjections.CorrSpect.' celltype tst 'Onto' tst2 ' = thisproj;'])
%         end
%         eval(['Spectra.CorrSpect.' celltype tst ' =  tcorrspect;']);
        % Spect of correlation v spike rate
        
        %overall average correlation spectrum projection
        eval(['tcorrspect = squeeze(nanmean(v.r_Cells' celltype tst '(:,:,7),2));'])
%         tcorrspect = squeeze(nanmean(thiss(:,tbidx,:),3));
%         tcorrspect = tcorrspect(1:end-1);%get rid of broadband
        tcorrspect = tcorrspect';        
        for stidx2 = 1:length(u.stateslist)
            tst2 = u.stateslist{stidx2};
            eval(['thisbinamp = ' tst2 'binamp;'])
            thisproj = dot(repmat(tcorrspect,size(thisbinamp,1),1),thisbinamp,2);
            eval(['SpectralProjections.CorrSpect.' celltype tst 'Onto' tst2 ' = thisproj;'])
        end
        eval(['Spectra.CorrSpect.' celltype tst ' =  tcorrspect;']);
    end
end


PopSpikingPredictionVectorData = v2struct(PopSpikes,StateWaveletAmps,PowerbandAmplitudes,EIRatios,Spectra,SpectralProjections);
save(fullfile(basepath,[basename '_PopSpikingPredictionVectorData.mat']),'PopSpikingPredictionVectorData')