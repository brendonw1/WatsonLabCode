function [HighPowerPhase,LowPowerPhase] = HighLowPowerPhases(phase,amp,stateint,samplingRate,zthreshold,freqlist)

StateIdx = logical(belong(stateint,(1:size(amp{1},1))/samplingRate));
for i = 1:length(phase)
    zs{i} = nan(size(amp{i}));
    HighPowerPhase{i} = nan(size(phase{i}));
    LowPowerPhase{i} = nan(size(phase{i}));
    for j =1:length(freqlist)
        zs{i}(StateIdx,j) = zscore(log(amp{i}(StateIdx,j))); % log for normalizing power data??
        [AboveInt,BelowInt] = continuousabove2(zs{i}(:,j),zthreshold,1/freqlist(j)*3*samplingRate); % z-score threshold??
        for k = 1:length(AboveInt)
            HighPowerPhase{i}(AboveInt(k,1):AboveInt(k,2),j) = phase{i}(AboveInt(k,1):AboveInt(k,2),j);
        end
        for k = 1:length(BelowInt)
            LowPowerPhase{i}(BelowInt(k,1):BelowInt(k,2),j) = phase{i}(BelowInt(k,1):BelowInt(k,2),j);
        end
    end
end