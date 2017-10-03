function [vertplots,horizplots] = determinenumsubplots(numplots)

horizplots = ceil(sqrt(numplots));

nexthighestsquare = horizplots^2;

if (horizplots - (nexthighestsquare - numplots))<=0;
    vertplots = horizplots-1;
else
    vertplots = horizplots;
end