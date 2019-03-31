function stateInts = SleepPETHs_getstateInts(statenames,SWSPacketInts,SWSEpisodeInts,SleepInts,REMEpisodeInts,WakeInts)
% statenames = {'SWSPackets','SWSEpisodes','Sleep','SWSSleep','REM','REMThenSWS','REMThenWake','Wake'};

stateInts = {};

for a = 1:length(statenames);
    switch statenames{a}
        case 'SWSPackets'
            stateInts{end+1} = StartEnd(SWSPacketInts,'s');%packets
        case 'SWSEpisodes'
            stateInts{end+1} = StartEnd(SWSEpisodeInts,'s');%sws episodes
        case 'Sleep'
            stateInts{end+1} = StartEnd(SleepInts,'s');%sleep
        case 'SWSSleep'
            stateInts{end+1} = StartEnd(SleepInts,'s');%sleep
        case 'REM'
            stateInts{end+1} = StartEnd(REMEpisodeInts,'s');%rem
        case 'REMThenSWS'
            ints = StartEnd(REMEpisodeInts,'s');
            sints = StartEnd(SWSPacketInts,'s');
            evergood = zeros(size(ints,1),1);
            for b = 1:size(ints,1);
                d = sints(:,1)-ints(b,2);
                g = d<10 & d>0;%if packet within 10 secs of end of REM
                evergood(b) = logical(sum(g));
            end
            stateInts{end+1} = ints(logical(evergood),:);%rem followed by SWS
        case 'REMThenWake'
            ints = StartEnd(REMEpisodeInts,'s');
            sints = StartEnd(WakeInts,'s');
            evergood = zeros(size(ints,1),1);
            for b = 1:size(ints,1);
                d = sints(:,1)-ints(b,2);
                g = d<10 & d>0;%if packet within 10 secs of end of REM
                evergood(b) = logical(sum(g));
            end
            stateInts{end+1} = ints(logical(evergood),:);%rem followed by wake
        case 'Wake'
            stateInts{end+1} = StartEnd(WakeInts,'s');
        case 'MA'
            MAMaxDur = 40;
            %get some intervals
            IPIs = minus(SleepInts,SWSPacketInts);
            REM = intersect(REMEpisodeInts,IPIs);
            AnyWakish = minus(IPIs,REM);
            MA = dropLongIntervals(AnyWakish,MAMaxDur*10000);
            %find MAs within 2sec of REM, get rid of them
            mass = StartEnd(MA,'s');
            mass(:,1) = mass(:,1)-2;
            mass(:,2) = mass(:,2)+2;
            bad = InIntervalsBW(mass(:,1),StartEnd(REM,'s')) + InIntervalsBW(mass(:,2),StartEnd(REM,'s'));
            maidxs = 1:length(length(MA));
            MA = subset(MA,maidxs(~bad));
            stateInts{end+1} = StartEnd(MA,'s');
            
%% Transitional states, defined as the transition between pairs of states
        case 'SWStoREM'
            rints = StartEnd(REMEpisodeInts,'s');
            sints = StartEnd(SWSPacketInts,'s');
            evergood = zeros(size(rints,1),1);
            for b = 1:size(sints,1);
                d = rints(:,1)-sints(b,2);
                g = d<=2 & d>=0;%if REM within 1 sec of end of packet
                evergood(b) = logical(sum(g));
            end
            iints = sints(logical(evergood),:);
            iints = [iints(:,2)-19 iints(:,2)+21];
            stateInts{end+1} = iints;%rem followed by SWS
        case 'SWStoMA'
            % Get MA
            MAMaxDur = 40;
            %get some intervals
            IPIs = minus(SleepInts,SWSPacketInts);
            REM = intersect(REMEpisodeInts,IPIs);
            AnyWakish = minus(IPIs,REM);
            MA = dropLongIntervals(AnyWakish,MAMaxDur*10000);
            %find MAs within 2sec of REM, get rid of them
            mass = StartEnd(MA,'s');
            mass(:,1) = mass(:,1)-2;
            mass(:,2) = mass(:,2)+2;
            bad = InIntervalsBW(mass(:,1),StartEnd(REM,'s')) + InIntervalsBW(mass(:,2),StartEnd(REM,'s'));
            maidxs = 1:length(length(MA));
            MA = subset(MA,maidxs(~bad));
        
            mints = StartEnd(MA,'s');
            sints = StartEnd(SWSPacketInts,'s');
            evergood = zeros(size(mints,1),1);
            for b = 1:size(sints,1);
                d = mints(:,1)-sints(b,2);
                g = d<=2 & d>=0;%if REM within 1 sec of end of packet
                evergood(b) = logical(sum(g));
            end
            iints = sints(logical(evergood),:);
            iints = [iints(:,2)-19 iints(:,2)+21];
            stateInts{end+1} = iints;%rem followed by SWS
    end
end

1;

