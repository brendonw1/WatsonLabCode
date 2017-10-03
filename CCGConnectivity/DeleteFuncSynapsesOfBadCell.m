function funcsynapses = DeleteFuncSynapsesOfBadCell(funcsynapses,cellnum)
% Give cell ID relative to the ID it had when funcsynapses was created.
% Finds all connections involving that cell and deletes them, makes a new
% funcsynapses for output.  Does not save.
% Brendon Watson 2015


% Get rid of connections involving now-bad cells
badcnxns = [];
for a = 1:length(cellnum)
    tcn = cellnum(a);
    [rownum,~]=find(funcsynapses.ConnectionsE==tcn);
    badcnxns = cat(1,badcnxns,funcsynapses.ConnectionsE(rownum,:));
    [rownum,~]=find(funcsynapses.ConnectionsI==tcn);
    badcnxns = cat(1,badcnxns,funcsynapses.ConnectionsI(rownum,:));
end
funcsynapses = FindSynapseToStruct(funcsynapses,badcnxns);


%have to renumber remaiing cells to correspond with removed cells now
cellnum = sort(cellnum);
for a = length(cellnum):-1:1
    tcn = cellnum(a);
    chg = funcsynapses.ConnectionsE>tcn;
    funcsynapses.ConnectionsE(chg) = funcsynapses.ConnectionsE(chg)-1;
    chg = funcsynapses.ConnectionsI>tcn;
    funcsynapses.ConnectionsI(chg) = funcsynapses.ConnectionsI(chg)-1;

    chg = funcsynapses.ECells>tcn;
    funcsynapses.ECells(chg) = funcsynapses.ECells(chg)-1;
    chg = funcsynapses.ICells>tcn;
    funcsynapses.ICells(chg) = funcsynapses.ICells(chg)-1;

    chg = funcsynapses.Connections0E>tcn;
    funcsynapses.Connections0E(chg) = funcsynapses.Connections0E(chg)-1;
    chg = funcsynapses.Connections0I>tcn;
    funcsynapses.Connections0I(chg) = funcsynapses.Connections0I(chg)-1;

    chg = funcsynapses.ConnectionsEE>tcn;
    funcsynapses.ConnectionsEE(chg) = funcsynapses.ConnectionsEE(chg)-1;    
    chg = funcsynapses.ConnectionsEI>tcn;
    funcsynapses.ConnectionsEI(chg) = funcsynapses.ConnectionsEI(chg)-1;
    chg = funcsynapses.ConnectionsIE>tcn;
    funcsynapses.ConnectionsIE(chg) = funcsynapses.ConnectionsIE(chg)-1;    
    chg = funcsynapses.ConnectionsII>tcn;
    funcsynapses.ConnectionsII(chg) = funcsynapses.ConnectionsII(chg)-1;

    chg = funcsynapses.ConnectionsEUnk>tcn;
    funcsynapses.ConnectionsEUnk(chg) = funcsynapses.ConnectionsEUnk(chg)-1;
    chg = funcsynapses.ConnectionsIUnk>tcn;
    funcsynapses.ConnectionsIUnk(chg) = funcsynapses.ConnectionsIUnk(chg)-1;
end

%remove bad cells from stored matrices
funcsynapses.CellShanks(cellnum) = [];
funcsynapses.CellShankIDs(cellnum) = [];
funcsynapses.FlippedCnxns(cellnum,:) = [];
funcsynapses.FlippedCnxns(:,cellnum) = [];
funcsynapses.CnxnTimesVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnTimesVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnBinsVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnBinsVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnTimesVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnTimesVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnBinsVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnBinsVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnStartTimesVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnStartTimesVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnStartBinsVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnStartBinsVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnStartTimesVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnStartTimesVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnStartBinsVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnStartBinsVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnEndTimesVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnEndTimesVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnEndBinsVsRefSpk(:,cellnum) = [];
funcsynapses.CnxnEndBinsVsRefSpk(cellnum,:) = [];
funcsynapses.CnxnEndTimesVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnEndTimesVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnEndBinsVsCCGStart(:,cellnum) = [];
funcsynapses.CnxnEndBinsVsCCGStart(cellnum,:) = [];
funcsynapses.CnxnWeightsZ(:,cellnum) = [];
funcsynapses.CnxnWeightsZ(cellnum,:) = [];
funcsynapses.CnxnWeightsR(:,cellnum) = [];
funcsynapses.CnxnWeightsR(cellnum,:) = [];
funcsynapses.PairUpperThreshs(:,cellnum) = [];
funcsynapses.PairUpperThreshs(cellnum,:) = [];
funcsynapses.PairLowerThreshs(cellnum,:) = [];
funcsynapses.PairLowerThreshs(:,cellnum) = [];
funcsynapses.fullCCGMtx(:,cellnum,:) = [];
funcsynapses.fullCCGMtx(:,:,cellnum) = [];
funcsynapses.fullRawCCGMtx(:,cellnum,:) = [];
funcsynapses.fullRawCCGMtx(:,:,cellnum) = [];
funcsynapses.CellRates(cellnum) = [];

