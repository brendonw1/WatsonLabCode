function [yfit,r2,p] =  RegressAndFindR2(x,y,n)

%Finds polynomial regression of x,y data at polynomial of degree n, gives
%fitted y and r2.

if ~exist('n','var')
    n = 1;
end
% modelspec = 'linear';
switch n
    case 1
        modelspec = 'linear';
    case 2 
        modelspec = 'quadratic';
end

oks = ~logical(isnan(x)+isnan(y));
x2 = x(oks);
y2 = y(oks);

lm = fitlm(x2,y2,modelspec);
c = lm.Coefficients;
coeffs = flipud(c.Estimate);
yfittemp = polyval(coeffs,x);
p = c.pValue(2);
r2 = lm.Rsquared.Ordinary;

%OLD... NO P value
coeffs = polyfit(x2,y2,n);
yfitttemp = polyval(coeffs,x2);

yfit = nan(size(y));
foks = find(oks)
for a = 1:length(foks)
    yfit(foks) = yfittemp(a);
end
    
% 
% yresid = y - yfit;
% SSresid = sum(yresid.^2);
% SStotal = (length(y)-1) * var(y);
% r2 = 1 - SSresid/SStotal;

