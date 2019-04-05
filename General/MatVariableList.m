function names = MatVariableList(matname)

w = whos(matfile(matname));
for a = 1:length(w);
    names{a}=w(a).name;
end