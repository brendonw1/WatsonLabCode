function [NormSpkRates,RtestPerFluct] = REM_SpkRatesPerInfraslowPhase(...
    SessionPaths,varargin)
%
% [NormSpkRates,RtestPerFluct] = REM_SpkRatesPerInfraslowPhase(SessionPaths,PhaseBinSizeDeg)
%
% MUA (not SUA) firing rates are 0-1 normalized across infraslow phases.
% This wrapper function can be used as a template.
%
% USAGE
%   - SessionPaths: single-column cell array, each cell with a path. This
%                   can be used to define data subsets (e.g., home cage,
%                   head fixed), ignore bad sessions, etc.
%   - varargin: please, see Input parser section
%
% OUTPUT
%   - NormSpkRates: matrix, ready for phase plotting.
%                   Rows: infraslow phases (see Input parser for bin size).
%                         Ascending order, zero degrees at the top.
%                   Columns: excitatory MUA, inhibitory MUA, ... repeat
%                            for number of physiologic fluctuations.
%   - RtestPerFluct (optional): Rayleigh tests for each column of the main
%                               output.
%                   
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

addParameter(p,'PhaseBinSize',45,@isnumeric) % degrees

parse(p,varargin{:})
PhaseBinSize = p.Results.PhaseBinSize;



%%
InitPath = pwd; % Go back to this path once finished.
SpkRatesPerPhase = cell(1,3);
for SessionIdx = 1:numel(SessionPaths)
    
    cd(SessionPaths{SessionIdx})
    disp(SessionPaths{SessionIdx})
    
    % Pre-saved Hilbert transforms from infraslow fluctuations.
    % See REM_InfraslowPhase.m ____________________________________________
    load([bz_BasenameFromBasepath(pwd) '.InfraSlowHilb.mat'],...
        'REMthetaRidge','REMthetaPower','REMemg','HilbSamplFreq')
    
    % Rates _______________________________________________________________
    load([bz_BasenameFromBasepath(pwd) '.sessionInfo.mat'],'sessionInfo');
    SpkSamplFreq  = sessionInfo.rates.wideband;
    HilbToSpkConv = SpkSamplFreq/HilbSamplFreq;
    
    % Trimmed REM intervals, buzcode style ________________________________
    load([bz_BasenameFromBasepath(pwd) '.TrimmedREMints.mat'],...
        'ints')
    ints = repmat(ints(:,1),1,3);
    
    % Existing buzcode conventions ________________________________________
    load([bz_BasenameFromBasepath(pwd) '.spikes.cellinfo.mat'],...
        'spikes')
    MaxWavefChn  = spikes.maxWaveformCh;
    spikes.ts    = spikes.ts(MaxWavefChn<=64);
    load([bz_BasenameFromBasepath(pwd) '.CellClass.cellinfo.mat'],...
        'CellClass')
    CellClass.pE = CellClass.pE(MaxWavefChn<=64);
    CellClass.pI = CellClass.pI(MaxWavefChn<=64);
    
    % Combine all units for MUA ___________________________________________
    pEspk = cell2mat(spikes.ts(CellClass.pE)'); % putative excitatory
    pIspk = cell2mat(spikes.ts(CellClass.pI)'); % putative inhibitory
    
    % Main loop ___________________________________________________________
    AllEpochs = [REMthetaRidge REMthetaPower REMemg];
    for EpochIdx = 1:numel(AllEpochs)
        
        % Infraslow sub-epochs ____________________________________________
        [~,SubEpochs,AngleCategs] = ...
            REM_CoarseInfraslowPhase(AllEpochs{EpochIdx},PhaseBinSize);
        SubEpochs = table2cell(SubEpochs);
        
        for SubEpIdx = 1:size(SubEpochs,1)
            
            SubEpochs{SubEpIdx,2} = ([...
                SubEpochs{SubEpIdx,2}(1) ...
                SubEpochs{SubEpIdx,2}(end)]*HilbToSpkConv)+(...
                ints(EpochIdx)*SpkSamplFreq);
            
            % MUA counts divided by neuron counts, to take into account
            % the diferent cell classes (e.g., putative inhibitory have
            % higher rates but are less numerous) _________________________
            SubEpochs{SubEpIdx,4} = sum(...
                pEspk>SubEpochs{SubEpIdx,2}(1) & ...
                pEspk<SubEpochs{SubEpIdx,2}(2))/sum(CellClass.pE);
            SubEpochs{SubEpIdx,5} = sum(...
                pIspk>SubEpochs{SubEpIdx,2}(1) & ...
                pIspk<SubEpochs{SubEpIdx,2}(2))/sum(CellClass.pI);
        end
        
        % Sum MUA and sub-epoch durations _________________________________
        AngleCategs = num2cell(AngleCategs);
        for CategIdx = 1:size(AngleCategs,1)
            
            AngleCategs{CategIdx,2} = sum(cell2mat(SubEpochs(ismember(...
                cell2mat(SubEpochs(:,1)),AngleCategs{CategIdx,1}),4)));
            AngleCategs{CategIdx,3} = sum(cell2mat(SubEpochs(ismember(...
                cell2mat(SubEpochs(:,1)),AngleCategs{CategIdx,1}),5)));
            AngleCategs{CategIdx,4} = sum(cell2mat(SubEpochs(ismember(...
                cell2mat(SubEpochs(:,1)),AngleCategs{CategIdx,1}),3)));
        end
        
        AllEpochs{EpochIdx} = cell2mat(AngleCategs);
    end
    
    % From sub-epoch to epoch level _______________________________________
    AllEpochs = permute(AllEpochs,[3 2 1]);
    for VarIdx = 1:size(AllEpochs,2)
        
        TempMatr = cell2mat(AllEpochs(1,VarIdx,:));
        AllEpochs{1,VarIdx,1} = [TempMatr(:,1,1) sum(TempMatr(:,2:4),3)];
    end
    
    SpkRatesPerPhase = cat(3,SpkRatesPerPhase,AllEpochs(1,:,1));
end
cd(InitPath)



%% Across sessions
for VarIdx = 1:size(SpkRatesPerPhase,2)
    
    TempMatr = cell2mat(SpkRatesPerPhase(1,VarIdx,2:end));
    SpkRatesPerPhase{1,VarIdx,1} = ...
        [TempMatr(:,1,1) sum(TempMatr(:,2:4),3)];
end
SpkRatesPerPhase = SpkRatesPerPhase(1,:,1);

for VarIdx = 1:size(SpkRatesPerPhase,2)
    
    TempMatr = SpkRatesPerPhase{1,VarIdx};
    
    % Divide by the total duration of each infraslow phase ________________
    TempMatr(:,2) = TempMatr(:,2)./TempMatr(:,4); % putative excitatory
    TempMatr(:,3) = TempMatr(:,3)./TempMatr(:,4); % putative inhibitory
    SpkRatesPerPhase{1,VarIdx} = TempMatr(:,1:3);
end



%% Normalize across physiologic fluctuations
PreNorm = cell2mat(SpkRatesPerPhase);
PreNorm(:,1:3:end) = [];
NormSpkRates = reshape(...
    rescale(PreNorm(:)),size(PreNorm,1),size(PreNorm,2));



%% Incidence per phase bin in radians, for circ_rtest.m
RtestPerFluct = zeros(size(NormSpkRates,2),1);
for ColIdx = 1:size(NormSpkRates,2)
    
    RtestPerFluct(ColIdx) = REM_CircRtestFromNormalized(...
        NormSpkRates(:,ColIdx));
end

end