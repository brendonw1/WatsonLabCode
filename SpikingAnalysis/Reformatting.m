ratname = 'Achilles_120413';
filestr = {[ratname, '_Collab Choices'],[ratname, '_Collab Choicesbaseline'] ... 
    ,[ratname, '_Collab Choicescircadian'],[ratname, '_All Units'] ...
    ,[ratname, '_All Unitsbaseline'],[ratname, '_All Unitscircadian']};
fileloc = 'Z:\BWRatKetamineDataset\Achilles_120413';
locationstr = 'C:\Users\duck7\Documents\Lab Shit\coNNECT_reformat\coNNECT reformatted spikes';

for indfile = 1:length(filestr)
    cd(fileloc);
    csvstr = [filestr{indfile},'.csv'];
    data = readtable(csvstr);
    unitnumber = find(strcmp(data.Properties.VariableNames,'AllFile_start')) - 1;
    
    conv = {};
    for i = 1:unitnumber
        disp(['loading unit',int2str(i)])
        convertedcol = table2cell(data(:,i));
        if ~isempty(convertedcol(~isnan(table2array(data(:,i)))))
            conv = [conv; convertedcol(~isnan(table2array(data(:,i))))];
            conv(end + 1) = {';'};
            disp('done')
        else
            disp('this bitch empty yeet')
        end
    end
    
    disp('writing txt file');
    cd(locationstr);
    writecell(conv,[filestr{indfile},'.txt'])
end