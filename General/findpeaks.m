function peaks = findpeaks(signal);
%finds any peak... ie a point where the slope before is positive and the
%slope after is negative.  Value returned is a series of indices, referring
%to the indices of the original input signal where the peaks are.

ds = diff(signal);%find changes between points
ds = sign(ds);%make either pos or negative
%below... make two vectors, one for positive slopes and one for
%negative ones, so we can multiply them by each other
dsneg = ds(2:end);%scoot up one so diffs relevant to a particular point are in register with the pos diffs
dspos = ds(1:end-1);%cutoff so same length as dneg
peaks = (find(dspos.*dsneg ==-1));%find places where pos followed by neg in original signal
peaks = peaks+1;%compensate for "diff"-ing


% dpos = ds>=0;
% dneg = ds<0;
% dneg(1) = [];
% dpos(end) = [];
% peaks = find(dpos.*dneg)==1;
% peaks = peaks+1;%compensate for "diff"-ing