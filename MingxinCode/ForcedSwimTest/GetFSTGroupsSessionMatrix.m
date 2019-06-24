function ds = GetFSTGroupsSessionMatrix

% [~,cname]=system('hostname');

d = getdropbox;
tx = readtable(fullfile(d,'/Data/FSTGroupsSessionMatrix.csv'),'ReadVariableNames',1);
ds= table2struct(tx);
end
