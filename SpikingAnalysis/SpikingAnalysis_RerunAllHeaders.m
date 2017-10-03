function SpikingAnalysis_RerunAllHeaders
% if changing header format, don't forget to change SaveBasicMetaData.m

wsw = 0;
synapses = 0;
spindles = 0;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    
    cd(basepath)
    
    if exist([basename '_BasicMetaData.mat'],'file')
        if ~exist([basename '_BasicMetaData_OLD_' date '.mat'],'file')
           movefile([basename '_BasicMetaData.mat'],[basename '_BasicMetaData_OLD_' date '.mat'])
        end
    end
    
    % cd basepath
    run(fullfile(basepath,[basename '_Header.m']))
end