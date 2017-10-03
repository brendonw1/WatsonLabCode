function [MaxTime,tidx] = MaxACGTimePoint(ACGs,Times)
%finds max point of each ACG in the array ACGs, where each ACG is a row in
%ACGs. Times denote times of each bin.  Output is Time value of the max bin
% Brendon Watson 2015

if ~exist('Times','var')
    Times = 1:length(ACG);
end

[~,tidx] = max(ACGs,[],1);
MaxTime = Times(tidx);