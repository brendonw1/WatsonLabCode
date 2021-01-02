function output = importPhoLabjackServerEventsCsvFileHelper(filename, dataLines)
%IMPORTFILE Import data from a .csv text file exported by LabjackEventsLoader.py
%  OUTPUT = IMPORTFILE(FILENAME) reads data from text file FILENAME for
%  the default selection.  Returns the data as a table.
%
%  OUTPUT = IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  output = importfile("C:\Users\halechr\repo\phoPythonVideoFileParser\results\output.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 2019-07-11 16:42:35.345

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options
% opts = delimitedTextImportOptions("NumVariables", 10);
% Ignoring Running Wheel Data:
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
% opts.VariableNames = ["milliseconds_since_epoch", "DIO0", "DIO1", "DIO2", "DIO3", "DIO4", "DIO5", "DIO6", "DIO7", "MIO0"];
% opts.VariableNames = ["milliseconds_since_epoch", "EIO0", "EIO1", "EIO2", "EIO3", "EIO4", "EIO5", "EIO6", "EIO7", "AIN0"];
% opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.VariableNames = ["milliseconds_since_epoch", "EIO0", "EIO1", "EIO2", "EIO3", "EIO4", "EIO5", "EIO6", "EIO7"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
output = readtable(filename, opts);

end