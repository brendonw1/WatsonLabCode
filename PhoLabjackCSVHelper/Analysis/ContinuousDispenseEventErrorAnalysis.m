%% Test for continuous dispense events without interleaved beambreaks.


% For each dispense event, there should be one or more preceeding beambreaks.


% Before any dispense event, there should be one or more beambreaks since the last dispense event.
OutputDeltasTimestampsAggregate.Food2 =  

previousDispenseEventTimestamp = OutputDeltasTimestamps.Food2_Dispense(1);
for i=2:length(OutputDeltasTimestamps.Food2_Dispense)
    currTimestamp = OutputDeltasTimestamps.Food2_Dispense(i);
    
    
    OutputDeltasTimestamps.Food2_BeamBreak(i);
    
end

% Between any two dispense events