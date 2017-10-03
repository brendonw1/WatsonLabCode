function CellIDs = ChangeStatusInCellIDs(thiscell,CellIDs,newstatus)
% Makes sure cell has appropriate status in "CellIDs", based on input
% "newstatus" which may be ELike, ILike, EDef or IDef.

switch newstatus
    case 'ELike'
        CellIDs.EDefinite(CellIDs.EDefinite==thiscell) = [];
        CellIDs.ELike = sort([CellIDs.ELike(:);thiscell]);
        CellIDs.EAll = sort([CellIDs.EAll(:);thiscell]);
        CellIDs.IDefinite(CellIDs.IDefinite==thiscell) = [];
        CellIDs.ILike(CellIDs.ILike==thiscell) = [];
        CellIDs.IAll(CellIDs.IAll==thiscell) = [];
    case 'EDef'
        CellIDs.EDefinite = sort([CellIDs.EDefinite(:);thiscell]);
        CellIDs.ELike = sort([CellIDs.ELike(:);thiscell]);
        CellIDs.EAll = sort([CellIDs.EAll(:);thiscell]);
        CellIDs.IDefinite(CellIDs.IDefinite==thiscell) = [];
        CellIDs.ILike(CellIDs.ILike==thiscell) = [];
        CellIDs.IAll(CellIDs.IAll==thiscell) = [];

    case 'ILike'
        CellIDs.EDefinite(CellIDs.EDefinite==thiscell) = [];
        CellIDs.ELike(CellIDs.ELike==thiscell) = [];
        CellIDs.EAll(CellIDs.EAll==thiscell) = [];
        CellIDs.IDefinite(CellIDs.IDefinite==thiscell) = [];
        CellIDs.ILike = sort([CellIDs.ILike(:);thiscell]);
        CellIDs.IAll = sort([CellIDs.IAll(:);thiscell]);
    case 'IDef'
        CellIDs.EDefinite(CellIDs.EDefinite==thiscell) = [];
        CellIDs.ELike(CellIDs.ELike==thiscell) = [];
        CellIDs.EAll(CellIDs.EAll==thiscell) = [];
        CellIDs.IDefinite = sort([CellIDs.IDefinite(:);thiscell]);
        CellIDs.ILike = sort([CellIDs.ILike(:);thiscell]);
        CellIDs.IAll = sort([CellIDs.IAll(:);thiscell]);
end

fn = fieldnames(CellIDs);
for a = 1:length(fn)
    tfn = fn{a};
    eval(['t = CellIDs.' tfn ';'])
    t = sort(unique(t));
    eval(['CellIDs.' tfn ' = t;'])
end
    