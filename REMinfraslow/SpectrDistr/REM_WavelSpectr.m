function [WavelSpectr,FreqList] = REM_WavelSpectr(LFPepoch,Params)
%
% [WavelSpectr,FreqList] = REM_WavelSpectr(LFPepoch,Params)
%
% Wavelet spectrogram.
%
% USAGE
%   - LFPepoch: vector of time samples (can be int16, double, etc.).
%   - Params: a structure
%       - .FreqLims:    frequency band, e.g., [5 10] -> 5-10 Hz
%       - .FreqBinSize: scalar in Hz (e.g., 0.05)
%       - .NumCycles:   scalar (e.g., 40)
%       - .SamplFreq:   scalar in Hz (e.g., 125)
%   - Dependencies (from https://github.com/buzsakilab/buzcode):
%       - MorletWavelet
%       - FConv
%
% OUTPUTS
%   - WavelSpectr: frequency bins (rows) x time samples (columns)
%   - FreqList: list of frequency bins
%
% Bueno-Junior et al. (2023)

%% Make sure LFP epoch is column vector with double precision
LFPepoch = double(LFPepoch);
if size(LFPepoch,1) > 1 && size(LFPepoch,2) > 1
    error('LFPepoch must be a vector')
elseif size(LFPepoch,1) == 1 && size(LFPepoch,2) > 1
    LFPepoch = LFPepoch';
end



%% Required inputs. Throw error messages if parameters are lacking.
FreqLims    = Params.FreqLims;
FreqBinSize = Params.FreqBinSize;
NumCycles   = Params.NumCycles;
SamplFreq   = Params.SamplFreq;



%% Frequency list
FreqList = FreqLims(1)+FreqBinSize:FreqBinSize:FreqLims(2);



%% Frequency loop
WavelSpectr   = zeros(length(FreqList),length(LFPepoch));
for FreqIdx   = 1:length(FreqList)
    TempWavel = MorletWavelet(FreqList(FreqIdx),NumCycles,1/SamplFreq);
    WavelSpectr(FreqIdx,:) = FConv(TempWavel',LFPepoch);
end



%% Spectrogram
WavelSpectr = abs(WavelSpectr);

end
