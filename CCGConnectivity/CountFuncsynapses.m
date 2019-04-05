function SynCounts = CountFuncsynapses(funcsynapses,CellIDs,SynCounts)
% Basic counting/recording of rates of incidence of various types of
% connections found in funcsynapses.  The input "Counts" is optional, if
% given as an input, the counts in the dataset carried by funcsynapses will
% be added to the values already in "Counts".
% Brendon Watson 2014

if ~exist('SynCounts','var')
    SynCounts.TotalPairsCompared = 0;
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

SynCounts.TotalPairsCompared = SynCounts.TotalPairsCompared + prod(size(funcsynapses.CnxnWeightsZ));

SynCounts.Cnxns = SynCounts.Cnxns + size(funcsynapses.ConnectionsE,1) + size(funcsynapses.ConnectionsI,1);

SynCounts.ECnxns = SynCounts.ECnxns + size(funcsynapses.ConnectionsE,1);
SynCounts.ICnxns = SynCounts.ICnxns + size(funcsynapses.ConnectionsI,1);

SynCounts.EECnxns = SynCounts.EECnxns + size(funcsynapses.ConnectionsEE,1);
SynCounts.EICnxns = SynCounts.EICnxns + size(funcsynapses.ConnectionsEI,1);
SynCounts.EUnkCnxns = SynCounts.EUnkCnxns + size(funcsynapses.ConnectionsEUnk,1);
for a = 1:size(funcsynapses.ConnectionsEUnk,1)
    if ismember(funcsynapses.ConnectionsEUnk(a,2),CellIDs.ELike)
        SynCounts.EELikeCnxns = SynCounts.EELikeCnxns + 1;
    elseif ismember(funcsynapses.ConnectionsEUnk(a,2),CellIDs.ILike)
        SynCounts.EILikeCnxns = SynCounts.EILikeCnxns + 1;
    end
end

SynCounts.IECnxns = SynCounts.IECnxns + size(funcsynapses.ConnectionsIE,1);
SynCounts.IICnxns = SynCounts.IICnxns + size(funcsynapses.ConnectionsII,1);
SynCounts.IUnkCnxns = SynCounts.IUnkCnxns + size(funcsynapses.ConnectionsIUnk,1);
for a = 1:size(funcsynapses.ConnectionsIUnk,1)
    if ismember(funcsynapses.ConnectionsIUnk(a,2),CellIDs.ELike)
        SynCounts.IELikeCnxns = SynCounts.IELikeCnxns + 1;
    elseif ismember(funcsynapses.ConnectionsIUnk(a,2),CellIDs.ILike)
        SynCounts.IILikeCnxns = SynCounts.IILikeCnxns + 1;
    end
end
