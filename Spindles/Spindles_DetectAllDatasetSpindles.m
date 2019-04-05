function Spindles_DetectAllDatasetSpindles
warning off
[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    %% Review/Create Header
    cd (basepath)

    bmd = load([basename '_BasicMetaData.mat']);
    %% Setup for Detection and Detection
    % Detect

    SpindleDetectWrapper(bmd.Par.nChannels, bmd.Spindlechannel, bmd.voltsperunit);%use default thresholds

    close all
end