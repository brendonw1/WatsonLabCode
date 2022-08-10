rat = 'Quiksilver';


%% Just need LFParray from LFPRead in Documents and some spikes by using this right here:
if ~exist('LFParray','var')
    cd(['/analysis/Dayvihd/',rat,'/Field Potentials']) 
    LFPtable = readtable([rat,' FP19.csv']);
    LFParray = table2array(LFPtable); 
end
%% Note: if using buzcode format, use:
% bz_GetLFP('all'); LFParray = double(ans.data);

%Keep in mind that allspikecells is identical to spikes.times in bz format
if ~exist('allspikecells','var') 
    cd(['/analysis/Dayvihd/',rat,'/Spikes']) %This only has the spikes in it
    directory = dir('*.csv');
    allspikecells = {};
    for i = 1:length(directory)
        allspikecells{i} = readtable(directory(i).name);
    end
    for i=1:length(allspikecells)
        try
        allspikecells{i} = correctTable(table2array(allspikecells{i}));
        catch
        allspikecells{i} = table2array(allspikecells{i})';
        end
    end
end
%% You also would need the wake windows. 
% For Nicolette's rats they would be found in /analysis/Dayvihd. Use
% MakeSleepStates. It should be a variable called ints that you can pretty
% readily use. 
if ~exist('ints','var')
    ints = makeints(rat);
end
%% Lastly, you need the function getCoherence found in Downloads.
%This function is located in /home/davskim/downloads

%Comparisons to make:
%Spike to Delta NREM 
%Spike to theta REM
%Spike to theta wake

hypnogram = MakeHypno(ints);
%% ALL LFP #NO FILTER
samp = 1000;
% Sleepstate = 'WAKE';
% Band = 'LFP';
% [ParentSleepSpkandLFP, filteredCoh] = MakeParentSleepSpkandLFP(allspikecells,LFParray,ints.WAKEstate,Sleepstate,Band,samp);
% plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFP,filteredCoh,Sleepstate,Band,hypnogram)


%% THETA WAKE and SPIKES
LFParrayTH = bandpass(LFParray,[4 10],1000);
Sleepstate = 'WAKE';
Band = 'THETA';
[ParentSleepSpkandLFPTHW, filteredCohWT] = MakeParentSleepSpkandLFP(allspikecells,LFParrayTH,ints.WAKEstate,Sleepstate,Band,samp);
plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFPTHW,filteredCohWT,Sleepstate,Band,hypnogram,rat)

%% THETA REM and SPIKES
Sleepstate = 'REM';
Band = 'THETA';
[ParentSleepSpkandLFPTHR, filteredCohRT] = MakeParentSleepSpkandLFP(allspikecells,LFParrayTH,ints.REMstate,Sleepstate,Band,samp);
plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFPTHR,filteredCohRT,Sleepstate,Band,hypnogram,rat)

%% DELTA NREM and SPIKES
LFParrayDE = bandpass(LFParray,[0.5 3.9],1000);
Sleepstate = 'NREM';
Band = 'DELTA';
[ParentSleepSpkandLFPDNR, filteredCohND] = MakeParentSleepSpkandLFP(allspikecells,LFParrayDE,ints.NREMstate,Sleepstate,Band,samp);
plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFPDNR,filteredCohND,Sleepstate,Band,hypnogram,rat)

%% MIDGAM WAKE and SPIKES
% LFParrayWMG = bandpass(LFParray,[60 100],1000);
% Sleepstate = 'WAKE';
% Band = 'MID GAMMA';
% [ParentSleepSpkandLFPWMG, filteredCohWMG] = MakeParentSleepSpkandLFP(allspikecells,LFParrayWMG,ints.WAKEstate,Sleepstate,Band,samp);
% plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFPWMG,filteredCohWMG,Sleepstate,Band,hypnogram,rat)

function plotSingleDat(hypno,ratname,ParentDNR,ParentTHR,ParentTHW)
    %Use plotSingleDat(hypnogram,rat,ParentSleepSpkandLFPDNR,ParentSleepSpkandLFPTHR,ParentSleepSpkandLFPTHW)
    fDNR = makefilteredCoh(ParentDNR);
    fTHR = makefilteredCoh(ParentTHR);
    fTHW = makefilteredCoh(ParentTHW);
    goodorbad1 = nanChecker(ParentDNR);
    goodorbad2 = nanChecker(ParentTHR);
    goodorbad3 = nanChecker(ParentTHW);
    
    goodorbad = goodorbad1 .* goodorbad2 .* goodorbad3;
    for i = 1:length(goodorbad)
        if goodorbad(i)
            figure;
            subplot(2,1,1);
            plot(cell2mat(ParentDNR{1,i}(:,7)),fDNR{i},'LineWidth',2);
            axis tight;
            ylim([0 1]);
            hold on;
            plot(cell2mat(ParentTHR{1,i}(:,7)),fTHR{i},'LineWidth',2);
            plot(cell2mat(ParentTHW{1,i}(:,7)),fTHW{i},'LineWidth',2);
            hold off;
            legend('DeltaNREM','ThetaREM','ThetaWAKE')
            subplot(2,1,2);
            imagesc(hypno);
            colorMap = [255/256 255/256 0; 102/256 178/256 255/256; 255/256 102/256 178/256];
            colormap(colorMap);
            sgtitle([ratname ' Filtered Coherence Val for Unit ' num2str(i)]);
        end
    end
    
end

function [ints] = makeints(ratname)
    cd(['/analysis/Dayvihd/',ratname]);
    wakeints = table2array(readtable([cd '/' ratname ' Wake Windows.csv']));
    nremints = table2array(readtable([cd '/' ratname ' NREM Windows.csv']));
    remints = table2array(readtable([cd '/' ratname ' REM Windows.csv']));

    ints = struct('WAKEstate',wakeints,'NREMstate',nremints,'REMstate',remints);
end

function [hypno] = MakeHypno(ints)
    maxtime = max([max(ints.WAKEstate) max(ints.NREMstate) max(ints.REMstate)]);

    hypno = zeros(1,round(maxtime));
    for i = 1:length(hypno)
        for j = 1:length(ints.WAKEstate(:,1))
            if (i > ints.WAKEstate(j,1) && i < ints.WAKEstate(j,2))
                hypno(i) = .9;
            end
        end
        for j = 1:length(ints.NREMstate(:,1))
            if (i > ints.NREMstate(j,1) && i < ints.NREMstate(j,2))
                hypno(i) = 1.5;
            end
        end
        for j = 1:length(ints.REMstate(:,1))
            if (i > ints.REMstate(j,1) && i < ints.REMstate(j,2))
                hypno(i) = 2.9;
            end
        end    
    end
end

function plotSleepSpkandLFP(allspikecells,ParentSleepSpkandLFP,filteredCoh,Sleepstate,Band,hypnogram,rat)
    goodorbad = nanChecker(ParentSleepSpkandLFP);
    figure;
    spindex = 1;
    for i = 1:length(allspikecells)
        if goodorbad(i)
        subplot(sum(goodorbad) + 1,1,spindex)
        spindex = spindex + 1;
        plot(cell2mat(ParentSleepSpkandLFP{1,i}(:,7))/60/60,cell2mat(ParentSleepSpkandLFP{1,i}(:,5)));
        hold on
        plot(cell2mat(ParentSleepSpkandLFP{1,i}(:,7))/60/60,smooth(filteredCoh{i}),'LineWidth',2);
        hold off
        %title(['Spike Train ' num2str(i)]);
        ylabel(['Coherence Val Unit ' num2str(i)]);
        axis tight;
        ylim([0 1]);
        end
    end
    subplot(sum(goodorbad) + 1,1,spindex)
    imagesc(hypnogram);
    colorMap = [255/256 255/256 0; 102/256 178/256 255/256; 255/256 102/256 178/256];
    colormap(colorMap);
    xlabel('Time (Hr)');
    sgtitle([rat, ' Spike Coherence over Time for ',Band,' during ',Sleepstate])
    savefig([rat,Sleepstate,Band,'SpkFPCoh.fig']);
   % savefig([rat,Sleepstate,Band,'SpkFPCoh.png']);
end

function [ParentSleepSpkandLFP, filteredCoh] = MakeParentSleepSpkandLFP(allspikecells,LFParray,Sleepwinds,Sleepstate,Band,samp)
    ParentSleepSpkandLFP = {};
    filteredCoh = {};
    for i = 1:length(allspikecells)
        spikecell = allspikecells(i);
        [ParentSleepSpkandLFP{i}, filteredCoh{i}] = makeSleepSpkandLFP(samp,LFParray,Sleepwinds,spikecell,Sleepstate,Band);
    end
end

function [goodorbad] = nanChecker(ParentSleepSpkandLFP)
    %I basically want this code to take in a sleepspkandlfp nested cell
    %thing and spit out a logical column vector with the bad guys (too many
    %nans) taken out. 
    goodorbad = zeros(1,length(ParentSleepSpkandLFP));
    for i = 1:length(ParentSleepSpkandLFP)
        temp = cell2mat(ParentSleepSpkandLFP{1,i}(:,5));
        nonnan = temp(~isnan(temp));
        if length(nonnan) / length(temp) > .9
            goodorbad(i) = 1;
        end
    end
end

function [filteredCoh] = makefilteredCoh(ParentSleepSpkandLFP)
    filteredCoh = {};
    goodorbad = nanChecker(ParentSleepSpkandLFP);
    for i = 1:length(ParentSleepSpkandLFP)
        if goodorbad(i)
            filteredCoh{i} = movmean(cell2mat({ParentSleepSpkandLFP{1,i}{:,5}}),8);
        else
            filteredCoh{i} = [];
        end
    end
end

function [SleepSpkandLFP, filteredCoh] = makeSleepSpkandLFP(samp,LFParray,Sleepwinds,spikecell,statetype,lfptype)
    %% Parameters: 
    % samp (sampling frequency)
    % LFP (the goddamn lfp)
    % Sleepwinds (the 2 column matrix of sleep windows)
    % spikecell (a single cell that has a spiketrain... it's weird format, but it works okay?)

    SleepSpkandLFP = {};
    LFPTimestamps = (1/samp:1/samp:length(LFParray)/samp)';
    for i = 1:length(Sleepwinds)
        SleepSpkandLFP{i,1} = ntimeframedivy(Sleepwinds(i,1),Sleepwinds(i,2),spikecell);
        SleepSpkandLFP{i,2} = LFPDivy(Sleepwinds(i,1),Sleepwinds(i,2),LFParray,LFPTimestamps);
        try
        [hana,dul,set,net,dasut] = getCoherence(SleepSpkandLFP{i,1},SleepSpkandLFP{i,2},1000,1,10,0);
        SleepSpkandLFP{i,3} = dul;
        catch
            SleepSpkandLFP{i,3} = [];
            disp('too few spikes I think...')
            disp(i);
            disp(' num units: ')
            disp(length(SleepSpkandLFP{i,1}));
            disp('^^ This should be a low number, otherwise, you might not have included getCoherence filepath')
        end
        SleepSpkandLFP{i,4} = SleepSpkandLFP{i,3}(~isnan(SleepSpkandLFP{i,3}));
        SleepSpkandLFP{i,5} = median(SleepSpkandLFP{i,4});
        SleepSpkandLFP{i,6} = std(SleepSpkandLFP{i,4});
        SleepSpkandLFP{i,7} = (Sleepwinds(i,2) + Sleepwinds(i,1)) / 2; % timestamp for the plotting
    end
    
    filteredCoh = movmean(cell2mat({SleepSpkandLFP{:,5}}),8);
    
    %Commenting out the lower block because I don't want to get inundated
    %with a shit ton of figures.
%     fig = figure;
%     plot(cell2mat({SleepSpkandLFP{:,7}})/60/60,cell2mat({SleepSpkandLFP{:,5}}));
%     hold on;
%     plot(cell2mat({SleepSpkandLFP{:,7}})/60/60,smooth(filteredCoh),'LineWidth',2);
%     xlabel('time (hr)')
%     ylabel('Coherence Metric')
%     title(['Spike Field Coherence of ', statetype, ' to ',lfptype])
end

function [newspikes] = ntimeframedivy(lowlimit,highlimit,spikes)
newspikes = {};
    for k = 1:length(spikes)
        newspikes{1,k} = spikes{1,k}(spikes{1,k} >= lowlimit & spikes{1,k}<= highlimit);
    end
newspikes = cell2mat(newspikes);
checkmono(newspikes);
newspikes = newspikes - lowlimit;
end

function checkmono(vector)
    temp = diff(vector);
    ismonotonic = isempty(temp(temp < 0));
    if ~ismonotonic
        disp('spikes got fucked. Maybe you have more than 1 spike train')
    end
end

function [newLFP] = LFPDivy(lowlimit,highlimit,LFParray,LFPTimestamps)
    newLFP = LFParray(LFPTimestamps >= lowlimit & LFPTimestamps <= highlimit);
end

function [corrected] = correctTable(cellarray)
    corrected = zeros(1,length(cellarray));
    for i = 1:length(cellarray)
        corrected(i) = str2double(cellarray{i});
    end
end