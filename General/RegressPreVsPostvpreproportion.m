function [r,p,coeffs] = RegressPreVsPostvpreproportion(pre,post)
% Pre and Post are vectors of the same length, presumably referring
% element-wise to the same data generators.
% h is a handle of all figures generated
% r,p and coeffs are each cell array of 4 values relating to x vs y 
% correlations for linear vs linear, log vs linear, linear vs log and
% log vs log versions of x and y

%% Basic initial calculations and setup
pre = pre(:);
post = post(:);

% % percent changes... look at linear changes on this
% prepostpercentchg = ConditionedPercentChange(pre,post);

% proportions of original - use geometric stats here
postvpreproportion = ConditionedProportion(pre,post);

x = pre;
y = postvpreproportion;

if ~isempty(x) & ~isempty(y) & ~all(isnan(x)) & ~all(isnan(y)) & all(isreal(x)) & all(isreal(y)) 
        [yfit{1},r{1},p{1},coeffs{1}] =  RegressAndFindR(x,y,1);

        xl = log10(x);
        xl = real(xl);
        badx = logical(isnan(xl) + isinf(xl));
        xl(badx) = [];
        y2 = y;
        y2(badx) = [];
        [yfit{2},r{2},p{2},coeffs{2}] =  RegressAndFindR(xl,y2,1);
        
        yl = log10(y);
        yl = real(yl);
        bady =  logical(isnan(yl) + isinf(yl));
        x2 = x;
        x2(bady) = [];
        [yfit{3},r{3},p{3},coeffs{3}] =  RegressAndFindR(x,yl,1);
        
        xl = log10(x);
        xl = real(xl);
        badx = isnan(xl) + isinf(xl);
        yl = log10(y);
        yl = real(yl);
        bady = isnan(yl) + isinf(yl);
        badbad = logical(badx+bady);
        xl(badbad) = [];
        yl(badbad) = [];
        [yfit{4},r{4},p{4},coeffs{4}] =  RegressAndFindR(xl,yl,1);        
else
    for a = 1:4
        yfit{a} = [];
        r{a} = [];
        p{a} = [];
        coeffs{a} = [];
    end
    axes
end