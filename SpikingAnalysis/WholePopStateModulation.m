function [allStateRates, allStateModulations] = WholePopStateModulation(S,CellIDs,intervals)

Se = S(CellIDs.EAll);
SeDef = S(CellIDs.EDefinite);
% SeLike = S(CellIDs.ELike);
Si = S(CellIDs.IAll);
SiDef = S(CellIDs.IDefinite);
% SiLike = S(CellIDs.ILike);

[cellStateRates,modulations] = StateModulationIndices(S,intervals);

[cellStateRatesE,modulationsE] = StateModulationIndices(Se,intervals);
[cellStateRatesI,modulationsI] = StateModulationIndices(Si,intervals);

[cellStateRatesEDef,modulationsEDef] = StateModulationIndices(SeDef,intervals);
[cellStateRatesIDef,modulationsIDef] = StateModulationIndices(SiDef,intervals);

allStateRates = v2struct(cellStateRates,cellStateRatesE,cellStateRatesI,cellStateRatesEDef,cellStateRatesIDef);
allStateModulations = v2struct(modulations,modulationsE,modulationsI,modulationsEDef,modulationsIDef);


local_plot(cellStateRatesE,modulationsE,'g','ECells')
local_plot(cellStateRatesI,modulationsI,'r','ICells')

%%%%%%%%%%%%%%%%%%

function local_plot(cellStateRates,modulations,colorstring,namestring)

figure('position',[10 10 840 630],'name',namestring)
subplot(3,3,1)
plot(cellStateRates.meanwakecellrates,cellStateRates.meanswscellrates,'.','color',colorstring)
title('SWS Rate vs Wake Rate')
xlabel('Cell Wake firing rate')
ylabel('Cell SWS firing rate')

subplot(3,3,2)
plot(cellStateRates.meanwakecellrates,cellStateRates.meanremcellrates,'.','color',colorstring)
title('REM Rate vs Wake Rate')
xlabel('Cell Wake firing rate')
ylabel('Cell REM firing rate')

subplot(3,3,3)
plot(cellStateRates.meanswscellrates,cellStateRates.meanremcellrates,'.','color',colorstring)
title('REM Rate vs SWS Rate')
xlabel('Cell SWS firing rate')
ylabel('Cell REM firing rate')

subplot(3,3,4)
plot(cellStateRates.totalrates,modulations.wakeswsmodulationindex,'.','color',colorstring)
title('SWS:Wake Modulation vs Total Rate')
xlabel('Cell total firing rate')
ylabel('Wake:SWS modulation')

subplot(3,3,5)
plot(cellStateRates.totalrates,modulations.remwakemodulationindex,'.','color',colorstring)
title('Wake:REM Modulation vs Total Rate')
xlabel('Cell total firing rate')
ylabel('REM:Wake modulation')

subplot(3,3,6)
plot(cellStateRates.totalrates,modulations.remswsmodulationindex,'.','color',colorstring)
title('REM:SWS Modulation vs Total Rate')
xlabel('Cell total firing rate')
ylabel('REM:SWS modulation')

subplot(3,3,7)
plot(modulations.remswsmodulationindex,modulations.wakeswsmodulationindex,'.','color',colorstring)
title('REM:SWS Modulation vs Wake:SWSModulation')
xlabel('REM:SWS modulation')
ylabel('Wake:SWS modulation')

subplot(3,3,8)
plot(modulations.remwakemodulationindex,modulations.wakeswsmodulationindex,'.','color',colorstring)
title('REM:Wake Modulation vs Wake:SWS Modulation')
xlabel('REM:Wake modulation')
ylabel('Wake:SWS modulation')

subplot(3,3,9)
plot(cellStateRates.meanwakecellrates,modulations.wakeswsmodulationindex,'.','color',colorstring)
title('Wake:SWS Modulation vs Wake Rate')
xlabel('Waking firing rate')
ylabel('Wake:SWS Modulation')

