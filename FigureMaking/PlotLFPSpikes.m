function PlotLFPSpikes(basepath,basename,startsec,endsec,lfpchans,cellnums)

if ~exist('startsec','var')
    startsec = 0;
end
if ~exist('endsec','var')
    endsec = Inf;
end
if ~exist('lfpchans','var')
    lfpchans = 1:5;
end
if ~exist('cellnums','var')
    cellnums = [1 inf];
end
if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

%% Get spikes from that shank for that time
load(fullfile(basepath,[basename '_SStable.mat']));
if cellnums(end) == inf
    cellnums(end) = length(S);
    cellnums = cellnums(1):cellnums(end);
end
S = S(cellnums);
ri = intervalSet(startsec*10000, endsec*10000);
S = Restrict(S,ri);

%% Get LFP traces from that shank for that time
bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
lfppath = getSessionEegLfpPath(bmd);
lfpfreq = bmd.Par.lfpSampleRate;
lfp = LoadBinary_FMA(lfppath,'channels',lfpchans,'nChannels',bmd.Par.nChannels,'frequency',lfpfreq,'start',startsec,'duration',endsec-startsec);
lfp = lfp*bmd.voltsperunit;
% for a = 1:size(lfp,2);
%     s = smooth(lfp(:,a),2500);
%     lfp(:,a) = lfp(:,a)-s;
% end
timestamps = 1/lfpfreq*(1:(size(lfp,1)))'+startsec;

%% Plot
h = figure('color',[1 1 1]);
subplot(20,1,19:20)%bottom: combined spikes
plot(TimePoints(oneSeries(S),'s'),ones(size(oneSeries(S))),'.');

subplot(20,1,13:18)%middle bottom: cell-wise spiketrains
plot(S);
yl = ylim;
ylim([yl(1)-.5 yl(2)+.5])
set(gca,'XTickLabel',[])

subplot(20,1,1:12)%top: lfp
hold on
for a = 1:size(lfp,2)
    plot(timestamps',lfp(:,a)+0.0005*a)
end
axis tight
set(gca,'XTickLabel',[])

1;
% plot(timestamps,lfp)

% 
% bottom = ylim;
% top = [ylim(2) ylim(2)+1.5*diff(yl)];
% total = [bottom(1) top(2)];
% ylim(total)


