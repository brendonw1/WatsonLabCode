function output = StructFieldSizes(aaainputstruct)

v2struct(aaainputstruct);
w = whos;

for a = 1:length(w);
%     bytes(a) = w(a).bytes;
%     names{a} = w(a).name;
    output{a,1} = [w(a).name ': ' num2str(w(a).bytes)];
end