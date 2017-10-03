function CompleteCellID = SpikingAnalysis_MakeCompleteCellID(CellClassificationOutput,CellIDs)
% Takes CellID and CellClassificationOutput structs and combines their info
% to create a single matrix with 3 columns with cell type, and 2 measured
% parameters
% INPUTS:
% -CellClassificationOutput: has parameter measures, cell nums, etc, from
%               BWCellClassification
% -CellIDs: IDs of cells in various classes, from
%              "SpikingAnalysis_BigScript"
%
% OUTPUTS: 
% -CompleteCellID: 3 column matrix, as below
%       Column1: Cell type: 2 = excitatory cell determined by synapse
%                           1 = excitatory-like as determined by spike
%                           params
%                           0 = undetermined (usually no 0s)
%                           -1 = inhibitory-like as determined by spike
%                           params
%                           1 = inhibitory cell determined by synapse
%       Column2: Spike trough to peak time (average spike measured on 
%                           largest amplitude channel)
%       Column3: Total spike width (by wavelets on average spike measured on 
%                           largest amplitude channel)
%       


cellids = zeros(size(CellClassificationOutput.CellClassOutput,1),1);
cellids(CellIDs.EDefinite) = 2;
cellids(CellIDs.IDefinite) = -2;
cellids(CellIDs.ELike) = 1;
cellids(CellIDs.ILike) = -1;

params = CellClassificationOutput.CellClassOutput(:,2:3);

CompleteCellID = [cellids,params];