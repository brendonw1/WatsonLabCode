function SpectralFreqInator()
    % Create the UI figure
    fig = uifigure('Position', [100, 100, 700, 600], 'Name', 'LFP Spectrogram Generator');
    
    % LFP File Path
    lfpFileLabel = uilabel(fig, 'Position', [10, 540, 100, 22], 'Text', 'LFP File:');
    lfpFileField = uieditfield(fig, 'text', 'Position', [120, 540, 350, 22], ...
        'Value', '/path/to/your/file.lfp');
    lfpFileButton = uibutton(fig, 'push', 'Position', [480, 540, 100, 22], ...
        'Text', 'Browse...', 'ButtonPushedFcn', @(btn, event) selectFile(lfpFileField, fig));
    
    % Channels Selection label and list box
    channelsLabel = uilabel(fig, 'Position', [10, 350, 100, 22], 'Text', 'Select Channels:');
    channelsList = uilistbox(fig, 'Position', [120, 300, 200, 200], 'Multiselect', 'on');
    
    % Channels Input label and text box
    channelsInputLabel = uilabel(fig, 'Position', [340, 350, 250, 22], 'Text', 'or Enter Channels (e.g., 1 7 24 67):');
    channelsInputField = uieditfield(fig, 'text', 'Position', [340, 320, 200, 22]);
    
    % Total Number of Channels
    nChLabel = uilabel(fig, 'Position', [10, 260, 150, 22], 'Text', 'Total Channels:');
    nChField = uieditfield(fig, 'numeric', 'Position', [170, 260, 200, 22], ...
        'Value', 128, 'Limits', [1 Inf]);
    nChField.ValueChangedFcn = @(src, event) updateChannelList(channelsList, nChField.Value);
    
    % Set initial channel list
    updateChannelList(channelsList, nChField.Value);
    
    % Sampling Frequency
    fsLabel = uilabel(fig, 'Position', [10, 230, 150, 22], 'Text', 'Sampling Frequency (Hz):');
    fsField = uieditfield(fig, 'numeric', 'Position', [170, 230, 200, 22], ...
        'Value', 1250, 'Limits', [1 Inf]);
    
    % FFT Length
    nFFTLabel = uilabel(fig, 'Position', [10, 200, 100, 22], 'Text', 'FFT Length:');
    nFFTField = uieditfield(fig, 'numeric', 'Position', [120, 200, 250, 22], ...
        'Value', 3075, 'Limits', [1 Inf]);
    
    % Frequency Range
    fRangeLabel = uilabel(fig, 'Position', [10, 170, 150, 22], 'Text', 'Frequency Range (Hz):');
    lowFreqLabel = uilabel(fig, 'Position', [170, 170, 40, 22], 'Text', 'Low:');
    lowFreqField = uieditfield(fig, 'numeric', 'Position', [210, 170, 80, 22], ...
        'Value', 0, 'Limits', [0 Inf]);
    highFreqLabel = uilabel(fig, 'Position', [300, 170, 50, 22], 'Text', 'High:');
    highFreqField = uieditfield(fig, 'numeric', 'Position', [350, 170, 80, 22], ...
        'Value', 200, 'Limits', [0 Inf]);
    
    % Output Path
    outputPathLabel = uilabel(fig, 'Position', [10, 110, 100, 22], 'Text', 'Output Path:');
    outputPathField = uieditfield(fig, 'text', 'Position', [120, 110, 350, 22], ...
        'Value', '/path/to/output/directory');
    outputPathButton = uibutton(fig, 'push', 'Position', [480, 110, 100, 22], ...
        'Text', 'Browse...', 'ButtonPushedFcn', @(btn, event) selectDirectory(outputPathField, fig));
    
    % Run Button
    runButton = uibutton(fig, 'Position', [250, 60, 100, 30], 'Text', 'Run', ...
        'ButtonPushedFcn', @(btn, event) runFunction(fig, lfpFileField, channelsList, ...
        channelsInputField, nChField, fsField, nFFTField, lowFreqField, highFreqField, ...
        outputPathField));
end

function selectFile(lfpFileField, fig)
    [file, path] = uigetfile('*.lfp', 'Select an LFP file');
    if ischar(file)
        lfpFileField.Value = fullfile(path, file);
    end
    % Bring the figure back to the front
    figure(fig);
end

function selectDirectory(outputPathField, fig)
    directory = uigetdir('Select Output Directory');
    if ischar(directory)
        outputPathField.Value = directory;
    end
    % Bring the figure back to the front
    figure(fig);
end

function updateChannelList(channelsList, numChannels)
    channelsList.Items = arrayfun(@num2str, 1:numChannels, 'UniformOutput', false);
end

function runFunction(fig, lfpFileField, channelsList, channelsInputField, nChField, fsField, nFFTField, lowFreqField, highFreqField, outputPathField)
    % Get the values from the UI fields
    lfpFile = lfpFileField.Value;
    
    % Checking if channels were selected from the list box or text input field
    if isempty(channelsInputField.Value)
        channels = cellfun(@str2num, channelsList.Value);
    else
        channels = str2num(channelsInputField.Value); %#ok<ST2NM>
    end
    
    nCh = nChField.Value;
    fs = fsField.Value;
    nFFT = nFFTField.Value;
    fRange = [lowFreqField.Value, highFreqField.Value];
    outputpath = outputPathField.Value;
    
    % Call the function with the input parameters
    specs = saveSpectrogramsFromLFP(outputpath, lfpFile, channels, nCh, fs, nFFT, fRange);

    [bands, epochs] = PowerFreqFromSpecFreqInator(specs, 1);
    
    disp('Completely done now');

    % Display a message or perform additional actions if needed
    uialert(fig, 'Spectrograms saved successfully!', 'Success');
end

%% Parameters (old, for testing)
%lfpFile = '/data/Jeremy/Canute/Canute_231208/Canute_231208.lfp';
%lfpFile = '/Users/noahmuscat/University of Michigan Dropbox/Noah Muscat/StateEditorStuff/Canute_231208.lfp';
%channels = [1 7 67 112]; % Example channels to process
%nCh = 128; % Total number of channels in the LFP file
%fs = 1250; % Sampling frequency
%nFFT = 3075; % FFT length for spectrogram
%fRange = [0 200]; % Frequency range for the spectrogram
%suffix = '.lfp'; % Suffix of the LFP file
%outputpath = '/home/noahmu/Documents/outputdata'; % The directory to save output
%outputpath = '/Users/noahmuscat/University of Michigan Dropbox/Noah Muscat/StateEditorStuff';

%specs = saveSpectrogramsFromLFP(outputpath, lfpFile, channels, nCh, fs, nFFT, fRange, suffix);

%% The Rest (mwahahahaha daunting)

function specs = saveSpectrogramsFromLFP(outputpath, lfpFile, channels, nCh, fs, nFFT, fRange)
    % basepath: the directory path for saving the output
    % lfpFile: .lfp file containing the data
    % channels: vector of channels to process
    % nCh: Total number of channels in the recording
    % fs: sampling frequency
    % nFFT: FFT length for spectrogram
    % fRange: frequency range for the spectrogram
    % suffix: suffix for the filename
    
    [~, baseName, ~] = fileparts(lfpFile);
    [basepath, ~, ~] = fileparts(lfpFile);
    [~, ~, suffix] = fileparts(lfpFile);
    eeg1 = loadLFPData(basepath, baseName, suffix, channels, nCh);

    % Initialize StateInfo structure to store spectrogram info
    StateInfo.fspec = cell(length(channels), 1);

    % Generate spectrograms for each channel
    for chIndex = 1:length(channels)
        ch = channels(chIndex);
        disp(['Whitening and computing spectrogram for channel ', int2str(ch), '. This will all be over in a minute.']);
        
        % Preprocess: Whiten the signal
        signal = whitenSignal(eeg1(chIndex, :), fs);
        
        % Compute the spectrogram
        [spec, fo, to] = computeSpectrogram(signal, nFFT, fs, fRange);
        
        % Store the spectrogram data
        StateInfo.fspec{chIndex}.spec = spec;
        StateInfo.fspec{chIndex}.fo = fo;
        StateInfo.fspec{chIndex}.to = to;
        StateInfo.fspec{chIndex}.info.Ch = ch;
        StateInfo.fspec{chIndex}.info.FileInfo.name = [baseName, suffix];
        
        disp('Done.');
    end

    StateInfo.fspec = StateInfo.fspec.';

    % Save the spectrograms information
    eegstatesname = fullfile(outputpath, [baseName '.eegStatesStreamlined.mat']);
    save(eegstatesname, 'StateInfo');
    
    specs = SaveSpectrogramsAsStruct(StateInfo);

    % Save the spectrograms information
    spec_files = fullfile(outputpath, [baseName '.specs.mat']);
    save(spec_files, 'specs');

end

function eeg1 = loadLFPData(basePath, baseName, suffix, Chs, nCh)
    disp(['Loading eeg channels: ', int2str(Chs)]);
        try %first try bz_getLFP
            eeg1 = bz_GetLFP(Chs,'basepath',basePath,'noPrompts',true);
            eeg1 = single(eeg1.data)';
        catch
            try
                % try Anton's LoadBinary
                eeg1 = LoadBinary([baseName, suffix], Chs+1, nCh, [], 'int16', 'single');
            catch
                % Otherwise try to use Micheal Zugaro
                eeg1 = LoadBinaryIn([baseName, suffix], 'channels', Chs+1, 'nChannels', nCh)';
                eeg1 = single(eeg1);
            end
        end
        disp('Done.');
end

function weeg = whitenSignal(signal, fs)
    % Implement the whitening logic as used in TheStateEditor.m
    weeg = WhitenSignalIn(signal, fs * 2000, 1);  % Assuming whitening function
end

function [spec, fo, to] = computeSpectrogram(signal, nFFT, fs, fRange)
    % Computing the spectrogram using mtchglongIn logic as in TheStateEditor.m
    [spec, fo, to] = mtchglongIn(signal, nFFT, fs, fs, 0, [], [], [], fRange);
    spec = single(spec);  % Ensure the spectrogram is in single precision
end

function [y, A] = WhitenSignalIn(x,varargin)

%artype =2; %Signal processing toolbox
artype =1; %arfit toolbox, (crushes sometimes with old version and single data type)

[window,CommonAR, ARmodel,ArOrder] = DefaultArgsIn(varargin,{[],1,[],1});
ArOrder = ArOrder+1;
Trans = 0;
if size(x,1)<size(x,2)
    x = x';
    Transf =1;
end
[nT nCh]  = size(x);
y = zeros(nT,nCh);
if isempty(window)
    seg = [1 nT];
    nwin=1;
else
    nwin = floor(nT/window)+1;
    seg = repmat([1 window],nwin,1)+repmat([0:nwin-1]'*window,1,2);
    if nwin*window>nT
        seg(end,2) =nT;
    end   
end

for j=1:nwin
    if ~isempty(ARmodel) 
        A = ARmodel;
        for i=1:nCh
            y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
        end
    else
        if CommonAR % meaning common model for all channels and segments!!! 
            for i=1:nCh
                if  j==1 & i==1
                    switch artype
                        case 1
                            [w Atmp] = arfitIn(x(seg(j,1):seg(j,2),i),ArOrder,ArOrder);
                            A = [1 -Atmp];
                        case 2
                            A = arburg(x(seg(j,1):seg(j,2),i),ArOrder);
                    end
                    ARmodel = A;
                end
                y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
            end
        else
            for i=1:nCh
                switch artype
                    case 1
                        [w Atmp] = arfitIn(x(seg(j,1):seg(j,2),i),ArOrder,ArOrder);
                        A =[1 -Atmp];
                    case 2
                        A = arburg(x(seg(j,1):seg(j,2),i),ArOrder);
                end
                y(seg(j,1):seg(j,2),i) = Filter0In(A, x(seg(j,1):seg(j,2),i));
            end
        end
    end
end

if Trans
    y =y';
end

end

function specs = SaveSpectrogramsAsStruct(input);

StateInfo = input; 

specs = struct('spec', {}, 'freqs', {}, 'times', {});

for a = 1:length(StateInfo.fspec)
    specs(a).spec = StateInfo.fspec{a}.spec;
    specs(a).freqs = StateInfo.fspec{a}.fo;
    specs(a).times = StateInfo.fspec{a}.to;    
end
end

function [x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,nChannels,nSamples,nFFTChunks,winstep,select,nFreqBins,f,t,FreqRange] ...
    = mtparamIn(P)

nargs = length(P);

x = P{1};
if (nargs<2 | isempty(P{2})) nFFT = 1024; else nFFT = P{2}; end;
if (nargs<3 | isempty(P{3})) Fs = 1250; else Fs = P{3}; end;
if (nargs<4 | isempty(P{4})) WinLength = nFFT; else WinLength = P{4}; end;
if (nargs<5 | isempty(P{5})) nOverlap = WinLength/2; else nOverlap = P{5}; end;
if (nargs<6 | isempty(P{6})) NW = 3; else NW = P{6}; end;
if (nargs<7 | isempty(P{7})) Detrend = ''; else Detrend = P{7}; end;
if (nargs<8 | isempty(P{8})) nTapers = 2*NW -1; else nTapers = P{8}; end;
if (nargs<9 | isempty(P{9})) FreqRange = [0 Fs/2]; else FreqRange = P{9}; end
% Now do some compuatations that are common to all spectrogram functions
if size(x,1)<size(x,2)
    x = x';
end
nChannels = size(x, 2);
nSamples = size(x,1);

if length(nOverlap)==1
    winstep = WinLength - nOverlap;
    % calculate number of FFTChunks per channel
    %remChunk = rem(nSamples-Window)
    nFFTChunks = max(1,round(((nSamples-WinLength)/winstep))); %+1  - is it ? but then get some error in the chunking in mtcsd... let's figure it later
    t = winstep*(0:(nFFTChunks-1))'/Fs;
else
    winstep = 0;
    nOverlap = nOverlap(nOverlap>WinLength/2 & nOverlap<nSamples-WinLength/2);
    nFFTChunks = length(nOverlap);
    t = nOverlap(:)/Fs; 
end 
%here is how welch.m of matlab does it:
% LminusOverlap = L-noverlap;
% xStart = 1:LminusOverlap:k*LminusOverlap;
% xEnd   = xStart+L-1;
% welch is doing k = fix((M-noverlap)./(L-noverlap)); why?
% turn this into time, using the sample frequency


% set up f and t arrays
if isreal(x)%~any(any(imag(x)))    % x purely real
	if rem(nFFT,2),    % nfft odd
		select = [1:(nFFT+1)/2];
	else
		select = [1:nFFT/2+1];
	end
	nFreqBins = length(select);
else
	select = 1:nFFT;
end
f = (select - 1)'*Fs/nFFT;
nFreqRanges = size(FreqRange,1);
%if (FreqRange(end)<Fs/2)
if nFreqRanges==1
    select = find(f>FreqRange(1) & f<FreqRange(end));
    f = f(select);
    nFreqBins = length(select);
else
    select=[];
    for i=1:nFreqRanges
        select=cat(1,select,find(f>FreqRange(i,1) & f<FreqRange(i,2)));
    end
    f = f(select);
    nFreqBins = length(select);
end
%end
end

function [y, f, t, phi, FStats]=mtchglongIn(varargin);
%function [yo, fo, to, phi, FStats]=mtchglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
% Multitaper Time-Frequency Cross-Spectrum (cross spectrogram)
% for long files - splits data into blockes to save memory
% function A=mtcsg(x,nFFT,Fs,WinLength,nOverlap,NW,nTapers)
% x : input time series
% nFFT = number of points of FFT to calculate (default 1024)
% Fs = sampling frequency (default 2)
% WinLength = length of moving window (default is nFFT)
% nOverlap = overlap between successive windows (default is WinLength/2)
% NW = time bandwidth parameter (e.g. 3 or 4), default 3
% nTapers = number of data tapers kept, default 2*NW -1
%
% output yo is yo(f, t)
%
% If x is a multicolumn matrix, each column will be treated as a time
% series and you'll get a matrix of cross-spectra out yo(f, t, Ch1, Ch2)
% NB they are cross-spectra not coherences. If you want coherences use
% mtcohere

% Original code by Partha Mitra - modified by Ken Harris 
% and adopted for long files and phase by Anton Sirota
% Also containing elements from specgram.m

% default arguments and that
[x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,nChannels,nSamples,nFFTChunks,winstep,select,nFreqBins,f,t] = mtparamIn(varargin);

% allocate memory now to avoid nasty surprises later
y=complex(zeros(nFFTChunks,nFreqBins, nChannels, nChannels)); % output array
if nargout>3
    phi=complex(zeros(nFFTChunks,nFreqBins, nChannels, nChannels));
end
nFFTChunksall= nFFTChunks;
freemem = FreeMemoryIn;
BlockSize = 2^8;
nBlocks = ceil(nFFTChunksall/BlockSize);
%h = waitbar(0,'Wait..');
for Block=1:nBlocks
    %   waitbar(Block/nBlocks,h);
    minChunk = 1+(Block-1)*BlockSize;
    maxChunk = min(Block*BlockSize,nFFTChunksall);
    nFFTChunks = maxChunk - minChunk+1;
    iChunks = [minChunk:maxChunk];
    Periodogram = complex(zeros(nFreqBins, nTapers, nChannels, nFFTChunks)); % intermediate FFTs
    Temp1 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    Temp2 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    Temp3 = complex(zeros(nFreqBins, nTapers, nFFTChunks));
    eJ = complex(zeros(nFreqBins, nFFTChunks));
    tmpy =complex(zeros(nFreqBins,nFFTChunks, nChannels, nChannels));
    % calculate Slepian sequences.  Tapers is a matrix of size [WinLength, nTapers]
    [Tapers V]=dpss(WinLength,NW,nTapers, 'calc');
    % New super duper vectorized alogirthm
    % compute tapered periodogram with FFT 
    % This involves lots of wrangling with multidimensional arrays.
    
    TaperingArray = repmat(Tapers, [1 1 nChannels]);
    for j=1:nFFTChunks
        jcur = iChunks(j);
        Segment = x((jcur-1)*winstep+[1:WinLength], :);
        if (~isempty(Detrend))
            Segment = detrend(Segment, Detrend);
        end;
        SegmentsArray = permute(repmat(Segment, [1 1 nTapers]), [1 3 2]);
        TaperedSegments = TaperingArray .* SegmentsArray;
        
        fftOut = fft(TaperedSegments,nFFT);
        normfac = sqrt(2/nFFT); %to get back rms of original units
        Periodogram(:,:,:,j) = fftOut(select,:,:)*normfac; %fft(TaperedSegments,nFFT);
        % Periodogram: size  = nFreqBins, nTapers, nChannels, nFFTChunks
    end	
    if nargout>4
        U0 = repmat(sum(Tapers(:,1:2:end)),[nFreqBins,1,nChannels,   nFFTChunks]);
        Mu = sq(sum(Periodogram(:,1:2:end,:,:) .* conj(U0), 2) ./  sum(abs(U0).^2, 2));
        Num = abs(Mu).^2;
        Sp = sq(sum(abs(Periodogram).^2,2));
        chunkFS = (nTapers-1) * Num ./ (Sp ./ sq(sum(abs(U0).^2, 2))- Num );
        %	sum(abs(Periodogram - U0.*repmat(Mu,[1,nTapers,1,1])), 2);
        FStats(iChunks, :, :)  = permute(reshape(chunkFS, [nFreqBins, nChannels, nFFTChunks]),[ 3 1, 2]);
    end
    % Now make cross-products of them to fill cross-spectrum matrix
    for Ch1 = 1:nChannels
        for Ch2 = Ch1:nChannels % don't compute cross-spectra twice
            Temp1 = reshape(Periodogram(:,:,Ch1,:), [nFreqBins,nTapers,nFFTChunks]);
            Temp2 = reshape(Periodogram(:,:,Ch2,:), [nFreqBins,nTapers,nFFTChunks]);
            Temp2 = conj(Temp2);
            Temp3 = Temp1 .* Temp2;
            eJ=sum(Temp3, 2);
            tmpy(:,:, Ch1, Ch2)= eJ/nTapers;
            
            % for off-diagonal elements copy into bottom half of matrix
            if (Ch1 ~= Ch2)
                tmpy(:,:, Ch2, Ch1) = conj(eJ) / nTapers;
            end            
            
        end
    end
    
    for Ch1 = 1:nChannels
        for Ch2 = 1:nChannels % don't compute cross-spectra twice
            
            if (Ch1 == Ch2)
                % for diagonal elements (i.e. power spectra) leave unchanged
                y(iChunks,:,Ch1, Ch2) = permute(tmpy(:,:,Ch1, Ch2),[2 1 3 4]);
            else
                % for off-diagonal elements, scale
                
                y(iChunks,:,Ch1, Ch2) = permute((abs(tmpy(:,:,Ch1, Ch2).^2) ...
                    ./ (tmpy(:,:,Ch1,Ch1) .* tmpy(:,:,Ch2,Ch2))), [2 1 3 4]);
                if nargout>3
                    phi(iChunks,:,Ch1,Ch2) = permute(angle(tmpy(:,:,Ch1, Ch2) ...
                        ./ sqrt(tmpy(:,:,Ch1,Ch1) .* tmpy(:,:,Ch2,Ch2))), [2 1 3 4]); 
                end
            end
        end
    end
    
    
end
%close(h);
% we've now done the computation.  the rest of this code is stolen from
% specgram and just deals with the output stage

if nargout == 0
    % take abs, and use image to display results
    newplot;
    for Ch1=1:nChannels, for Ch2 = 1:nChannels
            subplot(nChannels, nChannels, Ch1 + (Ch2-1)*nChannels);
	    if Ch1==Ch2
		if length(t)==1
			imagesc([0 1/f(2)],f,20*log10(abs(y(:,:,Ch1,Ch2))+eps)');axis xy; colormap(jet);
		else
			imagesc(t,f,20*log10(abs(y(:,:,Ch1,Ch2))+eps)');axis xy; colormap(jet);
		end
	    else
	    	imagesc(t,f,(abs(y(:,:,Ch1,Ch2)))');axis xy; colormap(jet);
	    end
        end; end;
    xlabel('Time')
    ylabel('Frequency')
end
end

function data = LoadBinaryIn(filename,varargin)

% Default values
start = 0;
nChannels = 1;
precision = 'int16';
skip = 0;
duration = Inf;
frequency = 20000;
channels = 1;

if nargin < 1 | mod(length(varargin),2) ~= 0,
  error('Incorrect number of parameters (type ''help LoadBinary'' for details).');
end

% Parse options
for i = 1:2:length(varargin),
  if ~isa(varargin{i},'char'),
    error(['Parameter ' num2str(i+3) ' is not a property (type ''help LoadBinary'' for details).']);
  end
  switch(lower(varargin{i})),
    case 'duration',
      duration = varargin{i+1};
      if ~isa(duration,'numeric') | length(duration) ~= 1 | duration < 0,
        error('Incorrect value for property ''duration'' (type ''help LoadBinary'' for details).');
      end
    case 'frequency',
      frequency = varargin{i+1};
      if ~isa(frequency,'numeric') | length(frequency) ~= 1 | frequency <= 0,
        error('Incorrect value for property ''frequency'' (type ''help LoadBinary'' for details).');
      end
    case 'start',
      start = varargin{i+1};
      if ~isa(start,'numeric') | length(start) ~= 1,
        error('Incorrect value for property ''start'' (type ''help LoadBinary'' for details).');
      end
		if start < 0, start = 0; end
    case 'nchannels',
      nChannels = varargin{i+1};
      if ~((round(channels) == channels & channels > 0)) | length(nChannels) ~= 1,
        error('Incorrect value for property ''nChannels'' (type ''help LoadBinary'' for details).');
      end
    case 'channels',
      channels = varargin{i+1};
      if ~(round(channels) == channels & channels > 0)
        error('Incorrect value for property ''channels'' (type ''help LoadBinary'' for details).');
      end
    case 'precision',
      precision = varargin{i+1};
      if ~isa(precision,'char'),
        error('Incorrect value for property ''precision'' (type ''help LoadBinary'' for details).');
      end
    case 'skip',
      skip = varargin{i+1};
      if ~IsPositiveInteger(skip) | length(skip) ~= 1,
        error('Incorrect value for property ''skip'' (type ''help LoadBinary'' for details).');
      end
    otherwise,
      error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help LoadBinary'' for details).']);
  end
end

sizeInBytes = 0;
switch precision,
	case {'uchar','unsigned char','schar','signed char','int8','integer*1','uint8'},
		sizeInBytes = 1;
	case {'int16','integer*2','uint16'},
		sizeInBytes = 2;
	case {'int32','integer*4','uint32','single','real*4','float32'},
		sizeInBytes = 4;
	case {'int64','integer*8','uint64','double','real*8','float64'},
		sizeInBytes = 8;
end

f = fopen(filename, 'r');
if f == -1
    error(['Could not open file ', filename]);
end

% Position file index for reading
start = floor(start * frequency) * nChannels * sizeInBytes;
status = fseek(f, start, 'bof');
if status ~= 0
    fclose(f);
    error('Could not start reading (possible reasons include trying to read past the end of the file).');
end

% Determine number of samples when duration is 'inf'
if isinf(duration),
	fileStart = ftell(f);
	status = fseek(f,0,'eof');
	if status ~= 0,
		fclose(f);
		error('Error reading the data file (possible reasons include trying to read past the end of the file).');
	end
	fileStop = ftell(f);
	nSamplesPerChannel = (fileStop-fileStart)/nChannels/sizeInBytes;
	duration = nSamplesPerChannel/frequency;
	frewind(f);
	status = fseek(f,start,'bof');
	if status ~= 0,
		fclose(f);
		error('Could not start reading (possible reasons include trying to read past the end of the file).');
	end
else
    nSamplesPerChannel = floor(frequency*duration);
    if nSamplesPerChannel ~= frequency*duration,
        %disp(['Warning: rounding duration (' num2str(duration) ' -> ' num2str(nSamplesPerChannel/frequency) ')']);
        duration = nSamplesPerChannel/frequency;
    end
end

% For large amounts of data, read chunk by chunkChangeThisStateAssigmnent_Key

maxSamplesPerChunk = 100000;
nSamples = nChannels*nSamplesPerChannel;
if nSamples > maxSamplesPerChunk,
	% Determine chunk duration and number of chunks
	nSamplesPerChunk = floor(maxSamplesPerChunk/nChannels)*nChannels;
	durationPerChunk = nSamplesPerChunk/frequency/nChannels;
	nChunks = floor(duration/durationPerChunk);
	% Preallocate memory
	data = zeros(nSamplesPerChannel,length(channels),precision);
	% Read all chunks
	i = 1;
	for j = 1:nChunks,
		d = LoadBinaryChunkIn(f,'frequency',frequency,'nChannels',nChannels,'channels',channels,'duration',durationPerChunk,'skip',skip);
		[m,n] = size(d);
		if m == 0, break; end
		data(i:i+m-1,:) = d;
		i = i+m;
%  		h=waitbar(j/nChunks);
	end
%  	close(h)
	% If the data size is not a multiple of the chunk size, read the remainder
	remainder = duration - nChunks*durationPerChunk;
	if remainder ~= 0,
		d = LoadBinaryChunkIn(f,'frequency',frequency,'nChannels',nChannels,'channels',channels,'duration',remainder,'skip',skip);
		[m,n] = size(d);
		if m ~= 0,
			data(i:i+m-1,:) = d;
		end
	end
else
    if skip ~= 0,
        data = fread(f,[nChannels frequency*duration],precision,skip);
    else
        data = fread(f,[nChannels frequency*duration],precision);
    end
    data=data';
    
    if ~isempty(channels),
        data = data(:,channels);
    end
end
fclose(f);
end

%function [Data OrigIndex]= LoadBinary(FileName, Channels, nChannels, method, intype, outtype, Periods, Resample)
%   Channels - list of channels to load starting from 1
%   nChannels - number of channels in a file, will be read from par/xml file
% if present
%   intype/outtype - data types in the file and in the matrix to load to
% by default assume input file is eeg/dat = int16 type (short int), and
% output is single (to save space) unless it is version 6.5 that cannot
% handle single type
%   method: (1,2,  3 or 4) differes by the way the loading is done - just for
% efficiency purposes some are better then others, default =2;
% method 2 works with buffers-works even for huge files. other methods
% don't work so far ..
% NB: method =3 allows to load data from within certain time epochs , give
% in variable Periods : [beg1 end1; beg2 end2....] (in sampling rate of the
% file you are loading, so if you are loading eeg - then Periods should be
% in eeg samples
% OrigIndex then returns the original samples index that samples in Data correspond
% to , so that you can use it for future spikes and other point process
% analysis
% NB: for method 4 for efficiency and historical reasons output is nCh x nT 
% complaints to : Anton


function [data OrigIndex]= LoadBinary(FileName, Channels, varargin)
if ~FileExists(FileName)
    error('File %s does not exist or cannot be open\n',FileName);
end

lastdot =strfind(FileName,'.');
FileBase=FileName(1:lastdot(end)-1);
if FileExists([FileBase '.xml']) || FileExists([FileBase '.par'])
    Par = LoadPar([FileBase]);
    nChannels = Par.nChannels;
else
    nChannels = 0;
end
[nChannels, method, intype, outtype,Periods,Resample] = DefaultArgs(varargin,{nChannels,2,'int16','double',[],1});

if ~nChannels error('nChannels is not specified and par/xml file is not present'); end

ver = version; ver = str2num(ver(1));
if ver<7 outtype ='double';end

PrecString =[intype '=>' outtype];
fileinfo = dir(FileName);
% get file size, and calculate the number of samples per channel
nSamples = ceil(fileinfo(1).bytes /datatypesize(intype) / nChannels);

if method<2 & ~isempty(Periods)
    error('this method does not perform (yet) selective loading with Periods, use method 3 or 4. Bug me to implement it ! :)');
end
if method==3 & isempty(Periods)
    method=2;
    fprintf('method 3 is replaced by method 2 which uses buffering');
end

%have not fixed the case of method 1 for periods extraction
if method<5

    filept = fopen(FileName,'r');

    if ~isempty(Periods)
        %        method=3;
        if Resample>1
            data = feval( outtype, zeros( length(Channels), sum( ceil((diff(Periods,1,2)+1)/nChannels/Resample) ) ) );
        else
            data = feval( outtype, zeros( length(Channels), sum(diff(Periods,1,2)+1) ) );
        end
    else
        Periods = [1 nSamples];
        if Resample>1
            data = feval(outtype,zeros(length(Channels), ceil(nSamples/Resample)));
        else
            data = feval(outtype,zeros(length(Channels), nSamples));
        end
    end
end

switch method
    case 1

        %compute continuous patches in chselect
        %lazy to do circular continuity search - maybe have patch [nch 1 2 3]
        %sort in case somebody didn't
        [Channels ChanOrd]= sort(Channels(:)');
        dch = diff([Channels(1) Channels]);
        PatchInd = cumsum(dch>1)+1;
        PatchLen = hist(PatchInd,unique(PatchInd));
        PatchSkip = (nChannels - PatchLen)*datatypesize(intype);
        nPatch = length(unique(PatchInd));

        for ii=1:nPatch
            patchch = find(PatchInd==ii);
            patchbeg = Channels(patchch(1));
            PatchPrecString = [num2str(PatchLen(ii)) '*' PrecString];
            fseek(filept,(patchbeg-1)*datatypesize(intype),'bof');
            data(patchch,:) = fread(filept,[PatchLen(ii) nSamples],PatchPrecString,PatchSkip(ii));

        end
        % put them back in the order they were in Channels argument
        data = data(ChanOrd,:);

        
    case 2 %old way - buffered, now deals with periods as well
        OrigIndex = [];
        nPeriods = size(Periods,1);
        buffersize = 400000;
        if Resample>1 buffersize = round(buffersize/Resample)*Resample; end
        totel=0;
        for ii=1:nPeriods
            numel=0;
            numelm=0;
            Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
            ReadSamples = diff(Periods(ii,:))+1;
            fseek(filept, Position, 'bof');
            while numel<ReadSamples 
                if numel==ReadSamples break; end
                [tmp,count] = fread(filept,[nChannels,min(buffersize,ReadSamples-numel)],PrecString);
                data(:,totel+1:totel+ceil(count/nChannels/Resample)) = tmp(Channels,1:Resample:end);
                numel = numel+count/nChannels;
                totel = totel+ceil(count/nChannels/Resample);
            end
            
            OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
        end

    case 3 % for full periods extraction, not buffered, use method 2 if periods are large.
        % OBSOLETE!!!
        nPeriods = size(Periods,1);
        numel=0;
        OrigIndex = [];
        for ii=1:nPeriods
            Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
            ReadSamples = diff(Periods(ii,:))+1;
            fseek(filept, Position, 'bof');
            
            [tmp count]= fread(filept, [nChannels, ReadSamples], PrecString);
            if count/nChannels ~= ReadSamples
                error('something went wrong!');
            end
            if Resample>1
                numelm = ceil(count/nChannels/Resample);
            else
                numelm = count/nChannels;
            end
            data(:,numel+1:numel+numelm) = tmp(Channels,1:Resample:end);
            numel = numel+count/nChannels;
            OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
        end
        
    case 4 %new way - with memmapfile

        if isempty(Periods)
            mmap = memmapfile(FileName, 'format',{intype [nChannels nSamples] 'x'},'offset',0,'repeat',1);
            data = mmap.Data.x(Channels,1:Resample:end);
        else
            %data = feval(outtype,zeros(length(Channels), sum(diff(Periods,1,2)))+size(Periods,1));
            nPeriods = size(Periods,1);
            data = [];
            OrigIndex = [];
            for ii=1:nPeriods
                Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
                ReadSamples = diff(Periods(ii,:))+1;
                mmap = memmapfile(FileName, 'format',{intype [nChannels ReadSamples] 'x'},'offset',Position,'repeat',1);
%                data = [data mmap.Data.x(Channels,Periods(ii,1):Periods(ii,2))];
                data = [data mmap.Data.x(Channels,1:Resample:end)];
                OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
            end
        end
        data = cast(data,outtype);
end
if method<4
    fclose(filept);
end
end

function data = LoadBinaryChunkIn(fid,varargin)

% Default values
start = 0;
fromCurrentIndex = true;
nChannels = 1;
precision = 'int16';
duration = 1;
frequency = 20000;
channels = [];

if nargin < 1 | mod(length(varargin),2) ~= 0,
  error('Incorrect number of parameters (type ''help LoadBinaryChunk'' for details).');
end

% Parse options
for i = 1:2:length(varargin),
  if ~isa(varargin{i},'char'),
    error(['Parameter ' num2str(i+3) ' is not a property (type ''help LoadBinaryChunk'' for details).']);
  end
  switch(lower(varargin{i})),
    case 'duration',
      duration = varargin{i+1};
      if ~isa(duration,'numeric') | length(duration) ~= 1 | duration < 0,
        error('Incorrect value for property ''duration'' (type ''help LoadBinaryChunk'' for details).');
      end
    case 'frequency',
      frequency = varargin{i+1};
      if ~isa(frequency,'numeric') | length(frequency) ~= 1 | frequency <= 0,
        error('Incorrect value for property ''frequency'' (type ''help LoadBinaryChunk'' for details).');
      end
    case 'start',
      start = varargin{i+1};
      fromCurrentIndex = false;
      if ~isa(start,'numeric') | length(start) ~= 1,
        error('Incorrect value for property ''start'' (type ''help LoadBinaryChunk'' for details).');
      end
		if start < 0, start = 0; end
    case 'nchannels',
      nChannels = varargin{i+1};
      if ~isa(nChannels,'numeric') | length(nChannels) ~= 1,
        error('Incorrect value for property ''nChannels'' (type ''help LoadBinaryChunk'' for details).');
      end
    case 'channels',
      channels = varargin{i+1};
      if ~isa(channels,'numeric'),
        error('Incorrect value for property ''channels'' (type ''help LoadBinaryChunk'' for details).');
      end
    case 'precision',
      precision = varargin{i+1};
      if ~isa(precision,'char'),
        error('Incorrect value for property ''precision'' (type ''help LoadBinaryChunk'' for details).');
      end
    case 'skip',
      skip = varargin{i+1};
      if ~isa(skip,'numeric') | length(skip) ~= 1,
        error('Incorrect value for property ''skip'' (type ''help LoadBinaryChunk'' for details).');
      end
    otherwise,
      error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help LoadBinaryChunk'' for details).']);
  end
end

sizeInBytes = 0;
switch precision,
	case {'uchar','unsigned char','schar','signed char','int8','integer*1','uint8'},
		sizeInBytes = 1;
	case {'int16','integer*2','uint16'},
		sizeInBytes = 2;
	case {'int32','integer*4','uint32','single','real*4','float32'},
		sizeInBytes = 4;
	case {'int64','integer*8','uint64','double','real*8','float64'},
		sizeInBytes = 8;
end

% Position file index for reading
if ~fromCurrentIndex,
	start = floor(start*frequency)*nChannels*sizeInBytes;
	status = fseek(fid,start,'bof');
	if status ~= 0,
		error('Could not start reading (possible reasons include trying to read a closed file or past the end of the file).');
	end
end

% Read data chunck
if skip ~= 0,
	data = fread(fid,[nChannels frequency*duration],precision,skip);
else
	data = fread(fid,[nChannels frequency*duration],precision);
end;
data=data';

% Keep only required channels
if ~isempty(channels) & ~isempty(data),
	data = data(:,channels);
end

end

% computes the available memory in bytes
function HowMuch = FreeMemoryIn
if isunix
	[junk mem] = unix('vmstat |tail -1|awk ''{print $4} {print $6}''');
	HowMuch = sum(mem);
else
	HowMuch = 200;
	%200Mb for windows machin
	
end
end

function y = Filter0In(b, x)

if size(x,1) == 1
	x = x(:);
end

% if mod(length(b),2)~=1
% 	error('filter order should be odd');
% end
if mod(length(b),2)~=1
    shift = length(b)/2;
else
    shift = (length(b)-1)/2;
end

[y0 z] = filter(b,1,single(x));

y = [y0(shift+1:end,:) ; z(1:shift,:)];

end

function varargout = DefaultArgsIn(Args, DefArgs)
% auxillary function to replace argument check in the beginning and def. args assigment
% sets the absent or empty values of the Args (cell array, usually varargin)
% to their default values from the cell array DefArgs. 
% Output should contain the actuall names of arguments that you use in the function

% e.g. : in function MyFunction(somearguments , varargin)
% calling [SampleRate, BinSize] = DefaultArgs(varargin, {20000, 20});
% will assign the defualt values to SampleRate and BinSize arguments if they
% are empty or absent in the varargin cell list 
% (not passed to a function or passed empty)
if isempty(Args)
    Args ={[]};
end

if iscell(Args{1}) & length(Args)==1
    Args = Args{1};
end

nDefArgs = length(DefArgs);
nInArgs = length(Args);
%out = cell(nDefArgs,1);
if (nargout~=nDefArgs)
    error('number of defaults is different from assigned');
    keyboard
end
for i=1:nDefArgs
    if (i>nInArgs | isempty(Args{i}))
        varargout(i) = {DefArgs{i}};
    else 
        varargout(i) = {Args{i}};
    end
end

end

function [lfp] = bz_GetLFP(varargin)
% bz_GetLFP - Get local field potentials.
%
%  Load local field potentials from disk. No longer dependent on
%  FMAT/SetCurrentSession.
%
%  USAGE
%
%    [lfp] = bz_GetLFP(channels,<options>)
%
%  INPUTS
%
%    channels(required) -must be first input, numeric  
%                        list of channels to load (use keyword 'all' for all)
%                        channID is 0-indexing, a la neuroscope
%  Name-value paired inputs:
%    'basepath'           - folder in which .lfp file will be found (default
%                           is pwd)
%                           folder should follow buzcode standard:
%                           whateverPath/baseName
%                           and contain file baseName.lfp
%    'basename'           -base file name to load
%    'intervals'          -list of time intervals [0 10; 20 30] to read from 
%                           the LFP file (default is [0 inf])
%    'downsample'         -factor to downsample the LFP (i.e. 'downsample',5
%                           will load a 1250Hz .lfp file at 250Hz)
%    'restrict'           - specification of time, in seconds, to load data
%                            from.  Given as [start end] bracketed pair.
%                            Default: no restriction, all lfp time loaded
%    'noPrompts'          -logical (default) to supress any user prompts
%    'fromDat'            -option to load directly from .dat file (default:false)

%  OUTPUT
%
%    lfp             struct of lfp data. Can be a single struct or an array
%                    of structs for different intervals.  lfp(1), lfp(2),
%                    etc for intervals(1,:), intervals(2,:), etc
%    .data           [Nt x Nd] matrix of the LFP data
%    .timestamps     [Nt x 1] vector of timestamps to match LFP data
%    .interval       [1 x 2] vector of start/stop times of LFP interval
%    .channels       [Nd X 1] vector of channel ID's
%    .samplingRate   LFP sampling rate [default = 1250]
%    .duration       duration, in seconds, of LFP interval
%
%
%  EXAMPLES
%
%    % channel ID 5 (= # 6), from 0 to 120 seconds
%    lfp = bz_GetLFP(5,'restrict',[0 120]);
%    % same, plus from 240.2 to 265.23 seconds
%    lfp = bz_GetLFP(5,'restrict',[0 120;240.2 265.23]);
%    % multiple channels
%    lfp = bz_GetLFP([1 2 3 4 10 17],'restrict',[0 120]);
%    % channel # 3 (= ID 2), from 0 to 120 seconds
%    lfp = bz_GetLFP(3,'restrict',[0 120],'select','number');

% Copyright (C) 2004-2011 by Michaël Zugaro
% editied by David Tingley, 2017
%
% NOTES
% -'select' option has been removed, it allowed switching between 0 and 1
%   indexing.  This should no longer be necessary with .lfp.mat structs
%
% TODO
% add saveMat input 
% expand channel selection options (i.e. region or spikegroup)
% add forcereload
%% Parse the inputs!

channelsValidation = @(x) isnumeric(x) || strcmp(x,'all');

% parse args
p = inputParser;
addRequired(p,'channels',channelsValidation)
addParameter(p,'basename','',@isstr)
addParameter(p,'intervals',[],@isnumeric)
addParameter(p,'restrict',[],@isnumeric)
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'downsample',1,@isnumeric);
% addParameter(p,'saveMat',false,@islogical);
% addParameter(p,'forceReload',false,@islogical);
addParameter(p,'noPrompts',false,@islogical);
addParameter(p,'fromDat',false,@islogical);

parse(p,varargin{:})
basename = p.Results.basename;
channels = p.Results.channels;
downsamplefactor = p.Results.downsample;
basepath = p.Results.basepath;
noPrompts = p.Results.noPrompts;
fromDat = p.Results.fromDat;

% doing this so you can use either 'intervals' or 'restrict' as parameters to do the same thing
intervals = p.Results.intervals;
restrict = p.Results.restrict;
if isempty(intervals) && isempty(restrict) % both empty
    intervals = [0 Inf];
elseif isempty(intervals) && ~isempty(restrict) % intervals empty, restrict isn't
    intervals = restrict;
end

%% let's check that there is an appropriate LFP file
if isempty(basename)
   %disp('No basename given, so we look for a *lfp/*eeg file...')
   switch fromDat
       case false
           d = dir([basepath filesep '*lfp']);
       case true
           d = dir([basepath filesep '*dat']);
   end
   if length(d) > 1 % we assume one .lfp file or this should break
       error('there is more than one .lfp file in this directory?');
   elseif length(d) == 0
       d = dir([basepath filesep '*eeg']);
       if isempty(d)
           error('could not find an lfp/eeg file..')
       end
   end
   lfp.Filename = d.name;
   basename = strsplit(lfp.Filename,'.');
   if length(basename) > 2
       base = [];
       for i=1:length(basename)-1
          base = [base basename{i} '.'];
       end
       basename = base(1:end-1);  % this is an fugly hack to make things work with Kenji's naming system...
   else
       basename = basename{1};
   end
   
else
   switch fromDat
       case false
           d = dir([basepath filesep basename '.lfp']);
       case true
           d = dir([basepath filesep basename '.dat']);
   end
   
   if length(d) > 1 % we assume one .lfp file or this should break
       error('there is more than one .lfp file in this directory?');
   elseif length(d) == 0
       d = dir([basepath filesep basename '.eeg']);
       if isempty(d)
           error('could not find an lfp/eeg file..')
       end
   end
   lfp.Filename = d.name;   
end

%% things we can parse from sessionInfo or xml file

sessionInfo = bz_getSessionInfo(basepath, 'noPrompts', noPrompts);

switch fromDat
   case false
        try
            samplingRate = sessionInfo.lfpSampleRate;
        catch
            samplingRate = sessionInfo.rates.lfp; % old ugliness we need to get rid of
        end
    case true
        samplingRate = sessionInfo.rates.wideband;
end
samplingRateLFP_out = samplingRate./downsamplefactor;

if mod(samplingRateLFP_out,1)~=0
    error('samplingRate/downsamplefactor must be an integer')
end
%% Channel load options
%Right now this assumes that all means channels 0:nunchannels-1 (neuroscope
%indexing), we could also add options for this to be select region or spike
%group from the xml...
if strcmp(channels,'all')
    channels = sessionInfo.channels;
else
    %Put in something here to collapse into X-Y for consecutive channels...
    display(['Loading Channels ',num2str(channels),' (0-indexing, a la Neuroscope)'])
end

%% get the data
disp('loading LFP file...')
nIntervals = size(intervals,1);
% returns lfp/bz format
for i = 1:nIntervals
    lfp(i).duration = (intervals(i,2)-intervals(i,1));
    lfp(i).interval = [intervals(i,1) intervals(i,2)];

    % Load data and put into struct
    % we assume 0-indexing like neuroscope, but bz_LoadBinary uses 1-indexing to
    % load....
    lfp(i).data = bz_LoadBinary([basepath filesep lfp.Filename],...
        'duration',double(lfp(i).duration),...
                  'frequency',samplingRate,'nchannels',sessionInfo.nChannels,...
                  'start',double(lfp(i).interval(1)),'channels',channels+1,...
                  'downsample',downsamplefactor);
    lfp(i).timestamps = [lfp(i).interval(1):(1/samplingRateLFP_out):...
                        (lfp(i).interval(1)+(length(lfp(i).data)-1)/...
                        samplingRateLFP_out)]';
    lfp(i).channels = channels;
    lfp(i).samplingRate = samplingRateLFP_out;
    % check if duration is inf, and reset to actual duration...
    if lfp(i).interval(2) == inf
        lfp(i).interval(2) = length(lfp(i).timestamps)/lfp(i).samplingRate;
        lfp(i).duration = (lfp(i).interval(i,2)-lfp(i).interval(i,1));
    end
    
    if isfield(sessionInfo,'region') && isfield(sessionInfo,'channels')
        [~,~,regionidx] = intersect(lfp(i).channels,sessionInfo.channels,'stable');
        lfp(i).region = sessionInfo.region(regionidx); % match region order to channel order..
    end
end
end

function [R, scale]=arqrIn(v, p, mcor)
%ARQR	QR factorization for least squares estimation of AR model.
%
%  [R, SCALE]=ARQR(v,p,mcor) computes the QR factorization needed in
%  the least squares estimation of parameters of an AR(p) model. If
%  the input flag mcor equals one, a vector of intercept terms is
%  being fitted. If mcor equals zero, the process v is assumed to have
%  mean zero. The output argument R is the upper triangular matrix
%  appearing in the QR factorization of the AR model, and SCALE is a
%  vector of scaling factors used to regularize the QR factorization.
%
%  ARQR is called by ARFIT. 
%
%  See also ARFIT.

%  Modified 29-Dec-99
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu

  % n: number of time steps; m: dimension of state vectors
  [n,m] = size(v);     

  ne    = n-p;                  % number of block equations of size m
  np    = m*p+mcor;             % number of parameter vectors of size m

  % If the intercept vector w is to be fitted, least squares (LS)
  % estimation proceeds by solving the normal equations for the linear
  % regression model
  %
  %                  v(k,:)' = Aaug*u(k,:)' + noise(C)
  %
  % with Aaug=[w A] and `predictors' 
  %
  %              u(k,:) = [1 v(k-1,:) ...  v(k-p,:)]. 
  %
  % If the process mean is taken to be zero, the augmented coefficient
  % matrix is Aaug=A, and the regression model
  %
  %                u(k,:) = [v(k-1,:) ...  v(k-p,:)]
  %
  % is fitted. 
  % The number np is the dimension of the `predictors' u(k). 

  % Assemble the data matrix K (of which a QR factorization will be computed)
  K = zeros(ne,np+m);                 % initialize K
  if (mcor == 1)
    % first column of K consists of ones for estimation of intercept vector w
    K(:,1) = ones(ne,1);
  end
  
  % Assemble `predictors' u in K 
  for j=1:p
    K(:, mcor+m*(j-1)+1:mcor+m*j) = [v(p-j+1:n-j, :)];
  end
  % Add `observations' v (left hand side of regression model) to K
  K(:,np+1:np+m) = [v(p+1:n, :)];
  
  % Compute regularized QR factorization of K: The regularization
  % parameter delta is chosen according to Higham's (1996) Theorem
  % 10.7 on the stability of a Cholesky factorization. Replace the
  % regularization parameter delta below by a parameter that depends
  % on the observational error if the observational error dominates
  % the rounding error (cf. Neumaier, A. and T. Schneider, 2001:
  % "Estimation of parameters and eigenmodes of multivariate
  % autoregressive models", ACM Trans. Math. Softw., 27, 27--57.).
  q     = np + m;             % number of columns of K
  delta = (q^2 + q + 1)*eps;  % Higham's choice for a Cholesky factorization
  scale = sqrt(delta)*sqrt(sum(K.^2));   
  R     = triu(qr([K; diag(scale)]));

% Add `observations' v (left hand side of regression model) to K
K(:,np+1:np+m) = [v(p+1:n, :)];

% Compute regularized QR factorization of K: The regularization
% parameter delta is chosen according to Higham's (1996) Theorem
% 10.7 on the stability of a Cholesky factorization. Replace the
% regularization parameter delta below by a parameter that depends
% on the observational error if the observational error dominates
% the rounding error (cf. Neumaier, A. and T. Schneider, 2001:
% "Estimation of parameters and eigenmodes of multivariate
% autoregressive models", ACM Trans. Math. Softw., 27, 27--57.).
q     = np + m;             % number of columns of K
delta = (q^2 + q + 1)*eps;  % Higham's choice for a Cholesky factorization
scale = sqrt(delta)*sqrt(sum(K.^2));
R     = triu(qr([K; diag(scale)]));
end

function [sbc, fpe, logdp, np] = arordIn(R, m, mcor, ne, pmin, pmax)
%ARORD	Evaluates criteria for selecting the order of an AR model.
%
%  [SBC,FPE]=ARORD(R,m,mcor,ne,pmin,pmax) returns approximate values
%  of the order selection criteria SBC and FPE for models of order
%  pmin:pmax. The input matrix R is the upper triangular factor in the
%  QR factorization of the AR model; m is the dimension of the state
%  vectors; the flag mcor indicates whether or not an intercept vector
%  is being fitted; and ne is the number of block equations of size m
%  used in the estimation. The returned values of the order selection
%  criteria are approximate in that in evaluating a selection
%  criterion for an AR model of order p < pmax, pmax-p initial values
%  of the given time series are ignored.
%
%  ARORD is called by ARFIT. 
%	
%  See also ARFIT, ARQR.

%  For testing purposes, ARORD also returns the vectors logdp and np,
%  containing the logarithms of the determinants of the (scaled)
%  covariance matrix estimates and the number of parameter vectors at
%  each order pmin:pmax.

%  Modified 17-Dec-99
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu

imax 	  = pmax-pmin+1;        % maximum index of output vectors

% initialize output vectors
sbc     = zeros(1, imax);     % Schwarz's Bayesian Criterion
fpe     = zeros(1, imax);     % log of Akaike's Final Prediction Error
logdp   = zeros(1, imax);     % determinant of (scaled) covariance matrix
np      = zeros(1, imax);     % number of parameter vectors of length m
np(imax)= m*pmax+mcor;

% Get lower right triangle R22 of R:
%
%   | R11  R12 |
% R=|          |
%   | 0    R22 |
%
R22     = R(np(imax)+1 : np(imax)+m, np(imax)+1 : np(imax)+m);

% From R22, get inverse of residual cross-product matrix for model
% of order pmax
invR22  = inv(R22);
Mp      = invR22*invR22';

% For order selection, get determinant of residual cross-product matrix
%       logdp = log det(residual cross-product matrix)
logdp(imax) = 2.*log(abs(prod(diag(R22))));

% Compute approximate order selection criteria for models of
% order pmin:pmax
i = imax;
for p = pmax:-1:pmin
    np(i)      = m*p + mcor;	% number of parameter vectors of length m
    if p < pmax
        % Downdate determinant of residual cross-product matrix
        % Rp: Part of R to be added to Cholesky factor of covariance matrix
        Rp       = R(np(i)+1:np(i)+m, np(imax)+1:np(imax)+m);
        
        % Get Mp, the downdated inverse of the residual cross-product
        % matrix, using the Woodbury formula
        L        = chol(eye(m) + Rp*Mp*Rp')';
        N        = L \ Rp*Mp;
        Mp       = Mp - N'*N;
        
        % Get downdated logarithm of determinant
        logdp(i) = logdp(i+1) + 2.* log(abs(prod(diag(L))));
    end
    
    % Schwarz's Bayesian Criterion
    sbc(i) = logdp(i)/m - log(ne) * (ne-np(i))/ne;
    
    % logarithm of Akaike's Final Prediction Error
    fpe(i) = logdp(i)/m - log(ne*(ne-np(i))/(ne+np(i)));
    
    % Modified Schwarz criterion (MSC):
    % msc(i) = logdp(i)/m - (log(ne) - 2.5) * (1 - 2.5*np(i)/(ne-np(i)));
    
    i      = i-1;                % go to next lower order
end

end

function [w, A, C, sbc, fpe, th]=arfitIn(v, pmin, pmax, selector, no_const)
%ARFIT	Stepwise least squares estimation of multivariate AR model.
%
%  [w,A,C,SBC,FPE,th]=ARFIT(v,pmin,pmax) produces estimates of the
%  parameters of a multivariate AR model of order p,
%
%      v(k,:)' = w' + A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C),
%
%  where p lies between pmin and pmax and is chosen as the optimizer
%  of Schwarz's Bayesian Criterion. The input matrix v must contain
%  the time series data, with columns of v representing variables
%  and rows of v representing observations.  ARFIT returns least
%  squares estimates of the intercept vector w, of the coefficient
%  matrices A1,...,Ap (as A=[A1 ... Ap]), and of the noise covariance
%  matrix C.
%
%  As order selection criteria, ARFIT computes approximations to
%  Schwarz's Bayesian Criterion and to the logarithm of Akaike's Final
%  Prediction Error. The order selection criteria for models of order
%  pmin:pmax are returned as the vectors SBC and FPE.
%
%  The matrix th contains information needed for the computation of
%  confidence intervals. ARMODE and ARCONF require th as input
%  arguments.
%       
%  If the optional argument SELECTOR is included in the function call,
%  as in ARFIT(v,pmin,pmax,SELECTOR), SELECTOR is used as the order
%  selection criterion in determining the optimum model order. The
%  three letter string SELECTOR must have one of the two values 'sbc'
%  or 'fpe'. (By default, Schwarz's criterion SBC is used.) If the
%  bounds pmin and pmax coincide, the order of the estimated model
%  is p=pmin=pmax. 
%
%  If the function call contains the optional argument 'zero' as the
%  fourth or fifth argument, a model of the form
%
%         v(k,:)' = A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C) 
%
%  is fitted to the time series data. That is, the intercept vector w
%  is taken to be zero, which amounts to assuming that the AR(p)
%  process has zero mean.

%  Modified 14-Oct-00
%  Authors: Tapio Schneider
%           tapio@gps.caltech.edu
%
%           Arnold Neumaier
%           neum@cma.univie.ac.at

  % n: number of observations; m: dimension of state vectors
  [n,m]   = size(v);     

  if (pmin ~= round(pmin) | pmax ~= round(pmax))
    error('Order must be integer.');
  end
  if (pmax < pmin)
    error('PMAX must be greater than or equal to PMIN.')
  end

  % set defaults and check for optional arguments
  if (nargin == 3)              % no optional arguments => set default values
    mcor       = 1;               % fit intercept vector
    selector   = 'sbc';	          % use SBC as order selection criterion
  elseif (nargin == 4)          % one optional argument
    if strcmp(selector, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
      selector = 'sbc';	          % default order selection 
    else
      mcor     = 1; 		  % fit intercept vector
    end
  elseif (nargin == 5)          % two optional arguments
    if strcmp(no_const, 'zero')
      mcor     = 0;               % no intercept vector to be fitted
    else
      error(['Bad argument. Usage: ', ...
	     '[w,A,C,SBC,FPE,th]=AR(v,pmin,pmax,SELECTOR,''zero'')'])
    end
  end

  ne  	= n-pmax;               % number of block equations of size m
  npmax	= m*pmax+mcor;          % maximum number of parameter vectors of length m

  if (ne <= npmax)
    error('Time series too short.')
  end

  % compute QR factorization for model of order pmax
  [R, scale]   = arqrIn(v, pmax, mcor);

  % compute approximate order selection criteria for models 
  % of order pmin:pmax
  [sbc, fpe]   = arordIn(R, m, mcor, ne, pmin, pmax);

  % get index iopt of order that minimizes the order selection 
  % criterion specified by the variable selector
  [val, iopt]  = min(eval(selector)); 

  % select order of model
  popt         = pmin + iopt-1; % estimated optimum order 
  np           = m*popt + mcor; % number of parameter vectors of length m

  % decompose R for the optimal model order popt according to 
  %
  %   | R11  R12 |
  % R=|          |
  %   | 0    R22 |
  %
  R11   = R(1:np, 1:np);
  R12   = R(1:np, npmax+1:npmax+m);    
  R22   = R(np+1:npmax+m, npmax+1:npmax+m);

  % get augmented parameter matrix Aaug=[w A] if mcor=1 and Aaug=A if mcor=0
  if (np > 0)   
    if (mcor == 1)
      % improve condition of R11 by re-scaling first column
      con 	= max(scale(2:npmax+m)) / scale(1); 
      R11(:,1)	= R11(:,1)*con; 
    end;
    Aaug = (R11\R12)';
    
    %  return coefficient matrix A and intercept vector w separately
    if (mcor == 1)
      % intercept vector w is first column of Aaug, rest of Aaug is 
      % coefficient matrix A
      w = Aaug(:,1)*con;        % undo condition-improving scaling
      A = Aaug(:,2:np);
    else
      % return an intercept vector of zeros 
      w = zeros(m,1);
      A = Aaug;
    end
  else
    % no parameters have been estimated 
    % => return only covariance matrix estimate and order selection 
    % criteria for ``zeroth order model''  
    w   = zeros(m,1);
    A   = [];
  end
  
  % return covariance matrix
  dof   = ne-np;                % number of block degrees of freedom
  C     = R22'*R22./dof;        % bias-corrected estimate of covariance matrix
  
  % for later computation of confidence intervals return in th: 
  % (i)  the inverse of U=R11'*R11, which appears in the asymptotic 
  %      covariance matrix of the least squares estimator
  % (ii) the number of degrees of freedom of the residual covariance matrix 
  invR11 = inv(R11);
  if (mcor == 1)
    % undo condition improving scaling
    invR11(1, :) = invR11(1, :) * con;
  end
  Uinv   = invR11*invR11';
  th     = [dof zeros(1,size(Uinv,2)-1); Uinv];
end

function [bands, epochs] = PowerFreqFromSpecFreqInator(specs, lightsOnTime)
    % Default value for lightsOnTime
    if ~exist('lightsOnTime', 'var') || isempty(lightsOnTime)
        lightsOnTime = 1; % seconds
    end

    %% Validate input structure
    if ~isstruct(specs)
        error('Input specs must be a struct array.');
    end
    
    if length(specs) ~= 2
        error('Input specs must be a 1x2 struct array.');
    end

    requiredFields = {'spec', 'freqs', 'times'};
    for i = 1:length(specs)
        if ~all(isfield(specs(i), requiredFields))
            error('Each element of specs must contain fields: spec, freqs, and times.');
        end
    end

    %% Defining frequency bands
    bands.delta.startstopfreq = [0.5 4];
    bands.theta.startstopfreq = [5 10];
    bands.spindle.startstopfreq = [11 19];
    bands.lowbeta.startstopfreq = [20 30];
    bands.highbeta.startstopfreq = [30 40];
    bands.lowgamma.startstopfreq = [40 60];
    bands.midgamma.startstopfreq = [60 100];
    bands.highgamma.startstopfreq = [100 140];
    bands.ripple.startstopfreq = [140 180];
    bands.thetaratio.startstopfreq = [0 0];
    bandnames = fieldnames(bands);

    %% Setting up time intervals
    timestamps = specs(1).times;
    if isempty(timestamps)
        error('The field "times" in specs cannot be empty.');
    end
    
    epochs.BinInterval = [lightsOnTime length(timestamps)];
    BinIntervalLength = epochs.BinInterval(2) - epochs.BinInterval(1) + 1;
    if BinIntervalLength > length(timestamps)
        error('Calculated BinInterval exceeds the length of timestamps.');
    end
    epochs.BinIndices = epochs.BinInterval(1):epochs.BinInterval(2);

    % Define HourlyBinStarts and HourlyBinEnd
    HourlyBinStarts = (1:3600:23*3600+1)';
    HourlyBinEnd = (3600:3600:24*3600)';
    epochs.HourlyBinIntervals = [HourlyBinStarts HourlyBinEnd];

    % Calculate HourlyBinIndices manually and ensure within range
    for hidx = 1:24
        hourly_start = epochs.HourlyBinIntervals(hidx, 1);
        hourly_end = min(epochs.HourlyBinIntervals(hidx, 2), length(timestamps));
        epochs.HourlyBinIndices{hidx} = hourly_start:hourly_end;
    end

    %% Initialize powervectors field for each band
    for b = 1:length(bandnames)
        tbandname = bandnames{b};
        bands.(tbandname).powervectors.All = cell(length(specs), 1);
        bands.(tbandname).powervectors.HourlyBin = cell(length(specs), 24);
    end

    %% Extracting powers for each frequency band (indexed over channels)
    for b = 1:length(bandnames) % for every band
        tbandname = bandnames{b};
        tband = bands.(tbandname);

        % Find indices of relevant frequencies for this band
        tband.freqidxs = find(specs(1).freqs >= tband.startstopfreq(1) & specs(1).freqs < tband.startstopfreq(2));
        if isempty(tband.freqidxs) && ~strcmp(tbandname, 'thetaratio')
            warning(['No frequencies found in the range for band: ', tbandname]);
            continue;
        end
        
        for a = 1:length(specs) % for every channel
            if strcmp(tbandname, 'thetaratio')
                % Ensure required fields exist before accessing them
                if ~isfield(bands.delta, 'powervectors') || ~isfield(bands.spindle, 'powervectors') || ~isfield(bands.theta, 'powervectors')
                    warning('Delta, spindle, and theta power vectors must exist for thetaratio calculation.');
                    continue;
                end
                
                % Ensure that 'All' field exists in the power vectors for required bands
                if ~isfield(bands.delta.powervectors, 'All') || ~isfield(bands.spindle.powervectors, 'All') || ~isfield(bands.theta.powervectors, 'All')
                    warning('Delta, spindle, and theta power vectors must exist in bands.');
                    continue;
                end

                % Add debug information:
                delta_power = bands.delta.powervectors.All{a};
                spindle_power = bands.spindle.powervectors.All{a};
                theta_power = bands.theta.powervectors.All{a};

                % Debug output for sizes
                fprintf('Channel %d: delta_power size = %d, spindle_power size = %d, theta_power size = %d\n', a, length(delta_power), length(spindle_power), length(theta_power));

                % Check if sizes of delta, spindle, and theta power vectors are equal
                if isempty(delta_power) || isempty(spindle_power) || isempty(theta_power)
                    warning(['Truncated power vectors for channel ', num2str(a), ' to length 0']);
                    tbandpower = [];
                else
                    min_length = min([length(delta_power), length(spindle_power), length(theta_power)]);
                    delta_power = delta_power(1:min_length);
                    spindle_power = spindle_power(1:min_length);
                    theta_power = theta_power(1:min_length);

                    tbandpower = theta_power ./ (delta_power + spindle_power);
                end
                tband.powervectors.All{a} = tbandpower; % Save the thetaratio power vector
            else
                tband.subspectrograms{a} = specs(a).spec(:, tband.freqidxs);
                if isempty(tband.subspectrograms{a})
                    warning(['Subspectrogram for band "', tbandname, '" is empty for channel ', num2str(a)]);
                    tbandpower = [];
                else
                    tbandpower = mean(tband.subspectrograms{a}, 2);
                    tband.powervectors.All{a} = tbandpower;
                end
            end

            % Calculate mean power by hourly bin intervals
            for p = 1:24
                if isempty(epochs.HourlyBinIndices{p}) || (max(epochs.HourlyBinIndices{p}) > length(tbandpower))
                    warning(['Epoch or band power data out of range for hourly bin ', num2str(p), ' in band "', tbandname]);
                    continue;
                end
                tbandpowervector = mean(tbandpower(epochs.HourlyBinIndices{p}));
                tband.powervectors.HourlyBin{a, p} = tbandpowervector; 
            end

            % Generate histogram versions of each power vector
            pvnames = fieldnames(tband.powervectors);
            for c = 1:length(pvnames) % loop through all powervectors
                tpvname = pvnames{c};
                if ~isfield(tband.powervectors, tpvname) || isempty(tband.powervectors.(tpvname))
                    continue;
                end
                tpv = tband.powervectors.(tpvname){a};
                [bincounts, powerbins] = hist(tpv, 100);
                tband.powerhistograms.(tpvname){a}.powerbins = powerbins;
                tband.powerhistograms.(tpvname){a}.bincounts = bincounts;
            end
        end

        bands.(tbandname) = tband;
    end

    %% Save the results to a .mat file
    if ~exist('basepath', 'var') || isempty(basepath)
        basepath = pwd;
    end

    if ~exist('basename', 'var') || isempty(basename)
        basename = 'default';
    end

    save(fullfile(basepath, [basename '.SpectralBandPowersJH.mat']), 'bands');

    %% Plotting
    figs = [];
    % Power vs. Time
    for a = 1:length(specs)  % for each channel
        ttitle = ['Channel ' num2str(a) ' Power Vs Time'];
        figs(end+1) = figure('Name', ttitle, 'Position', [100, 100, 1200, 800]);
        plotcounter = 0;
        for b = 1:length(bandnames) % for every band
            tbandname = bandnames{b};
            tband = bands.(tbandname);
            plotcounter = plotcounter + 1;
            subplot(4, 3, plotcounter);
            if ~isempty(tband.powervectors.All{a})
                plot(tband.powervectors.All{a});
                hold on;
                yl = get(gca, 'ylim');
                plot([lightsOnTime lightsOnTime], yl);
            else
                warning(['No power vector data to plot for band "', tbandname, '" on channel ', num2str(a)]);
            end
            title(tbandname);
            axis tight;
        end
        annotation('textbox', [0.5, 0.98, 0, 0], 'String', ttitle, 'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    end

    % Power vs. Time - Smoothed
    for a = 1:length(specs)  % for each channel
        ttitle = ['Channel ' num2str(a) ' Power Vs Time Smoothed 30s'];
        figs(end+1) = figure('Name', ttitle, 'Position', [100, 100, 1200, 800]);
        plotcounter = 0;
        for b = 1:length(bandnames) % for every band
            tbandname = bandnames{b};
            tband = bands.(tbandname);
            plotcounter = plotcounter + 1;
            subplot(4, 3, plotcounter);
            if ~isempty(tband.powervectors.All{a})
                plot(smooth(tband.powervectors.All{a}, 30));
                hold on;
                yl = get(gca, 'ylim');
                plot([lightsOnTime lightsOnTime], yl);
            else
                warning(['No power vector data to plot for band "', tbandname, '" on channel ', num2str(a)]);
            end
            title(tbandname);
            axis tight;
        end
        annotation('textbox', [0.5, 0.98, 0, 0], 'String', ttitle, 'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    end
end



