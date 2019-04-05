function [SynapseByState,h] = SpikeTransfer_ByState(basepath,basename)
% function [SynapseByState,h] = SpikeTransfer_ByState(basepath,basename)
% gathers ccgs of each known synapse (based on burst-filtered spike trains)
% in each of a number of states for comparison
% Inputs are basepath and basename.
% Outputs are SynapseByState, a struct (for details see section called "store info 
% per pair of cells") and h, a vector of handles for each figure generated.
% SynapseByState and figures are autosaved in a folder called FuncSyns in
% the basepath.
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

minSpikesPerCellPerState = 50;
ccgduration = 0.03;%sec... ie 30ms per side

if ~exist(fullfile(basepath,'FuncSyns'),'dir')
    mkdir(fullfile(basepath,'FuncSyns'),'dir')
end

%% 
t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));%Load funcsynapses
funcsynapses = t.funcsynapses;
binSize = funcsynapses.BinMs/1000;
ccgnumbins = ccgduration * 1000  * 1/binSize/1000 * 2 +1;
ccghalfbins = ccgduration * 1000  * 1/binSize/1000;
OrigCCGMtx = funcsynapses.fullCCGMtx;

numE = size(funcsynapses.ConnectionsE,1);
if isempty(funcsynapses.ConnectionsE)
    numE = 0;
end
numI = size(funcsynapses.ConnectionsI,1);
if isempty(funcsynapses.ConnectionsI)
    numI = 0;
end
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;
shank = funcsynapses.CellShanks;
ConvWidth = 12;%number of BINS for convolution
ConvWidth = ConvWidth*binSize;%... now in seconds
badstates = {'DNstates','OFFStates','LowGamma'};

if numE > 0 || numI > 0
    SynapseByState.EEPairIdxs = [];
    SynapseByState.EIPairIdxs = [];
    SynapseByState.IEPairIdxs = [];
    SynapseByState.IIPairIdxs = [];
    
    Epairs = funcsynapses.ConnectionsE;
    Ipairs = funcsynapses.ConnectionsI;
    Allpairs = cat(1,Epairs,Ipairs);

    t = load(fullfile(basepath,[basename '_SStable']));%Load spikes
    S = t.S;
    t = load(fullfile(basepath,[basename '_GoodSleepInterval']));%Load spikes
    gsi = t.GoodSleepInterval;

    load(fullfile(basepath,[basename '_StateIntervals.mat']),'StateIntervals');%Load spikes
    StateNames = fieldnames(StateIntervals);%state names
    for a = 1:size(Allpairs,1)
        if a<= numE
            class = 'E';
        else
            class = 'I';
        end
        pre = Allpairs(a,1);
        post = Allpairs(a,2);
        preSpikesAll = S{pre};
        postSpikesAll = S{post};
        
%         strengthbyratio = [];
%         strengthbyratediff = [];
%         measured = [];
%         expected = [];
%         prespikes = {};
%         postspikes = {};
%         ccg = [];
%         goodstatesperpair = zeros(
        
        for b = 1:length(StateNames)%for each state 
            if b == 16;
                1;
            end
%             if ~ismember(StateNames{b},lower(badstates))
                eval(['tpreS = Restrict(preSpikesAll,StateIntervals.' StateNames{b} ');']) 
                eval(['tpostS = Restrict(postSpikesAll,StateIntervals.' StateNames{b} ');']) 
                STimesPre = Range(tpreS,'s');%note, now at samplerate = 1 (ie 1sec)
                STimesPost = Range(tpostS,'s');
                prespikes{b} = STimesPre;
                postspikes{b} = STimesPost;

                numprespikes = length(STimesPre);%record number of spikes by ref cell in each window
                numpostspikes = length(STimesPost);%record number of spikes by ref cell in each window

                if numprespikes > minSpikesPerCellPerState && numpostspikes > minSpikesPerCellPerState
%                     goodstates(b) = 1;
                    OrigCCG = OrigCCGMtx(:,pre,post);
                    cnxnstartms = ConnectionStarts(pre, post);
                    cnxnendms = ConnectionEnds(pre, post);
                    % handle question of when are bins of pre-determined
                    % "connection" times, including if is a flipped cnxn
                    if Flips(pre,post)
                        cnxnstartms = -cnxnstartms;
                        cnxnendms = -cnxnendms;
                    end

                    if shank(pre)==shank(post)
                        sameshank = 1;
                    else
                        sameshank = 0;
                    end

    %             get ccg, numprespikes, numpostspikes, measured, expected, strengthbyratio, strengthbyratediff
    %             save in struct per cnxn by state
                    [strengthbyratio(a,b), strengthbyratediff(a,b), ccgs(:,a,b), measured(a,b), expected(a,b)] =...
                        SpikeTransfer_Norm2(STimesPre,STimesPost,binSize,ccgduration,[cnxnstartms cnxnendms],ConvWidth,sameshank,1);
                    1;
                else %if not enough spikes...
                    strengthbyratio(a,b) = NaN;
                    strengthbyratediff(a,b) = NaN;
%                     ccg(:,end+1) =  NaN(ccgnumbins,1); 
                    measured(a,b) = NaN;
                    expected(a,b) = NaN;
                end
%             end
    %% store info per pair of cells
        end
    end
    SynapseByState.StateNames = StateNames;%constant for all pairs actually
    SynapseByState.MinSpikesPerCellPerState = minSpikesPerCellPerState;%constant for all pairs actually
    SynapseByState.AllPairs = Allpairs;% pre and post cell ids in terms of SStable (can reference Se or Si using CellIDs for indexing)
    SynapseByState.EPairs = Epairs;%E or I
    SynapseByState.IPairs = Ipairs;%E or I
    SynapseByState.EEPairs = funcsynapses.ConnectionsEE;
    SynapseByState.EIPairs = funcsynapses.ConnectionsEI;
    SynapseByState.IEPairs = funcsynapses.ConnectionsIE;
    SynapseByState.IIPairs = funcsynapses.ConnectionsII;
    SynapseByState.EPairIdxs = 1:size(Epairs,1);%E or I
    SynapseByState.IPairIdxs = size(Epairs,1) + (1:size(Ipairs,1));%E or I
    if ~isempty(SynapseByState.EEPairs)
        [~,SynapseByState.EEPairIdxs] = ismember(SynapseByState.EEPairs,Allpairs,'rows');
    end
    if ~isempty(SynapseByState.EIPairs)
        [~,SynapseByState.EIPairIdxs] = ismember(SynapseByState.EIPairs,Allpairs,'rows');
    end
    if ~isempty(SynapseByState.IEPairs)
        [~,SynapseByState.IEPairIdxs] = ismember(SynapseByState.IEPairs,Allpairs,'rows');
    end
    if ~isempty(SynapseByState.IIPairs)
        [~,SynapseByState.IIPairIdxs] = ismember(SynapseByState.IIPairs,Allpairs,'rows');
    end
    SynapseByState.OrigCCG = OrigCCG;
    SynapseByState.ConnectionMs = [cnxnstartms cnxnendms];
    SynapseByState.ConnectionBins = [cnxnstartms cnxnendms]/binSize;
%             SynapseByState(a).GoodStates = goodstates;
    SynapseByState.PreSpikes = prespikes;%all spiketimes of precell in seconds over all states
    SynapseByState.PostSpikes = postspikes;%all spiketimes of precell in seconds over all states
    SynapseByState.CCGs = ccgs;% ccg for pair, over all states (dim2)
    SynapseByState.Measured = measured;%single measure of height of peak per state (in hz)
    SynapseByState.Expected = expected;%single measure of approx baseline at site of peak, per state (in hz)
    SynapseByState.StrengthByRatio = strengthbyratio;%ratio of measured/expected
    SynapseByState.StrengthByRateDiff = strengthbyratediff;%difference of measured-expected
else %     save empty version of struct
    SynapseByState = struct([]);
end

%% Saving
save(fullfile(basepath,'FuncSyns',[basename ,'_FuncSynByState.mat']),'SynapseByState','-v7.3')


%% Plotting
plotting = 0;
h = [];
if plotting
    % plotting all
    h(end+1) = figure('Position',[2 2 800 400],'name',[basename '_SynapsesBy9States']);
    tlabels = cat(1,'Orignal',StateNames);
    for a = 1:length(SynapseByState);
        subplot(1,length(SynapseByState),a);
        tccg = cat(2,SynapseByState(a).OrigCcg,SynapseByState(a).StateCcgs);
        imagesc(zscore(tccg,[],1));
        colormap(gray)
        hold on;
        plot([.5 length(tlabels)+0.5],[ccghalfbins+1 ccghalfbins+1],'r')
        title(SynapseByState(a).EIClass)
        xticklabel_rotate([1:length(tlabels)]-.5,90,tlabels)
    end

    % plotting only Spindles, UPs, MovingWake, NonMovingWake, REM
    tnamevect = [1 3 7 8 9];
    StateNames_Faves = StateNames(tnamevect);%Spindles, UPs, MovingWake, NonMovingWake, REM
    tlabels = cat(1,'Orignal',StateNames_Faves);
    h(end+1) = figure('Position',[2 533 1878 420],'name',[basename '_SynapsesBy5States']);
    for a= 1:length(SynapseByState);
        subplot(1,length(SynapseByState),a);
        tccg = cat(2,SynapseByState(a).OrigCcg,SynapseByState(a).StateCcgs(:,tnamevect));
        imagesc(zscore(tccg,[],1));
        colormap(gray)
        hold on;
        plot([.5 length(tlabels)+0.5],[ccghalfbins+1 ccghalfbins+1],'r')
        title(SynapseByState(a).EIClass)
        xticklabel_rotate([1:length(tlabels)]-.5,90,tlabels)
    end

    % plotting only UPs, Wake, REM
    tnamevect = [3 6 9];
    StateNames_Faves = StateNames(tnamevect);%Spindles, UPs, MovingWake, NonMovingWake, REM
    tlabels = cat(1,'Orignal',StateNames_Faves);
    h(end+1) = figure('Position',[2 533 1878 420],'name',[basename '_SynapsesBy5States']);
    for a= 1:length(SynapseByState);
        subplot(1,length(SynapseByState),a);
        tccg = cat(2,SynapseByState(a).OrigCcg,SynapseByState(a).StateCcgs(:,tnamevect));
        imagesc(zscore(tccg,[],1));
        colormap(gray)
        hold on;
        plot([.5 length(tlabels)+0.5],[ccghalfbins+1 ccghalfbins+1],'r')
        title(SynapseByState(a).EIClass)
        xticklabel_rotate([1:length(tlabels)]-.5,90,tlabels)
    end

    %bar plot
    h(end+1) = figure('Position',[2 533 1878 420],'name',[basename '_SynapsesBy3States_Bars']);
    for a= 1:length(SynapseByState);
        subplot(1,length(SynapseByState),a);
        tccg = cat(2,SynapseByState(a).OrigCcg,SynapseByState(a).StateCcgs(:,tnamevect));
        subplot(1,length(SynapseByState),a)
    %     bar(zscore(tccg,[],1),'BarLayout','grouped')
        bar3_bw(zscore(tccg,[],1))
    %     legend(tlabels,'Location','Best')
        title(SynapseByState(a).EIClass)
    end
    axes('position',[.95 .5 0.01 0.01])
        bar(zscore(tccg,[],1))
        set(gca,'Visible','Off')
        legend(tlabels,'Location','NorthOutside')

    MakeDirSaveFigsThere(fullfile(basepath,'FuncSyns','FuncSynByState'),h)

end
