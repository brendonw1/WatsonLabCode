function [ComodAllChn,CFCmeasAllChn] = REM_MultiChannelMultiEpochCFC(...
    ZscFluct,Band1,Band2,Params,varargin)
%
% REM_MultiChannelMultiEpochCFC(ZscFluct,Band_1,Band2,Params,varargin)
%
% This function saves multi-channel CFC data per infraslow category in the
% session folder. This is long-duration processing, it may require an
% overnight run if the number of epochs is high (e.g., > 10 epochs).  To be
% run after REM_CFCsummValues.m as well as REM epoch'ing and infraslow
% REM_InfraslowPhase.m.  
%
% USAGE
%   - ZscFluct: one-dimensional cell array from pre-saved
%               ConcatEpochs.mat. For example, run:
%               table2cell(ConcatEpochs(:,4)) to obtain the cell array,
%               each cell with one epoch of zscored detrended infraslow
%               fluctuations (see REM_EpochLoop).
%   - Band1 or Band2: structures to name and delimit CFC blobs for
%                     quantification (see OUTPUTS).
%       - .Name: string (e.g., 'HFO' or 'Gamma')
%       - .AmplitLims: band limits in Hz (e.g., [80 160] or [40 80])
%   - Params: a structure
%       - .ChnMap: channel map (e.g., from sessionInfo). A linear probe
%                  will result in laminar data.
%       - .EpochLims: two-column list of epoch limits in seconds,
%                     buzcode-style
%       - .FluctSamplFreq: sampling frequency of Z scored infraslow
%                          fluctuation, in Hz (e.g., 125)
%       - .StateName: string ('REM' or 'WAKE'). Make sure this corresponds
%                     to .EpochLims and .FluctSamplFreq.
%   - varargin:  please see input parser section
%
% OUTPUTS (saved in the session folder)
%   - ComodAllChn:   table with remapped channels in rows, infraslow
%                    categories in columns. Each cell is a comodulation
%                    map, averaged across episodes, i.e., infraslow
%                    categories are cumulatively measured across epochs.
%   - CFCmeasAllChn: multi-channel central phase and CFC strength data from
%                    the comodulation maps (see REM_CFCsummValues). Data
%                    are organized in a table: amplitude bands in rows
%                    (e.g., HFO and gamma), measures in columns
%                    (centran phase and CFC strength). Each cell is a
%                    channel x infraslow category matrix.
%
% Bueno-Junior et al. (2023)

%% Input parser (default parameters)
p = inputParser;

% To control REM_CFCsummValues
addParameter(p,'PhaseLims',[6 11],@isnumeric) % Hz
% Infraslow coarsening
addParameter(p,'AngleBinSize',45,@isnumeric) % degrees
addParameter(p,'MinSubEpochDurSec',3,@isnumeric)
% Wait bar?
addParameter(p,'ShowWaitBar',false,@islogical)

parse(p,varargin{:})
PhaseLims         = p.Results.PhaseLims;
AngleBinSize      = p.Results.AngleBinSize;
MinSubEpochDurSec = p.Results.MinSubEpochDurSec;
ShowWaitBar       = p.Results.ShowWaitBar;

Params.PhaseLims  = PhaseLims;



%% Required inputs. Throw error messages if parameters are lacking.
ChnMap         = Params.ChnMap;
EpochLims      = Params.EpochLims;
FluctSamplFreq = Params.FluctSamplFreq;
NumChn         = length(ChnMap);
NumEpochs      = size(EpochLims,1);



%% LFP at default sampling rate
LFPall = bz_GetLFP(ChnMap,'intervals',EpochLims);
DefSamplFreq = LFPall(1).samplingRate;
LFPall = table2cell(struct2table(LFPall));
LFPall = LFPall(:,4);
DwnSamplFactor = DefSamplFreq/FluctSamplFreq;



%% Channel x infraslow category array of comodulation maps
ComodAllChn = [];
for ChnIdx  = 1:NumChn % Channel loop _____________________________________
    
    ComodAllEp = [];
    
    for EpIdx = 1:NumEpochs % Epoch loop __________________________________
        
        if ShowWaitBar
            h = waitbar(EpIdx/(NumEpochs+1),...
                ['epoch processing progress, channel #' ...
                num2str(ChnIdx) ' of ' num2str(NumChn)]);
        end
        
        LFPsingleEpChn = double(LFPall{EpIdx}(:,ChnIdx));
        FluctPhase = ZscFluct{EpIdx};
        FluctPhase = REM_InfraslowPhase(FluctPhase);
        [~,SubEpochs,AngleCategs] = ...
            REM_CoarseInfraslowPhase(FluctPhase,AngleBinSize);
        
        SubEpochs = table2cell(SubEpochs);
        SubEpochs = SubEpochs(cell2mat(SubEpochs(:,3))>...
            MinSubEpochDurSec*FluctSamplFreq,1:2);
        
        AngleCategs = num2cell(AngleCategs);
        
        for CategIdx = 1:size(AngleCategs,1) % Category loop ______________
            
            SubEpochSubset = SubEpochs(cell2mat(SubEpochs(:,1))==...
                AngleCategs{CategIdx,1},2);
            UpSamplTstamps = cell(1,1,size(SubEpochSubset,1));
            
            for SubEpIdx = 1:size(SubEpochSubset,1) % Sub-epoch loop ______
                
                [ComodMap,MapParams] = REM_CFCmap(LFPsingleEpChn(...
                    SubEpochSubset{SubEpIdx}(1)*DwnSamplFactor:...
                    SubEpochSubset{SubEpIdx}(end)*DwnSamplFactor),...
                    DefSamplFreq,'PhaseFreqBins',1,'AmplitFreqBins',20);
                UpSamplTstamps{SubEpIdx} = ComodMap;
            end
            AngleCategs{CategIdx,2} = mean(cell2mat(UpSamplTstamps),3);
        end
        ComodAllEp = cat(3,ComodAllEp,AngleCategs(:,2)');
        
        if ShowWaitBar
            close(h)
        end
    end
    
    % Average infraslow categories across episodes ________________________
    ComodAvgEp = cell(1,size(ComodAllEp,2));
    for CategIdx = 1:size(ComodAllEp,2)
        ComodAvgEp{CategIdx} = mean(cell2mat(ComodAllEp(1,CategIdx,:)),3);
        if isempty(ComodAvgEp{CategIdx})
            ComodAvgEp{CategIdx} = nan(...
                numel(MapParams.PhaseAxis)-1,numel(MapParams.AmplitAxis)-1);
        end
    end
    
    ComodAllChn = vertcat(ComodAllChn,ComodAvgEp); %#ok<*AGROW>
end



%% Summary values across channels and infraslow categories. Fixed number of
% bands to analyze: two.
Params.PhaseAxis  = MapParams.PhaseAxis;
Params.AmplitAxis = MapParams.AmplitAxis;
CFCmeasBand1 = ComodAllChn;
CFCmeasBand2 = ComodAllChn;
for CellIdx  = 1:numel(ComodAllChn)
    
    Params.AmplitLims = Band1.AmplitLims;
    [CentralPhase,CFCstrength] = REM_CFCsummValues(...
        ComodAllChn{CellIdx},Params);
    CFCmeasBand1{CellIdx} = [CentralPhase,CFCstrength];
    
    Params.AmplitLims = Band2.AmplitLims;
    [CentralPhase,CFCstrength] = REM_CFCsummValues(...
        ComodAllChn{CellIdx},Params);
    CFCmeasBand2{CellIdx} = [CentralPhase,CFCstrength];
end



%% Organize the summary values above into a table
CFCmeasAllChn = cell(2,3);
for BandIdx   = 1:2 % Fixed number of bands
    
    if BandIdx == 1
        BandName = Band1.Name;
        BandData = cell2mat(CFCmeasBand1);
    else
        BandName = Band2.Name;
        BandData = cell2mat(CFCmeasBand2);
    end
    
    for ColIdx = 1:3
        
        if ColIdx == 1
            CFCmeasAllChn{BandIdx,ColIdx} = BandName;
        elseif ColIdx == 2
            CFCmeasAllChn{BandIdx,ColIdx} = BandData(:,1:2:end);
        elseif ColIdx == 3
            CFCmeasAllChn{BandIdx,ColIdx} = BandData(:,2:2:end);
        end
    end
end



%% Output tables
for CategIdx = 1:size(AngleCategs,1)
    AngleCategs{CategIdx,2} = ...
        ['Categ_' num2str(AngleCategs{CategIdx,1}) 'deg'];
end

ComodAllChn = cell2table(ComodAllChn,'VariableNames',...
    AngleCategs(:,2)');
CFCmeasAllChn = cell2table(CFCmeasAllChn,'VariableNames',...
    {'Band','CentralPhase','CFCstrength'});
AngleCategs = AngleCategs(:,1)';

save([bz_BasenameFromBasepath(pwd) ...
    '.FullCFCanalysis_' Params.StateName '.mat'],...
    'ComodAllChn','CFCmeasAllChn','AngleCategs')

end