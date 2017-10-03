function ConvertTSObjectsTo1PerSec(obasepath,obasename)

if ~exist('obasepath','var')
    [~,obasename] = fileparts(cd);
    obasepath = cd;
end

%% GoodSleepInterval will guide all else
if exist(fullfile(obasepath,[obasename, '_GoodSleepInterval.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_GoodSleepInterval.mat']))
        t.timePairFormat = StartEnd(GoodSleepInterval,'s')/10000;
        GoodSleepInterval = intervalSet(t.timePairFormat(:,1),t.timePairFormat(:,2));
        save(fullfile(obasepath,[obasename, '_GoodSleepInterval.mat']),'GoodSleepInterval')
        clear GoodSleepInterval t
    catch
        disp([obasename ': _GoodSleepInterval didn''t work'])
    end
else
    disp([obasename ': No _GoodSleepInterval found'])
end

%% Basic metadata
if exist(fullfile(obasepath,[obasename, '_BasicMetaData.mat']),'file')
    try
        load(fullfile(obasepath,[obasename '_BasicMetaData.mat']));
        if exist('masterpath','var');
            s = strfind(masterpath,'/');
            masterpath = strcat(masterpath(1:s(2)),'brendon7',masterpath(s(3):end));
        end
        basepath = obasepath;
        basename = obasename;
        t = StartEnd(RecordingFileIntervals,'s')/10000;
        RecordingFileIntervals = intervalSet(t(:,1),t(:,2));
        SaveBasicMetaData
        clear masterpath
    catch
        disp([obasename ': _BasicMetaData didn''t work'])
    end
else
    disp([obasename ': No _BasicMetaData found'])
end

%% .mats that need conversion
%AssemblyBasicData
if exist(fullfile(obasepath,[obasename, '_AssemblyBasicData.mat']),'file')
    try
        load(fullfile(obasepath,[obasename '_AssemblyBasicData.mat']));
        t = Range(AssemblyBasicData.SBinned,'s')/10000;
        d = Data(AssemblyBasicData.SBinned);
        AssemblyBasicData.SBinned = tsd(t,d);
        save(fullfile(obasepath,[obasename '_AssemblyBasicData.mat']),'AssemblyBasicData');
        clear t d
    catch
        disp([obasename ': _AssemblyBasicData didn''t work'])
    end
else
    disp([obasename ': No _AssemblyBasicData found'])
end

%ClusterQualityMeasures 
if exist('masterpath','var');
    tpath = masterpath;
    tname = mastername;
else
    tpath = obasepath;
    tname = obasename;
end

if exist(fullfile(tpath,[tname, '_ClusterQualityMeasures.mat']),'file')
    try
        load(fullfile(tpath,[tname '_ClusterQualityMeasures.mat']));
        for a = 1:length(ClusterQualityMeasures.SelfMahalDistances);
            ttimes = Range(ClusterQualityMeasures.SelfMahalDistances{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        ClusterQualityMeasures.SpikeEnergies = tsdArray(t);
        for a = 1:length(ClusterQualityMeasures.SpikeEnergies);
            ttimes = Range(ClusterQualityMeasures.SpikeEnergies{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        ClusterQualityMeasures.SpikeEnergies = tsdArray(t);
        save(fullfile(tpath,[tname '_ClusterQualityMeasures.mat']),'ClusterQualityMeasures');
        clear t ttimes
    catch
        disp([obasename ': _ClusterQualityMeasures didn''t work'])
    end
else
    disp([obasename ': No _ClusterQualityMeasures found'])
end
clear tpath tname


%SAll
if exist(fullfile(obasepath,[obasename, '_SAll.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_SAll.mat']))
        for a = 1:length(S);
            ttimes = Range(S{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        S = tsdArray(t);
        save(fullfile(obasepath,[obasename '_SAll.mat']),'S','shank','cellIx');
        clear S t shank cellIx ttimes
    catch
        disp([obasename ': _SAll didn''t work'])
    end
else
    disp([obasename ': No _SAll found'])
end

%SBurstFiltered
if exist(fullfile(obasepath,[obasename, '_SBurstFiltered.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_SBurstFiltered.mat']))
        for a = 1:length(Sbf);
            ttimes = Range(Sbf{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        Sbf = tsdArray(t);
        save(fullfile(obasepath,[obasename '_SBurstFiltered.mat']),'Sbf');
        clear Sbf t ttimes
    catch
        disp([obasename ': _SBurstFiltered didn''t work'])
    end        
else
    disp([obasename ': No _SBurstFiltered found'])
end

%SStable
if exist(fullfile(obasepath,[obasename, '_SStable.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_SStable.mat']))
        for a = 1:length(S);
            ttimes = Range(S{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        S = tsdArray(t);
        if ~exist('badcells','var');
            badcells = [];
        end
        if ~exist('numgoodcells','var');
            numgoodcells = length(S);
        end
        save(fullfile(obasepath,[obasename '_SStable.mat']),'S','shank','cellIx','badcells','numgoodcells');
        clear S t shank cellIx badcells numgoodcells ttimes
    catch
        disp([obasename ': _SStable didn''t work'])
    end
else
    disp([obasename ': No _SStable found'])
end

%SSubtypes
if exist(fullfile(obasepath,[obasename, '_SSubtypes.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_SSubtypes.mat']))
            % Se
        for a = 1:length(Se);
            ttimes = Range(Se{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            Se = tsdArray(t);
        end
        clear t ttimes
        % SeDef
        for a = 1:length(SeDef);
            ttimes = Range(SeDef{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            SeDef = tsdArray(t);
        end
        clear t ttimes
        % SeLike
        for a = 1:length(SeLike);
            ttimes = Range(SeLike{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            SeLike = tsdArray(t);
        end
        clear t ttimes
        % Si
        for a = 1:length(Si);
            ttimes = Range(Si{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            Si = tsdArray(t);
        end
        clear t ttimes
        % SiDef
        for a = 1:length(SiDef);
            ttimes = Range(SiDef{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            SiDef = tsdArray(t);
        end
        clear t ttimes
        % SiLike
        for a = 1:length(SiLike);
            ttimes = Range(SiLike{a})/10000;%correct for new version of toolbox
            t{a} = tsd(ttimes,ttimes);
        end
        if exist('t','var')
            SiLike = tsdArray(t);
        end
        clear t ttimes

        save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'Se');
        try
            save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'SeDef','-append')
        end
        try
            save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'SeLike','-append')
        end
        try 
            save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'Si','-append')
        end
        try
            save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'SiDef','-append')
        end
        try
            save(fullfile(obasepath,[obasename '_SSubtypes.mat']),'SiLike','-append')
        end
        clear S t Se Si SeDef SiDef SeLike SiLike SeRates SiRates
    catch
        disp([obasename ': _SSubtypes didn''t work'])
    end        
else
    disp([obasename ': No _SSubtypes found'])
end

%UP/DOWN states - these are already restricted
if exist(fullfile(obasepath,[obasename, '_UPDOWNIntervals.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_UPDOWNIntervals.mat']))
        UPIntsTimePairFormat = StartEnd(UPInts)/10000;
        UPInts = intervalSet(UPIntsTimePairFormat(:,1),UPIntsTimePairFormat(:,2));
        DNIntsTimePairFormat = StartEnd(DNInts)/10000;
        DNInts = intervalSet(DNIntsTimePairFormat(:,1),DNIntsTimePairFormat(:,2));
        ONIntsTimePairFormat = StartEnd(ONInts)/10000;
        ONInts = intervalSet(ONIntsTimePairFormat(:,1),ONIntsTimePairFormat(:,2));
        OFFIntsTimePairFormat = StartEnd(OFFInts)/10000;
        OFFInts = intervalSet(OFFIntsTimePairFormat(:,1),OFFIntsTimePairFormat(:,2));
        GammaIntsTimePairFormat = StartEnd(GammaInts)/10000;
        GammaInts = intervalSet(GammaIntsTimePairFormat(:,1),GammaIntsTimePairFormat(:,2));
        save(fullfile(obasepath,[obasename '_UPDOWNIntervals.mat']),...
            'UPInts','DNInts', 'ONInts','OFFInts','GammaInts','UPchannel');
        clear UPInts DNInts ONInts OFFInts GammaInts UPchannel
    catch
        disp([obasename ': _UPDOWNIntervals didn''t work'])
    end
else
    disp([obasename ': No _UPDOWNIntervals found'])
end

% WSRestrictedIntervals
if exist(fullfile(obasepath,[obasename, '_WSRestrictedIntervals.mat']),'file')
    try
        load(fullfile(obasepath,[obasename, '_WSRestrictedIntervals.mat']))
        REMEpisodeTimePairFormat = StartEnd(REMEpisodeInts,'s')/10000;
        REMEpisodeInts = intervalSet(REMEpisodeTimePairFormat(:,1),REMEpisodeTimePairFormat(:,2));
        REMTimePairFormat = StartEnd(REMInts,'s')/10000;
        REMInts = intervalSet(REMTimePairFormat(:,1),REMTimePairFormat(:,2));
        SWSEpisodeTimePairFormat = StartEnd(SWSEpisodeInts,'s')/10000;
        SWSEpisodeInts = intervalSet(SWSEpisodeTimePairFormat(:,1),SWSEpisodeTimePairFormat(:,2));
        SWSPacketTimePairFormat = StartEnd(SWSPacketInts,'s')/10000;
        SWSPacketInts = intervalSet(SWSPacketTimePairFormat(:,1),SWSPacketTimePairFormat(:,2));
        MATimePairFormat = StartEnd(MAInts,'s')/10000;
        MAInts = intervalSet(MATimePairFormat(:,1),MATimePairFormat(:,2));
        WakeInterruptionTimePairFormat = StartEnd(WakeInterruptionInts,'s')/10000;
        WakeInterruptionInts = intervalSet(WakeInterruptionTimePairFormat(:,1),WakeInterruptionTimePairFormat(:,2));
        WakeTimePairFormat = StartEnd(WakeInts,'s')/10000;
        WakeInts = intervalSet(WakeTimePairFormat(:,1),WakeTimePairFormat(:,2));
        SleepTimePairFormat = StartEnd(SleepInts,'s')/10000;
        SleepInts = intervalSet(SleepTimePairFormat(:,1),SleepTimePairFormat(:,2));
        for a = 1:length(WakeSleep);
            WakeSleepTimePairFormat{a} = StartEnd(WakeSleep{a},'s')/10000;
            WakeSleep{a} = intervalSet(WakeSleepTimePairFormat{a}(:,1),WakeSleepTimePairFormat{a}(:,2));
        end
        save(fullfile(obasepath,[obasename '_WSRestrictedIntervals.mat']),...
            'REMEpisodeInts','REMInts','SWSEpisodeInts','SWSPacketInts',...
            'MAInts','WakeInterruptionInts','WakeInts','SleepInts','WakeSleep');
        clear REMEpisodeInts REMInts SWSEpisodeInts SWSPacketInts MAInts ...
            WakeInterruptionInts WakeInts SleepInts WakeSleep
    catch
        disp([obasename ': _WSRestrictedIntervals didn''t work'])
    end
else
    disp([obasename ': No _WSRestrictedIntervals found'])
end




% 
% % EMGCorr
% load(fullfile(basepath,[basename, '_EMGCorr.mat']))
% i = EMGCorr(:,1)<=gend;
% EMGCorr = EMGCorr(i,:);
% save(['/mnt/brendon4/ForCRCNS/' basename '/' basename '_EMGCorr.mat'],'EMGCorr')
% clear EMGCorr i
% 
% % Motion
% load(fullfile(basepath,[basename, '_Motion.mat']))
% i = 1:length(motiondata.motion);
% i = i<=gend;
% motiondata.motion = motiondata.motion(i);
% motiondata.thresholdedsecs = motiondata.thresholdedsecs(i);
% save(['/mnt/brendon4/ForCRCNS/' basename '/' basename '_Motion.mat'],'motiondata')
% clear motiondata
% 
% %% Detected Events
% 
% %Spindles - already restricted
% eval(['! cp ' fullfile(basepath,[basename '_SpindleData.mat']) ' /mnt/brendon4/ForCRCNS/' basename '/' [basename, '_Spindles.mat']])
% 
% 
%% other .mats
% eval(['! cp ' fullfile(basepath,[basename '_CellClassificationOutput.mat']) ' /mnt/brendon4/ForCRCNS/' basename '/'])
% eval(['! cp ' fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']) ' /mnt/brendon4/ForCRCNS/' basename '/'])



%    