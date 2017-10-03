function funcsynapses = FindSynapse_KeepOnlyDiffShank(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

% load funcsynapsesMoreStringent
t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
funcsynapses = t.funcsynapses;

%% Correct weird [0,1] size matrices
% ind = 0;
% if numel(funcsynapses.ConnectionsE) == 0
%     funcsynapses.ConnectionsE = [];
%     ind = 1;
% end
% if numel(funcsynapses.ConnectionsI) == 0
%     funcsynapses.ConnectionsI = [];
%     ind = 1;
% end
% if ind == 1;
%     save(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']),'funcsynapses')    
%     disp('redid empty Cnxns')
% end

%%    
ne = size(funcsynapses.ConnectionsE,1);
ni = size(funcsynapses.ConnectionsI,1);
badcnxns = [];

% Go through each pair, grab shanks, if same ok
% if not same add too badcnxns
% E cnxns
for a = 1:ne
    s1 = funcsynapses.CellShanks(funcsynapses.ConnectionsE(a,1));
    s2 = funcsynapses.CellShanks(funcsynapses.ConnectionsE(a,2));
    if s1 == s2
        badcnxns(end+1,:) = funcsynapses.ConnectionsE(a,:);
    end
end
for a = 1:ni
    s1 = funcsynapses.CellShanks(funcsynapses.ConnectionsI(a,1));
    s2 = funcsynapses.CellShanks(funcsynapses.ConnectionsI(a,2));
    if s1 == s2
        badcnxns(end+1,:) = funcsynapses.ConnectionsI(a,:);
    end
end

fsold = funcsynapses;
funcsynapses = FindSynapseToStruct(funcsynapses,badcnxns,[]);

% delete(fullfile(basepath,[basename '_funcsynapsesMS_SameShank.mat']))
save(fullfile(basepath,[basename '_funcsynapsesMS_DiffShank.mat']),'funcsynapses')