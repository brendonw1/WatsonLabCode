function [sub] = LFPSubsetBasedOnInterval(sig,fs,win1,win2)
%LFPSUBSETBASEDONINTERVAL Aight, so check this out. You have this LFP, and
%you wanna get a subset of that based on time windows, namsayin? You give
%it a signal (of course), a sampling rate (PER SECOND, so hz...), and two 
%time windows expressed in SECONDS
%   sig = the signal
%   fs = the sampling rate in Hz
%   win1 = the start of the interval in seconds
%   win2 = the end of the interval in seconds



%% First, let's make sure that the parameters are pretty okay
if win1 > win2
    error('bitch ass, you cant start your interval after you stop. Check your params')
end

t = (0:(length(sig) - 1)) / fs;

condition = (t > win1) & (t < win2);
sub = sig(condition);

end

