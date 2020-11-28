function PlotGathered_PopSpikingPredictorCorrs(folderpath)

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','PopSpikingPredictorCorrs.mat'),'PopSpikingPredictorCorrs')
t = PopSpikingPredictorCorrs;
clear PopSpikingPredictorCorrs

saveloc1 = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','PopSpikingPredictors');
saveloc2 = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','PopSpikingPredictors','SubsetForFigure');

PredictorNames = t.PredictorNames{1};

%% 
h1 = [];
h2 = [];
plotidxsforfig = [3:10,21];%band powers and projection of ECorr

for iidx = 1:2
    if iidx == 1;
        celltype = 'E';
    elseif iidx == 2
        celltype = 'I';
    end
    %linear or log of output
    for ll1 = 1:2;
        if ll1 == 1;
            ll1name = 'linear';
        else
            ll1name = 'log';
        end
        %linear or log of inputs
        for ll2 = 1:2;
            if ll2 == 1;
                ll2name = 'linear';
            else
                ll2name = 'log';
            end
            %now have ins and out... go to town

            tname = [ll2name 'PredictorsVs' ll1name celltype 'PopSpikes'];
            eval(['tR = t.' tname '.Rs;'])
            
            h1(end+1) = figure('Name',['PopSpikingPredictors_' tname],'position',[10 100 900 600]);
            distributionPlot(tR')
            axis tight
            set(gca,'XTick',1:length(PredictorNames),'XTickLabels',PredictorNames)
            xticklabel_rotate
            title(tname)
%             SignificanceInset(gca,{});

            h2(end+1) = figure('Name',['PopSpikingPredictors_' tname],'position',[10 100 900 600]);
            distributionPlot(tR(plotidxsforfig,:)')
            axis tight
            set(gca,'XTick',1:length(PredictorNames(plotidxsforfig)),'XTickLabels',PredictorNames(plotidxsforfig))
            xticklabel_rotate
            title(tname)

        end
    end
end

MakeDirSaveFigsThere(saveloc1,h1,'fig')
MakeDirSaveFigsThere(saveloc1,h1,'png')
MakeDirSaveFigsThere(saveloc2,h2,'fig')
MakeDirSaveFigsThere(saveloc2,h2,'png')
