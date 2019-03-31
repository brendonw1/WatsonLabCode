function  StateCompressedSpikes = MakeStateCompressedSpikesSet(basename)
% Compresses spike TSDs to ONLY those in the various state intervals... no
% gaps in between.  So things like Rate can be measured accurately using
% TSToolbox.f

fname = [basename '_StateCompressedSpikes.mat'];
if exist(fname,'file')
    t = load(fname);
    StateCompressedSpikes = t.StateCompressedSpikes;
else
    t = load([basename,'_Intervals.mat']);
    intervals = t.intervals;

    t = load(fullfile('Spindles','SpindleData.mat'),'SpindleData');
    normspindles = t.SpindleData.normspindles;
    sp_starts = 10000*normspindles(:,1);
%     sp_peaks = 10000*normspindles(:,2);
    sp_stops = 10000*normspindles(:,3);
    sp_ints = intervalSet(sp_starts,sp_stops);

    t = load([basename,'_SStable.mat']);
    S = t.S;
    shank = t.shank;
    cellIx = t.cellIx;        

    t = load([basename '_SSubtypes.mat']);
    Se = t.Se;
    Si = t.Si;
    Sed = t.SeDef;
    Sid = t.SiDef;
   
    t = load([basename '_CellIDs.mat']);
    CellIDs = t.CellIDs;
    
    disp(['Starting Wake ' basename])
    S_inWake =  CompressSpikeTrainsToIntervals(S,intervals{1});
    Se_inWake =  CompressSpikeTrainsToIntervals(Se,intervals{1});
    Si_inWake =  CompressSpikeTrainsToIntervals(Si,intervals{1});
    Sed_inWake =  CompressSpikeTrainsToIntervals(Sed,intervals{1});
    Sid_inWake =  CompressSpikeTrainsToIntervals(Sid,intervals{1});

    disp(['Starting SWS ' basename])
    S_inSWS =  CompressSpikeTrainsToIntervals(S,intervals{3});
    Se_inSWS =  CompressSpikeTrainsToIntervals(Se,intervals{3});
    Si_inSWS =  CompressSpikeTrainsToIntervals(Si,intervals{3});
    Sed_inSWS =  CompressSpikeTrainsToIntervals(Sed,intervals{3});
    Sid_inSWS =  CompressSpikeTrainsToIntervals(Sid,intervals{3});

    disp(['Starting REM ' basename])
    S_inREM =  CompressSpikeTrainsToIntervals(S,intervals{5});
    Se_inREM =  CompressSpikeTrainsToIntervals(Se,intervals{5});
    Si_inREM =  CompressSpikeTrainsToIntervals(Si,intervals{5});
    Sed_inREM =  CompressSpikeTrainsToIntervals(Sed,intervals{5});
    Sid_inREM =  CompressSpikeTrainsToIntervals(Sid,intervals{5});

    disp(['Starting Spindles ' basename])
    S_inSpindles =  CompressSpikeTrainsToIntervals(S,sp_ints);
    Se_inSpindles =  CompressSpikeTrainsToIntervals(Se,sp_ints);
    Si_inSpindles =  CompressSpikeTrainsToIntervals(Si,sp_ints);
    Sed_inSpindles =  CompressSpikeTrainsToIntervals(Sed,sp_ints);
    Sid_inSpindles =  CompressSpikeTrainsToIntervals(Sid,sp_ints);

    disp(['Starting UPs ' basename])
    UPs = load([basename,'_UPDOWNIntervals.mat']);
    S_inUPs =  CompressSpikeTrainsToIntervals(S,UPs.UPInts);
    Se_inUPs =  CompressSpikeTrainsToIntervals(Se,UPs.UPInts);
    Si_inUPs =  CompressSpikeTrainsToIntervals(Si,UPs.UPInts);
    Sed_inUPs =  CompressSpikeTrainsToIntervals(Sed,UPs.UPInts);
    Sid_inUPs =  CompressSpikeTrainsToIntervals(Sid,UPs.UPInts);

    StateCompressedSpikes = v2struct(...
        S_inWake, Se_inWake, Si_inWake, Sed_inWake, Sid_inWake,...
        S_inSWS, Se_inSWS, Si_inSWS, Sed_inSWS, Sid_inSWS,...
        S_inREM, Se_inREM, Si_inREM, Sed_inREM, Sid_inREM,...
        S_inSpindles, Se_inSpindles, Si_inSpindles, Sed_inSpindles, Sid_inSpindles,...
        S_inUPs, Se_inUPs, Si_inUPs, Sed_inUPs, Sid_inUPs,...
        cellIx, shank, CellIDs);
    save(fname,'StateCompressedSpikes')
end
