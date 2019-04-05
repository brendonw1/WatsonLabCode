function UPstates_FirstPartPacking(basepath,basename)
% 

%% constants
SecFromAnch = [0.05 0.1 0.15 0.2 0.25];
PercentsFromStart = [0.05 0.1 0.15 0.2 0.25];

if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end

t = load(fullfile(basepath,[basename, '_UPDOWNIntervals']));
UPInts = t.UPInts;
t = load(fullfile(basepath,[basename '_SStable.mat']));
SAll = t.S;
t = load(fullfile(basepath,[basename '_SSubtypes.mat']));
SE = t.Se;
SI = t.Si;
t = load(fullfile(basepath,[basename '_CellIDs.mat']));
CellIDs = t.CellIDs;

%% Extract basic UP info
UPstarts = Start(UPInts);
UPstops = End(UPInts);
% get peaks - !THIS CODE DOESN'T WORK... should be max of histogram
% basically

%% extract up
celltypes = {'All','E','I'};
anchortypes = {'Start','Peak'};
for tn = 1:1%length(celltypes)
    ct = celltypes{tn};
    eval(['tSct = S' ct ';'])
    numcells = length(tSct);
    [UPSpkMeansFromUPStart,UPSpkMeansFromFileStart] = DetectIntervalPopSpikePeaks(UPInts,tSct,1);%times relative to start of up
    for an = 1:length(anchortypes)
        anchN = anchortypes{an};
        for a = 1:length(length(UPInts))% for each interval
            %define basics for this interval
            tint = subset(UPInts,a);
            switch anchN
                case 'Start'
                    tanch = Start(tint,'s');
                case 'Peak'
                    tanch = UPSpkMeansFromFileStart(a);
            end
            tS = Restrict(tSct,tint);%get tsd of restricted spikes

            %% Figure out what percent of cells fire in a certain portion of the up state... ie kind of UP burstiness
            tspkts = TimePoints(oneSeries(tS),'s');%get absolute times of spikes
            tspktFromAnch = tspkts - tanch;%subtract from anchor time
            
            %run metric of % of activity in a given time period vs activity
            %over the whole UP state
            for b = 1:length(SecFromAnch)
                eval(['TimePctIdxFrom' anchN ct 'Cells(a,b) = sum(tspktFromAnch<SecFromAnch(b))/length(tspkts);'])
            end
            
            %% Figure out how many participants there were in the specified portion vs whole epoch
            for b = 1:numcells%how many cells in this upstate
                UPParticipants(b) = logical(prod(size(tS{b})));
            end
            UPParticipants = sum(double(UPParticipants));
            
            for b = 1:length(SecFromAnch)%how many cells subperiod of upstate
                t = Restrict(tS,intervalSet(0,10000*[tanch+SecFromAnch(b)]));
                for c = 1:numcells
                    PeriodParticipants(c) = logical(prod(size(t{c})));
                end
                PeriodParticipants = sum(double(PeriodParticipants));

                eval(['ParticPctIdxFrom' anchN ct 'Cells(a,b) = PeriodParticipants/UPParticipants;'])
            end
            
%             %% By the way, collect summated counts for all UPs vs their anchor
%             maxbinsec = 1;
%             bininterval = 0.001;
%             updur = diff(StartEnd(subset(UPInts,a),'s'));
%             binmax = maxbinsec+tanch;
%             binmin = 1;
%             binnedcounts(:,a) = histc(tspktFromAnch,[bininterval:bininterval:maxbinsec]);
%             if updur<maxbinsec
%                 firstbad = ceil(updur);
%                 binnedcounts(firstbad:end,a) = NaN;
%             end
%             
        end
        eval(['BinnedCountsFrom' anchN ct 'Cells = binnedcounts';])
        disp([anchN ' done'])
    end
    disp([ct ' done'])
end

