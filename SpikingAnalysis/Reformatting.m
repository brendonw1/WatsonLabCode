%if ~exist(filestr,'var')
    filestr = 'Dino_080114';
% end
csvstr = [filestr,'.csv']; %['E:\', filestr,'.csv'];
data = readtable(csvstr);
unitnumber = find(strcmp(data.Properties.VariableNames,'AllFile_start')) - 1;

conv = {};
for i = 1:unitnumber
    disp(['loading unit',int2str(i)])
    convertedcol = table2cell(data(:,i));
    conv = [conv; convertedcol(~isnan(table2array(data(:,i))))];
    conv(end + 1) = {';'};
    disp('done')
end

disp('writing txt file');
%cd('E:\');
writecell(conv,[filestr,'.txt'])