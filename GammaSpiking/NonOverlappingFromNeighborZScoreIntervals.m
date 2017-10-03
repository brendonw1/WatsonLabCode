function NonOverlappingFromNeighborZScoreIntervals(basepath)
%function FindHighPowerNonOverlapping(basepath,desiredz)
% Just finding times of high power in one band but not in neighboring bands
% and saving them.  Later function can trigger off of them for various 
% purposes

%% constants
bandsimilaritycutoff = 0.1;%10% difference in frequency is considered similar
maxProportionOfDissimBands = 0.3;
% mincylesthresh = 3;%high power must be for at least this many cycles at the frequency it lives in to be considered

%% input/variable management
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

% if ~exist('desiredz','var')
%     desiredz = 0.5;
% end

load(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),...
    'AboveInt_ZByState','AboveInt_ZCombined','freqlist','neighborShanks','zthreshold_all')


%% Setting more values
par = LoadParameters(fullfile(basepath,[basename '.xml']));
sampfreq = par.lfpSampleRate;%wavelet data this was based upon, was itself based upon .lfp files, assumed at 1250... could import from metadata/xml
d = dir(fullfile(basepath,[basename '.lfp']));
filesamps = round(d.bytes/par.nChannels/(par.nBits/8));
clear par d

% zidx = find(zlookup==desiredz);
numshanks = length(neighborShanks);

%% Find long-enough epochs
% for fidx = 1:length(freqlist);% for each frequency (or each band)]
%     tfreq = freqlist(fidx);
%     
%     % find num points needed for least 1/f * 3cycles
%     mindursec = 1/tfreq * mincylesthresh;
%     mindurpoints = mindursec*sampfreq;
%     
%     %% for this one band, find long enough ints in each zbin and on each shank
%     % ... can output this too
%     longenough = cell(size(AboveInt_all));
%     for shidx = 1:numshanks
%         for zidx = 1:size(AboveInt_all,3)
%             tints = AboveInt_all{shidx,fidx,zidx};
%             d = diff(tints,[],2);
%             d = find(d>mindurpoints);%necessary??
%             tints = tints(d,:);
%             longenough{shidx,fidx,zidx} = tints;
%         end
%     end
% end

IsolatedAboveInt_ZByState = AboveInt_ZByState;
% IsolatedAboveInt_ZCombined = AboveInt_ZCombined;
% IsolatedBelowInt_ZByState = BelowInt_ZEachState;
% IsolatedBelowInt_ZCombined = BelowInt_ZCombined;


%% go through each event and make sure each event isn't buffered by periods of high power in nearby bands
for fidx = 1:length(freqlist);% for each frequency (or each band)]
%     tic
    tfreq = freqlist(fidx);
    % find DISsimilar channels with radius of +/- 1-2 times bandsimilaritycutoff
    dissimbandidxs = finddissimbandidxs(fidx,freqlist,bandsimilaritycutoff);%see below

    %now go through each event on each shank for each zscore and make sure
    %there isn't overlap on other bands
    for shidx = 1:numshanks
        for zidx = 1:size(AboveInt_ZByState,3)
            tints = AboveInt_ZByState{shidx,fidx,zidx};
            
            dissimbools = zeros(length(dissimbandidxs),filesamps);
            for didx = 1:length(dissimbandidxs)
                td = dissimbandidxs(didx);
                tint = AboveInt_ZByState{shidx,td,zidx};
                dissimbools(didx,:) = inttobool(tint,filesamps);
            end
            
            bad = logical(zeros(size(tints,1),1));
            for eidx = 1:size(tints,1);
%             parfor eidx = 1:size(tints,1);
                tss = tints(eidx,:);
                %make booleans for dissimilar bands
                tbool = dissimbools(:,tss(1):tss(2));
                denom = numel(tbool);
                numer = sum(sum(double(tbool)));
                if numer/denom >= maxProportionOfDissimBands
                    bad(eidx) = 1;
                end
            end
            IsolatedAboveInt_ZByState{shidx,fidx,zidx}(bad,:) = [];
            
        end
    end
%     toc
    disp(fidx)
end

IsolatedBandAboveZData = v2struct(bandsimilaritycutoff,maxProportionOfDissimBands,...
    sampfreq,filesamps,numshanks,freqlist,neighborShanks,zthreshold_all,...
    IsolatedAboveInt_ZByState);

save(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervals.mat']),'IsolatedBandAboveZData')

1;



function dissimbandidxs = finddissimbandidxs(fidx,freqlist,bandsimilaritycutoff)
%finds bands between 1-2 radii away from current band, handles execeptional
%cases near limits of bands, or with few nearby bands

tfreq = freqlist(fidx);

if fidx <= length(freqlist)-2
    twoaway = fidx + 2;%must have a band at least 2 away
else
    twoaway = [];
end
percentlist = find([freqlist < tfreq*(1+2*bandsimilaritycutoff)] & [freqlist > tfreq*(1+bandsimilaritycutoff)]);
if isempty(percentlist)
    thismaxmin = twoaway;
else
    thismaxmin = max([percentlist(1) twoaway]);
end
upperdissimilarbandidxs = cat(2,twoaway,percentlist);
if ~isempty(upperdissimilarbandidxs)
    upperdissimilarbandidxs(upperdissimilarbandidxs < thismaxmin) = [];
    upperdissimilarbandidxs = sort(unique(upperdissimilarbandidxs));
end

if fidx >= 3
    twoaway = fidx - 2;%must have a band at least 2 away
else
    twoaway = [];
end
percentlist = find([freqlist > tfreq*(1-2*bandsimilaritycutoff)] & [freqlist < tfreq*(1-bandsimilaritycutoff)]);
if isempty(percentlist)
    thisminmax = twoaway;
elseif length(percentlist)==1
    thisminmax = min([percentlist twoaway]);
else
    thisminmax = min([percentlist(2) twoaway]);
end
lowerdissimilarbandidxs = cat(2,twoaway,percentlist);
if ~isempty(lowerdissimilarbandidxs)
    lowerdissimilarbandidxs(lowerdissimilarbandidxs > thisminmax) = [];
    lowerdissimilarbandidxs = sort(unique(lowerdissimilarbandidxs));
end

dissimbandidxs = sort(cat(2,upperdissimilarbandidxs,lowerdissimilarbandidxs));
