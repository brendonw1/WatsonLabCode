function RayleighTest_MD

basepath = cd;
[~,basename] = fileparts(cd);

alpha = 0.01; % significant level

load(fullfile(basepath,[basename '_PhaseLockingData50-150Hz.mat']),'PhaseLockingData');
% MRL = PhaseLockingData.phasestats.r;
% for i = 1:length(PhaseLockingData.spkphases)
% nspk(i) = length(PhaseLockingData.spkphases{i});
% p_value(i) = exp(-MRL(i)^2*nspk(i));
% end

p_values = PhaseLockingData.phasestats.p;
CellNum = length(PhaseLockingData.spkphases);
CorrID = find(p_values*CellNum<alpha); % Bonferroni correction for p values

end