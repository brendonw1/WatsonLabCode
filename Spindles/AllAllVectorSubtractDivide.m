function [msub,mdiv,l10mdiv] = AllAllVectorSubtractDivide(v)
v = v(:);

m1 = repmat(v,[1 length(v)]);
m2 = m1';

msub = m1-m2;
mdiv = m1./m2;
l10mdiv = log10(mdiv);