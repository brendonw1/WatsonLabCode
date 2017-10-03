function temp

s = SpikingAnalysis_GatherAllStateRates;
for a 1:length(s.NumEcells);
    CellSessNum = cat(1,CellSessNum,a*ones(s.NumEcells(a)));
    CellSessCellNum = cat(1,CellSessCellNum,1:s.NumEcells(a));
end