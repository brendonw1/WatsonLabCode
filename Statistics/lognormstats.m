function [m,sd,meanci,sdci,cv] = lognormstats(v,mode)
% stats of lognormal distribution input vector v.  m is mean, sd is
% standard dev, meanci is confidence interval of mean estimate, sdci is
% confidence interval of sd estimate, cv is coefficient of variation.  The
% mode input specifies whether you want natural log or base10 log and can
% be either 'e' or '10' or e or 10 numbers.

if ~exist('mode','var')
    mode = 'e';
end

[stats,ci] = lognfit(v);

switch mode
    case 'e'
        basis = exp(1);
    case '10'
        basis = 10;
        stats = stats/log(10);%convert to log10
        ci = ci/log(10);%convert to log10
end

m = stats(1);
sd = stats(2);
meanci = ci(:,1);
sdci = ci(:,2);

cv= sqrt(basis^(sd^2) - 1);%not sure this works for base10
        
1;

% var = sd^2;
% cv2 = sqrt(10^var / (10^m * 10^m));


% See http://www.itl.nist.gov/div898/handbook/eda/section3/eda3669.htm
%     This and others give CV  = sqrt( exp(sigma^2)-1 )
% See both http://fmwww.bc.edu/RePEc/bocode/l/lognfit.html 
%               & 
%          http://fmwww.bc.edu/RePEc/bocode/l/lognfit.ado
%     These give 1/2 CV squared = i2 = .5*`e(var)'/(`e(mean)'*`e(mean)')
%                             ?So i2 = .5*10^var / (10^m * 10^m);
%                            ? So cv = sqrt(10^var / (10^m * 10^m));

