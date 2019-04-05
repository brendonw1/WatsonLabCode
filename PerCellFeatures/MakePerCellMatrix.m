function [PCM,labels] = MakePerCellMatrix

[names,dirs] = GetDefaultDataset;
PCM = [];
labels = {};

%%
% - Animal
% - Anatomical region
% - Cortical Layer
% - Session number


%% Waveform class 
%% Consider: % - Burst index, Burst/Shoulder, ACG other indices

%formulaic setup
tmtx = [];
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
% get data
    t = load(fullfile(basepath,[basename '_CellIDs.mat']));
    CellIDs = t.CellIDs;
    t = load(fullfile(basepath,[basename '_CellClassificationOutput.mat']));
% prepare
    numcells = size(t.CellClassificationOutput.CellClassOutput,1);
% put in matrix, going down dimension 1
    tm = zeros(numcells,3);
    tm(CellIDs.EAll,1) = 1;
    tm(CellIDs.EDefinite,1) = 2;
    tm(CellIDs.IAll,1) = -1;
    tm(CellIDs.IDefinite,1) = -2;
    tm(:,2) = t.CellClassificationOutput.CellClassOutput(:,2);
    tm(:,3) = t.CellClassificationOutput.CellClassOutput(:,3);
% cat to this temp matrix along dim 1
    tmtx = cat(1,tmtx,tm);
end
% cat along dim 2 to full matrix
PCM = cat(2,PCM,tmtx);
labels{end+1} = 'EIStatus';
labels{end+1} = 'Peak-TroughMs';
labels{end+1} = 'SpikeWidthMs';


%% State-wise spike rates
StateRates = SpikingAnalysis_GatherAllStateRates;
PCM = cat(2,PCM,StateRates.AllAllRates);
PCM = cat(2,PCM,StateRates.AllWakeRates);
PCM = cat(2,PCM,StateRates.AllMWakeRates);
PCM = cat(2,PCM,StateRates.AllNMWakeRates);
PCM = cat(2,PCM,StateRates.AllSWSRates);
PCM = cat(2,PCM,StateRates.AllREMRates);
PCM = cat(2,PCM,StateRates.AllUPRates);
PCM = cat(2,PCM,StateRates.AllSpindleRates);
labels{end+1} = 'AllSpikeRate';
labels{end+1} = 'WakeSpikeRate';
labels{end+1} = 'MovingWakeSpikeRate';
labels{end+1} = 'NMovingWakeSpikeRate';
labels{end+1} = 'SWSSpikeRate';
labels{end+1} = 'REMSpikeRate';
labels{end+1} = 'REMUPStateSpikeRate';
labels{end+1} = 'REMSpindleSpikeRate';

%% State Rate Ratios, consider INT-SWS ratio
PCM = cat(2,PCM,StateRates.AllSWSRates./StateRates.AllWakeRates);
PCM = cat(2,PCM,StateRates.AllREMRates./StateRates.AllWakeRates);
PCM = cat(2,PCM,StateRates.AllREMRates./StateRates.AllSWSRates);
PCM = cat(2,PCM,StateRates.AllMWakeRates./StateRates.AllNMWakeRates);
PCM = cat(2,PCM,StateRates.AllUPRates./StateRates.AllWakeRates);
PCM = cat(2,PCM,StateRates.AllSpindleRates./StateRates.AllWakeRates);
PCM = cat(2,PCM,StateRates.AllSpindleRates./StateRates.AllUPRates);
labels{end+1} = 'SWS/WakeRatio';
labels{end+1} = 'REM/WakeRatio';
labels{end+1} = 'REM/SWSRatio';
labels{end+1} = 'Mvmnt/NonMvmntRatio';
labels{end+1} = 'UP/WakeRatio';
labels{end+1} = 'Spindle/WakeRatio';
labels{end+1} = 'Spindle/UPRatio';



% Make a per-cell matrix
% - Sleep decreases
% - Chorister/Soloist
% - ? other modulations
% - Hubbiness/Centrality in graph
% - Average order in UP state
% - Average order in spindles
% - Spindle modulation
% - Spindle phase
% - gamma modulation
% - gamma phase