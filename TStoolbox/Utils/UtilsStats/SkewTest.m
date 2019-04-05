function P = SkewTest(X);

%  Test for a positive skewness based on a Kolmogorov-Smirnov test between the population higher than the mean
%  and the population below the mean

alpha = 0.05;

mu = mean(X);

posPt = X(X>mu) - mu;
negPt = mu - X(X<mu);

[H,P] = kstest2(posPt,negPt,alpha,'larger');
