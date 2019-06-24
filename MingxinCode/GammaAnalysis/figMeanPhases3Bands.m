for ii = 1:16
    [phasedistros(:,ii),phasebins,~]=CircularDistribution(double(spkphasesIso.H{ii,5*ii-3}),'nBins',180);
    for jj = 1:200
        [jitphasedistros(:,ii,jj),jitphasebins,~]=CircularDistribution(double(jitspkphasesIso.H{ii,5*ii-3,jj}),'nBins',180);
    end
end

figure;
for ii = 1:16
    subplot(4,4,ii);
    if find(CellIDs.EAll==ii)
        bar(phasebins*180/pi,phasedistros(:,ii),'EdgeColor','g','FaceColor','g','BarWidth',1);
        hold on;
        boundedline(phasebins*180/pi,mean(jitphasedistros(:,ii,:),3),std(jitphasedistros(:,ii,:),[],3),'b','alpha');
    else
        bar(phasebins*180/pi,phasedistros(:,ii),'EdgeColor','r','FaceColor','r','BarWidth',1);
        hold on;
        boundedline(phasebins*180/pi,mean(jitphasedistros(:,ii,:),3),std(jitphasedistros(:,ii,:),[],3),'cmap',[0.5 0 0.5],'alpha');
    end
    title(['SpikeNum ' num2str(spkNum.H(ii,5*ii-3))]);
    % legend(['pE Cell   ';'pE Shuffle'])
    xlim([0 360]);
    ylim([0 0.03]);
    set(gca,'XTick',[0 90 180 270 360])
end