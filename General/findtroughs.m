function troughs = findtroughs(signal);
%finds any trough... ie a point where the slope before is negative and the
%slope after is positive.  Value returned is a series of indices, referring
%to the indices of the original input signal where the troughs are.

ds = diff(signal);%find changes between points
ds = sign(ds);%make either pos or negative
dpos = ds>=0;
dneg = ds<0;
dpos(1) = [];%scoot up one so diffs relevant to a particular point are in register with the pos diffs
dneg(end) = [];%cutoff so same length as dneg
troughs = find(dpos.*dneg);%find places where pos followed by neg in original signal
troughs = troughs+1;%compensate for "diff"-ing