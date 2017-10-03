function PlotPerMinuteSpikeTranferOverInterval(STPM,pairnum,iSet)
% STPM is SpikeTransferPerMinute
% pairnum is which pair to plot
% iSet is the interval over which to plot


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

switch class(iSet)
    case 'double'
        iSet = intervalSet(iSet(1)*10000,iSet(2)*10000);
end

intimes = mean([STPM.windowstarts;STPM.windowends])*10000;

ratios = tsd(intimes,STPM.ratios(pairnum,:)');
ratios = Restrict(ratios,iSet);
times = TimePoints(ratios,'s');
ratios = nanmean(Data(ratios),2);

ratechgs = tsd(intimes,STPM.ratechgs(pairnum,:)');
ratechgs = nanmean(Data(Restrict(ratechgs,iSet)),2);

measureds = tsd(intimes,STPM.measureds(pairnum,:)');
measureds = nanmean(Data(Restrict(measureds,iSet)),2);
expecteds = tsd(intimes,STPM.expecteds(pairnum,:)');
expecteds = nanmean(Data(Restrict(expecteds,iSet)),2);

numprespikes = tsd(intimes,STPM.numprespikes(pairnum,:)');
numprespikes = nanmean(Data(Restrict(numprespikes,iSet)),2);
numpostspikes = tsd(intimes,STPM.numpostspikes(pairnum,:)');
numpostspikes = nanmean(Data(Restrict(numpostspikes,iSet)),2);

h = figure('position',[50 50 800 600]);
subplot(3,2,1)
    hold on
    plot(times,numprespikes,'g')
    plot(times,numpostspikes,'k')
    legend('NumPreSpikes','NumPostSpikes','location','best')
    ylabel('# Spikes')
    xlim([times(1) times(end)])
subplot(3,2,2)
    hold on
    plot(times,nanzscore(numprespikes),'g')
    plot(times,nanzscore(numpostspikes),'k')
    legend('NumPreSpikes','NumPostSpikes','location','best')
    ylabel('Z')
    xlim([times(1) times(end)])

subplot(3,2,3)
    hold on
    plot(times,measureds,'c')
    plot(times,expecteds,'m')
    legend('MeasuredPeaks','ExpectedValuesInBins','location','best')
    ylabel('Hz Co-occurrence')
    xlim([times(1) times(end)])
subplot(3,2,4)
    hold on
    plot(times,nanzscore(measureds),'c')
    plot(times,nanzscore(expecteds),'m')
    legend('MeasuredPeaks','ExpectedValuesInBins','location','best')
    ylabel('Z')
    xlim([times(1) times(end)])

subplot(3,2,5)
    hold on
    plot(times,ratios,'b')
    plot(times,ratechgs,'r')
    legend('Measured/Expected','Measured-Expected','location','best')
    xlabel('seconds')
    ylabel('Hz OR Hz/Hz')
    xlim([times(1) times(end)])
subplot(3,2,6)
    hold on
    plot(times,nanzscore(ratios),'b')
    plot(times,nanzscore(ratechgs),'r')
    legend('Measured/Expected','Measured-Expected','location','best')
    ylabel('Z')
    xlabel('seconds')
    xlim([times(1) times(end)])
