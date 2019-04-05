function MasterCopyPMSKKToBorderline_NoFromIsis(ratname,recordingname,destdrive)

if ~strcmp(destdrive(1),'/')
    destdrive = ['/',destdrive];
end

if iscell(recordingname);
    for a = 1:length(recordingname);
        trecordingname = recordingname{a};
%         CopyPMSandKKOutputToBorderline(ratname,trecordingname,isisdrive,destdrive)
        MoveResFetSpkCluEegLfpToRecordingBaseDir(ratname,trecordingname,destdrive)
        CopyClusToOriginalClusDir(ratname,trecordingname,destdrive)
        MoveMetaIniTspMpgToRecordingBaseDir(ratname,trecordingname,destdrive)
        MoveUnmergedDataToUnMergedDataDir(ratname,trecordingname,destdrive)
    end
else
%     CopyPMSandKKOutputToBorderline(ratname,recordingname,isisdrive,destdrive)
    MoveResFetSpkCluEegLfpToRecordingBaseDir(ratname,recordingname,destdrive)
    CopyClusToOriginalClusDir(ratname,recordingname,destdrive)
    MoveMetaIniTspMpgToRecordingBaseDir(ratname,recordingname,destdrive)
    MoveUnmergedDataToUnMergedDataDir(ratname,recordingname,destdrive)
end