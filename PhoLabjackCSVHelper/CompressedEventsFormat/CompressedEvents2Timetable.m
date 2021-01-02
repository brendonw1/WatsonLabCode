function [timetable] = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames)
%COMPRESSEDEVENTS2TIMETABLE Takes compressed events objects and outputs a timetable like the one loaded from the non-compressed events representations
%   Refactored from TestPlotAllCompressed.m on 7/12/19
% addpath(genpath('HelperFunctions'));
% Reconstruct timetable
fields = fieldnames(OutputDeltasTimestamps);
numVariables = numel(fields);
outputDateTimes = [];
outputEventRows = [];
    for i = 1:numVariables
        currNumRows = length(OutputDeltasTimestamps.(fields{i}));
        currTemplateRow = zeros(1,numVariables);
        currTemplateRow(i) = 1;
        currTemplateRows = repmat(currTemplateRow,[currNumRows, 1]);
        outputDateTimes = [outputDateTimes; OutputDeltasTimestamps.(fields{i})];
        outputEventRows = [outputEventRows; currTemplateRows];
    end
    
if exist('varNames','var')
    labjackData = array2table(outputEventRows,'VariableNames',varNames);
else
    labjackData = array2table(outputEventRows,'VariableNames',fields);
end

labjackData.dateTime = outputDateTimes;
% Convert the table to a timetable
timetable = table2timetable(labjackData,'RowTimes','dateTime');
% timetable = array2timetable(outputEventRows,'RowTimes',outputDateTimes,'VariableNames',varNames);
% timetable.Properties.VariableNames{'Time'} = 'dateTime';
end

