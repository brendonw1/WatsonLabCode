function [ComodMap,Params] = REM_CFCmap(LFPsubEpoch,varargin)
%
% [ComodMap,Params] = REM_CFCmap(LFPsubEpoch,varargin)
%
% Cross-frequency coupling comodulation map. Adapted from buzcode.
%
% USAGE
%   - LFPsubEpoch: time samples in a column vector, i.e., 1 channel.
%                  Sub-epoch extracted using timestamps from
%                  REM_CoarsePhase.
%   - varargin:    please see input parser section.  This includes basic
%   parameters including: Sampling Frequency and others
%
% OUTPUTS
%   - ComodMap: comodulation map (amplitude frequencies in dimension 1,
%               phase frequencies in dimension 2).
%   - Params: a structure
%       - .AmplitAxis: list of CFC amplitude frequencies
%       - .PhaseAxis:  list of CFC phase frequencies
%
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

addParameter(p,'SamplFreq',1250,@isnumeric) % Hz of LFP sampling, 1250=buzcode default
addParameter(p,'PhaseFreqRange',[4 12],@isnumeric) % Range of frequencies to check for phase modulation (Hz)
addParameter(p,'PhaseFreqBins',0.25,@isnumeric) % Hz
addParameter(p,'AmplitFreqRange',[20 200],@isnumeric) % Range of amplitudes over which to examine phase modulation (Hz)
addParameter(p,'AmplitFreqBins',5,@isnumeric) % Hz

parse(p,varargin{:})
SamplFreq       = p.Results.SamplFreq;
PhaseFreqRange  = p.Results.PhaseFreqRange;
PhaseFreqBins   = p.Results.PhaseFreqBins;
AmplitFreqRange = p.Results.AmplitFreqRange;
AmplitFreqBins  = p.Results.AmplitFreqBins;

PhaseAxis  = PhaseFreqRange(1):PhaseFreqBins:PhaseFreqRange(2);
AmplitAxis = AmplitFreqRange(1):AmplitFreqBins:AmplitFreqRange(2);



%% Filter LFP for phase frequency axis
FiltPhase = cell(1,length(PhaseAxis)-1);
for PhaseFreqIdx = 1:length(PhaseAxis)-1
    FiltPhase{PhaseFreqIdx} = bz_Filter(double(LFPsubEpoch),...
        'passband',PhaseAxis(PhaseFreqIdx:PhaseFreqIdx+1),...
        'filter','fir1','channels',1);
end



%% Comodulation matrix
Progress = 0;
fprintf(1,'Constructing CFC map: %1d%%\n',Progress);
ComodMap = zeros(length(AmplitAxis)-1,length(FiltPhase));
for AmplitFreqIdx = 1:length(AmplitAxis)-1
    
    Progress = 100+(100*(AmplitFreqIdx/length(AmplitAxis)-1));
    fprintf(1,'\b\b\b\b%3.0f%%',Progress)
    
    % Wavelet
    WaveSpectr = bz_WaveSpec(LFPsubEpoch,...
        'frange',[AmplitAxis(AmplitFreqIdx) AmplitAxis(AmplitFreqIdx+1)],...
        'nfreqs',1,'samplingRate',SamplFreq);
    WaveSpectr = abs(WaveSpectr.data);
    
    % Bin phase and power
    NumBins = 50;
    PhaseBins = linspace(-pi,pi,NumBins+1);
    for PhaseFreqIdx = 1:length(FiltPhase)
        
        [~,~,PhaseAll] = histcounts(angle(hilbert(...
            FiltPhase{PhaseFreqIdx})),PhaseBins);
        
        PhaseAmp = zeros(NumBins,1);
        for BinIdx = 1:NumBins
            PhaseAmp(BinIdx) = mean(WaveSpectr(PhaseAll==BinIdx),1);
        end
        PhaseAmp = PhaseAmp./sum(PhaseAmp,1);
        ComodMap(AmplitFreqIdx,PhaseFreqIdx) = sum(PhaseAmp.*log(...
            PhaseAmp./(ones(NumBins,size(PhaseAmp,2))/NumBins)))/log(NumBins);
    end
end
fprintf('\n')



%% Frequency lists for later use
Params.PhaseAxis  = PhaseAxis;
Params.AmplitAxis = AmplitAxis;

end
