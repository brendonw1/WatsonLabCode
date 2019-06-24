function SpecByStates(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

figpath = fullfile(basepath,[basename '_SpecFig']);
if ~exist(figpath,'dir')
    mkdir(figpath);
end

load(fullfile(basepath,[basename,'.eegstates.mat']),'StateInfo');
load(fullfile(basepath,[basename,'_KetamineIntervalState.mat']));

% spec{1} = StateInfo.fspec{1}.spec;
% spec{2} = StateInfo.fspec{2}.spec;
% timestamps = StateInfo.fspec{1}.fo;

BaselineWAKE = KetamineIntervalState.baselineStateIntervals.int1WAKE;
BaselineNREM = KetamineIntervalState.baselineStateIntervals.int1NREM;
BaselineREM = KetamineIntervalState.baselineStateIntervals.int1REM;
BaselineMA = KetamineIntervalState.baselineStateIntervals.int1MA;

Baseline24WAKE = KetamineIntervalState.baseline24StateIntervals.int2WAKE;
Baseline24NREM = KetamineIntervalState.baseline24StateIntervals.int2NREM;
Baseline24REM = KetamineIntervalState.baseline24StateIntervals.int2REM;
Baseline24MA = KetamineIntervalState.baseline24StateIntervals.int2MA;

InjM1WAKE = KetamineIntervalState.InjM1StateIntervals.int1WAKE;
InjM1NREM = KetamineIntervalState.InjM1StateIntervals.int1NREM;
InjM1REM = KetamineIntervalState.InjM1StateIntervals.int1REM;
InjM1MA = KetamineIntervalState.InjM1StateIntervals.int1MA;

InjP1WAKE = KetamineIntervalState.InjP1StateIntervals.int2WAKE;
InjP1NREM = KetamineIntervalState.InjP1StateIntervals.int2NREM;
InjP1REM = KetamineIntervalState.InjP1StateIntervals.int2REM;
InjP1MA = KetamineIntervalState.InjP1StateIntervals.int2MA;

InjP2WAKE = KetamineIntervalState.InjP2StateIntervals.int2WAKE;
InjP2NREM = KetamineIntervalState.InjP2StateIntervals.int2NREM;
InjP2REM = KetamineIntervalState.InjP2StateIntervals.int2REM;
InjP2MA = KetamineIntervalState.InjP2StateIntervals.int2MA;

% InjP4WAKE = KetamineIntervalState.InjP4StateIntervals.int2WAKE;
% InjP4NREM = KetamineIntervalState.InjP4StateIntervals.int2NREM;
% InjP4REM = KetamineIntervalState.InjP4StateIntervals.int2REM;
% InjP4MA = KetamineIntervalState.InjP4StateIntervals.int2MA;

colors = RainbowColors(5);
for i = 1:length(StateInfo.fspec)
    spec{i} = StateInfo.fspec{i}.spec;
    Ch{i} = StateInfo.fspec{i}.info.Ch;
    fre{i} = StateInfo.fspec{i}.fo;
    
    
    % WAKE spec comparison
    BaselineWAKEspec{i} = spec{i}(IStoIDX(BaselineWAKE),:);
    Baseline24WAKEspec{i} = spec{i}(IStoIDX(Baseline24WAKE),:);
    InjM1WAKEspec{i} = spec{i}(IStoIDX(InjM1WAKE),:);
    InjP1WAKEspec{i} = spec{i}(IStoIDX(InjP1WAKE),:);
    InjP2WAKEspec{i} = spec{i}(IStoIDX(InjP2WAKE),:);
%     InjP4WAKEspec{i} = spec{i}(IStoIDX(InjP4WAKE),:);
    
    MeanLogWAKEspec = [mean(log(BaselineWAKEspec{i}));mean(log(InjM1WAKEspec{i}));mean(log(InjP1WAKEspec{i}));...
        mean(log(InjP2WAKEspec{i}));mean(log(Baseline24WAKEspec{i}))];
    figure;
    for j = 1:5
        hold on;
        plot(fre{i},MeanLogWAKEspec(j,:),'Color',colors(j,:));
    end
    
   legend({'baseline','Inj-1hr','Inj+1hr','Inj+2hr','baseline+24hr'})
    xlabel('Frequency (Hz)');
    title(['Ch' num2str(Ch{i}) ' WAKE spec']);
    savefig(fullfile(figpath,[basename '_WAKESpec_Ch' num2str(Ch{i}) '.fig']));
    print(fullfile(figpath,[basename '_WAKESpec_Ch' num2str(Ch{i})]),'-dpng','-r0');
    
    
    %NREM
    BaselineNREMspec{i} = spec{i}(IStoIDX(BaselineNREM),:);
    Baseline24NREMspec{i} = spec{i}(IStoIDX(Baseline24NREM),:);
    InjM1NREMspec{i} = spec{i}(IStoIDX(InjM1NREM),:);
    InjP1NREMspec{i} = spec{i}(IStoIDX(InjP1NREM),:);
    InjP2NREMspec{i} = spec{i}(IStoIDX(InjP2NREM),:);
%     InjP4NREMspec{i} = spec{i}(IStoIDX(InjP4NREM),:);
    
    MeanLogNREMspec = [mean(log(BaselineNREMspec{i}));mean(log(InjM1NREMspec{i}));mean(log(InjP1NREMspec{i}));...
        mean(log(InjP2NREMspec{i}));mean(log(Baseline24NREMspec{i}))];
    figure;
    for j = 1:5
        hold on;
        plot(fre{i},MeanLogNREMspec(j,:),'Color',colors(j,:));
    end
    
    legend({'baseline','Inj-1hr','Inj+1hr','Inj+2hr','baseline+24hr'})
    xlabel('Frequency (Hz)');
    title(['Ch' num2str(Ch{i}) ' NREM spec']);
    savefig(fullfile(figpath,[basename '_NREMSpec_Ch' num2str(Ch{i}) '.fig']));
    print(fullfile(figpath,[basename '_NREMSpec_Ch' num2str(Ch{i})]),'-dpng','-r0');
    
    % REM
    BaselineREMspec{i} = spec{i}(IStoIDX(BaselineREM),:);
    Baseline24REMspec{i} = spec{i}(IStoIDX(Baseline24REM),:);
    InjM1REMspec{i} = spec{i}(IStoIDX(InjM1REM),:);
    InjP1REMspec{i} = spec{i}(IStoIDX(InjP1REM),:);
    InjP2REMspec{i} = spec{i}(IStoIDX(InjP2REM),:);
%     InjP4REMspec{i} = spec{i}(IStoIDX(InjP4REM),:);
    
    MeanLogREMspec = [mean(log(BaselineREMspec{i}));mean(log(InjM1REMspec{i}));mean(log(InjP1REMspec{i}));...
        mean(log(InjP2REMspec{i}));mean(log(Baseline24REMspec{i}))];
    figure;
    for j = 1:5
        hold on;
        plot(fre{i},MeanLogREMspec(j,:),'Color',colors(j,:));
    end
    
    legend({'baseline','Inj-1hr','Inj+1hr','Inj+2hr','baseline+24hr'})
    xlabel('Frequency (Hz)');
    title(['Ch' num2str(Ch{i}) ' REM spec']);
    savefig(fullfile(figpath,[basename '_REMSpec_Ch' num2str(Ch{i}) '.fig']));
    print(fullfile(figpath,[basename '_REMSpec_Ch' num2str(Ch{i})]),'-dpng','-r0');
    
    
    
    % MA
    BaselineMAspec{i} = spec{i}(IStoIDX(BaselineMA),:);
    Baseline24MAspec{i} = spec{i}(IStoIDX(Baseline24MA),:);
    InjM1MAspec{i} = spec{i}(IStoIDX(InjM1MA),:);
    InjP1MAspec{i} = spec{i}(IStoIDX(InjP1MA),:);
    InjP2MAspec{i} = spec{i}(IStoIDX(InjP2MA),:);
%     InjP4MAspec{i} = spec{i}(IStoIDX(InjP4MA),:);
    
    MeanLogMAspec = [mean(log(BaselineMAspec{i}));mean(log(InjM1MAspec{i}));mean(log(InjP1MAspec{i}));...
        mean(log(InjP2MAspec{i}));mean(log(Baseline24MAspec{i}))];
    figure;
    for j = 1:5
        hold on;
        plot(fre{i},MeanLogMAspec(j,:),'Color',colors(j,:));
    end
    
    legend({'baseline','Inj-1hr','Inj+1hr','Inj+2hr','baseline+24hr'})
    xlabel('Frequency (Hz)');
    title(['Ch' num2str(Ch{i}) ' MA spec']);
    savefig(fullfile(figpath,[basename '_MASpec_Ch' num2str(Ch{i}) '.fig']));
    print(fullfile(figpath,[basename '_MASpec_Ch' num2str(Ch{i})]),'-dpng','-r0');
    
end

end


function IDX = IStoIDX(IntervalSet)
% convert intervalsets to index (by second)
SE = StartEnd(IntervalSet);
IDX = [];
for ii = 1:length(SE(:,1))
    IDX_sub = [];
    IDX_sub = uint32(SE(ii,1):SE(ii,2));
    IDX(end+1:end+length(IDX_sub)) = IDX_sub;
end
end
