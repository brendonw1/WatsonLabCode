function funcsynapses = UpdateFuncSynConnectionClassification(basepath,basename)
% Circle back and re-classify funcsynapses based on CellIDs

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_CellIDs.mat']));
load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));

%% keep initial classes
funcsynapses.ConnectionsEEDefinite = funcsynapses.ConnectionsEE;
funcsynapses.ConnectionsEIDefinite = funcsynapses.ConnectionsEI;
funcsynapses.ConnectionsIEDefinite = funcsynapses.ConnectionsIE;
funcsynapses.ConnectionsIIDefinite = funcsynapses.ConnectionsII;

%% Now define postcell based on spike waveform (which is already squared with synapse)
e = funcsynapses.ConnectionsE;
i = funcsynapses.ConnectionsI;

if ~isempty(e)
    eeidx = ismember(e(:,2),CellIDs.EAll);
    eiidx = ismember(e(:,2),CellIDs.IAll);
    funcsynapses.ConnectionsEE = e(eeidx,:);
    funcsynapses.ConnectionsEI = e(eiidx,:);
else
    funcsynapses.ConnectionsEE = [];
    funcsynapses.ConnectionsEI = [];
end    

if ~isempty(i)
    ieidx = ismember(i(:,2),CellIDs.EAll);
    iiidx = ismember(i(:,2),CellIDs.IAll);

    funcsynapses.ConnectionsIE = i(ieidx,:);
    funcsynapses.ConnectionsII = i(iiidx,:);
else
    funcsynapses.ConnectionsIE = [];
    funcsynapses.ConnectionsII = [];
end    

%% save
save(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']),'funcsynapses');
