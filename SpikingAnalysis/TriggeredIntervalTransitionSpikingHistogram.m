function [tstarts,AvailCells,rawcounts,normcounts,norminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
    (postInterval,preInterval,beforesample,aftersample,S,IncludeIntervals,tssampfreq,binsize,plotting)
% function [AvailCells,rawcounts,normcounts,norminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
%    (postInterval,preInterval,beforesample,aftersample,S,intervals,tssampfreq,binsize,plotting)
% SUMMARY
% Triggers a histogram spike count off of an interval transition.  The
% trigger interval is the input "postInterval" and it is assumed
% "preInterval" occurs immediately prior to postInterval.  Counts come from
% S.  Plotting may be called with the plotting boolean.
%
% INPUTS
% postInterval - interval the start of which is the time of interest (ie sleep)
% preInterval - interval immediately preceding the start time (ie pre-wake)
% binsize - size of bins (in seconds) this program will quantify things in
% beforesample - number of seconds before start time to grab for histogram
% aftersample - number of seconds after start time to grab for histogram
% S - TSDArray of spiking for all cells in this session
% IncludeIntervals - intervals to chop out (ie SWS)
% tssampfreq - sampling frequency for TSobjects/intervals
% plotting - boolean to determine whether plotting will happen.  Default is
% 0.
% 
% OUTPUTS
% tstarts - start time of each timebin
% AvailCells - matrix of cells with valid spiking occuring in each time bin
% rawcounts - counts per bin, with SWS taken out
% normcounts - counts per bin 


%% Basic pre-allocations and pre-calculations
pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;

%% Record how many bins are fillable with each dataset in the loop based on how long the durations of the wake and sleep are
BeforeDur = End(preInterval)-Start(preInterval);%time points of duration of before interval...
BeforeDur = floor(BeforeDur/tssampfreq/binsize);%... converted to #of bins long there is sleep data for
AvailCellsBefore = [zeros(1,pethNumBeforeBins-BeforeDur) size(S,1)*ones(1,BeforeDur)];
AvailCellsBefore = AvailCellsBefore(end-pethNumBeforeBins+1:end);

AfterDur = End(postInterval)-Start(postInterval);
AfterDur = floor(AfterDur/tssampfreq/binsize);%#of bins long there is sleep data for
AvailCellsAfter = [size(S,1)*ones(1,AfterDur) zeros(1,pethNumAfterBins-AfterDur)];
AvailCellsAfter = AvailCellsAfter(1:pethNumAfterBins);

AvailCells = [AvailCellsBefore,AvailCellsAfter];

%% Get spike counts per cell
eventstart = Start(postInterval)/tssampfreq;%in seconds
[tstarts, ttcounts] = PETH_pg (S, eventstart , beforesample, aftersample, binsize, 0);

%% zero bins that are in disallowed regions
wakestart = Start(preInterval)/tssampfreq;
sleepstop = End(postInterval)/tssampfreq;
ttcounts(:,tstarts<wakestart | tstarts>sleepstop) = 0;
rawcounts = ttcounts;
interpcounts = ttcounts;

%% if there are bits to keep (and to not keep), accumulate keeper chunks and NaN anything in between    
if ~isempty(IncludeIntervals)
    [st, et] = intervalSetToVectors(intersect(postInterval,IncludeIntervals));
    if st(1) ~= Start(postInterval)
        et = [Start(postInterval);et];
        ststart = 1;
    else
        ststart = 2;
    end
    if st(end) ~= End(postInterval)
        st = [st;End(postInterval)];
        eend = length(et);
    else
        eend = length(et)-1;
    end
    s = et(1:eend);%finding intervals between SWSs
    e = st(ststart:end);
    s = s/tssampfreq;
    e = e/tssampfreq;
    for b = 1:length(s)
        g = tstarts>=s(b) & tstarts<=e(b);
        fg = find(g);
        rawcounts(:,g) = NaN;
        if ~isempty(fg)
            for c = 1:size(rawcounts,1);
                startfg = max([1,fg(1)-1]);%nonzero
                try
                    interpcounts(c,fg) = linspace(rawcounts(c,startfg),rawcounts(c,fg(end)+1),length(fg));
                catch
                    interpcounts(c,fg) = rawcounts(c,startfg)*ones(1,length(fg));
                end
            end
        end
    end
end

%% alternate: Cat together SWS chunks     
%     [s, e] = intervalSetToVectors(inters0ect(subset(WSEpisodes{WSBestIdx},2),intervals{3}));
%     s = s/tssampfreq;
%     e = e/tssampfreq;
%     rawcounts = ttcounts(:,tstarts<sleepstart);%grab part before sleep start
%     tstarts = ttstarts(:,tstarts<sleepstart);
%     for b = 1:length(s);
%         g = ttstarts>=s(b) & ttstarts<=e(b);
%         rawcounts = cat(2,rawcounts,ttcounts(:,g));
%     %        numpointscut = e(b)-s(b)-1;
%         tstarts = cat(2,tstarts,ttstarts(g));
%     end


% clear places late in these plots where sleep was no longer ongoing 
%     rawcounts(:,AvailCellsBefore == 0) = 0;
%     rawcounts(:,pethNumBeforeBins+find(AvailCellsAfter) == 0) = 0;

%% Normalization
% old style
% normcounts = bsxfun(@rdivide,rawcounts,Rate(S));%normalize bins for each cell by global rate of that cell
% norminterpolatedcounts = bsxfun(@rdivide,interpcounts,Rate(S));
% new style
normcounts = bsxfun(@rdivide,rawcounts,mean(rawcounts,2));%normalize bins for rate of that cell in this collection
normcounts((sum(rawcounts,2)==0),:) = 0;%replaces nans from divide by zero
norminterpolatedcounts = bsxfun(@rdivide,interpcounts,mean(interpcounts,2));
norminterpolatedcounts((sum(interpcounts,2)==0),:) = 0;%replaces nans from divide by zero

if plotting
    figure('name','IntervalTriggeredSpiking')
        plot(tstarts,sum(norminterpolatedcounts,1),'m');%interpolated sections magenta (underneath)
        hold on;
        plot(tstarts,sum(normcounts,1),'b');%rest is blue
        plot([eventstart eventstart],ylim(gca),'k')
end
