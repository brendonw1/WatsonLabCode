function [DistrHist,BinList] = REM_DistrHist(DataVector,Params)
%
% [DistrHist,BinList] = REM_DistrHist(DataVector,Params)
%
% Distribution of physiological fluctuations.
%
% USAGE
%   - DataVector: vector of time samples (double precision)
%       - RECOMMENDED: detrending and z scoring (or normalization) of
%                      DataVector within epoch pairs
%   - Params: a structure
%       - .HistLims: histogram limits (e.g., [- 5 5] or [0 1])
%       - .HistBinSize: scalar (e.g., 0.1 or 0.01)
%
% OUTPUT
%   - DistrHist: distribution histogram
%   - BinList: histogram bins (their right edges); same length as DistrHist
%
% Bueno-Junior et al. (2023)

%% Required inputs. Throw error messages if parameters are lacking.
HistLims    = Params.HistLims;
HistBinSize = Params.HistBinSize;



%% Bin list
BinList = HistLims(1):HistBinSize:HistLims(2);



%% Counts per bin, probability density function
DistrHist = histcounts(DataVector,'normalization','pdf');
BinList   = BinList(2:end); % same length as DistrHist (ready for plotting)

end
