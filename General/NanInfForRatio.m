function x=NanInfForRatio(x)

x(isnan(x)) = 1; %means 0/0
x(x==Inf) = 2;%arbitrary... so that on linear scale is equally far from the 0 created by -Inf from a 1
x(x==-Inf) = 0;