function [ccgR, tR] = ccg_wrapper(tsdspikes,clus1,clus2,BinSize)
% Wrapper for getting ccgs out of pairs of cells in a tsdarray
% BinSize in ms
% Brendon Watson 2014

res1 = TimePoints(tsdspikes{clus1});
res2 = TimePoints(tsdspikes{clus2});
T = cat(1,res1,res2);

G = cat(1,1+zeros(size(res1)),2+zeros(size(res2)));

SampleRate = 10000;%%Based on usual TSD object sample rate<< NEED TO GENERALIZE THIS, HAVEN'T FIGURED OUT HOW YET
BinSize = BinSize*SampleRate/1000;
HalfBins = round(300/BinSize);

GSubset = [1,2];
Normalization = 'count';

[ccgR, tR, Pairs] = CCG(T, G, BinSize, HalfBins, SampleRate, GSubset, Normalization);