function lfp_out = RestrictLFPToIntervals(lfp,intervals)
% Takes LFP data and keeps only segments specified by timestamps in
% "intervals" input.  
%
% INPUTS
% lfp: in buzcode format, such as from bz_GetLFP.m
% intervals: nx2 (two column) matrix, one row per epoch.  Column 1 is start
%   times (in seconds)for each epoch/interval.  Column 2 is stop times (in
%   seconds)
% 
% OUTPUTS
%
% lfp_out: identical to lfp (input) but with timestamps and data of times
%   only in intervals specified.  
%
% Brendon Watson 2018

lfp_out = lfp;
timestamps_out = [];
data_out = [];

for iidx = 1:size(intervals,1);
    goodidxs = lfp.timestamps>=intervals(iidx,1) & lfp.timestamps<=intervals(iidx,2);
    
    timestamps_out = cat(1, timestamps_out, lfp.timestamps(goodidxs));
    data_out = cat(1, data_out, lfp.data(goodidxs,:));
end

lfp_out.timestamps = timestamps_out;
lfp_out.data = data_out;
