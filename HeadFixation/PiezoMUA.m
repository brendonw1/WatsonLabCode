% Piezo-locked MUA from S1 cortical layers recorded during task (e.g.,
% Go/No-go) or under anesthesia (e.g., whisker-barrel somatotopy).
%
%
%
% OUTPUT STRUCTURES _______________________________________________________
% - stackedChannels - Data behind figure 1: binary and Zscored/smoothed
%   perievent raster plots across channels (with sweeps merged), in
%   addition to a 2-column matrix summarizing channel reactivity (mean Z
%   score during piezo and peak latency in columns 1 and 2 respectively).
% - stackedSweeps - Data behind figures 2 and 3: binary perievent raster
%   plots across sweeps and corresponding spike count histograms from
%   sorted channels (ranked top 8 or bottom 8 in reactivty strength).
%
%
%
% USAGE ___________________________________________________________________
% - Set working directory containing the *.dat, and run.
%
% - Rows are cumulatively added to output structures with successive runs
%   from different chunks (e.g., with stimulation of different whiskers).
%   Hence the user is prompted to name the run (e.g., 'whisker C2').
%   Multiple-whisker structures can then be further analyzed with
%   WhiskerSorting.m.
%
%
%
% LSBuenoJr _______________________________________________________________



%% Loads Intan data, re-maps channels, and sets parameters.
clc;whiskerID = input('Which whisker? ','s');
tic;disp('Loading data')

rawLamnFrng = bz_LoadBinary('amplifier_analogin_auxiliary_int16.dat',...
    'start',9000,...
    'duration',600,...
    'nChannels',73,...
    'channels',[1:64 69]);
rawPiezoWav = rawLamnFrng(:,size(rawLamnFrng,2));
rawLamnFrng = channelMap_CambrH3(rawLamnFrng(:,1:size(rawLamnFrng,2)-1));

samplFreq   = 20000;           % Digitization rate
befPiezo    = 1*samplFreq;     % 1 sec pre-stimulus
durPiezo    = 1*samplFreq;     % 1 sec during stimulus
aftPiezo    = 2*samplFreq;     % 2 sec post-stimulus
largeBins   = 0.010*samplFreq; % Bin sizes: 10 ms
intermBins  = 0.002*samplFreq; % 2 ms
shortBins   = 0.001*samplFreq; % 1 ms
clear samplFreq;toc



%% Gets multi-channel MUA with another custom script.
[~,nonEpoched] = multiChannelMUA(rawLamnFrng);clear rawLamnFrng



%% Aligns MUA and piezo stimuli into perievent sweeps.
tic;disp('Epoching MUA around piezo stimuli')

piezoStamps = [0;diff(rawPiezoWav)];
piezoStamps = find(piezoStamps>((max(piezoStamps)-median(piezoStamps))/2));

epoched     = cell(length(piezoStamps)-2,size(nonEpoched,2));
for j       = 1:size(nonEpoched,2)
    for i   = 2:length(piezoStamps)-1
        epoched{i-1,j} = nonEpoched(...
            piezoStamps(i)-(befPiezo):...
            piezoStamps(i)+(durPiezo+aftPiezo)-1,j)';
    end
end

% Just a representative downsampled piezo waveform for figure plotting
singlePiezo = ((decimate(double(rawPiezoWav(...
    piezoStamps(1)-(befPiezo):...
    piezoStamps(1)+(durPiezo+aftPiezo)-1))',20)-10000)*5)/10000;
singlePiezo([1:befPiezo/20 ((befPiezo+durPiezo)/20)+1:end]) = 0;
clear nonEpoched piezoStamps rawPiezoWav;toc



%% Puts together output structures, and stack them with equivalent
% structures from previous runs (if existent).
tic;disp('Preparing output structures')

temp  = cell(size(epoched,2),8);
for i = 1:size(epoched,2)
    % Channel IDs
    temp{i,1} = i;
    
    % Binary and Zscored/smoothed rasters (stacked channels, merged sweeps)
    temp{i,4} = sum(binning(cell2mat(epoched(:,i)),shortBins,'s'));
    temp{i,5} = temp{i,4};
    temp{i,5}(temp{i,5} > 1)   = 1;
    temp{i,4} = smooth(zscore(temp{i,4}),10)';
    
    % Mean Z score during piezo and latency to response peak (ms)
    temp{i,2} = abs(temp{i,4}(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins));
    temp{i,3} = find(temp{i,2} == max(temp{i,2}));
    temp{i,3} = temp{i,3}(1);
    temp{i,2} = mean(temp{i,2});
    
    % Rasters and histograms (stacked sweeps, ranked channels): whole epoch
    temp{i,6} = binning(cell2mat(epoched(:,i)),largeBins,'s');
    temp{i,7} = temp{i,6};
    temp{i,7}(temp{i,7} > 1)   = 1;
    temp{i,6} = sum(temp{i,6});
    
    % As above, but in zoomed piezo-aligned epochs (no histograms, piezo
    % waveform will be plotted instead)
    temp{i,8} = binning(cell2mat(epoched(:,i)),intermBins,'s');
    temp{i,8}(temp{i,8} > 1)   = 1;
end;sorted    = sortrows(temp(:,[1:3 6:8]),2,'descend');

if exist('stackedChannels','var')     == 0
    stackedChannels(1).whiskerID       = whiskerID;
    stackedChannels(1).binaryRaster    = cell2mat(temp(:,5));
    stackedChannels(1).ZscoredRaster   = cell2mat(temp(:,4));
    stackedChannels(1).meanZscDurPiezo = cell2mat(temp(:,2));
    stackedChannels(1).peakLatencyMS   = cell2mat(temp(:,3));

    % Columns 1-3 of each cell array are respectively: channel IDs,
    % Mean Z score during piezo (the descending sorting criterion used
    % above), and peak latency (ms). Peak latency is used below as the
    % second (ascending) sorting criterion
    stackedSweeps(1).whiskerID         = whiskerID;
    stackedSweeps(1).binaryStrongChn   = sortrows(sorted(1:8,[1:3 5:6]),3);
    stackedSweeps(1).binaryWeakChn     = sortrows(sorted(57:end,[1:3 5:6]),3);
    stackedSweeps(1).spkCountStrongChn = sortrows(sorted(1:8,1:4),3);
    stackedSweeps(1).spkCountWeakChn   = sortrows(sorted(57:end,1:4),3);
else
    stackedChannels(length(stackedChannels)+1).whiskerID     = ...
        whiskerID;
    stackedChannels(length(stackedChannels)).binaryRaster    = ...
        cell2mat(temp(:,5));
    stackedChannels(length(stackedChannels)).ZscoredRaster   = ...
        cell2mat(temp(:,4));
    stackedChannels(length(stackedChannels)).meanZscDurPiezo = ...
        cell2mat(temp(:,2));
    stackedChannels(length(stackedChannels)).peakLatencyMS   = ...
        cell2mat(temp(:,3));
    
    stackedSweeps(length(stackedSweeps)+1).whiskerID         = ...
        whiskerID;
    stackedSweeps(length(stackedSweeps)).binaryStrongChn     = ...
        sortrows(sorted(1:8,[1:3 5:6]),3);
    stackedSweeps(length(stackedSweeps)).binaryWeakChn       = ...
        sortrows(sorted(57:end,[1:3 5:6]),3);
    stackedSweeps(length(stackedSweeps)).spkCountStrongChn   = ...
        sortrows(sorted(1:8,1:4),3);
    stackedSweeps(length(stackedSweeps)).spkCountWeakChn     = ...
        sortrows(sorted(57:end,1:4),3);
end;clear intermBins largeBins sorted temp;toc



%% Figure 1
tic;disp('Plotting perievent data')
figure('name','Stacked-channel rasters (merged sweeps)')

% Top left
sp1 = subplot('position',[0.05 0.35 0.40 0.60]);
imagesc(~stackedChannels(length(stackedChannels)).binaryRaster)
colormap(sp1,gray);title('Binary')
ylabel('Channels across S1 layers');xticklabels([])

% Top right
sp2 = subplot('position',[0.50 0.35 0.40 0.60]);
imagesc(stackedChannels(length(stackedChannels)).ZscoredRaster)
colormap(sp2,jet);caxis([-2 2]);title('Smoothed Z scored')
yticklabels([]);xticklabels([])
colorbar('position',[0.92 0.52 0.005 0.30]);clear sp1 sp2

% Bottom left
subplot('position',[0.05 0.10 0.40 0.20]);
plot(singlePiezo,'k')
ylabel('Piezo vibration (volts)');xlabel('Perievent time (s)')
xticks(0:length(singlePiezo)/8:length(singlePiezo))
xticklabels(-1:0.5:4);

% Bottom right
subplot('position',[0.50 0.10 0.40 0.20]);
plot(singlePiezo,'k')
xticks(0:length(singlePiezo)/8:length(singlePiezo))
xticklabels([]);yticklabels([]);



%% Figure 2
figure('name','Stacked-sweep rasters; eight most reactive channels')

% Left column, top three group of subplots
ax = zeros(8,1);j = 0.83;k = 0.76;colormap(gray)
for i = 1:3
    subplot('position',[0.05 j 0.22 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{i,4})
    xticks([]);yticks([])
    ax(i) = subplot('position',[0.05 k 0.22 0.07]);
    bar(stackedSweeps(length(stackedSweeps)).spkCountStrongChn{i,4},...
        'barwidth',1,'facecolor','k');xticks([]);yticks([])
    text(10,3+(max(stackedSweeps(...
        length(stackedSweeps)).spkCountStrongChn{i,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountStrongChn{i,1})])
    subplot('position',[0.28 j 0.08 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{i,5})
    xticks([]);yticks([])
    subplot('position',[0.28 k 0.08 0.07])
    plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
    xticks([]);yticks([]);j = j-0.23;k = k-0.23;
end

% Bottom left group
subplot('position',[0.05 0.14 0.22 0.14])
imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{4,4})
xticks([]);yticks([]);ylabel([num2str(size(...
    stackedSweeps(length(stackedSweeps)).binaryStrongChn{4,4},1)) ' sweeps'])
ax(4) = subplot('position',[0.05 0.07 0.22 0.07]);
bar(stackedSweeps(length(stackedSweeps)).spkCountStrongChn{4,4},...
    'barwidth',1,'facecolor','k')
xticks(0:...
    length(stackedSweeps(length(stackedSweeps)).spkCountStrongChn{4,4})/8:...
    length(stackedSweeps(length(stackedSweeps)).spkCountStrongChn{4,4}))
ylabel('Spike count');xticklabels(-1:0.5:4);xlabel('Perievent time (s)')
text(10,3+(max(stackedSweeps(...
    length(stackedSweeps)).spkCountStrongChn{4,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountStrongChn{4,1})])
subplot('position',[0.28 0.14 0.08 0.14])
imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{4,5})
xticks([]);yticks([])
subplot('position',[0.28 0.07 0.08 0.07])
plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
xticks([]);yticks([])

% Right column
j = 0.83;k = 0.76;
for i = 5:8
    subplot('position',[0.53 j 0.22 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{i,4})
    xticks([]);yticks([])
    ax(i) = subplot('position',[0.53 k 0.22 0.07]);
    bar(stackedSweeps(length(stackedSweeps)).spkCountStrongChn{i,4},...
        'barwidth',1,'facecolor','k');xticks([]);yticks([])
    text(10,3+(max(stackedSweeps(...
        length(stackedSweeps)).spkCountStrongChn{i,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountStrongChn{i,1})])
    subplot('position',[0.76 j 0.08 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryStrongChn{i,5})
    xticks([]);yticks([])
    subplot('position',[0.76 k 0.08 0.07])
    plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
    xticks([]);yticks([]);j = j-0.23;k = k-0.23;
end

linkaxes(ax(1:8),'y')



%% Figure 3
figure('name','Stacked-sweep rasters; eight less reactive channels')

% Left column, top three group of subplots
ax = zeros(8,1);j = 0.83;k = 0.76;colormap(gray)
for i = 1:3
    subplot('position',[0.05 j 0.22 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{i,4})
    xticks([]);yticks([])
    ax(i) = subplot('position',[0.05 k 0.22 0.07]);
    bar(stackedSweeps(length(stackedSweeps)).spkCountWeakChn{i,4},...
        'barwidth',1,'facecolor','k');xticks([]);yticks([])
    text(10,3+(max(stackedSweeps(length(...
        stackedSweeps)).spkCountWeakChn{i,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountWeakChn{i,1})])
    subplot('position',[0.28 j 0.08 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{i,5})
    xticks([]);yticks([])
    subplot('position',[0.28 k 0.08 0.07])
    plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
    xticks([]);yticks([]);j = j-0.23;k = k-0.23;
end

% Bottom left group
subplot('position',[0.05 0.14 0.22 0.14])
imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{4,4})
xticks([]);yticks([]);ylabel([num2str(size(...
    stackedSweeps(length(stackedSweeps)).binaryWeakChn{4,4},1)) ' sweeps'])
ax(4) = subplot('position',[0.05 0.07 0.22 0.07]);
bar(stackedSweeps(length(stackedSweeps)).spkCountWeakChn{4,4},...
    'barwidth',1,'facecolor','k')
xticks(0:...
    length(stackedSweeps(length(stackedSweeps)).spkCountWeakChn{4,4})/8:...
    length(stackedSweeps(length(stackedSweeps)).spkCountWeakChn{4,4}))
ylabel('Spike count');xticklabels(-1:0.5:4);xlabel('Perievent time (s)')
text(10,3+(max(stackedSweeps(length(...
    stackedSweeps)).spkCountWeakChn{4,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountWeakChn{4,1})])
subplot('position',[0.28 0.14 0.08 0.14])
imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{4,5})
xticks([]);yticks([])
subplot('position',[0.28 0.07 0.08 0.07])
plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
xticks([]);yticks([])

% Right column
j = 0.83;k = 0.76;
for i = 5:8
    subplot('position',[0.53 j 0.22 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{i,4})
    xticks([]);yticks([])
    ax(i) = subplot('position',[0.53 k 0.22 0.07]);
    bar(stackedSweeps(length(stackedSweeps)).spkCountWeakChn{i,4},...
        'barwidth',1,'facecolor','k');xticks([]);yticks([])
    text(10,3+(max(stackedSweeps(...
        length(stackedSweeps)).spkCountWeakChn{i,4})*0.95),...
        ['Chn ' num2str(stackedSweeps(...
        length(stackedSweeps)).spkCountWeakChn{i,1})])
    subplot('position',[0.76 j 0.08 0.14])
    imagesc(~stackedSweeps(length(stackedSweeps)).binaryWeakChn{i,5})
    xticks([]);yticks([])
    subplot('position',[0.76 k 0.08 0.07])
    plot(singlePiezo(...
        (befPiezo/shortBins)+1:(befPiezo+durPiezo)/shortBins),'k')
    xticks([]);yticks([]);j = j-0.23;k = k-0.23;
end

linkaxes(ax(1:8),'y')
clear aftPiezo ax befPiezo durPiezo epoched i j k shortBins whiskerID;toc