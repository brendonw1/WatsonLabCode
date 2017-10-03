function outbins = makebinsforsliding_byproportion(starttime,endtime,binwidthproportion,slideproportion)
%makes sliding bins of a width spanning from starttime to endtime.
% bin width specified by by binwidthproportion (ie 0.1 means the bin is
% 1/10th of the total span from starttime to endtime).  Slideproportion
% specifies the proportion of binwidth that each subsequent bin is scooted
% by (ie 0.2 means means each adjacent pair of bins overlaps 80%).
% Allows bins to continue until within "binwidth" of the end.  No pad of
% decrementing width bins.
% Brendon Watson 2015

totalwidth = endtime-starttime;
binwidth = totalwidth*binwidthproportion;
bininterval = binwidth*slideproportion;

binstarts = starttime:bininterval:(endtime-binwidth);
binends = (starttime+binwidth):bininterval:endtime;

outbins = [binstarts' binends'];


