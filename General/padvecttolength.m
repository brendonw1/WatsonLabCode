function vect = padvecttolength(vect,newlength)
% adds nans to a vector to pad it out to be as long as newlength, us long
% as newlength is longer than vect

if newlength <= length(vect)
    return
end

s = size(vect);
vect = vect(:);
pad = nan(newlength-length(vect),1);
vect = cat(1,vect,pad);

if s(2)>s(1)
    vect = vect';
end