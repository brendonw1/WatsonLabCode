function funcsynapses = cleanfuncsynapses(funcsynapses,badclus)
% Gets rid of all info relating to clusters denoted in "badclus"... ie if
% restricting shanks or for other reasons

numclus = size(funcsynapses.CellShanks,1);
remaining = 1:numclus;
remaining(badclus) = [];
[dummy,cnv] = sort(remaining);

funcsynapses.CellShanks(badclus) = [];
funcsynapses.CellShankIDs(badclus) = [];

fn = fieldnames(funcsynapses);
for a = 1:length(fn)
    eval(['tsz = size(funcsynapses.' fn{a} ');'])    
    if size(tsz,2)==2 && tsz(1) == numclus && tsz(2) == numclus
        eval(['funcsynapses.' fn{a} ' = elimelsonbothdims(funcsynapses.' fn{a} ',badclus);'])
    end
end
    
funcsynapses.fullCCGMtx(:,badclus,:) = [];
funcsynapses.fullCCGMtx(:,:,badclus) = [];
funcsynapses.fullRawCCGMtx(:,badclus,:) = [];
funcsynapses.fullRawCCGMtx(:,:,badclus) = [];

funcsynapses.CellRates(badclus,:) = [];

funcsynapses.ConnectionsE = rmvBadShiftToNewOrder(funcsynapses.ConnectionsE,badclus,remaining,cnv);
funcsynapses.ConnectionsI = rmvBadShiftToNewOrder(funcsynapses.ConnectionsI,badclus,remaining,cnv);
funcsynapses.ECells = rmvBadShiftToNewOrder(funcsynapses.ECells,badclus,remaining,cnv);
funcsynapses.ICells = rmvBadShiftToNewOrder(funcsynapses.ICells,badclus,remaining,cnv);
% funcsynapses.Connections0E = rmvBadShiftToNewOrder(funcsynapses.Connections0E,badclus,remaining,cnv);
% funcsynapses.Connections0I = rmvBadShiftToNewOrder(funcsynapses.Connections0I,badclus,remaining,cnv);
funcsynapses.ConnectionsEE = rmvBadShiftToNewOrder(funcsynapses.ConnectionsEE,badclus,remaining,cnv);
funcsynapses.ConnectionsEI = rmvBadShiftToNewOrder(funcsynapses.ConnectionsEI,badclus,remaining,cnv);
funcsynapses.ConnectionsEUnk = rmvBadShiftToNewOrder(funcsynapses.ConnectionsEUnk,badclus,remaining,cnv);
funcsynapses.ConnectionsIUnk = rmvBadShiftToNewOrder(funcsynapses.ConnectionsIUnk,badclus,remaining,cnv);
funcsynapses.ConnectionsIE = rmvBadShiftToNewOrder(funcsynapses.ConnectionsIE,badclus,remaining,cnv);
funcsynapses.ConnectionsII = rmvBadShiftToNewOrder(funcsynapses.ConnectionsII,badclus,remaining,cnv);
funcsynapses.BadConnections = rmvBadShiftToNewOrder(funcsynapses.BadConnections,badclus,remaining,cnv);
funcsynapses.WideConnections = rmvBadShiftToNewOrder(funcsynapses.WideConnections,badclus,remaining,cnv);

% funcsynapses.ConnectionsE(any(ismember(funcsynapses.ConnectionsE, badclus),2),:)=[];
% funcsynapses.ConnectionsI(any(ismember(funcsynapses.ConnectionsI, badclus),2),:)=[];
% funcsynapses.ECells(any(ismember(funcsynapses.ECells, badclus),2),:)=[];
% funcsynapses.ICells(any(ismember(funcsynapses.ICells, badclus),2),:)=[];
% funcsynapses.Connections0E(any(ismember(funcsynapses.Connections0E, badclus),2),:)=[];
% funcsynapses.Connections0I(any(ismember(funcsynapses.Connections0I, badclus),2),:)=[];
% funcsynapses.ConnectionsEE(any(ismember(funcsynapses.ConnectionsEE, badclus),2),:)=[];
% funcsynapses.ConnectionsEI(any(ismember(funcsynapses.ConnectionsEI, badclus),2),:)=[];
% funcsynapses.ConnectionsEUnk(any(ismember(funcsynapses.ConnectionsEUnk, badclus),2),:)=[];
% funcsynapses.ConnectionsIE(any(ismember(funcsynapses.ConnectionsIE, badclus),2),:)=[];
% funcsynapses.ConnectionsII(any(ismember(funcsynapses.ConnectionsII, badclus),2),:)=[];
% funcsynapses.ConnectionsIUnk(any(ismember(funcsynapses.ConnectionsIUnk, badclus),2),:)=[];
% funcsynapses.BadConnections(any(ismember(funcsynapses.BadConnections, badclus),2),:)=[];
% funcsynapses.WideConnections(any(ismember(funcsynapses.WideConnections, badclus),2),:)=[];

% Opting to do nothing with OriginalConnectivity
% if isfield(funcsynapses,'OriginalConnectivity') 
% end

if isfield(funcsynapses,'ZeroLag')
    funcsynapses.ZeroLag = cleanfuncsynapseszl(funcsynapses.ZeroLag,badclus);
end
    
%%
function mtx = elimelsonbothdims(mtx,badclus)
mtx(:,badclus) = [];
mtx(badclus,:) = [];

%%
function funcsynapses = cleanfuncsynapseszl(funcsynapses,badclus)
numclus = size(funcsynapses.CellShanks,1);
remaining = 1:numclus;
remaining(badclus) = [];
[dummy,cnv] = sort(remaining);

funcsynapses.CellShanks(badclus) = [];


fn = fieldnames(funcsynapses);
for a = 1:length(fn)
    eval(['tsz = size(funcsynapses.' fn{a} ');'])    
    if size(tsz,2)==2 && tsz(1) == numclus && tsz(2) == numclus
        eval(['funcsynapses.' fn{a} ' = elimelsonbothdims(funcsynapses.' fn{a} ',badclus);'])
    end
end
    
funcsynapses.fullCCGMtx(:,badclus,:) = [];
funcsynapses.fullCCGMtx(:,:,badclus) = [];

funcsynapses.ERanges = rmvBadShiftToNewOrder(funcsynapses.ERanges,badclus,remaining,cnv);
funcsynapses.IRanges = rmvBadShiftToNewOrder(funcsynapses.IRanges,badclus,remaining,cnv);
funcsynapses.EPairs = rmvBadShiftToNewOrder(funcsynapses.EPairs,badclus,remaining,cnv);
funcsynapses.IPairs = rmvBadShiftToNewOrder(funcsynapses.IPairs,badclus,remaining,cnv);

% funcsynapses.ERanges(any(ismember(funcsynapses.EPairs, badclus),2),:)=[];
% funcsynapses.IRanges(any(ismember(funcsynapses.IPairs, badclus),2),:)=[];
% funcsynapses.EPairs(any(ismember(funcsynapses.EPairs, badclus),2),:)=[];
% funcsynapses.IPairs(any(ismember(funcsynapses.IPairs, badclus),2),:)=[];