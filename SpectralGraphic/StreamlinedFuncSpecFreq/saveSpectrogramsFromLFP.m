function specs = saveSpectrogramsFromLFP(basepath, lfpFile, channels, nCh, fs, nFFT, fRange, suffix)
    % basepath: the directory path for saving the output
    % lfpFile: .lfp file containing the data
    % channels: vector of channels to process
    % nCh: Total number of channels in the recording
    % fs: sampling frequency
    % nFFT: FFT length for spectrogram
    % fRange: frequency range for the spectrogram
    % suffix: suffix for the filename
    
    [~, baseName, ~] = fileparts(lfpFile);
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
    eegstatesname = fullfile(basepath, [baseName '.eegstates.mat']);
    save(eegstatesname, 'StateInfo');
    
    specs = SaveSpectrogramsAsStruct(StateInfo);
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