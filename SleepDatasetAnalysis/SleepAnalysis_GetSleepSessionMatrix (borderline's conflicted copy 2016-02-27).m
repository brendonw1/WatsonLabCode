function tx = SleepAnalysis_GetSleepSessionMatrix

[~,cname]=system('hostname');

d = getdropbox;
if strcmp(cname(1:9),'MAC157688') | strcmp(cname(1:10),'borderline')%if a Brendon computer
    tx = read_mixed_csv(fullfile(d,'Data','SleepSessionMatrix.csv'),',');
else %other computers...
    
end

%
% 
% if strcmp(cname(1:9),'MAC157688')%if I'm on my laptop
%     tx = read_mixed_csv('/Users/brendon/Dropbox/Data/Sleep/SleepSessionMatrix.csv',',');
% else %ie if at lab
%     tx = read_mixed_csv('/mnt/brendon4/Dropbox/Data/Sleep/SleepSessionMatrix.csv',',');
% end
