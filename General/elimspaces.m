function outstring = elimspaces(instring);

idxs = strfind(instring,' ');
outstring = instring;
outstring(idxs) = [];
