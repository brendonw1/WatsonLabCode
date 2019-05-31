% Piezo-locked ERP and MUA from S1 cortical layers recorded under
% anesthesia for whisker-barrel somatotopy.
%
%
%
% OUTPUT STRUCTURES _______________________________________________________
% - stackedChannels - ERPs and binary Zscored/smoothed perievent raster
%   plots across DV-remapped channels (with sweeps merged). Additional
%   vectors summarize reativity strength with a single value per channel
%   (see field names in the output structure).
% - stackedSweeps - ERPs across sweeps, averaged ERP, binary perievent
%   raster plots across sweeps, and spike count histograms.
%
%
%
% USAGE ___________________________________________________________________
% - Set the working directory with data subfolders (i.e., chunks of a given
%   day of recording), and run. The working directory can contain any
%   number of subfolders, which in turn should be named as (for example):
%   LB_12_C2_190429_085756 (LB_12 -> mouse; C2 -> whisker; then date, time).
%
% - Outputs can be analyzed with PiezoERPandMUAfigs.m and/or
%   WhiskerSorting.m.
%
%
%
% LSBuenoJr _______________________________________________________________



%% Sets parameters, loads Intan data, re-maps channels
tic;clc;disp('Loading the raw...')
params.samplFreq     = 20000;                  % Digitization rate
params.befPiezo      = 1*params.samplFreq;     % 1 sec pre-stimulus
params.durPiezo      = 1*params.samplFreq;     % 1 sec during stimulus
params.aftPiezo      = 2*params.samplFreq;     % 2 sec post-stimulus
params.stimFreq      = 10;                     % Piezo waveform frequency (Hz)
params.stimDur       = 1;                      % Piezo duration (s)
params.largeBins     = 0.010*params.samplFreq; % Bin sizes: 10 ms
params.intermBins    = 0.002*params.samplFreq; %       ...:  2 ms
params.shortBins     = 0.001*params.samplFreq; %       ...:  1 ms

% rawLamnData = bz_LoadBinary('amplifier_analogin_auxiliary_int16.dat',...
%     'start',8400,...
%     'duration',600,...
%     'nChannels',73,...
%     'channels',[1:64 69])*0.195; % *0.195 converts to microvolts (Intan)
% rawPiezoWav = rawLamnData(:,size(rawLamnData,2));
% rawLamnData = channelReMapping(...
%     rawLamnData(:,1:size(rawLamnData,2)-1),'CambridgeH3'); % Or 'NeuroNexusH64LP'

chunkDir = dir;chunkDir = chunkDir(3:end);chunkDir(~[chunkDir.isdir]) = [];
for i    = length(chunkDir):-1:1
    whiskerChunks(i).whiskerID   = chunkDir(i).name(7:8);

    % *0.195 converts to microvolts (Intan)
    disp(['     ...' chunkDir(i).name(7:8) ' whisker chunk'])
    whiskerChunks(i).data        = channelReMapping(bz_LoadBinary(...
        [chunkDir(i).folder '/' chunkDir(i).name '/amplifier_analogin_auxiliary_int16.dat'],...
        'nChannels',68,...
        'channels',1:64)*0.195,'NeuroNexusH64LP');

    whiskerChunks(i).piezoStamps = bz_LoadBinary(...
        [chunkDir(i).folder '/' chunkDir(i).name '/digitalin.dat'],...
        'nChannels',1);
end;clear chunkDir;toc



%% Alternative loading method adapted from Intan website
% http://intantech.com/files/Intan_RHD2000_data_file_formats.pdf
% read_Intan_RHD2000_file
% 
% amplifFileInfo   = dir('amplifier.dat');
% analogFileInfo   = dir('analogin.dat');
% 
% amplifNumSamples = amplifFileInfo.bytes/...
%     (length(amplifier_channels)*2); % int16 = 2 bytes
% analogNumSamples = analogFileInfo.bytes/...
%     (length(board_adc_channels)*2);
% 
% amplifFid        = fopen('amplifier.dat','r');
% analogFid        = fopen('analogin.dat','r');
% 
% rawLamnData = fread(amplifFid,...
%     [length(amplifier_channels),amplifNumSamples],'int16')'...
%     *0.195; % This multiplication converts to microvolts.
% rawPiezoWav = fread(analogFid,...
%     [length(board_adc_channels),analogNumSamples],'int16')'...
%     *0.195;
% 
% fclose(amplifFid);fclose(analogFid);
% clear amplifFid amplifFileInfo amplifier_channels amplifNumSamples ...
%     analogFid analogFileInfo analogNumSamples ans aux_input_channels ...
%     board_adc_channels filename frequency_parameters notes path ...
%     spike_triggers supply_voltage_channels



%% Gets multi-channel MUA.
disp('Getting MUA from the...')
for i = length(whiskerChunks):-1:1
    nonEpoched(i).whiskerID   = whiskerChunks(i).whiskerID;

    disp(['     ...' whiskerChunks(i).whiskerID ' whisker chunk'])
    [~,temp1,temp2]          = multiChannelMUA(whiskerChunks(i).data);
    nonEpoched(i).binaryMUA = temp1;
    nonEpoched(i).rawMUA    = temp2;

    nonEpoched(i).piezoStamps = whiskerChunks(i).piezoStamps;
end



%% Aligns MUA and piezo stimuli into perievent sweeps.
tic;disp('Epoching MUA around piezo stimuli:...')

for k = length(nonEpoched):-1:1
    epoched(k).whiskerID   = nonEpoched(k).whiskerID;

    disp(['     ...' nonEpoched(k).whiskerID ' whisker chunk'])
    tempNonEpoched1 = nonEpoched(k).binaryMUA;
    tempNonEpoched2 = nonEpoched(k).rawMUA;
    tempPiezoStamps = [0;diff(nonEpoched(k).piezoStamps)];
    tempPiezoStamps = find(tempPiezoStamps == 1);
    tempEpoched1    = cell(length(tempPiezoStamps)-2,size(tempNonEpoched1,2));
    tempEpoched2    = cell(length(tempPiezoStamps)-2,size(tempNonEpoched2,2));
    for j     = 1:size(tempNonEpoched1,2)
        for i = 2:length(tempPiezoStamps)-1
        tempEpoched1{i-1,j} = tempNonEpoched1(...
            tempPiezoStamps(i)-(params.befPiezo):...
            tempPiezoStamps(i)+(params.durPiezo+params.aftPiezo)-1,j)';
        tempEpoched2{i-1,j} = tempNonEpoched2(...
            tempPiezoStamps(i)-(params.befPiezo):...
            tempPiezoStamps(i)+(params.durPiezo+params.aftPiezo)-1,j)';
        end
    end
    epoched(k).binaryMUA   = tempEpoched1;
    epoched(k).rawMUA      = tempEpoched2;
    epoched(k).piezoStamps = tempPiezoStamps;
end

% piezoDiff   = [0;diff(rawPiezoWav)];
% piezoDiff   = find(piezoDiff>((...
%     max(double(piezoDiff))-mean(double(piezoDiff)))/6));
% piezoDiff   = [piezoDiff [0;diff(piezoDiff)]];
% piezoStamps = piezoDiff(:,2);
% piezoStamps(piezoStamps<(samplFreq/5)) = NaN;
% piezoStamps(~isnan(piezoStamps)) = 1;
% piezoStamps = [piezoDiff(:,1) [1;piezoStamps(2:end)]];clear piezoDiff
% piezoStamps = piezoStamps(:,1).*piezoStamps(:,2);
% piezoStamps(isnan(piezoStamps)) = [];



%% ERP: downsamples/filters LFP
tic;disp('Filtering, re-referencing data (ERP):...')
filtBand      = [0.5 500];           % Bandpass
downSamplFreq = params.samplFreq/10; % Downsampled digit rate for ERP
Nyquist       = downSamplFreq/2;
[b,a] = butter(4,[filtBand(1)/Nyquist filtBand(2)/Nyquist],'bandpass');


for j = length(whiskerChunks):-1:1
    disp(['     ...' whiskerChunks(j).whiskerID ' whisker chunk'])

    % Filtering
    tempData = whiskerChunks(j).data;
    tempFilt = zeros(size(tempData,1)/10,size(tempData,2));

    for i    = 1:size(tempFilt,2)
        tempFilt(:,i) = (filtfilt(b,a,decimate(tempData(:,i),10)))/1000;
        % (...)/1000 converts to fractions of millivolts (for the figure)
    end

%     % Re-referencing against the average across channels (in a separate loop
%     % because this must be done after filtering all channels)
%     tempRef  = zeros(size(tempData,1)/10,size(tempData,2));
%     for i    = 1:size(tempRef,2)
%         tempRef(:,i)  = (tempFilt(:,i) - mean(tempFilt,2))/1000;
%         % (...)/1000 converts to fractions of millivolts (for the figure)
%     end
% 
%     nonEpoched(j).LFP    = tempRef;
     nonEpoched(j).LFP    = tempFilt;
end;toc
clear a b downSamplFreq filtBand Nyquist tempData tempFilt tempRef whiskerChunks



%% ERP epoching: aligns LFP and piezo stimuli into perievent sweeps.
tic;disp('Epoching LFP around piezo stimuli:...')

for k = length(nonEpoched):-1:1
    disp(['     ...' nonEpoched(k).whiskerID ' whisker chunk'])

    tempNonEpoched  = nonEpoched(k).LFP;
    tempPiezoStamps = round(epoched(k).piezoStamps/10);
    tempEpoched     = cell(length(tempPiezoStamps)-2,size(tempNonEpoched,2));
    for j           = 1:size(tempNonEpoched,2)
        for i       = 2:length(tempPiezoStamps)-1
            tempEpoched{i-1,j} = tempNonEpoched(...
                tempPiezoStamps(i)-(params.befPiezo/10):...
                tempPiezoStamps(i)+((params.durPiezo+params.aftPiezo)/10)-1,j)';
            tempEpoched{i-1,j} = single(decimate(tempEpoched{i-1,j},2));
        end
    end

    epoched(k).ERP  = tempEpoched;
end;epoched         = rmfield(epoched,'piezoStamps');
clear tempEpoched tempNonEpoched tempPiezoStamps;toc



%% Puts together output structures
tic;disp('Preparing output structures:...')

for k     = length(epoched):-1:1
    disp(['     ...' epoched(k).whiskerID ' whisker chunk'])
    temp  = cell(size(epoched(1).binaryMUA,2),15);
    for j = 1:size(temp,1)
    
        % Perievent data:
        % stacked-channel ERP (averaged sweeps).
        temp{j,6} = single(smooth(mean(cell2mat(epoched(k).ERP(:,j))),5)');
    
        % Descriptive value per channel:
        % mean absolute Z-scored ERP voltage DURING piezo. Division by 20
        % is because of LFP downsampling made in previous sections.
        temp{j,1}  = BaselineZscore(temp{j,6},params.befPiezo/20);
        temp{j,1}  = single(mean(abs(temp{j,1}(...
            (params.befPiezo/20)+51:(params.befPiezo+params.durPiezo)/20))));
        % +51 is to avoid the unexpected artifact from Bpod digital stamps
        % (i.e., initial 50 ms are excluded from this averaging)

        % Descriptive value per channel:
        % mean absolute Z-scored ERP voltage AFTER piezo.
        temp{j,2}  = BaselineZscore(temp{j,6},params.befPiezo/20);
        temp{j,2}  = single(mean(abs(temp{j,2}(...
            ((params.befPiezo+params.durPiezo)/20)+1:...
            (params.durPiezo+params.aftPiezo)/20))));
    
        % Perievent data:
        % stacked-channel MUA rasters (merged sweeps). Three copies of
        % merged-sweep data are created. Then one copy is kept unchanged
        % for future spike count histograms, the other is binarized, and
        % the other is Z scored and smoothed.
        temp{j,9}  = sum(binning(cell2mat(...
            epoched(k).binaryMUA(:,j)),params.shortBins,'s'));
        temp{j,8}  = single(temp{j,9});
        temp{j,7}  = single(temp{j,9});
        temp{j,7}(temp{j,7} > 1) = 1;
        temp{j,9}  = single(smooth(BaselineZscore(...
            temp{j,8},params.befPiezo/20),50)');
    
        % Three descriptive values per channel:
        % mean absolute Z-scored MUA DURING piezo, AFTER piezo, and latency
        % of the first response peak within the DURING + AFTER period (peak
        % is either peak itself or valley)
        temp{j,3}  = abs(temp{j,8}(...
            (params.befPiezo/params.shortBins)+51:...
            (params.befPiezo+params.durPiezo)/params.shortBins));
        temp{j,4}  = abs(temp{j,8}(...
            ((params.befPiezo+params.durPiezo)/params.shortBins)+1:...
            (params.durPiezo+params.aftPiezo)/params.shortBins));
        temp{j,5}  = [temp{j,3} temp{j,4}];
        temp{j,5}  = find(temp{j,5} == max(temp{j,5}));
        temp{j,5}  = single(temp{j,5}(1));
        temp{j,3}  = single(mean(temp{j,3}));
        temp{j,4}  = single(mean(temp{j,4}));
    
        % Perievent data:
        % stacked-sweep ERP (whole epoch)
        temp{j,10} = cell2mat(epoched(k).ERP(:,j));
        for i      = 1:size(temp{j,10},1)
            temp{j,10}(i,:) = single(smooth(temp{j,10}(i,:),5));
        end
    
        % Perievent data:
        % stacked-sweep ERP (zoomed epoch, same length as piezo)
        temp{j,11} = single(temp{j,10}(:,...
            (params.befPiezo/20)+1:(params.befPiezo+params.durPiezo)/20));
    
        % Perievent data:
        % stacked-sweep rasters and spike count histograms (whole epoch)
        temp{j,13} = binning(cell2mat(...
            epoched(k).binaryMUA(:,j)),params.largeBins,'s');
        temp{j,12} = single(temp{j,13});
        temp{j,12}(temp{j,12} > 1) = 1;
        temp{j,13} = single(sum(temp{j,13}));
    
        % Perievent data:
        % stacked-sweep rasters and spike count histograms (zoomed epoch)
        temp{j,15} = binning(cell2mat(...
            epoched(k).binaryMUA(:,j)),params.intermBins,'s');
        temp{j,15} = temp{j,15}(:,...
            (params.befPiezo/params.intermBins)+1:...
            (params.befPiezo+params.durPiezo)/params.intermBins);
        temp{j,14} = single(temp{j,15});
        temp{j,14}(temp{j,14} > 1) = 1;
        temp{j,15} = single(sum(temp{j,15}));
    end

    % Structure with merged/averaged sweeps.
    stackedChannels(k).whiskerID             = epoched(k).whiskerID;
    stackedChannels(k).absZscERPVoltDurPiezo = cell2mat(temp(:,1));
    stackedChannels(k).absZscERPVoltAftPiezo = cell2mat(temp(:,2));
    stackedChannels(k).absZscMUADurPiezo     = cell2mat(temp(:,3));
    stackedChannels(k).absZscMUAAftPiezo     = cell2mat(temp(:,4));
    stackedChannels(k).peakMUALatency        = cell2mat(temp(:,5));
    stackedChannels(k).ERP                   = cell2mat(temp(:,6));
    stackedChannels(k).binaryRaster          = cell2mat(temp(:,7));
    stackedChannels(k).spkCount              = cell2mat(temp(:,8));
    stackedChannels(k).ZscoredRaster         = cell2mat(temp(:,9));

    % Structure with individual sweeps preserved
    stackedSweeps(k).whiskerID               = epoched(k).whiskerID;
    stackedSweeps(k).ERPwholeEpoch           = temp(:,10);
    stackedSweeps(k).ERPzoomEpoch            = temp(:,11);
    stackedSweeps(k).binaryRastWholeEpoch    = temp(:,12);
    stackedSweeps(k).spkCountWholeEpoch      = temp(:,13);
    stackedSweeps(k).binaryRastZoomEpoch     = temp(:,14);
    stackedSweeps(k).spkCountZoomEpoch       = temp(:,15);
end;clear i j k temp;toc

save('whiskerChunks.mat','params','stackedChannels','stackedSweeps')