function CopyClusToOriginalClusDir(ratname,recordingname,destdrive)

disp('CopyClusToOriginalClusDir');
% ratname = 'Dino';
% destdrive = '/mnt/brendon6/';

OriginalClusDirPath = fullfile(destdrive,ratname,'OriginalClus',recordingname);
if ~exist(OriginalClusDirPath,'dir')
    mkdir (OriginalClusDirPath)
end
OriginalClusRecordingPath = fullfile(OriginalClusDirPath);

wildcardcpstring = fullfile(destdrive,ratname,recordingname,'*.clu*');
eval(['!sudo chmod 777 ' wildcardcpstring ';'])
eval(['!cp -av ' wildcardcpstring ' ' OriginalClusRecordingPath])