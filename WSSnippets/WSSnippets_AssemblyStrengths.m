function WakeBIAssWSSnippets = WSSnippets_AssemblyStrengths(basepath,basename,ep1,ep2)
% Gathers vector traces and medians of ICA-based assembly activity from
% timespans around Wake-Sleep Episodes. 
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




%% Assemblies - Written as of now to grab ICA-based 100sec bin E-cell only assemblies
t = load(fullfile(basepath,'Assemblies','WakeBasedICA','AssemblyBasicDataWakeDetect'));
aa = t.AssemblyBasicDataWakeDetect.AssemblyActivities;
[preWakeBIAss,postWakeBIAss] = VectorsFromEpochPairs(aa,ep1,ep2);

WakeBIAssh = [];

% Prep & Plot simple per-cell vector medians
for a = 1:length(preWakeBIAss) % for each WS
    WakeBIAssr{a} = [];
    WakeBIAssp{a} = [];
    WakeBIAsscoeffs{a} = [];

    for b = 1:length(preWakeBIAss{a})
        medianPreWakeBIAss(b,a) = nanmedian(Data(preWakeBIAss{a}{b}));
        medianPostWakeBIAss(b,a) = nanmedian(Data(postWakeBIAss{a}{b}));
    end
    
    eval(['WakeBasedICAAssPreActWS' num2str(a) ' = medianPreWakeBIAss(:,a);'])
    eval(['WakeBasedICAAssPostActWS' num2str(a) ' = medianPostWakeBIAss(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(WakeBasedICAAssPreActWS' num2str(a) ',WakeBasedICAAssPostActWS' num2str(a) ');'])
    WakeBIAssh = cat(1,WakeBIAssh,th(:));
    WakeBIAssr{a} = cat(1,WakeBIAssr{a},tr);WakeBIAssp{a} = cat(1,WakeBIAssp{a},tp);WakeBIAsscoeffs{a} = cat(2,WakeBIAsscoeffs{a},tcoeffs);
end

%saving Spike stuff
figsavedir = fullfile(basepath,'WSSnippets',ep1str,'WakeBIAssFigs');
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_WakeBIAssWSSnippets']);

mkdir(figsavedir)
MakeDirSaveFigsThereAs(figsavedir,WakeBIAssh,'fig')
WakeBIAssWSSnippets = v2struct(preWakeBIAss,postWakeBIAss,... %raw tsdarray vectors
    medianPreWakeBIAss,medianPostWakeBIAss,... %cell-wise rates
    WakeBIAssr, WakeBIAssp, WakeBIAsscoeffs);%correlation/fit data
save(savefilename,'WakeBIAssWSSnippets')
