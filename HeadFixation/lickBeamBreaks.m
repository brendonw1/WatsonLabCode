function lickBeamBreaks(...
    trialLength,preStimPeriod,stimDuration,punishmPeriod)

% Extracts and organizes beam break (lick) responses from the head-fixed
% mouse across trials. Data must be from the Bpod "RawEvents" structure.
% Outputs are cell arrays ready for raster plotting (X and Y vectors can
% be obtained with cell2mat).
%
%
%
% INPUTS __________________________________________________________________
% A single value for each of the four inputs (self-explanatory names)
%
%
%
% LSBuenoJr _______________________________________________________________



%% Loads beam break timestamps and trial IDs
temp     = load('Bpod.mat');
temp     = temp.SessionData.RawEvents;
rawLicks = cell(length(temp.Trial),1);
trialIDs = cell(length(temp.Trial),1);
for ii   = 1:length(rawLicks)
    if isfield(temp.Trial{ii}.Events,'Port1In')
        rawLicks{ii} = temp.Trial{ii}.Events.Port1In;
    else
        rawLicks{ii} = [];
    end
    tempFieldNames   = fieldnames(temp.Trial{ii}.States);
    trialIDs{ii}     = tempFieldNames{2};
end


%% Prepares cell arrays and saves the *.mat
rasterY = cell(size(rawLicks));
rasterX = cell(size(rawLicks));
for ii  = 1:length(rasterY)
    if isempty(rawLicks{ii})
        rasterY{ii}  = ii;
        rasterX{ii}  = NaN;
    else
        rasterY{ii}  = repmat(ii,1,length(rawLicks{ii}))';
        rasterX{ii}  = rawLicks{ii}';
    end
end
trialStamps          = [rasterY rasterX trialIDs];
params.trialLength   = trialLength;
params.preStimPeriod = preStimPeriod;
params.stimDuration  = stimDuration;
params.punishmPeriod = punishmPeriod;

save('allLicks.mat','trialStamps','params');

% plot(tmStamps,trialIDs,'.','color','k','markersize',5);xlim([0 6])
% set(gca,'YDir','reverse')

end
