function BurstPerBinData = BurstPerBin(binwidthsecs,smoothingnumpoints,basepath,basename)

%% Constants
if ~exist('binwidthsecs','var')
    binwidthsecs = 10;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end

sampfreq = 1;
plotting = 0;
savingfigs = 0;
bursttime = 0.015;

%% Variables and Loading
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if exist([basename '_InjectionComparisionIntervals.mat'],'file')
    load([basename '_InjectionComparisionIntervals.mat'])
end

%DAVID 11/01/2022 THIS below chunk is now pretty antiquated!
% load(fullfile(basepath,[basename '_SSubtypes.mat']),'Se')
% load(fullfile(basepath,[basename '_SSubtypes.mat']),'Si')
% numEcells = length(Se);
% numIcells = length(Si);

%DAVID, for the new function, we need to add in spikes and CellClasses.
%States are actually not necessary which is pretty cool
basename = bz_BasenameFromBasepath(basepath); % Grab the basename
spikes = bz_GetSpikes('basepath',basepath); % Grab the spikes
CellClass = bz_LoadCellinfo(basepath,'CellClass'); % Grab the new stuff that replaces SSubtypes

numEcells = sum(CellClass.pE);
numIcells = sum(CellClass.pI); % With this, we effectively replaced the above block! I think...


% DAVID, this is another antiquated block!
%% Generate bins
% if numIcells>0
%     maxbin = min([max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);%because of Inf as max of some Good Sleeps
% else
%     maxbin = min([max(TimePoints(oneSeries(Se),'s'))]);%because of Inf as max of some Good Sleeps
% end
% binstartends = 0:binwidthsecs:maxbin;
% binstartends(end+1) = binstartends(end)+binwidthsecs;
% if binstartends(end) == binstartends(end-1)
%     binstartends(end) = [];
% end
% binstartends = binstartends * sampfreq;
% binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));
% bincentertimes = mean([binstartends(1:end-1)' binstartends(2:end)'],2)/sampfreq;



ecells = spikes.times(:,CellClass.pE);

if numIcells > 0
    icells = spikes.times(:,CellClass.pI);
else
    % cry();
end

%% David's Bursts
SmEburstiness = makeBurstiness(ecells,bursttime,binwidthsecs);
SmIburstiness = makeBurstiness(icells,bursttime,binwidthsecs);

figure;
if exist('InjectionComparisionIntervals','var')
    InjTime = InjectionComparisionIntervals.BaselineEndRecordingSeconds / binwidthsecs; % Holy crap. This variable's name tho
    CircMatch = InjectionComparisionIntervals.BaselineP24StartRecordingSeconds / binwidthsecs;
end

subplot(2,1,1);
plot(SmEburstiness);
ylabel('E Cell')
axis tight;
vline(InjTime,'r:','Injection'); 
vline(CircMatch,'r:','Circ Match');
subplot(2,1,2);
plot(SmIburstiness);
ylabel('I Cell')
axis tight;
vline(InjTime,'r:','Injection'); 
vline(CircMatch,'r:','Circ Match');
sgtitle(['Burstiness for ', basename]);

if ~exist([basepath, '/Figures'],'dir')
    mkdir([basepath, '/Figures']);
end

cd([basepath, '/Figures'])
savefig(gcf, [basename '_BurstinessEI_bin' num2str(binwidthsecs) '.fig'])
cd('..')

BurstPerBinData = struct('EBursts',SmEburstiness,'IBursts',SmIburstiness)

% %% Bin and Divide to get EIRatio (non-normalized)
% BIE = nan(length(bincentertimes),numEcells);
% for a = 1:length(bincentertimes)
%     thisS = 0;%Restrict(er,subset(binInts,a));
%     BIE(a,:) = BurstIndex_TsdArray(thisS,bursttime);
% %     if rem(a,100)==0
% %         disp(a)
% %     end
% end
% MBIE = nanmean(BIE,2);%mean of BI for E cells for each timebin
% 
% BII = nan(length(bincentertimes),numIcells);
% if numIcells>1
%     for a = 1:length(bincentertimes)
%         thisS = Restrict(Si,subset(binInts,a));
%         BII(a,:) = BurstIndex_TsdArray(thisS,bursttime);
%     %     if rem(a,100)==0
%     %         disp(a)
%     %     end
%     end
% end
% MBII = nanmean(BII,2);%mean of BI for I cells for each timebin
% 
% %% Smooth
% MBIE = smooth(MBIE,smoothingnumpoints);
% MBII = smooth(MBII,smoothingnumpoints);
% for a = 1:numEcells
%     BIE(:,a) = smooth(BIE(:,a),smoothingnumpoints);
% end
% for a = 1:numIcells
%     BII(:,a) = smooth(BIE(:,a),smoothingnumpoints);
% end
% 
% % %% Plot
% % if plotting
% %     load(fullfile(basepath,[basename '_StateIDM.mat']),'stateintervals')
% %     load(fullfile(basepath,[basename '_Motion.mat']))
% %     m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
% %     m = tsdArray(m);
% %     m = MakeSummedValQfromS(m,binInts);
% %     m = Data(m);
% %     m(isnan(m))=0;
% %     m = smooth(m,smoothingnumpoints);
% %     
% %     h = figure('position',[2 2 500 900]);
% %     subplot(6,1,1:3);
% %     imagesc(log10(EBinRates)');colormap jet
% %     
% %     subplot(6,1,4);
% %     imagesc(log10(IBinRates)');colormap jet
% %     
% %     subplot(6,1,5);
% %     plot(bincentertimes,MBIE,'b')
% %     axis tight
% %     plotIntervalsStrip(gca,stateintervals,1)
% % 
% %     subplot(6,1,6);
% %     plot(bincentertimes,MBII,'r')
% %     axis tight
% %     plotIntervalsStrip(gca,stateintervals,1)
% % end
% % 
% %     figname = [basename '_EIRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
% %     h = figure('position',[100 100 600 600],'name',figname);
% %     subplot(4,1,1)
% %         plot(bincentertimes,EI,'k')
% %         hold on
% %         axis tight
% %         plotIntervalsStrip(gca,intervals,1)
% %         yl = ylim;
% %         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
% %         axis tight
% %         ylabel('EIRatio')
% %         title(['E/I Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
% %     subplot(4,1,2)
% %         plot(bincentertimes,er,'b')
% %         hold on
% %         axis tight
% %         yl = ylim;
% %         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
% %         ylabel('E Rate(Hz)')
% %     subplot(4,1,3)
% %         plot(bincentertimes,ir,'r')
% %         hold on
% %         axis tight
% %         yl = ylim;
% %         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
% %         ylabel('I Rate(Hz)')
% %     subplot(4,1,4)
% %         plot(bincentertimes,m,'color',[.4 .4 .4])
% %         hold on
% %         axis tight
% %         yl = ylim;
% %         plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
% %         ylabel('Motion')
% % %% save figure
% %     if savingfigs
% %         savedir = ['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/EIRatio/Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
% %         MakeDirSaveFigsThereAs(savedir,h,'png')
% %     end
% % end
% 
% BurstPerBinData = v2struct(MBIE,MBII,BIE,BII,binwidthsecs,bincentertimes,smoothingnumpoints,numEcells,numIcells);
% save(fullfile(basepath,[basename '_BurstPerBinData.mat']),'BurstPerBinData')

end

function [SmoothedBurstiness, unsmoothedburstiness, burstmat, bursttimes] = makeBurstiness(spiketimes,bursttime,binwidthsecs)
bursttimes = {};
    for i = 1:length(spiketimes)
        thisspiketrain = spiketimes{i};
        difference = diff(spiketimes{i});
        isburst = difference < bursttime;
        midpointofwind = (thisspiketrain(2:end) + thisspiketrain(1:end-1)) / 2;
        bursttimes{i} = midpointofwind(isburst); %bursttimes should look a lot like spikes.times
    end
    
burstmat = dv_SpktToSpkmat(bursttimes,binwidthsecs);
unsmoothedburstiness = sum(burstmat,1);
SmoothedBurstiness = movmean(unsmoothedburstiness,10);
end