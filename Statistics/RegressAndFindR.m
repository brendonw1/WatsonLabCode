function [yfit,r,p,coeffs,CI] =  RegressAndFindR(x,y,n)
%function [yfit,r,p,coeffs] =  RegressAndFindR(x,y,n)
%Finds polynomial regression of x,y data at polynomial of degree n (default 
%n = 1), gives
%fitted y and r.  
%Uses a mixed series of approaches because some are faster but others more
%accurate.

x = x(:);
y = y(:);

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

%% get fit model
r = [];
p = [];
yfit = [];
coeffs = [];
CI = [];
if ~isempty(x) & ~isempty(y) & ~all(isnan(x)) & ~all(isnan(y)) & all(isreal(x)) & all(isreal(y)) 
    lm = fitlm(x,y,modelspec);
    c = lm.Coefficients;
    coeffs = flipud(c.Estimate);
    yfit = polyval(coeffs,x);

    try
    %     [b,int] = regress(x,y);
        [p,S] = polyfit(x,y,n);
        CI = polyparci(p,S,0.95);
    end
    
    %% p
    p = c.pValue(2);% based on lm, more accurate p than "corr"

    %% correlation coefficient based on corr since it's just easier than taking root of r2 and figuring out sign
    % r2 = lm.Rsquared.Ordinary;
    %get rid of rows with 
    nans = any(isnan([x,y]'));
    x(nans) = [];
    y(nans) = [];

    r = corr([x,y]);
    r = r(1,2);
end

%OLD... NO P value
% coeffs = polyfit(x,y,n);
% yfit = polyval(coeffs,x);
% 
% yresid = y - yfit;
% SSresid = sum(yresid.^2);
% SStotal = (length(y)-1) * var(y);
% r2 = 1 - SSresid/SStotal;

