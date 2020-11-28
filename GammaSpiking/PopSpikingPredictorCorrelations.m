function PopSpikingPredictorCorrelations(basepath)
% Outcomes to predict: Want to predict pE pop rate, pI pop rate, and also 
% average Zs of pE and pI.  
% Inputs to use to predict: 50-180, Miller's whole band (What exactly is
% that?), full whole band, dot projection of plot of freq vs pE, EIR.

%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

plotting = 0;

%% Loading and prepping loaded variables
datafilename = fullfile(basepath,[basename '_PopSpikingPredictionVectorData.mat']);
if ~exist(datafilename,'file')
    disp('Running Script to grab predictors, since not already present as a .mat')
    PopSpikingPredictionVectorGather(basepath);
end
load(datafilename,'PopSpikingPredictionVectorData')
t = PopSpikingPredictionVectorData;
clear PopSpikingPredictionVectorData

%% Gather outcomes and predictors for later stats analyses
bandnames = {'FullBroad','LfpBroad','Delta','Theta','Sigma','Beta',...
    'LowGamma','BroadbandGamma','HighghighGamma'};

tst = 'Wake';
    %outcome measure
    eval(['u.PopSpikesE = t.PopSpikes.' tst 'PopSe;'])
    eval(['u.PopSpikesI = t.PopSpikes.' tst 'PopSi;'])

    v.Predictors = [];
    v.PredictorNames = {};

    %EI Ratio
    v.Predictors(:,end+1) = getfield(t.EIRatios,[tst 'EI']);
    v.PredictorNames{end+1} = [tst 'EI'];

    %Bandwise power in this state
    for bidx = 1:length(bandnames)
       tb = bandnames{bidx};
       v.Predictors(:,end+1) = getfield(t.PowerbandAmplitudes,[tst tb]);
       v.PredictorNames{end+1} = [tst tb];
    end

    %Dot products of projections of various spectra
    %Start with average statewise spectra onto each bin
    w = t.SpectralProjections.Raw;
    fn = fieldnames(w);
    templ = ['Onto' tst];
    for fnidx = 1:length(fn);
       if strcmp(fn{fnidx}(end-(length(templ)-1):end),templ)
           v.Predictors(:,end+1) = getfield(w,fn{fnidx});
           v.PredictorNames{end+1} = ['RawSpectralProjection_' fn{fnidx}];
       end
    end

    %Add special case of Wake-Nrem spectra
    w = t.SpectralProjections.WakeVNrem;
    v.Predictors(:,end+1) = getfield(w,['WakeMinusNremOnto' tst]);
    v.PredictorNames{end+1} = ['WakeMinusNremOnto' tst];
    
    %Add projections of preferred spectral weights for prediction of cell
    %firing rates (allow E and I to predict E or I)
    w = t.SpectralProjections.CorrSpect;
    fn = fieldnames(w);
    templ = ['Onto' tst];
    for fnidx = 1:length(fn);
       if strcmp(fn{fnidx}(end-(length(templ)-1):end),templ)
           v.Predictors(:,end+1) = getfield(w,fn{fnidx});
           v.PredictorNames{end+1} = ['CorrSpectralProjection_' fn{fnidx}];
       end
    end

%% Measure simple correlation values - R, P for each in log and linear condition
h = [];

%normalize predictors so can handle log transform
v.Predictors = bwnormalize_array(v.Predictors')';
v.Predictors(v.Predictors==0) = eps; 

for iidx = 1:2
    if iidx == 1;
        celltype = 'E';
    elseif iidx == 2
        celltype = 'I';
    end
    %linear or log of output
    for ll1 = 1:2;
        eval(['out = u.PopSpikes' celltype ';'])
        if ll1 == 1;
            ll1name = 'linear';
        else
            out = log10(out);
            ll1name = 'log';
        end
        %linear or log of inputs
        for ll2 = 1:2;
            ins = v.Predictors;
            if ll2 == 1;
                ll2name = 'linear';
            else
                ins = log10(v.Predictors);
                ll2name = 'log';
            end
            %now have ins and out... go to town
            [tr,tp] = corr(cat(2,out,ins));
            tr = tr(2:end,1);
            tp = tp(2:end,1);
            
            
            tname = [ll2name 'PredictorsVs' ll1name celltype 'PopSpikes'];
            eval(['PopSpikePredictorCorrVals.' tname '.Rs = tr;'])
            eval(['PopSpikePredictorCorrVals.' tname '.Ps = tp;'])
                
            
            if plotting
                h(end+1) = figure('position',[100 100 1000 550],'name',tname);
                bar(tr)
                axis tight
                set(gca,'XTick',1:length(v.PredictorNames),'XTickLabels',v.PredictorNames)
                xticklabel_rotate
            end
            
        end
    end
end

PopSpikePredictorCorrVals.PredictorNames = v.PredictorNames;
save(fullfile(basepath,[basename '_PopSpikingPredictorCorrVals']),'PopSpikePredictorCorrVals')

%% 
   1;
