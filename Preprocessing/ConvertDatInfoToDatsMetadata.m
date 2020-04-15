function temp(basepath)

basename = bz_BasenameFromBasepath(basepath);

tfileIN = fullfile(basepath,[basename,'_DatInfo.mat']);
tfileOUT = fullfile(basepath,[basename,'_DatsMetadata.mat']);

load(tfileIN);
DatsMetadata = DatInfo;
DatsMetadata.Recordings = DatsMetadata.Files;
DatsMetadata = rmfield(DatsMetadata,'Files');
save(tfileOUT,'DatsMetadata');