function OutData = REM_BinnedVector(InData,BinSize)
%
% OutData = REM_BinnedVector(InData,BinSize)
%
% Averages data into bins.
%
% USAGE
%   - InData:  single-column vector or matrix with number of rows greater
%              than number of columns.
%   - BinSize: integer in number of data points. May correspond to the
%              frame or sampling rate.
%
% OUTPUT
%   - OutData: binned data.
%
% Bueno-Junior et al. (2023)

%% Round length
RoundLength = floor(length(InData)/BinSize)*BinSize;
OutData = InData(1:RoundLength,:);



%% Binning
OutData = reshape(mean(reshape(OutData,...
    BinSize,numel(OutData)/BinSize),'omitnan')',...
    size(OutData,1)/BinSize,size(OutData,2));

end