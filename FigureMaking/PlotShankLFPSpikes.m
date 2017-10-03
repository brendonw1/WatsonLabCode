function PlotShankLFPSpikes(shanknum,startsec,endsec,basepath,basename)

if ~exist('startsec','var')
    startsec = 0;
end
if ~exist('endsec','var')
    endsec = Inf;
end
if ~exist('shanknum','var')
    shanknum = 1;
end
if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

%% Get spikes from that shank for that time
load(fullfile(basepath,[basename '_SStable.mat']));
cellidxs = find(shank == shanknum);
% S = S(cellidxs);
ri = intervalSet(startsec*10000, endsec*10000);
S = Restrict(S,ri);

%% Get LFP traces from that shank for that time
bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
ch = bmd.Par.SpkGrps(shanknum).Channels;
lfppath = getSessionEegLfpPath(bmd);
lfpfreq = bmd.Par.lfpSampleRate;
lfp = LoadBinary_FMA(lfppath,'channels',ch,'nChannels',bmd.Par.nChannels,'frequency',lfpfreq,'start',startsec,'duration',endsec-startsec);
lfp = lfp*bmd.voltsperunit;
timestamps = 1/lfpfreq*(1:(size(lfp,1)))'+startsec;

%% Plot
h = figure('color',[1 1 1]);
subplot(20,1,19:20)%bottom: combined spikes
plot(TimePoints(oneSeries(S),'s'),ones(size(oneSeries(S))),'.');

subplot(20,1,13:18)%middle bottom: cell-wise spiketrains
plot(S);
yl = ylim;
ylim([yl(1)-.5 yl(2)+.5])

subplot(20,1,1:12)%top: lfp
hold on
for a = 1:size(lfp,2)
    plot(timestamps',lfp(:,a)+0.0005*a,'b')
end
axis tight

1;
% plot(timestamps,lfp)

% 
% bottom = ylim;
% top = [ylim(2) ylim(2)+1.5*diff(yl)];
% total = [bottom(1) top(2)];
% ylim(total)


