function [CellClassOutput, PyrBoundary] = RedoCellClass(ESynapseCells, ISynapseCells,basepath,basename)

%% Load basics including prior CellClassificationOutput to start with
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_CellClassificationOutput.mat']));
v2struct(CellClassificationOutput);%outputs PyrBoundary and CellClassOutput

%% Declare some basic variables from unadulterated portions of data struct
cellnums = CellClassOutput(:,1);
x = CellClassOutput(:,2);%trough to peak time in ms
y = CellClassOutput(:,3);%full trough time in ms

ELike = inpolygon(x, y, PyrBoundary(:,1),PyrBoundary(:,2));

%% Re-declare output variable from scratch
clear CellClassOutput
CellClassOutput(:,1) = cellnums;
CellClassOutput(:,2) = x;%trough to peak time in ms
CellClassOutput(:,3) = y;%full trough time in ms
CellClassOutput(:,4) = -1;%ilike, based on user click (outside polygon)
CellClassOutput(ELike,4) = 1;%elike, inside polygon
CellClassOutput(:,5) = zeros(size(cellnums));
CellClassOutput(ISynapseCells,5) = -1;%ICells, based on funcsynapse input
CellClassOutput(ESynapseCells,5) = 1;%Ecells, based on funcsynapse output
