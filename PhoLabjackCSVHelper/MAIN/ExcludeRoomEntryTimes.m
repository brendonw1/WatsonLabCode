function Data = ExcludeRoomEntryTimes(Data,RoomEntryIns,RoomEntryOuts)


fns = fieldnames(Data.DeltaTimestamps);

for a = 1:length(fns)
    tfn = fns{a};
    eval(['[Data.DeltaTimestamps.' tfn ',badidxs] = ExcludeTimeEpochsFromTimeTable(Data.DeltaTimestamps.' tfn ',RoomEntryIns,RoomEntryOuts);'])
%              !! need idxs of excluded times and apply those to events
%     SumBads = sum(double(badidxs))
    eval(['Data.DeltaIdxs.' tfn '(badidxs) = [];'])
end