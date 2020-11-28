function temp(basepath,basename)
SAllP = fullfile(basepath,[basename '_SAll.mat']);
SStableP = fullfile(basepath,[basename '_SStable.mat']);
SBurstFilteredP = fullfile(basepath,[basename '_SBurstFiltered.mat']);
SSubtypesP = fullfile(basepath,[basename '_SSubtypes.mat']);

SAllPo = fullfile(basepath,[basename '_SAll.mat_old']);
SStablePo = fullfile(basepath,[basename '_SStable.mat_old']);
SBurstFilteredPo = fullfile(basepath,[basename '_SBurstFiltered.mat_old']);
SSubtypesPo = fullfile(basepath,[basename '_SSubtypes.mat_old']);

if exist(SAllP,'file')
    load(SAllP,'S')
    if max(End(S))>1000000%if long enough assume it's upsampled (1000000 seconds or 277 hours)
        eval(['! cp ' SAllP ' ' SAllPo])
        S = StoSDown(S);
        save(SAllP,'S')
    end
end
clear S

if exist(SStableP,'file')
    load(SStableP,'S')
    if max(End(S))>1000000%if long enough assume it's upsampled (1000000 seconds or 277 hours)
        eval(['! cp ' SStableP ' ' SStablePo])
        S = StoSDown(S);
        save(SStableP,'S')
    end
end
clear S

if exist(SBurstFilteredP,'file')
    load(SBurstFilteredP,'Sbf')
    if max(End(Sbf))>1000000%if long enough assume it's upsampled (1000000 seconds or 277 hours)
        eval(['! cp ' SBurstFilteredP ' ' SBurstFilteredPo])
        Sbf = StoSDown(Sbf);
        save(SBurstFilteredP,'Sbf')
    end
end
clear Sbf

if exist(SSubtypesP,'file')
    load(SSubtypesP,'Se')
    if max(End(Se))>1000000%if long enough assume it's upsampled (1000000 seconds or 277 hours)
        eval(['! cp ' SSubtypesP ' ' SSubtypesPo])
        load(SSubtypesP,'SeDef')
        load(SSubtypesP,'SeLike')
        load(SSubtypesP,'Si')
        load(SSubtypesP,'SiDef')
        load(SSubtypesP,'SiLike')
        
        if exist('Se','var')
            Se = StoSDown(Se);
        end
        if exist('Si','var')
            Si = StoSDown(Si);
        end
        if exist('SeDef','var')
            SeDef = StoSDown(SeDef);
        end
        if exist('SeLike','var')
            SeLike = StoSDown(SeLike);
        end
        if exist('SiDef','var')
            SiDef = StoSDown(SiDef);
        end
        if exist('SiLike','var')
            SiLike = StoSDown(SiLike);
        end
        save(SSubtypesP,'Se','Si','SeDef','SeLike','SiDef','SiLike')
    end
end
clear Se Si SeDef SeLike SiDef SiLike




function Sn = StoSDown(S)

if length(S)==0
    Sn = S;
    return
end

S = cellArray(S);
for a = 1:length(S);
    t = TimePoints(S{a})/10000;
    Sn{a} = tsd(t,t);
end
Sn = tsdArray(Sn);
