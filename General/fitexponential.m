function [a,b,cia,cib] = fitexponential(x,y)
% fits an exponential, gives a, b, cia, cib based on y = a*b^x
% might also consider nlinfit followed by nlparci
% Brendon Watson 2015


f = fit(x,y,'exp1');

[cv] = coeffvalues(f);
a = cv(1);
b = cv(2);

ci = confint(f);
cia = ci(:,1)';
cib = ci(:,2)';