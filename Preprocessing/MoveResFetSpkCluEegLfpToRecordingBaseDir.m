function MoveResFetSpkCluEegLfpToRecordingBaseDir(ratname,recordingname,destdrive)
disp('MoveResFetSpkCluEegLfpToRecordingBaseDir');
% ratname = 'Dino';
% recordingname = 'Dino_062514';
% destdrive = '/mnt/brendon6/';

wildcardcpstring = fullfile(destdrive,ratname,recordingname,recordingname,'*.{res,fet,spk,clu,eeg,lfp,xml}*');
destdir = fullfile(destdrive,ratname,recordingname);
eval(['!mv -v ' wildcardcpstring ' ' destdir])