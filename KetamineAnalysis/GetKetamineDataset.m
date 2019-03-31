function [names,dirs]=GetKetamineDataset(varargin)
%just enter any of the variable names below to get a dataset restricted to
%criteria where the variable with that name is set to 1
ketamine = 0;
saline = 0;
mk801 = 0;

if exist('varargin','var')
    for a = 1:length(varargin);
        if exist(varargin{a},'var')
            eval([varargin{a} '= 1;']);
        else
            error([varargin{a} ' is an Invalid entry'])
        end
    end
end

[names,dirs] = GetDatasetNameDirsFromKetamineSessionMatrix(ketamine,saline,mk801);


for a = 1:length(names)
    basename = names{a};
    basepath = dirs{a};
    if ~exist(basepath,'dir')
        dirs{a} = fullfile(getdropbox,'Data','KetamineDataset',basename);
    end
end

1;