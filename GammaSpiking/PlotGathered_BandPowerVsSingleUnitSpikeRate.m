function PlotGathered_BandPowerVsSingleUnitSpikeRate

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','UnitRateVsBandPowerGathered.mat'))

u = UnitRateVsBandPowerGathered;
plotbinwidth = 1;
stateslist = u.stateslist;
numbands = length(u.bandmeans);
numbinsz = length(u.binwidthseclist);
%plot mean-over-cells correlations across bands - spectrogram-like

broadbandgammarange = [50 180];
BBminbin = find(u.bandmeans>=broadbandgammarange(1),1,'first');
BBmaxbin = find(u.bandmeans<=broadbandgammarange(2),1,'last');
broadbandbins = BBminbin:BBmaxbin;

deltarange = [1 4];
Deltaminbin = find(u.bandmeans>deltarange(1),1,'first');
Deltamaxbin = find(u.bandmeans<deltarange(2),1,'last');
deltabandbins = Deltaminbin:Deltamaxbin;

thetarange = [6 10];
Thetaminbin = find(u.bandmeans>thetarange(1),1,'first');
Thetamaxbin = find(u.bandmeans<thetarange(2),1,'last');
thetabandbins = Thetaminbin:Thetamaxbin;

sigmarange = [11 18];
Sigmaminbin = find(u.bandmeans>sigmarange(1),1,'first');
Sigmamaxbin = find(u.bandmeans<sigmarange(2),1,'last');
sigmabandbins = Sigmaminbin:Sigmamaxbin;

betarange = [21 35];
Betaminbin = find(u.bandmeans>betarange(1),1,'first');
Betamaxbin = find(u.bandmeans<betarange(2),1,'last');
betabandbins = Betaminbin:Betamaxbin;

lowgammarange = [36 49];
LGminbin = find(u.bandmeans>lowgammarange(1),1,'first');
LGmaxbin = find(u.bandmeans<lowgammarange(2),1,'last');
lowgammabandbins = LGminbin:LGmaxbin;

highghighgammarange = [200 600];
HGminbin = find(u.bandmeans>highghighgammarange(1),1,'first');
HGmaxbin = find(u.bandmeans<highghighgammarange(2),1,'last');
highhighgammabandbins = HGminbin:HGmaxbin;



u.AnimalNums = [1 1 1 2 2 3 4 4 5 5 6 6 6 7 8 8 8 8 8 8 8 8 9 9 10 10 11];%I didn't wanna code this esp w Jenn's animal


%% Images showing r of each cell w each band at specific bin widths
% h = [];
% plotbinlist = [.1 1 10];
% for bidx = 1:length(plotbinlist)
%     tbinwidth = plotbinlist(bidx);
%     for stidx = 1:length(stateslist)
%         tst = stateslist{stidx};
% 
%         h(end+1) = figure('position',[5 5 1200 700],'name',['BandPowerVsSingleUnitSpikeRates_EachCell_' num2str(tbinwidth) 'SecBin' tst]); 
%         for iidx = 1:2
%             if iidx == 1;
%                 celltype = 'E';
%             elseif iidx == 2
%                 celltype = 'I';
%             end
%             eval(['tmtx = u.r_Cells' celltype tst ';']);
%             tt = zscore(tmtx(:));
%             toohighz = 4;
%             okval = max(tmtx(find(tt<toohighz)));
%             if ~isempty(okval)
%                 tmtx(tmtx>okval) = okval;
%             end
% 
%             subplot(1,2,iidx)
%             imagesc((tmtx(:,:,u.binwidthseclist==tbinwidth))');axis ij
%             xlabel('Frequency(Hz)')
%             xt = round(linspace(1,length(u.bandmeans),5));
%             set(gca,'xtick',xt)
%             set(gca,'xticklabel',u.bandmeans(xt))
%             ylabel('Cell')
%             colorbar
%             xl = xlim;
%             hold on
% 
%             start = 0; 
%             stop = [];
%             eval(['tn = u.num' celltype 'cells;'])
% 
%             for ridx = 1:length(tn);%plot recording indicators
%                 stop = start+tn(ridx);
%                 if mod(ridx,2)==1
%                     plot([0 0],[start stop],'color','k','linewidth',7)
%                 end
%                 start = stop;
%             end
% 
%             start = 0;
%             stop = [];
%             anims = unique(u.AnimalNums);
%             for aidx = 1:length(anims);%plot recording indicators
%                 tnumcells = sum(tn(u.AnimalNums == anims(aidx)));
%                 stop = start+tnumcells;
%                 if mod(aidx,2)==1
%                     plot([-1 -1],[start stop],'color','r','linewidth',7)
%                 else
%                     plot([-1 -1],[start stop],'color',[.7 .7 .7],'linewidth',7)
%                 end
%                 start = stop;
%             end
% 
%             xlim([-1.5 xl(2)])
%             title(['R values. ' celltype ' cells.'])
%         end
%         AboveTitle({[tst];['Values w Z>' toohighz ' set to equivlaent of Z=' toohighz '.']})
%     end
% end
% MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'fig')
% MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'png')
% 

%% Correlation by band - mean of all POPULATIONS in spectrogram-like display
h = [];
col = RainbowColors(length(stateslist));
plotbinlist = [.1 1 10];
for bidx = 1:length(plotbinlist)
    tbinwidth = plotbinlist(bidx);
    tbidx = (u.binwidthseclist==tbinwidth);
    for iidx = 1:2
        if iidx == 1;
            celltype = 'E';
        elseif iidx == 2
            celltype = 'I';
        end

        h(end+1) = figure('position',[1 1 1200 800],'Name',['BandPowerVsSingleUnitSpikeRates_AllPopMeans_' celltype 'Cell_' num2str(tbinwidth) 'SecBins']);
%         for stidx = 1:length(stateslist)
        for stidx = 2:6
            tst = stateslist{stidx};
            eval(['thisr = u.r_All' celltype tst ';'])

            subplot(2,3,stidx-1)
            plot(nanmean(thisr(:,tbidx,:),3));
            axis tight
            hold on
            xl = xlim(gca);
            plot(xl,[0 0],'r')
            plot(xl,[.03 .03],'color',[1 .7 .7])
            xlabel('Frequency(Hz)')
            xt = round(linspace(1,length(u.bandmeans),5));
            set(gca,'xtick',xt)
            set(gca,'xticklabel',u.bandmeans(xt))

            ylabel('Rate-Power Corr(r)')
            title(tst,'fontweight','normal')

            subplot(2,3,6)
            hold on
            plot(nanmean(thisr(:,tbidx,:),3),'color',col(stidx,:),'linewidth',2)
            hold on
            xl = xlim(gca);
            xt = round(linspace(1,length(u.bandmeans),5));
            set(gca,'xtick',xt)
            set(gca,'xticklabel',u.bandmeans(xt))
        end
        subplot(2,3,6)
        legend(stateslist{2:6},'location','Southeast')
        plot(xl,[0 0],'k')
        title('bands at 1sec')

        AboveTitle({[celltype 'PopMeanVsBands ' num2str(tbinwidth) ' Sec Bins']})
    end
end
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'png')
        


%% Correlation by band - mean of all CELLS in spectrogram-like display
h = [];
col = RainbowColors(length(stateslist));
plotbinlist = [.1 1 10];
for bidx = 1:length(plotbinlist)
    tbinwidth = plotbinlist(bidx);
    tbidx = (u.binwidthseclist==tbinwidth);
    for iidx = 1:2
        if iidx == 1;
            celltype = 'E';
        elseif iidx == 2
            celltype = 'I';
        end

        h(end+1) = figure('position',[1 1 1200 800],'Name',['BandPowerVsSingleUnitSpikeRates_AllCellMeans_' celltype 'Cell_' num2str(tbinwidth) 'SecBins']);
%         for stidx = 1:length(stateslist)
        for stidx = 2:6
            tst = stateslist{stidx};
            eval(['thisr = u.r_Cells' celltype tst ';'])

            subplot(2,3,stidx-1)
            plot(nanmean(thisr(:,:,tbidx),2));
            axis tight
            hold on
            xl = xlim(gca);
            plot(xl,[0 0],'r')
            plot(xl,[.03 .03],'color',[1 .7 .7])
            xlabel('Frequency(Hz)')
            xt = round(linspace(1,length(u.bandmeans),5));
            set(gca,'xtick',xt)
            set(gca,'xticklabel',u.bandmeans(xt))

            ylabel('Rate-Power Corr(r)')
            title(tst,'fontweight','normal')

            subplot(2,3,6)
            hold on
            plot(nanmean(thisr(:,:,tbidx),2),'color',col(stidx,:),'linewidth',2)
            hold on
            xl = xlim(gca);
            xt = round(linspace(1,length(u.bandmeans),5));
            set(gca,'xtick',xt)
            set(gca,'xticklabel',u.bandmeans(xt))
        end
        subplot(2,3,6)
        legend(stateslist{2:6},'location','Southeast')
        plot(xl,[0 0],'k')
        title('bands at 1sec')

        AboveTitle({[celltype 'CellMeanVsBands ' num2str(tbinwidth) ' Sec Bins']})
    end
end
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrelationSpecta'),h,'png')
        
    
%% Histograms of cell-wise R values 
h = [];
col = RainbowColors(length(stateslist));
plotbinlist = [.1 1 10];
for bidx = 1:length(plotbinlist)
    tbinwidth = plotbinlist(bidx);
    for iidx = 1:2
        if iidx == 1;
            celltype = 'E';
            nhistbins = 100;
        elseif iidx == 2
            celltype = 'I';
            nhistbins = 50;
        end
        h(end+1) = figure('position',[5 5 1200 700],'name',['CellwiseCorrWBroadbandGamma' celltype 'Cells' num2str(tbinwidth) 'SecBin']); 

%         for stidx = 1:length(stateslist)
        for stidx = 2:6
            tst = stateslist{stidx};

            subplot(2,3,stidx-1)
            eval(['tr = u.r_Cells' celltype tst ';'])
    %         hist(mean(tr(broadbandbins,:,u.binwidthseclist==plotbinwidth),1),100);
            [tcts,tcntrs] = hist(mean(tr(broadbandbins,:,u.binwidthseclist==tbinwidth),1),nhistbins);
            bar(tcntrs,tcts)
            eval(['HistRCounts' celltype tst ' = tcts;'])
            eval(['HistRCenters' celltype tst ' = tcts;'])
            axis tight
            hold on
            yl = ylim;
            plot([0 0],yl,'r')
            title(tst)

            subplot(2,3,6)
            plot(tcntrs,smooth(tcts),'linewidth',2)
            axis tight
            hold on
            yl = ylim;
            title('State Overlay')
        end
        subplot(2,3,6)
        legend(stateslist{2:6},'location','Northeast')
        plot([0 0],yl,'k')
        AboveTitle([celltype 'Cells ' num2str(tbinwidth) 'Sec Bins vs Broadband Gamma:' num2str(broadbandgammarange(1)) '-' num2str(broadbandgammarange(2)) 'Hz']);
   end
end
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','HistogramsOfCellRsVsBroadband'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','HistogramsOfCellRsVsBroadband'),h,'png')

%% Relating firing rate and gamma correlation
h = [];
plotbinlist = [.1 1 10];
for bidx = 1:length(plotbinlist)
    tbinwidth = plotbinlist(bidx);
    a = u.WakeRates;
    bbg = nanmean(u.r_CellsEWake(broadbandbins,:,u.binwidthseclist==tbinwidth));
    c = nanstd(u.r_CellsEWake(broadbandbins,:,u.binwidthseclist==tbinwidth));
    d = nanmax(u.r_CellsEWake(broadbandbins,:,u.binwidthseclist==tbinwidth));
    f = nanmin(u.r_CellsEWake(broadbandbins,:,u.binwidthseclist==tbinwidth));
    g = d-f;

    h(end+1) = figure('name',['FiringRateVsBBGammaCorrPerCell_' num2str(tbinwidth) 'SecBins']);
    subplot(2,3,1)
        PlotAndRegressLogAndLinear(a(:),bbg(:));
    %     ScatterWStats(a(:),bbg(:),'logx');
        xlabel('Firing Rate')
        ylabel('Correlation w Broadband')
        axis tight
    subplot(2,3,2)
        PlotAndRegressLog(a(:),c(:));
    %     ScatterWStats(a(:),c(:),'logx');
        xlabel('Firing Rate')
        ylabel('STD across bands')
        axis tight
    subplot(2,3,3)
        PlotAndRegressLogAndLinear(a(:),c(:)./bbg(:));
    %     ScatterWStats(a(:),c(:)./bbg(:),'logx');
        xlabel('Firing Rate')
        ylabel('CV across bands')
        axis tight
    subplot(2,3,4)
        PlotAndRegressLogAndLinear(a(:),d(:));
    %     ScatterWStats(a(:),d(:),'loglog');
        xlabel('Firing Rate')
        ylabel('Max of corr across bands')
        axis tight
    subplot(2,3,5)
        PlotAndRegressLogAndLinear(a(:),f(:));
    %     ScatterWStats(a(:),f(:),'logx');
        xlabel('Firing Rate')
        ylabel('Min of corr across bands')
        axis tight
    subplot(2,3,6)
        PlotAndRegressLog(a(:),g(:));
    %     ScatterWStats(a(:),g(:),'loglog');
        xlabel('Firing Rate')
        ylabel('Range of corr across bands')
        axis tight
        
        AboveTitle([num2str(tbinwidth),' Sec bins'])
end
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','PerCellRateVsGammaPowerRateCorr'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','PerCellRateVsGammaPowerRateCorr'),h,'png')

%% Varying bin size and frequency at once

h(1) = figure('Name','ImageOfECellMeanCorrsOverBinFreq','position',[10 100 1300 1000]);
h(2) = figure('Name','ImageOfICellMeanCorrsOverBinFreq','position',[10 100 1300 1000]);
% for stidx = 1:length(stateslist)
for iidx = 1:2
    figure(h(iidx))
    if iidx == 1;
        celltype = 'E';
        nhistbins = 100;
    elseif iidx == 2
        celltype = 'I';
        nhistbins = 50;
    end
    for stidx = 2:6%only Wake, NREM, REM
        tst = stateslist{stidx};

        eval(['thisr = u.r_Cells' celltype tst ';'])
        thisr1 = squeeze(nanmean(thisr,2));
        thisr2 = zscore(squeeze(nanmean(thisr,2)),[],1);
        thisr3 = squeeze(nanstd(thisr,[],2)./nanmean(thisr,2));
%         thisr3 = squeeze(nanstd(thisr,[],2));
        thisr4 = zscore(thisr,[],1);
        xt = round(linspace(1,length(u.bandmeans),5));
        
        % Raw correlations
        subplot(4,5,stidx-1)
        imagesc(thisr1')
        colorbar
        axis xy
        axis square
        xlabel('Frequency(Hz)')
        set(gca,'xtick',xt);
        set(gca,'xticklabel',u.bandmeans(xt))
        ylabel('BinSize(s)')
        yt = get(gca,'ytick');
        set(gca,'yticklabel',u.binwidthseclist(yt))
        title([tst,': Mean Corrs'])
        

        % map of where per-cell peaks occur in raw data
        xband = [];
        ybinsz = [];
        thiscellmax = max(thisr,[],3,'omitnan');
        thiscellmax = max(thiscellmax,[],1,'omitnan');
        for cidx = 1:size(thisr,2)
            [x,y] = find(thisr(:,cidx,:)==thiscellmax(cidx));
            xband = cat(2,xband,x(:)');
            ybinsz = cat(2,ybinsz,y(:)');
        end
        [counts,bins1,bins2]=hist2d(xband,ybinsz,1:length(u.bandmeans),1:length(u.binwidthseclist));
        subplot(4,5,stidx-1+5)
        imagesc(counts)
        axis xy
        colorbar
        axis square        
        xlabel('Frequency(Hz)')
        set(gca,'xtick',xt);
        set(gca,'xticklabel',u.bandmeans(xt))
        ylabel('BinSize(s)')
        yt = get(gca,'ytick');
        set(gca,'yticklabel',u.binwidthseclist(yt))
        title([tst,':Max points per cell (raw)'])
        
%         % coefficient of variation across cells
%         subplot(4,3,stidx-1+6)
%         imagesc(thisr3')
%         axis xy
%         xlabel('Frequency(Hz)')
%         xt = get(gca,'xtick');
%         set(gca,'xticklabel',u.bandmeans(xt))
%         ylabel('BinSize(s)')
%         yt = get(gca,'ytick');
%         set(gca,'yticklabel',u.binwidthseclist(yt))
%         colorbar
%         title([tst,':CoV Corrs (over cells)'])
%         axis square
        
        % ZScored correlations
        subplot(4,5,stidx-1+10)
        imagesc(thisr2')
        axis xy
        colorbar
        axis square        
        xlabel('Frequency(Hz)')
        set(gca,'xtick',xt);
        set(gca,'xticklabel',u.bandmeans(xt))
        ylabel('BinSize(s)')
        yt = get(gca,'ytick');
        set(gca,'yticklabel',u.binwidthseclist(yt))
        title([tst,':Zscored Corrs'])

        % map of where per-cell peaks occur in Zscore data
        xband = [];
        ybinsz = [];
        thiscellmax = max(thisr4,[],3,'omitnan');
        thiscellmax = max(thiscellmax,[],1,'omitnan');
        for cidx = 1:size(thisr4,2)
            [x,y] = find(thisr4(:,cidx,:)==thiscellmax(cidx));
            xband = cat(2,xband,x(:)');
            ybinsz = cat(2,ybinsz,y(:)');
        end
        [counts,bins1,bins2]=hist2d(xband,ybinsz,1:length(u.bandmeans),1:length(u.binwidthseclist));
        subplot(4,5,stidx-1+15)
        imagesc(counts)
        axis xy
        colorbar
        axis square        
        xlabel('Frequency(Hz)')
        set(gca,'xtick',xt);
        set(gca,'xticklabel',u.bandmeans(xt))
        ylabel('BinSize(s)')
        yt = get(gca,'ytick');
        set(gca,'yticklabel',u.binwidthseclist(yt))
        title([tst,':Max points per cell (zscored)'])
    end
    AboveTitle([celltype ' Cells'])
end

% figure;plot(xband,ybinsz,'.')
% figure;bar3(counts)
% figure;imagesc(counts)

MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrVsFreqAndBinSz'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrVsFreqAndBinSz'),h,'png')




%% Relating band-wise correlations against each other correlation
h = [];
plotbinlist = [.1 1 10];
for bidx = 1:length(plotbinlist)
    tbinwidth = plotbinlist(bidx);
    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};

        for iidx = 1:2
            if iidx == 1;
                celltype = 'E';
            elseif iidx == 2
                celltype = 'I';
            end
        
            eval(['bbgammar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(broadbandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['deltar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(deltabandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['thetar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(thetabandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['sigmar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(sigmabandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['betar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(betabandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['lgammar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(lowgammabandbins,:,u.binwidthseclist==tbinwidth));'])
            eval(['hhgammar' tst celltype ' = nanmean(u.r_Cells' celltype tst '(highhighgammabandbins,:,u.binwidthseclist==tbinwidth));'])

            h(end+1) = figure('position',[5 5 1500 800],'name',['ModulationPerECellPerBand_' num2str(tbinwidth),'sec' tst]);
            eval(['mcorr_bw(deltar' tst celltype ',thetar' tst celltype...
                ',sigmar' tst celltype ',betar' tst celltype ',lgammar'...
                tst celltype ',bbgammar' tst celltype ',hhgammar'...
                tst celltype ');'])
            AboveTitle([tst celltype])
        end
    end
end

MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrOfPowerRateCorrsAcrossBands'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','CorrOfPowerRateCorrsAcrossBands'),h,'png')

%% Per cell looking for changes in R value vs BBGamma across states
h = [];
h(end+1) = figure('Name','BBGammaModulationByStatePerCell','position',[10 0 1200 1000]);
count = 1;
for stidx1 = 2:6
    tst1 = stateslist{stidx1};    
    
    for stidx2 = 2:6
        tst2 = stateslist{stidx2};   
        if stidx1 >= stidx2
            count = count+1;
            continue
        end
        subplot(5,5,count)
        eval(['PlotAndRegressLinear(bbgammar' tst1 'E,bbgammar' tst2 'E,[0 1 0]);'])
        hold on;
        eval(['PlotAndRegressLinear(bbgammar' tst1 'I,bbgammar' tst2 'I,[1 0 0]);'])
        xl = xlim;
        yl = ylim;
        plot(xl,[0 0],'color',[.2 .2 .2])
        plot([0 0],yl,'color',[.2 .2 .2])
        eval(['plot(nanmedian(bbgammar' tst1 'E),nanmedian(bbgammar' tst2 'E),''marker'',''.'',''color'',[0 .6 0],''markersize'',50)'])
        eval(['plot(nanmedian(bbgammar' tst1 'I),nanmedian(bbgammar' tst2 'I),''marker'',''.'',''color'',[.6 0 0],''markersize'',50)'])
        xlabel(tst1)
        ylabel(tst2)
        axis square
        count = count+1;
    end
end
AboveTitle('Green: pE.  Red: pI')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','ShiftingCorrsByState'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs','ShiftingCorrsByState'),h,'png')


%%
shortbinidx = 1;
medbinidx = 7;
longbinidx = 13;
shortbinsecs = u.binwidthseclist(shortbinidx);
medbinsecs = u.binwidthseclist(medbinidx);
longbinsecs = u.binwidthseclist(longbinidx);

wake_shortbinE = u.r_AllEWakeToBroad(1,:);
nrem_shortbinE = u.r_AllENremToBroad(1,:);
rem_shortbinE = u.r_AllERemToBroad(1,:);
shortbinsE = [wake_shortbinE;nrem_shortbinE;rem_shortbinE]';
wake_shortbinI = u.r_AllIWakeToBroad(1,:);
nrem_shortbinI = u.r_AllINremToBroad(1,:);
rem_shortbinI = u.r_AllIRemToBroad(1,:);
shortbinsI = [wake_shortbinI;nrem_shortbinI;rem_shortbinI]';

wake_medbinE = u.r_AllEWakeToBroad(7,:);
nrem_medbinE = u.r_AllENremToBroad(7,:);
rem_medbinE = u.r_AllERemToBroad(7,:);
medbinsE = [wake_medbinE;nrem_medbinE;rem_medbinE]';
wake_medbinI = u.r_AllIWakeToBroad(7,:);
nrem_medbinI = u.r_AllINremToBroad(7,:);
rem_medbinI = u.r_AllIRemToBroad(7,:);
medbinsI = [wake_medbinI;nrem_medbinI;rem_medbinI]';

wake_longbinE = u.r_AllEWakeToBroad(12,:);
nrem_longbinE = u.r_AllENremToBroad(12,:);
rem_longbinE = u.r_AllERemToBroad(12,:);
longbinsE = [wake_longbinE;nrem_longbinE;rem_longbinE]';
wake_longbinI = u.r_AllIWakeToBroad(12,:);
nrem_longbinI = u.r_AllINremToBroad(12,:);
rem_longbinI = u.r_AllIRemToBroad(12,:);
longbinsI = [wake_longbinI;nrem_longbinI;rem_longbinI]';

% shortbinsE(isnan(shortbinsE)) = 0;
% medbinsE(isnan(medbinsE)) = 0;
% longbinsE(isnan(longbinsE)) = 0;
% shortbinsI(isnan(shortbinsI)) = 0;
% medbinsI(isnan(medbinsI)) = 0;
% longbinsI(isnan(longbinsI)) = 0;

h = figure('Name','BroadbandCorrByStateAndBinSize','position',[10 100 900 600]);

subplot(2,3,1)
    distributionPlot(shortbinsE)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(shortbinsecs) ' sec bins, pE'])
    SignificanceInset(gca,{wake_shortbinE;nrem_shortbinE;rem_shortbinE;});
subplot(2,3,2)
    distributionPlot(medbinsE)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(medbinsecs) ' sec bins, pE'])
    SignificanceInset(gca,{wake_medbinE;nrem_medbinE;rem_medbinE});
subplot(2,3,3)
    distributionPlot(longbinsE)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(longbinsecs) ' sec bins, pE'])
    SignificanceInset(gca,{wake_longbinE;nrem_longbinE;rem_longbinE;});

subplot(2,3,4)
    distributionPlot(shortbinsI)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(shortbinsecs) ' sec bins, pI'])
    SignificanceInset(gca,{wake_shortbinI;nrem_shortbinI;rem_shortbinI;});
subplot(2,3,5)
    distributionPlot(medbinsI)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(medbinsecs) ' sec bins, pI'])
    SignificanceInset(gca,{wake_medbinI;nrem_medbinI;rem_medbinI});
subplot(2,3,6)
    distributionPlot(longbinsI)
    axis square
    set(gca,'xticklabel',{'WAKE','nonREM','REM'})
    title([num2str(longbinsecs) ' sec bins, pI'])
    SignificanceInset(gca,{wake_longbinI;nrem_longbinI;rem_longbinI;});
    
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs'),h,'fig')
MakeDirSaveFigsThere(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','BandPowerVsSingleUnitFigs'),h,'png')

1;