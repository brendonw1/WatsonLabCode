function SpikeRateWSSnippets = WSSnippets_SpikeRates(basepath,basename,ep1,ep2,plotting)
% Gathers vector traces and medians of spike rates from timespans 
% around Wake-Sleep Episodes. 
% Available inputs to specify times around WS (for more see PrePostIntervalTimes.m):
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeB' - Look at wake before 
%         - 'WSSleep' - Look at all of sleep in a given WS episode
%         - 'WSSWS' - Look at all SWS in a given WS episode
%         - 'WWSREM' - Look at all REM in a given WS episode
%
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('ep1','var')
    ep1 = '5minSWS';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

if isnumeric(ep1)
    ep1str = inputdlg('Enter string to depict snippet timing');
else
    ep1str = ep1;
end

if ~exist('plotting','var')
    plotting = 0;
end

warning off
mkdir(fullfile(basepath,'WSSnippets'))
mkdir(fullfile(basepath,'WSSnippets',ep1str))
warning on

%% Spikes
%Extract
load(fullfile(basepath,[basename '_SSubtypes.mat']));
[preSpikesE,postSpikesE,preEpoch,postEpoch] = VectorsFromEpochPairs(Se,ep1,ep2);
[preSpikesI,postSpikesI] = VectorsFromEpochPairs(Si,ep1,ep2);

for a = 1:length(preSpikesE)
    if length(preSpikesE{a}) ~= length(Se)
        1;
    end
end


ESpkh = [];
ISpkh = [];
% Prep & Plot simple per-cell vector medians
for a = 1:length(preSpikesE) % for each WS
    ESpkr{a} = [];
    ESpkp{a} = [];
    ESpkcoeffs{a} = [];
    ISpkr{a} = [];
    ISpkp{a} = [];
    ISpkcoeffs{a} = [];

    ratePreSpikesE(:,a) = Rate(preSpikesE{a});
    ratePostSpikesE(:,a) = Rate(postSpikesE{a});

    if prod(size(Si))==0
        anyi = 0;
        ratePreSpikesI(:,a) = nan;
        ratePostSpikesI(:,a) = nan;
    else
        anyi = 1;
        ratePreSpikesI(:,a) = Rate(preSpikesI{a});
        ratePostSpikesI(:,a) = Rate(postSpikesI{a});
    end

    eval(['ECellRatesPreWS' num2str(a) '  = ratePreSpikesE(:,a);'])
    eval(['ECellRatesPostWS' num2str(a) ' = ratePostSpikesE(:,a);'])
    if plotting
        eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ECellRatesPreWS' num2str(a) ',ECellRatesPostWS' num2str(a) ');'])
        ESpkh = cat(1,ESpkh,th(:));
    else
        eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ECellRatesPreWS' num2str(a) ',ECellRatesPostWS' num2str(a) ');'])
    end
    ESpkr{a} = cat(1,ESpkr{a},tr);
    ESpkp{a} = cat(1,ESpkp{a},tp);
    ESpkcoeffs{a} = cat(2,ESpkcoeffs{a},tcoeffs);
    
    eval(['ICellRatesPreWS' num2str(a) '  = ratePreSpikesI(:,a);'])
    eval(['ICellRatesPostWS' num2str(a) ' = ratePostSpikesI(:,a);'])
    if plotting
        eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ICellRatesPreWS' num2str(a) ',ICellRatesPostWS' num2str(a) ');'])
        ISpkh = cat(1,ISpkh,th);
    else
        eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ICellRatesPreWS' num2str(a) ',ICellRatesPostWS' num2str(a) ');'])
    end
    ISpkr{a} = cat(1,ISpkr{a},tr);
    ISpkp{a} = cat(1,ISpkp{a},tp);
    ISpkcoeffs{a} = cat(2,ISpkcoeffs{a},tcoeffs);

%     % Save
%     ... in some new folder PrePostJune2015
%     save figs
%     save rates
end

%saving figs
if plotting
    figsavedir = fullfile(basepath,'WSSnippets',ep1str,'SpikeRateFigs');

    MakeDirSaveFigsThereAs(figsavedir,ESpkh,'fig')
    MakeDirSaveFigsThereAs(figsavedir,ISpkh,'fig')
end

%saving data
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_SpikeRateWSSnippets']);
SpikeRateWSSnippets = v2struct(anyi,preEpoch,postEpoch,preSpikesE,postSpikesE,preSpikesI,postSpikesI,... %raw tsdarray vectors
    ratePreSpikesE,ratePostSpikesE,ratePreSpikesI,ratePostSpikesI,... %cell-wise rates
    ESpkr, ESpkp, ESpkcoeffs, ISpkr, ISpkp, ISpkcoeffs);%correlation/fit data
save(savefilename,'SpikeRateWSSnippets', '-v7.3')