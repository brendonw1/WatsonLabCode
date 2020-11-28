function KetamineDrivesToChemo(DestDrive)
%copies specific files from ketamine basepaths to corresponding paths in
%data1/Data/KetamineDataset
% Mingxin Ding 02/2017

if strcmp(DestDrive,'data1')
    folderpath = fullfile('/data1','KetamineDataset');
elseif strcmp(DestDrive,'data2')
    folderpath = fullfile('/data2','KetamineDataset2');
else
    error('No such drive.');
end

[KeNames,KeDirs]=GetKetamineDataset;

DestNames = {};
DestDirs = {};
for a = 1:length(KeDirs)
    DestNames{a} = KeNames{a};
    IDNames{a} = strtok(KeNames{a},'_');
    %         [~,IDNames{a}] = fileparts(fileparts(KeDirs{a}));
    %         DestDirs{a} = fullfile(folderpath,IDNames{a});
    %         if ~exist(DestDirs{a},'dir')
    %             mkdir(DestDirs{a});
    %         end
    DestDirs{a} = fullfile(folderpath,IDNames{a},KeNames{a});
    if ~exist(DestDirs{a},'dir')
        mkdir(DestDirs{a});
    end
    
end

% only c3po, Achilles and Cicero are copied to data1, otherwise copied to
% data2
for a = 1:length(DestNames)
    if strcmp(IDNames{a},'c3po') || strcmp(IDNames{a},'Achilles') || strcmp(IDNames{a},'Cicero')
        if strcmp(DestDrive,'data1')
            syncstr = ['!rsync -a --exclude ''*.dat'' ' KeDirs{a} '/ ' DestDirs{a}];
            disp(syncstr);
            eval(syncstr);
        end
    elseif strcmp(DestDrive,'data2')
        syncstr = ['!rsync -a --exclude ''*.dat'' ' KeDirs{a} '/ ' DestDirs{a}];
        disp(syncstr);
        eval(syncstr);
    end
    
end
end


