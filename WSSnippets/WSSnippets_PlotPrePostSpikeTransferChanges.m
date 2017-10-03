function WSSnippets_PlotPrePostSpikeTransferChanges(ep1)
% Brendon Watson 2015

%% Load pre-post rates for each cell
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
ep2 = [];
SynCorrWSSnippets = WSSnippets_GatherAllSynCorrMedians;

%% Declare some variables for later use...names used for labeling by PlotPrePost
% ESynRatioEarly = SynCorrWSSnippets.medianPreSynCorrRatioE;
% ESynRatioLate = SynCorrWSSnippets.medianPostSynCorrRatioE;
% ISynRatioEarly = SynCorrWSSnippets.medianPreSynCorrRatioI;
% ISynRatioLate = SynCorrWSSnippets.medianPostSynCorrRatioI;
ESynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgE;
ESynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgE;
ISynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgI;
ISynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgI;
EESynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgEE;
EESynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgEE;
EISynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgEI;
EISynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgEI;
IESynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgIE;
IESynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgIE;
IISynRateChgEarly = SynCorrWSSnippets.medianPreSynCorrRateChgII;
IISynRateChgLate = SynCorrWSSnippets.medianPostSynCorrRateChgII;

%% Plot pre vs post spikes
h = [];
% [th,rEr,pEr,coeffsEr,prepostpercentchgEr,postvpreproportionEr] = PlotPrePost(ESynRatioEarly,ESynRatioLate,20);
% h = cat(1,h(:),th(:));
[th,rEd,pEd,coeffsEd,prepostpercentchgEd,postvpreproportionEd] = PlotPrePost_StableOnly(ESynRateChgEarly,ESynRateChgLate,20);
h = cat(1,h(:),th(:));

% [th,rIr,pIr,coeffsIr,prepostpercentchgIr,postvpreproportionIr] = PlotPrePost(ISynRatioEarly,ISynRatioLate,20);
% h = cat(1,h(:),th(:));
[th,rId,pId,coeffsId,prepostpercentchgId,postvpreproportionId] = PlotPrePost_StableOnly(ISynRateChgEarly,ISynRateChgLate,20);
h = cat(1,h(:),th(:));

%SUBTYPES
[th,rEEd,pEEd,coeffsEEd,prepostpercentchgEEd,postvpreproportionEd] = PlotPrePost_StableOnly(EESynRateChgEarly,EESynRateChgLate,20);
h = cat(1,h(:),th(:));
[th,rEId,pEId,coeffsEId,prepostpercentchgEId,postvpreproportionEId] = PlotPrePost_StableOnly(EISynRateChgEarly,EISynRateChgLate,20);
h = cat(1,h(:),th(:));
[th,rIEd,pIEd,coeffsIEd,prepostpercentchgIEd,postvpreproportionIEd] = PlotPrePost_StableOnly(IESynRateChgEarly,IESynRateChgLate,20);
h = cat(1,h(:),th(:));
[th,rIId,pIId,coeffsIId,prepostpercentchgIId,postvpreproportionIId] = PlotPrePost_StableOnly(IISynRateChgEarly,IISynRateChgLate,20);
h = cat(1,h(:),th(:));

% PrePostCorrelations = v2struct(...
%     rEr,pEr,coeffsEr,prepostpercentchgEr,postvpreproportionEr,...
%     rEd,pEd,coeffsEd,prepostpercentchgEd,postvpreproportionEd,...
%     rIr,pIr,coeffsIr,prepostpercentchgIr,postvpreproportionIr,...
%     rId,pId,coeffsId,prepostpercentchgId,postvpreproportionId);
PrePostCorrelations = v2struct(...
    rEd,pEd,coeffsEd,prepostpercentchgEd,postvpreproportionEd,...
    rId,pId,coeffsId,prepostpercentchgId,postvpreproportionId,...
    rEEd,pEEd,coeffsEEd,prepostpercentchgEEd,postvpreproportionEEd,...
    rEId,pEId,coeffsEId,prepostpercentchgEId,postvpreproportionEId,...
    rIEd,pIEd,coeffsIEd,prepostpercentchgIEd,postvpreproportionIEd,...
    rIId,pIId,coeffsIId,prepostpercentchgIId,postvpreproportionIId);
 
%% Save Figs
supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer',ep1);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')