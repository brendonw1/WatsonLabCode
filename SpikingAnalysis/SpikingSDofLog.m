function SpikingSDofLog = SpikingSDofLog(binwidthsecs,smoothingnumpoints,basepath,basename)

%% Constants
if ~exist('binwidthsecs','var')
    binwidthsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end
sampfreq = 10000;
plotting = 0;
savingfigs = 0;

%% Variables and Loading
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
load(fullfile(basepath,[basename '_SSubtypes.mat']))
numEcells = length(Se);
numIcells = length(Si);

% if numIcells<3
%     return
% end

%% Generate bins
if numIcells>0
    maxbin = min([max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);%because of Inf as max of some Good Sleeps
else
    maxbin = min([max(TimePoints(oneSeries(Se),'s'))]);%because of Inf as max of some Good Sleeps
end
binstartends = 0:binwidthsecs:maxbin;
binstartends(end+1) = binstartends(end)+binwidthsecs;
if binstartends(end) == binstartends(end-1)
    binstartends(end) = [];
end
binstartends = binstartends * sampfreq;
binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));
bincentertimes = mean([binstartends(1:end-1)' binstartends(2:end)'],2)/sampfreq;

%% Bin and Divide to get EIRatio (non-normalized)
EBinRates = Data(MakeQfromS(Se,binInts))/binwidthsecs;
z = EBinRates ==0;%account for log of zero in 2 lines
EBinRates = log10(EBinRates);
EBinRates(z) = min(EBinRates(~z));
% CoVE = std(EBinRates,[],2)./mean(EBinRates,2);
SDLE = nanstd(EBinRates,[],2);

if numIcells>1
    IBinRates = Data(MakeQfromS(Si,binInts))/binwidthsecs;
    z = IBinRates ==0;%account for log of zero in 2 lines
    IBinRates = log10(IBinRates);
    IBinRates(z) = min(IBinRates(~z));
%     CoVI = log10(CoVI);
else
    IBinRates = zeros(size(EBinRates,1),1);
end
% CoVI = std(IBinRates,[],2)./mean(IBinRates,2);
SDLI = nanstd(IBinRates,[],2);

%% Smooth
SDLE = smooth(SDLE,smoothingnumpoints);
SDLI = smooth(SDLI,smoothingnumpoints);
for a = 1:numEcells
    EBinRates(:,a) = smooth(EBinRates(:,a),smoothingnumpoints);
end
for a = 1:numIcells
    IBinRates(:,a) = smooth(IBinRates(:,a),smoothingnumpoints);
end

%% Plot
if plotting
    load(fullfile(basepath,[basename '_StateIDM.mat']),'stateintervals')
    load(fullfile(basepath,[basename '_Motion.mat']))
    m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
    m = tsdArray(m);
    m = MakeSummedValQfromS(m,binInts);
    m = Data(m);
    m(isnan(m))=0;
    m = smooth(m,smoothingnumpoints);
    
    h = figure('position',[2 2 500 900]);
    subplot(6,1,1:3);
    imagesc(log10(EBinRates)');colormap jet
    
    subplot(6,1,4);
    imagesc(log10(IBinRates)');colormap jet
    
    subplot(6,1,5);
    plot(bincentertimes,SDLE,'b')
    axis tight
    plotIntervalsStrip(gca,stateintervals,1)

    subplot(6,1,6);
    plot(bincentertimes,SDLI,'r')
    axis tight
    plotIntervalsStrip(gca,stateintervals,1)
end
% 
%     figname = [basename '_EIRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
%     h = figure('position',[100 100 600 600],'name',figname);
%     subplot(4,1,1)
%         plot(bincentertimes,EI,'k')
%         hold on
%         axis tight
%         plotIntervalsStrip(gca,intervals,1)
%         yl = ylim;
%         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         axis tight
%         ylabel('EIRatio')
%         title(['E/I Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
%     subplot(4,1,2)
%         plot(bincentertimes,er,'b')
%         hold on
%         axis tight
%         yl = ylim;
%         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('E Rate(Hz)')
%     subplot(4,1,3)
%         plot(bincentertimes,ir,'r')
%         hold on
%         axis tight
%         yl = ylim;
%         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('I Rate(Hz)')
%     subplot(4,1,4)
%         plot(bincentertimes,m,'color',[.4 .4 .4])
%         hold on
%         axis tight
%         yl = ylim;
%         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('Motion')
% %% save figure
%     if savingfigs
%         savedir = ['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/EIRatio/Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
%         MakeDirSaveFigsThereAs(savedir,h,'png')
%     end
% end

SpikingSDofLog = v2struct(SDLE,SDLI,EBinRates,IBinRates,binwidthsecs,bincentertimes,smoothingnumpoints,numEcells,numIcells);
save(fullfile(basepath,[basename '_SpikingSDofLog.mat']),'SpikingSDofLog')