function RidgeLinePlots(inputArg1,inputArg2)
rats = {'Achilles_120413', 'Bogey_012715', 'Bogey_012915', 'Bogey_020215', 'BWRat20_101513', 'c3po_160218', 'c3po_160225', 'c3po_160302', 'Dino_072914', 'Dino_080114','Splinter_021015', 'Splinter_021215', 'Splinter_021615'};
filter = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
%filter= {0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
%for ref {A, B, B, B, W, C, C, C, D, D, S, S, S}

    for i = 1:length(rats)
        if filter{i}
            parentdir = '/analysis/BWRatKetamineDataset/';
            dirstring = [parentdir, rats{i}];
            cd(dirstring);
            
            load([rats{i}, '.SleepState.states.mat']);
            load([rats{i}, '_InjectionComparisionIntervals.mat']);
            
            %dataofchoice = HighLowFRRatio(cd,'all',5,1,6,true);
            dataofchoice = EIRatio(cd,5,1,1);
            subdataofchoice = dataofchoice.EI;
            
            wake = SleepState.ints.WAKEstate;
            
            combinedWakeHR = {};
            combinedWakeHRpostinj = {};
            combinedWakeHRsub = [];
            combinedWakeHRpostinjsub = [];
            
            j = 1;
            divy = 6;
            startlim = InjectionComparisionIntervals.BaselineEndRecordingSeconds / divy;
            for k = 1:divy
            while wake(j,2) < startlim %this conditional may be a problem
                combinedWakeHRsub = [combinedWakeHRsub; subdataofchoice(round(wake(j,1) / dataofchoice.binwidthsecs):(round(wake(j,2) / dataofchoice.binwidthsecs)))];
                j = j + 1;
            end
            combinedWakeHR{k} = combinedWakeHRsub;
            combinedWakeHRsub = [];
            startlim = startlim + (startlim / k);
            end
            
            for k = 1:divy 
            while wake(j,2) < startlim
                combinedWakeHRpostinjsub = [combinedWakeHRpostinjsub; subdataofchoice(round(wake(j,1) / dataofchoice.binwidthsecs):(round(wake(j,2) / dataofchoice.binwidthsecs)))];
                j = j + 1;
            end
            combinedWakeHRpostinj{k} = combinedWakeHRpostinjsub; 
            combinedWakeHRpostinjsub = [];
            startlim = startlim + (3600);
            end
            
            %finding the best binwidth for the data.
            binwidth = max(subdataofchoice) / 30;
            
            %making a cell of just histogram plots per hour. 
            figure;
            c = colormap(jet);
            histogs = {};
            for l = 1:length(combinedWakeHR)
                histogs{l} = histogram(combinedWakeHR{l},'BinWidth',binwidth,'FaceAlpha',.25,'FaceColor',c(round(l * length(c)/12),:));
                hold on;
            end
            for h = 1:length(combinedWakeHRpostinj)
                histogs{h + l} = histogram(combinedWakeHRpostinj{h},'BinWidth',binwidth,'FaceAlpha',.25,'FaceColor',c(round((h+l) * length(c)/12),:));
                hold on;
            end
            
            maxbins = 0;
            for l = 1:length(histogs)
                if maxbins < histogs{l}.NumBins
                    maxbins = histogs{l}.NumBins;
                end
            end
            
            joyplotdat = zeros(length(histogs),maxbins);
            
            for l = 1:length(histogs)
                joyplotdat(l,1:length(histogs{l}.Values)) = histogs{l}.Values; 
            end
            
            figure;
            joyPlot(joyplotdat',1:maxbins,25,'FaceColor',mean(joyplotdat,2));
            title('spacing is 25')
            
            figure;
            joyPlot(joyplotdat',1:maxbins,50,'FaceColor',mean(joyplotdat,2));
            title('spacing is 50')
            
            %plotting the line version of this
            figure;
            for y = 1:length(histogs)
                plot((histogs{y}.Values),'Color',c(round(y * length(c)/length(histogs)),:),'LineWidth',2)
                hold on;
            end
            
            
            %making a colorbar
%             figure;
%             for p = 1:12
%                 plot(p*[1,1,1,1],'Color',c(round(p * length(c)/length(histogs)),:))
%                 hold on;
%             end
            
            %testing some shit out.
%             justdata = {};
%             for y = 1:length(histogs)
%                 justdata{y} = histogs{y}.Values;
%             end
            
        end
    end
end

