function CopySleepDataToGamma(fileextension)

if strcmp(fileextension(end-3:end),'.mat')
    fileextension = strcat(fileextension,'.mat');s
end

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    %% Execute
    copyfile(fullfile(basepath,[basename,fileextension]),fullfile('proraid','GammaDataset',basename,[basename fileextension]))
   
end