function SynCounts = CountFuncsynapses_DiffShanks(funcsynapses,CellIDs,SynCounts)
% Basic counting/recording of rates of incidence of various types of
% connections found in funcsynapses.  The input "Counts" is optional, if
% given as an input, the counts in the dataset carried by funcsynapses will
% be added to the values already in "Counts".
% Brendon Watson 2014

if ~exist('SynCounts','var')
    SynCounts.DiffShankPairsCompared = 0;
    SynCounts.Cnxns = 0;
    SynCounts.ECnxns = 0;
    SynCounts.ICnxns = 0;
    SynCounts.EECnxns = 0;
    SynCounts.EICnxns = 0;
    SynCounts.EUnkCnxns = 0;
    SynCounts.EELikeCnxns = 0;
    SynCounts.EILikeCnxns = 0;
    SynCounts.IECnxns = 0;
    SynCounts.IICnxns = 0;
    SynCounts.IUnkCnxns = 0;
    SynCounts.IELikeCnxns = 0;
    SynCounts.IILikeCnxns = 0;
end

sh = funcsynapses.CellShanks;
[mx,my] = meshgrid(sh);
ds = mx - my;
SynCounts.DiffShankPairsCompared = SynCounts.DiffShankPairsCompared + sum(sum(abs(ds)>0));

SynCounts.Cnxns = SynCounts.Cnxns + GetNumDiffShankPairs([funcsynapses.ConnectionsE; funcsynapses.ConnectionsI],sh);

SynCounts.ECnxns = SynCounts.ECnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsE,sh);
SynCounts.ICnxns = SynCounts.ICnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsI,sh);

SynCounts.EECnxns = SynCounts.EECnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsEE,sh);
SynCounts.EICnxns = SynCounts.EICnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsEI,sh);
SynCounts.EUnkCnxns = SynCounts.EUnkCnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsEUnk,sh);
eeltemp = [];
eiltemp = [];
for a = 1:size(funcsynapses.ConnectionsEUnk,1)
    if ismember(funcsynapses.ConnectionsEUnk(a,2),CellIDs.ELike)
        eeltemp(end+1,:) = funcsynapses.ConnectionsEUnk(a,:);
    elseif ismember(funcsynapses.ConnectionsEUnk(a,2),CellIDs.ILike)
        eiltemp(end+1,:) = funcsynapses.ConnectionsEUnk(a,:);
    end
end
SynCounts.EELikeCnxns = SynCounts.EELikeCnxns + GetNumDiffShankPairs(eeltemp,sh);
SynCounts.EILikeCnxns = SynCounts.EILikeCnxns + GetNumDiffShankPairs(eiltemp,sh);

%% I Pre
SynCounts.IECnxns = SynCounts.IECnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsIE,sh);
SynCounts.IICnxns = SynCounts.IICnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsII,sh);
SynCounts.IUnkCnxns = SynCounts.IUnkCnxns + GetNumDiffShankPairs(funcsynapses.ConnectionsIUnk,sh);
ieltemp = [];
iiltemp = [];
for a = 1:size(funcsynapses.ConnectionsIUnk,1)
    if ismember(funcsynapses.ConnectionsIUnk(a,2),CellIDs.ELike)
        ieltemp(end+1,:) = funcsynapses.ConnectionsIUnk(a,:);
    elseif ismember(funcsynapses.ConnectionsIUnk(a,2),CellIDs.ILike)
        iiltemp(end+1,:) = funcsynapses.ConnectionsIUnk(a,:);
    end
end
SynCounts.IELikeCnxns = SynCounts.IELikeCnxns + GetNumDiffShankPairs(ieltemp,sh);
SynCounts.IILikeCnxns = SynCounts.IILikeCnxns + GetNumDiffShankPairs(iiltemp,sh);



function numdiffshank = GetNumDiffShankPairs(pairslist,cellshanks)

numdiffshank = 0;
if prod(size(pairslist))>0
    for a = 1:size(pairslist,1);
        tpre = pairslist(a,1);
        tpost = pairslist(a,2);
        if cellshanks(tpre)~=cellshanks(tpost)
            numdiffshank = numdiffshank+1;
        end;
    end
end