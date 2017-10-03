function PlotLFPSpikes_Cohen(basepath,basename,startsec,endsec,lfpchans,ecell)

if ~exist('startsec','var')
    startsec = 2737;
end
if ~exist('endsec','var')
    endsec = startsec+5;
end
if ~exist('lfpchans','var')
    lfpchans = 49;
end
if ~exist('cellnums','var')
    cellnums = [1 inf];
end
if ~exist('ecell','var')
    ecell = 7;
end
if ~exist('basepath','var')
    basepath = '/mnt/brendon6/JennBuzsaki22/20140527_421um';
    basename = '20140527_421um';
end

%% Get spikes from that shank for that time
load(fullfile(basepath,[basename '_SStable.mat']));
load(fullfile(basepath,[basename '_SSubtypes.mat']));
if cellnums(end) == inf
    cellnums(end) = length(S);
    cellnums = cellnums(1):cellnums(end);
end
S = S(cellnums);
ri = intervalSet(startsec*10000, endsec*10000);
S = Restrict(S,ri);
Se = Restrict(Se,ri);
Si = Restrict(Si,ri);

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
endsec = timestamps(end);

%% Plot
h = figure('color',[1 1 1]);
% subplot(20,1,1:6,'visible','off','xtick',[])%top: lfp
%     hold on
%     for a = 1:size(lfp,2)
%         plot(timestamps',lfp(:,a)+0.0005*a,'k')
%     end
%     axis tight
% %     set(gca,'XTickLabel',[])
%     ylabel('LFP')

% ecell = 10;
icell = 4;

subplot(20,1,8:10,'visible','off','xtick',[])%middle bottom: cell-wise spiketrains
    hold on
    t = Range(Se{ecell});    
    a = 1;
    plot([t';t'],[(a-1)*ones(size(t'));a*ones(size(t'))],'b')
 
    t = Range(Si{icell});    
    a = 2;
    plot([t';t'],[(a-1)*ones(size(t'));a*ones(size(t'))],'r')
    
    
%     for a = 1:length(Se);
%         t = Range(Se{a});    
%         plot([t';t'],[(a-1)*ones(size(t'));a*ones(size(t'))],'b')
%     end
%     set(gca,'XTickLabel',[])
%     for ix = 1:length(Si);
%         b = a+ix;
%         t = Range(Si{ix});    
%         plot([t';t'],[(b-1)*ones(size(t'));b*ones(size(t'))],'r')
%     end
%     set(gca,'XTickLabel',[])
    axis tight

    
%% plotting smoothed spike train sums
binspersec = 100;
gaussigmainnumbins = 3;
g = gaussian([-30:1:30]/binspersec,0,gaussigmainnumbins/binspersec);

subplot(20,1,11:20)%middle bottom: combined E spikes
    hold on
    t = Range(oneSeries(Si),'s');   
    t = t-t(1)+1/binspersec;
    ispikevec = zeros(1,ceil((endsec-startsec)*binspersec));
    ispikevec(round(t*binspersec)) = 1;
    ispikevec = conv(ispikevec,g)/length(Si);
    plot(ispikevec,'r')
    hold on

    t = Range(oneSeries(Se),'s');   
    t = t-t(1)+1/binspersec;
    espikevec = zeros(1,ceil((endsec-startsec)*binspersec));
    espikevec(round(t*binspersec)) = 1;
    espikevec = conv(espikevec,g)/length(Se);
    plot(espikevec,'b')
%     plot([t';t'],[(.5)*ones(size(t'));1.5*ones(size(t'))],'b')
    
1;
% plot(timestamps,lfp)

% 
% bottom = ylim;
% top = [ylim(2) ylim(2)+1.5*diff(yl)];
% total = [bottom(1) top(2)];
% ylim(total)

MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/Manuscripts/CohenTsien/SpikingLFPFig',h)
MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/Manuscripts/CohenTsien/SpikingLFPFig',h,'svg')


