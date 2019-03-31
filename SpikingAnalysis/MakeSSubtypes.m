function [Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_CellIDs.mat']));
CellIDs = t.CellIDs;

t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;
% cellIx = t.cellIx;
% shank = t.shank;

%%

Se = S(CellIDs.EAll);
SeDef = S(CellIDs.EDefinite);
SeLike = S(CellIDs.ELike);
Si = S(CellIDs.IAll);
SiDef = S(CellIDs.IDefinite);
SiLike = S(CellIDs.ILike);

%Set all to 0x0 tsdArrays if empty, rather than other strange problematic
%0x1 arrays and others
snames = {'Se','Si','SeDef','SiDef','SeLike','SiLike'};
for a  = 1:length(snames)
    sn = snames{a};
    eval(['ps = prod(size(' sn '));'])
    if ps==0
        eval([sn ' = tsdArray;'])
    end
end


SRates = Rate(S);
SeRates = Rate(Se);
SiRates = Rate(Si);

save(fullfile(basepath,[basename '_SSubtypes']),'Se','SeDef','SeLike','Si','SiDef','SiLike','SRates','SeRates','SiRates')
