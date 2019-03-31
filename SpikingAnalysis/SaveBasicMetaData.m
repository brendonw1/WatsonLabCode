outvars = v2struct(basename,basepath,Par,goodshanks,voltsperunit);

if exist('tbasepath','var')
    outvars.tbasepath = tbasepath;
end
if exist('dropbasepathstr','var')
    outvars.dropbasepathstr = dropbasepathstr;
end
if exist('RecordingFileIntervals','var')
    outvars.RecordingFileIntervals = RecordingFileIntervals;
end
if exist('RecordingFilesForSleep','var')
    outvars.RecordingFilesForSleep = RecordingFilesForSleep;
end
if exist('BadInterval','var')
    outvars.BadInterval = BadInterval;
end
if exist('BadIntervali','var')
    outvars.BadIntervali = BadIntervali;
end
if exist('goodeegchannel','var')
    outvars.goodeegchannel = goodeegchannel;
end
if exist('UPstatechannel','var')
    outvars.UPstatechannel = UPstatechannel;
end
if exist('Spindlechannel','var')
    outvars.Spindlechannel = Spindlechannel;
end
if exist('Thetachannel','var')
    outvars.Thetachannel = Thetachannel;
end
if exist('Ripplechannel','var')
    outvars.Ripplechannel = Ripplechannel;
end
if exist('RippleNoiseChannel','var')
    outvars.RippleNoiseChannel = RippleNoiseChannel;
end
if exist('KetamineStartFile','var')
    outvars.KetamineStartFile = KetamineStartFile;
end
if exist('KetamineTimeStamp','var')
    outvars.KetamineTimeStamp = KetamineTimeStamp;
end
if exist('InjectionStartTime','var')
    outvars.InjectionStartTime = InjectionStartTime;
end
if exist('InjectionTimestamp','var')
    outvars.InjectionTimestamp = InjectionTimestamp;
end
if exist('InjectionType','var')
    outvars.InjectionType = InjectionType;
end
if exist('mastername','var')
    outvars.mastername = mastername;
end
if exist('masterpath','var')
    outvars.masterpath = masterpath;
end
if exist('manualGoodSleeep','var')
    outvars.manualGoodSleep = manualGoodSleeep;
end
if exist('sleepstart','var')
    outvars.sleepstart = sleepstart;
end
if exist('sleepstop','var')
    outvars.sleepstop = sleepstop;
end

if exist('Ripplechannel_hemisphere2','var')
    outvars.Ripplechannel_hemisphere2 = Ripplechannel_hemisphere2;
end
if exist('RippleNoiseChannel_hemisphere2','var')
    outvars.RippleNoiseChannel_hemisphere2 = RippleNoiseChannel_hemisphere2;
end

if exist('tbasepath','var')
    save(fullfile(tbasepath,[basename '_BasicMetaData.mat']),'-struct','outvars')
    disp(['Saved ' fullfile(tbasepath,[basename '_BasicMetaData.mat'])])
else
    save(fullfile(basepath,[basename '_BasicMetaData.mat']),'-struct','outvars')
    disp(['Saved ' fullfile(basepath,[basename '_BasicMetaData.mat'])])
end
% save([basename '_BasicMetaData.mat']);
% load([basename '_BasicMetaData.mat']);