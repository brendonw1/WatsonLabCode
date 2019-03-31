function [i1,i2] = IntervalOverlaps(int1,int2)
% startstop pairs of rows int1 and int2 are inputs.
% function will output indices of overlapping intervals: i1 are indices of
% int1 that overlap with int2 elements.  i2 is indices of int2 that overlap
% with int1 elements.  

% starting with principle that a pair of intervals can be quickly
% determined to overlap if the start of one is before the stop of two AND
% the start of two is before the stop of one
[m11,m12]=meshgrid(int1(:,1),int2(:,2));%make repeating matrix of starts of 1 and stops of 2
m1 = (m12-m11)>=0;%find cases where start of 1 less than stop of 2
[m21,m22]=meshgrid(int1(:,2),int2(:,1));%make repeating matrix of starts of 2 and stops of 1
m2 = (m21-m22)>=0;%find cases where start of 2 less than stop of 1
m = m1.*m2;%find cases of full overlap using logicals

i1 = find(sum(m,1));
i1 = i1(:);
i2 = find(sum(m,2));
i2 = i2(:);