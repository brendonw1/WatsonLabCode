function out = overUnder1(X)

X(X > 0) = 1;
X(X < 0) = -1;
out = X;