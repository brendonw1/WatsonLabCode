function [AssemblyBasicData,h] = GetICAAssembliesPrebinnedNoProj(iBinnedMatrix,binsecs,CellIDs)
% specify interval of times to determine components from

% binpoints = binsecs*10000;
numtotalcells = size(iBinnedMatrix,2);

% iS = CompressSpikeTrainsToIntervals(S,restrictints);%compress to wake spiking only 
% iSBinned = MakeQfromS(iS,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
% iBinnedMatrix = Data(iSBinned);

% Find assembly patterns
opts.threshold.method = 'MarcenkoPastur';
opts.Patterns.method = 'ICA';
opts.Patterns.number_of_iterations = 1000;

if isempty(iBinnedMatrix)
    Patterns = [];
    Threshold = [];
    NonSignifPatterns = [];
    cellnum = [];
    assemblynum = [];
    AssemblyBasicData = v2struct(opts,binsecs,Patterns,Threshold,cellnum,assemblynum,NonSignifPatterns);
    h = [];
else
    [Patterns,Threshold,NonSignifPatterns] = assembly_patterns_bw(iBinnedMatrix',opts);

    % Find and label neurons with significant contributions on to assemblies
    [cellnum,assemblynum]=find(abs(Patterns)>Threshold);%find cell,assembly ID's of contributions with abs>Threshold
    % shigecellnum = cellinds(cellnum,2);%convert back to shige's number system

    % empties = setdiff(1:size(Patterns,2),unique(assemblynum));% for some reason sometimes some "patterns" or assemblies actually have no cells above threshold
    % Patterns(:,empties) = [];%if find such assemblies, delete them

    % Plot Assembly PatternsPrep for all but final analysis BWRat19... anticipate  

    maxproj = max(Patterns(:));%get the max projection of any initial variable onto any PC
    minproj = min(Patterns(:));%get the min
    numassemblies = size(Patterns,2);

    [vert,horiz]=determinenumsubplots(numassemblies);

    if numassemblies<1
        h = [];
    else 
        %Stem plots of assemblies
        h = figure;
        for a = 1:numassemblies
            subplot(vert,horiz,a);
            hold on
            signifassemblycellinds = cellnum(find(assemblynum==a));
            othercellinds = setdiff((1:numtotalcells),signifassemblycellinds);
            stem(othercellinds,Patterns(othercellinds,a),'color','k');
            if ~isempty(signifassemblycellinds)
                if exist('CellIDs','var')
                    Es = intersect(signifassemblycellinds,CellIDs.EAll);
                    Is = intersect(signifassemblycellinds,CellIDs.IAll);
                    if ~isempty(Es)
                        stem(Es,Patterns(Es,a),'color','g');
                    end
                    if ~isempty(Is)
                        stem(Is,Patterns(Is,a),'color','r');
                    end
                else
                    stem(signifassemblycellinds,Patterns(signifassemblycellinds,a),'color','c');
                end
            end
            plot([1 numtotalcells],[Threshold Threshold],'color',[.5 .5 .5])
            plot([1 numtotalcells],[-Threshold -Threshold],'color',[.5 .5 .5])
            xlim([1 numtotalcells])
            ylim([minproj maxproj])
            title(['Assembly ',num2str(a)])
            for b = 1:length(signifassemblycellinds)
                x = signifassemblycellinds(b);
                y = Patterns(signifassemblycellinds(b),a);
                textstr = num2str(signifassemblycellinds(b));
                text(x+1,y,textstr)
            end
        end
        % >> highlight connected cells in green or red
    end

    AssemblyBasicData = v2struct(opts,binsecs,Patterns,Threshold,cellnum,assemblynum,NonSignifPatterns);

    % SumAssemblyActivities = sum(abs(AssemblyActivities),1);
end

% Plot activity of each assembly
% figure 
% subplot(3,1,1) 
% imagesc(binnedEachCellData')
% xlim([1 size(AssemblyActivities,2)])
% 
% subplot(3,1,2) 
% hold on;
% plot(SumAssemblyActivities,'k')
% plot(AssemblyActivities')
% xlim([1 size(AssemblyActivities,2)])
% title('Activities of assemblies found by PCA: Erepmat(sum(ccg,1),size(ccg,1),1)ach color is 1 assembly, Black is sum of all others')
% 
% subplot(3,1,3)s
% hold on
% plot(sum(binnedEachCellData,2),'k')
% % plotIntervalsStrip(gca,intervals,1)
% % plot(binnedTrains.EAll,'g')
% % plot(binnedTrains.IAll,'r')
% plotIntervalsStrip(gca,intervals,.1)

% title({['Spikes from All cells (black), all ECells (green) and all ICells (red)'];['Bottom state indicator: Dark blue-wake, Cyan-SWS, Magenta-REM']})

function barbyei(EIR)
eEIR = find(EIR>0.5);%Ecell dominated
iEIR = find(EIR<0.5);%Icell dominated
nEIR = find(EIR==0.5);%neutral
if ~isempty(eEIR)
    barh(eEIR,EIR(eEIR),'g');
end
hold on;
if ~isempty(iEIR)
    barh(iEIR,EIR(iEIR),'r');
end
if ~isempty(nEIR)
    barh(nEIR,EIR(nEIR),'k');
end
