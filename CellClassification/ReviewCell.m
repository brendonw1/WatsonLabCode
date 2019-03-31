function ReviewCell(cellnum,basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_CellIDs.mat']));
CellIDs = t.CellIDs;
t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent']));
funcsynapses = t.funcsynapses;
t = load(fullfile(basepath,[basename '_CellClassificationOutput.mat']));
CellClassificationOutput = t.CellClassificationOutput;
v2struct(CellClassificationOutput)
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;


figure
PlotCell2DWPyrBound(cellnum,CellClassOutput,PyrBoundary)

FindSynapse_ReviewOutput(funcsynapses,S,'t',cellnum)