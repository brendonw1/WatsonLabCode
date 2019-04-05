function out = makeShuffledPlaceVector(V)
%function out = makeShuffledPlaceVector(V)
%Resamples the non-zero elements of V without replacement
%Does NOT perform 'rng('shuffle')'!!!!!


a = V(V > 0);
V(V > 0) = a(tiedrank(rand(length(a), 1)));
out = V;