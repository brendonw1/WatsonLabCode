clearvars;
clc;

activeFileName = 'Table_S1_6.0.xlsx';
sanatizedOutputFileName = 'Table_S1_6';
activeExperimentSheetName = 'Expt 1';

[HighlyMobile, Mobile, Immobile, finalOutputTable, activeHighlyMobile, activeMobile, activeImmobile] = performPhoPaulFSTAnalysis(activeFileName, activeExperimentSheetName, sanatizedOutputFileName);


Mobile.experimentalResults.experimentalIsOutlier


% Write to spreadsheet
excel_output_filename = 'results/Pho FST Analysis Results 12-9-2019 - WithExclusions.xlsx';
writetable(T,excel_output_filename,'Sheet',activeExperimentSheetName,'Range','D1')

highlyMobileColumnCell = 'B';
mobileColumnCell = 'G';
immobileColumnCell = 'L';

