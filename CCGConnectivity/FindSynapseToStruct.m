function funcsynapses = FindSynapseToStruct(funcsynapses,badcnxns,widecnxns)
% Identifies and stores in a structure types of connections and cell types
% based on connectivity, based on Make_FindSynapse_bw. Takes out bad
% connections and also re-categorizes wide connections.
%
% "funcsynapses" must already have in it the following:
% funcsynapses.CnxnTimes = synTimes;
% funcsynapses.CnxnWeightsZ = synWeightsZ;
% funcsynapses.CnxnWeightsR = synWeightsR;
% funcsynapses.PairUpperThreshs = triu(synSig);
% funcsynapses.PairLowerThreshs = tril(synSig);

if~exist('badcnxns','var') && ~exist('widecnxns','var')
    badcnxns = [];
end
if ~exist('widecnxns','var')
    widecnxns = [];
end
if isfield(funcsynapses,'ConnectionsE')
    ConnectionsE = funcsynapses.ConnectionsE;
    ConnectionsI = funcsynapses.ConnectionsI; 
    ECells = funcsynapses.ECells;
    ICells = funcsynapses.ICells;
    ConnectionsEE = funcsynapses.ConnectionsEE;
    ConnectionsEI = funcsynapses.ConnectionsEI;
    ConnectionsEUnk = funcsynapses.ConnectionsEUnk;
    ConnectionsIE = funcsynapses.ConnectionsIE;
    ConnectionsII = funcsynapses.ConnectionsII;
    ConnectionsIUnk = funcsynapses.ConnectionsIUnk;

    if isfield(funcsynapses,'BadConnections');
        BadConnections = funcsynapses.BadConnections;
    else
        BadConnections = [];
    end
    if isfield(funcsynapses,'WideConnections');
        WideConnections = funcsynapses.WideConnections;
    else
        WideConnections = [];
    end

    temp = v2struct(ConnectionsE, ConnectionsI, ECells, ICells,...
        ConnectionsEE, ConnectionsEI, ConnectionsEUnk,...
        ConnectionsIE,ConnectionsII,ConnectionsIUnk,BadConnections,WideConnections);
    if ~isfield(funcsynapses,'OriginalConnectivity')
        newfieldname = 'OriginalConnectivity';
    else
        newfieldname = 'MostRecentConnectivity';
    end
    eval(['funcsynapses.' newfieldname '=temp;'])
%     fields = {'ConnectionsE','ConnectionsI','ECells', 'ICells',...
%         'ConnectionsEE', 'ConnectionsEI','ConnectionsEUnk', 'ConnectionsIE',...
%         'ConnectionsII', 'ConnectionsIUnk', 'BadConnections'};
%     funcsynapses=rmfield(funcsynapses,fields);
%         clear ConnectionsE ConnectionsI ECells ICells...
%             ConnectionsEE ConnectionsEI ConnectionsEUnk ConnectionsIE... 
%             ConnectionsII ConnectionsIUnk BadConnections

    funcsynapses.ConnectionsE = ConnectionsE;
    funcsynapses.ConnectionsI = ConnectionsI;
else
    funcsynapses.ConnectionsE = [];
    funcsynapses.ConnectionsI = [];
    
    [pre,post] = find(funcsynapses.CnxnWeightsZ>0);%grabbing excitatory cnxns
    funcsynapses.ConnectionsE = [pre post];
    [pre,post] = find(funcsynapses.CnxnWeightsZ<0);%grabbing inhibitory cnxns
    funcsynapses.ConnectionsI = [pre post];
end

%% setting/resetting some things
funcsynapses.ECells = [];
funcsynapses.ICells = [];
% funcsynapses.Connections0E = [];
% funcsynapses.Connections0I = [];
funcsynapses.ConnectionsEE = [];
funcsynapses.ConnectionsEI = [];
funcsynapses.ConnectionsEUnk = [];
funcsynapses.ConnectionsIE = [];
funcsynapses.ConnectionsII = [];
funcsynapses.ConnectionsIUnk = [];
funcsynapses.BadConnections = badcnxns;
funcsynapses.WideConnections = widecnxns;



%% Get rid of bad Connections
if ~isempty(badcnxns)
    % Elim bad E Cnxns
    if ~isempty(funcsynapses.ConnectionsE)
        [lia,locb]=ismember(badcnxns,funcsynapses.ConnectionsE,'rows');
        funcsynapses.ConnectionsE(locb(lia),:) = [];
    end
    
    % Elim bad I Cnxns
    if ~isempty(funcsynapses.ConnectionsI)
        [lia,locb]=ismember(badcnxns,funcsynapses.ConnectionsI,'rows');
        funcsynapses.ConnectionsI(locb(lia),:) = [];
    end
end
if numel(funcsynapses.ConnectionsE) == 0
    funcsynapses.ConnectionsE = [];
end
if numel(funcsynapses.ConnectionsI) == 0
    funcsynapses.ConnectionsI = [];
end

%% Simple ID'ing of each cell
if ~isempty(funcsynapses.ConnectionsE)
    funcsynapses.ECells = unique(funcsynapses.ConnectionsE(:,1));
end

if ~isempty(funcsynapses.ConnectionsI)
    funcsynapses.ICells = unique(funcsynapses.ConnectionsI(:,1));
end

funcsynapses.EIProblemCells = intersect(funcsynapses.ECells,funcsynapses.ICells);

%% Classfying EE, EI, IE and II connections
if ~isempty(funcsynapses.ConnectionsE)
    for a = 1:size(funcsynapses.ConnectionsE)
        thisconnection = funcsynapses.ConnectionsE(a,:);
        if ~isempty(find(funcsynapses.ECells==thisconnection(2)));
            funcsynapses.ConnectionsEE(end+1,:) = thisconnection;
        elseif ~isempty(find(funcsynapses(1).ICells==thisconnection(2)));
            funcsynapses.ConnectionsEI(end+1,:) = thisconnection;
        else
            funcsynapses.ConnectionsEUnk(end+1,:) = thisconnection;
        end
    end
end

if ~isempty(funcsynapses.ConnectionsI)
    for a = 1:size(funcsynapses.ConnectionsI)
        thisconnection = funcsynapses.ConnectionsI(a,:);
        if ~isempty(find(funcsynapses.ECells==thisconnection(2)));
            funcsynapses.ConnectionsIE(end+1,:) = thisconnection;
        elseif ~isempty(find(funcsynapses(1).ICells==thisconnection(2)));
            funcsynapses.ConnectionsII(end+1,:) = thisconnection;
        else
            funcsynapses.ConnectionsIUnk(end+1,:) = thisconnection;
        end
    end
end
    

%% If zero lag synapses, categorize unique pairs
if isfield(funcsynapses,'ZeroLag');
    if isfield(funcsynapses.ZeroLag,'CnxnWeightsZ')
        [pre post]=find(funcsynapses.ZeroLag.CnxnWeightsZ>0);
        prepost = unique([pre post],'rows');
        prepost = EliminatePalindromeRows(prepost);
        funcsynapses.ZeroLag.EPairs = prepost;
        
        [pre post]=find(funcsynapses.ZeroLag.CnxnWeightsZ<0);
        prepost = unique([pre post],'rows');
        prepost = EliminatePalindromeRows(prepost);
        funcsynapses.ZeroLag.IPairs = prepost;

        funcsynapses.ZeroLag.ERanges = [];
        funcsynapses.ZeroLag.IRanges = [];        

        epairs = funcsynapses.ZeroLag.EPairs;
        for a  = 1:size(epairs,1)
            if a==1;
                funcsynapses.ZeroLag.ERanges = [];
            end
            temp = CalcZeroLagRange(funcsynapses,epairs(a,1),epairs(a,2),'above');
            if ~isempty(temp)
                funcsynapses.ZeroLag.ERanges(a,:) = temp;
            end
        end
        
        ipairs = funcsynapses.ZeroLag.IPairs;
        for a  = 1:size(ipairs,1)
            if a==1;
                funcsynapses.ZeroLag.ERanges = [];
            end
            temp = CalcZeroLagRange(funcsynapses,ipairs(a,1),ipairs(a,2),'below');
            if ~isempty(temp)
                funcsynapses.ZeroLag.IRanges(a,:) = temp;
            end
        end    
        
    end    
end

if isfield(funcsynapses,'wide')
   %% do same as above basically?? 
end
