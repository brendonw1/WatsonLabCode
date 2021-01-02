function [bbIDString] = bbid2string(bbid)
%BBID2STRING Converts an integer bbid into a 2-digit fixed-width (2 -> '02', 15 -> '15') string
	bbIDString = sprintf('%0.2d',bbid);
end

