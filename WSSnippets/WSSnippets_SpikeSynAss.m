function WSSnippets_SpikeSynAss(ep1,ep2)
% Gathers vector traces and medians of spike rates, Synaptic Timescale 
% Correlations and wake-generated assembly projections from timespans 
% around Wake-Sleep Episodes. 
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

if isnumeric(ep1)
    ep1str = inputdlg('Enter string to depict snippet timing');
else
    ep1str = ep1;
end


mkdir(fullfile(basepath,'WSSnippets'))
mkdir(fullfile(basepath,'WSSnippets',ep1str))

%% Spikes
SpikeRateWSSnippets = WSSnippets_GatherSpikeRates(basepath,basename,ep1,ep2);%saved to disk alreadyinside this fcn

%% Synapse stuff
SynCorrWSSnippets = WSSnippets_GatherSynapseStrengths(basepath,basename,ep1,ep2);%saved to disk alreadyinside this fcn

%% Assemblies - Written as of now to grab ICA-based 100sec bin E-cell only assemblies
WakeBIAssWSSnippets = WSSnippets_GatherAssemblyStrengths(basepath,basename,ep1,ep2);%saved to disk alreadyinside this fcn