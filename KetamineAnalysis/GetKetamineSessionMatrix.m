function tx = GetKetamineSessionMatrix

[~,cname]=system('hostname');

d = '/analysis/BWRatKetamineDataset';% getdropbox; David: It seems that this directory has changed quite significantly
% if strcmp(cname(1:6),'Mac176') | strcmp(cname(1:6),'border') | strcmp(cname(1:6),'balrog')%if I'm on my laptop or linux
    tx = read_mixed_csv(fullfile(d,'/KetamineSessionMatrix.csv'),','); % David: There is also a change here
% else %other computers...
    
% end

%
% 
% if strcmp(cname(1:9),'MAC157688')%if I'm on my laptop
%     tx = read_mixed_csv('/Users/brendon/Dropbox/Data/Sleep/SleepSessionMatrix.csv',',');
% else %ie if at lab
%     tx = read_mixed_csv('/mnt/brendon4/Dropbox/Data/Sleep/SleepSessionMatrix.csv',',');
% end
