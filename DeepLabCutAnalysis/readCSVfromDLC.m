function readCSVfromDLC

% Gets label coordinates from a DeepLabCut *.csv file.
%
%
%
% USAGE ___________________________________________________________________
% Enter readCSVfromDLC, and browse toward the *.csv in the dialog that
% appears. The *.csv-containing folder becomes the working directory where
% the output will be saved.
%
%
%
% OUTPUT __________________________________________________________________
% A structure, each field corresponding to a label defined in the DeepLabCut
% "Label Frames" GUI.
% See: https://www.biorxiv.org/content/biorxiv/early/2018/11/24/476531.full.pdf
% Dimension 1 of each field contains the frames. Columns 1 and 2 are
% X and Y coordinates, respectively.
%
%
%
% LSBuenoJr _______________________________________________________________



%%
[CSVfromDLC,CSVfromDLCpath,~] = ...
    uigetfile('*.csv','Select CSV from deeplabcut','MultiSelect','off');
cd(CSVfromDLCpath);clear CSVfromDLCpath

DLClabels = readtable(CSVfromDLC);
DLClabels = table2array(DLClabels(1,2:3:end)); % Could not figure out a
                                               % better way for extracting
                                               % only the row of labels.
                                               % Tried csvread, textscan, etc.

DLCdata   = single(readmatrix(CSVfromDLC));k = 2;

for i = 1:length(DLClabels)
    labelCoords.(DLClabels{i}) = DLCdata(:,k:k+1);
    k = k+3;
end

save('labelCoords.mat','labelCoords')
end