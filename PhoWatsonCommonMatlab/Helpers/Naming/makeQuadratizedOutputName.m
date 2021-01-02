function [quadratizedName] = makeQuadratizedOutputName(quadratizedGlobalGroupIndex, baseOutputPrefix)
%makeQuadratizedOutputName Summary of this function goes here
%   Detailed explanation goes here


% 'qMuxPair_0_mm-dd-yy' is the default format

if ~exist('baseName','var')
	baseOutputPrefix = 'qMuxPair';
end

formatOut = 'mm-dd-yy';
out_datestring = convertStringsToChars(datestr(now,formatOut));

% Build the final output info:
% quadratizedName = join([baseOutputPrefix, num2str(quadratizedGlobalGroupIndex), out_datestring],'_');
quadratizedName = join([baseOutputPrefix, string(quadratizedGlobalGroupIndex), out_datestring],'_');
quadratizedName = convertStringsToChars(quadratizedName);
end

