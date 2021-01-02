%% LabjackData to Python
%%  script that tries to help export a .mat file that can be read by Python, specifically my "phoPythonVideoFileParser" scripts.

%table_struct = struct(labjackTimeTable);
%table_columns = table_struct.varDim.labels;

%labjackTimeArray = table2array(labjackTimeTable);

%save table_as_struct table_struct table_columns;
labjackDataOutput.dateTime = datenum(labjackData.dateTime);
labjackDataOutput.dataArray = double(labjackTimeTable{:,13:20});
labjackDataOutput.ColumnNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense'};

pythonOutput.outputPath = 'Output/LabjackDataArray.mat';
    
if isfile(pythonOutput.outputPath)
    save(pythonOutput.outputPath, 'labjackDataOutput','-append','-v7.3');
else
    save(pythonOutput.outputPath, 'labjackDataOutput','-v7.3');
end
