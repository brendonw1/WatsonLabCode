%% Backup to balrog_zpool... which is backed up to NyuShare
% SyncSupradirDataFolders('/mnt/Amplipex4D/BW/Wedge','/balrog_zpool/Wedge');
% SyncSupradirDataFolders('/mnt/Amplipex4E/BW/Wedge','/balrog_zpool/Wedge');
% SyncSupradirDataFolders('/mnt/Amplipex4F/BW/Wedge','/balrog_zpool/Wedge');
% SyncSupradirDataFolders('/mnt/Amplipex7F/BW/Wedge','/balrog_zpool/Wedge');
% SyncSupradirDataFolders('/mnt/Amplipex7G/BW/Wedge','/balrog_zpool/Wedge');
% 
% SyncSupradirDataFolders('/mnt/Amplipex4D/BW/BWMouse3','/balrog_zpool/BWMouse3');
% SyncSupradirDataFolders('/mnt/Amplipex4E/BW/BWMouse3','/balrog_zpool/BWMouse3');
% SyncSupradirDataFolders('/mnt/Amplipex4F/BW/BWMouse3','/balrog_zpool/BWMouse3');
% SyncSupradirDataFolders('/mnt/Amplipex7F/BW/BWMouse3','/balrog_zpool/BWMouse3');
% SyncSupradirDataFolders('/mnt/Amplipex7G/BW/BWMouse3','/balrog_zpool/BWMouse3');

% SyncSupradirDataFolders('/mnt/Amplipex4D/BW/ACO1','/balrog_zpool/ACO1');
% SyncSupradirDataFolders('/mnt/Amplipex4E/BW/ACO1','/balrog_zpool/ACO1');
% SyncSupradirDataFolders('/mnt/Amplipex4F/BW/ACO1','/balrog_zpool/ACO1');
% SyncSupradirDataFolders('/mnt/Amplipex7F/BW/Mon','/balrog_zpool/Mon');
% SyncSupradirDataFolders('/mnt/Intan1E/BW/Mon','/balrog_zpool/Mon');
% SyncSupradirDataFolders('/mnt/Intan1F/BW/Mon','/balrog_zpool/Mon');
% SyncSupradirDataFolders('/mnt/Intan1G/BW/Mon','/balrog_zpool/Mon');
% SyncSupradirDataFolders('/mnt/Amplipex7G/BW/ACO1','/balrog_zpool/ACO1');
% SyncSupradirDataFolders('/mnt/CuspidD/BW/Mon','/balrog_zpool/Mon');
% SyncSupradirDataFolders('/mnt/Intan2E/BW/FSTGroup1','/balrog_zpool/FSTGroup1');
% eval(['!rsync -ra /mnt/Intan2E/BW/FSTGroup4/ /balrog_zpool/FSTGroup4'])
% eval(['!rsync -rav /mnt/Intan1F/BW/KetMouse1/ /balrog_zpool/KetMouse1'])

% SyncSupradirDataFolders('/mnt/Intan2E/BW/Ket1/ /balrog_zpool/Ket1');
% SyncSupradirDataFolders('/mnt/Intan2E/BW/DT8/ /balrog_zpool/DT8');
% SyncSupradirDataSubFolders('/mnt/Intan2E/BW/MLW1/','/balrog_zpool/MLW1');
% SyncSupradirDataSubFolders('/mnt/SpinningMouseE/BW/MLW1/','/balrog_zpool/MLW1');

%% Convert basler movie file names bc unix can't copy as is
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan1F/BW/M1M3KO1/')
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan1F/BW/M1M3WT2/')
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan1F/BW/M1M3KO3/')
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan2E/BW/M1M3WT1/')
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan2E/BW/M1M3KO2/')
ConvertBaslerAviNames_PerAnimalFolder('/mnt/Intan2E/BW/M1M3WT3/')

%% Copy data to backup directory
destpathscopied = {};
basenamescopied = {};

[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan1F/BW/M1M3KO1/', '/balrog_zpool/M1M3KO1');
[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan1F/BW/M1M3WT2/', '/balrog_zpool/M1M3WT2');
[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan1F/BW/M1M3KO3/', '/balrog_zpool/M1M3KO3');

[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan2E/BW/M1M3WT1/', '/balrog_zpool/M1M3WT1');
[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan2E/BW/M1M3KO2/', '/balrog_zpool/M1M3KO2');
[destpathscopied{end+1}, basenamescopied{end+1}] = SyncSupradirDataSubFolders('/mnt/Intan2E/BW/M1M3WT3/', '/balrog_zpool/M1M3WT3');

%% Run preprocessing
dpc = {};
bnc = {};
for ix = 1:length(destpathscopied)
    dpc = cat(1,dpc,destpathscopied{ix}');
    bnc = cat(1,bnc,basenamescopied{ix}');
end

for ix = 1:length(dpc);
    tbasepath = dpc{ix};
%     BWPreprocessing(tbasepath);
end



%% Make Dats and EEGs
% MakeConcatDats_SessionsInDirectory('/balrog_zpool/Mon');
% MakeLFPs_SessionsInDirectory('/balrog_zpool/Mon');



%% Backup to packmouse
% SyncSupradirDataFolders('/mnt/Amplipex4D/BW/BWMouse2','/mnt/packmouse/userdirs/brendon/yodaRaw');
% SyncSupradirDataFolders('/mnt/Amplipex4F/BW/BWMouse2','/mnt/packmouse/userdirs/brendon/yodaRaw');
% SyncSupradirDataFolders('/mnt/Amplipex7D/BW/BWMouse2','/mnt/packmouse/userdirs/brendon/yodaRaw');
% SyncSupradirDataFolders('/mnt/Amplipex7G/BW/BWMouse2','/mnt/packmouse/userdirs/brendon/yodaRaw');
% SyncSupradirDataFolders('/mnt/SurgeryE/BW/BWMouse2','/mnt/packmouse/userdirs/brendon/yodaRaw');

%% Backup to balrog_zpool... which is backed up to NyuShare
% SyncSupradirDataFolders('/mnt/Amplipex4D/BW/BWMouse2','/balrog_zpool/BWMouse2');
% SyncSupradirDataFolders('/mnt/Amplipex4F/BW/BWMouse2','/balrog_zpool/BWMouse2');
% SyncSupradirDataFolders('/mnt/Amplipex7D/BW/BWMouse2','/balrog_zpool/BWMouse2');
% SyncSupradirDataFolders('/mnt/Amplipex7G/BW/BWMouse2','/balrog_zpool/BWMouse2');
% SyncSupradirDataFolders('/mnt/SurgeryE/BW/BWMouse2','/balrog_zpool/BWMouse2');

%% 