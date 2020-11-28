LabJackData = PhoReadIn;
HumanCheckData = XXX;
CombinedData = merge(LabJackData,HumanCheckData);

[RoomEntryIns,RoomEntryOuts] = ReadBoxRoomEntry;

CombinedData = ExcludeTimeEpochsFromTimeTable(CombinedData,RoomEntryIns,RoomEntryOuts);

IntegrateCSV of sucrose etc


PLOT
specofy time duration
specify bin size