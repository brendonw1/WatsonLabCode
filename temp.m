function temp(basepath)
basename = bz_BasenameFromBasepath(basepath);

numShuffs = 200;

load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledGeneralMatrices.mat']))
load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledCorrs.mat']))
load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledRs.mat']))

BandPowerVsSingleUnitSpikeRateData_ShuffledGeneralMatrices.numShuffs =numShuffs;
BandPowerVsSingleUnitSpikeRateData_ShuffledCorrs.numShuffs =numShuffs;
BandPowerVsSingleUnitSpikeRateData_ShuffledRs.numShuffs =numShuffs;
save(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledGeneralMatrices']),'BandPowerVsSingleUnitSpikeRateData_ShuffledGeneralMatrices','-v7.3')
save(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledCorrs']),'BandPowerVsSingleUnitSpikeRateData_ShuffledCorrs','-v7.3')
save(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData_ShuffledRs']),'BandPowerVsSingleUnitSpikeRateData_ShuffledRs','-v7.3')

