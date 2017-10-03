function meanthischanspectra = StateTriggeredSpectrogram...
    (statenumber,beforesample,aftersample,channum,intervals,GoodSleepInterval,tssampfreq,basepath,basename)


meanperchannel = [];
channelanatomy = read_mixed_csv([fullfile(basepath,basename) '_ChannelAnatomy.csv'],',');
% 
% intervalstarts = Start(intersect(intervals{statenumber},GoodSleepInterval))/tssampfreq;%episode start time in sec
% prestarts = intervalstarts - beforesample;%get pre-start time
% poststarts = intervalstarts + aftersample;% and post
% 
% % get rid of events that will run off the end of the useable period
% tooearly = prestarts < Start(GoodSleepInterval);
% toolate = poststarts > End(GoodSleepInterval);
% toobad = tooearly | toolate;
% prestarts(toobad) = [];
% poststarts(toobad) = [];
[prestarts,poststarts] = getIntervalStartsWithinBounds(intervals{statenumber},GoodSleepInterval);

% read spectrum from .eegstates.mat file
t = load([fullfile(basepath,basename) '.eegstates.mat']);
chans = t.StateInfo.Chs;
fspec = t.StateInfo.fspec;
to = fspec{1}.to;
preinds = find(ismember(to,prestarts));
postinds = find(ismember(to,poststarts));

% for b = 1:length(fspec)
%     channum = b;
    thischan =  chans(channum);
    fo = fspec{channum}.fo;
    for c = 1:size(preinds,1);%for each state start
       thischanspectra(:,:,c) = fspec{channum}.spec(preinds(c):postinds(c),:)';
       
       [tstarts,AvailCells,rawcounts,normcounts,norminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
            (postInterval,preInterval,beforesample,aftersample,S,IncludeIntervals,tssampfreq,binsize,plotting);

    end
    meanperchannel(:,:,end+1) = mean(thischanspectra,3);

    h = PlotSpectrogram(meanperchannel(:,:,end),beforesample,fo,[0 100]);
    title([basename,'Spectrum from Channel ',num2str(thischan),': ',channelanatomy{thischan,2}])
% end

meanthischanspectra = mean(thischanspectra,3);


function h = PlotSpectrogram(spec,beforesample,fo,freqrange)

freqstart = find(fo<freqrange(1),1,'last');
if isempty(freqstart);
    freqstart = 1;
end
freqstop = find(fo>freqrange(end),1,'first');
if isempty(freqstop);
    freqstop = length(fo);
end
spec = spec(freqstart:freqstop,:);

h = figure('Name','Spectrogram');
imagesc([0 size(spec,2)-1],[fo(freqstart) fo(freqstop)],log(spec));
set(gca,'YDir','Normal');
yl = ylim;
hold on;
plot([beforesample beforesample],[0 500],'k')
ylim(yl);