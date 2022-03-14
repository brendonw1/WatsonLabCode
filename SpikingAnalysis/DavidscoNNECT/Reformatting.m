rat = 'Achilles_120413';
sieve = {'All Units','Max Choices','David Choices','Collab Choices'};
timestamps = {'','baseline','circadian'};
fileloc = 'Z:\BWRatKetamineDataset\Achilles_120413';
saveloc = 'C:\Users\duck7\Documents\Lab Shit\coNNECT_reformat\coNNECT reformatted spikes';
filestr = num2cell(1:12);
for u = 1:3
    for p = 1:4
    filestr{p + (4*(u-1))} = {[rat '_' sieve{p} timestamps{u}]};
    end
end



for y = 1:12
    cd(fileloc)
    csvstr = [filestr{y}{1},'.csv'];
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
    cd(saveloc);
    writecell(conv,[filestr{y}{1},'.txt'])
end