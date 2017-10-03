function [AllStateAssDataPCA, AllStateAssDataICA] = AssembliesByState(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin)
% Takes 1sec epochs from each state, generates PCA/ICA templates based on
% them and then projects them onto every state.  States here include:
% states = {'WakeE','MWakeE','NMWakeE','UPE','SUPE','SpindlesE','NDSpindlesE','REME'};
% Saves to disk the assemblies and projections for each session, in the
% Assemblies folder of each basefolder.
% 

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
% 
% secondsPerDetectionBin = 1;
% secondsPerProjectionBin = 1;

gsi = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
gsi = gsi.GoodSleepInterval;
StateRateBins = GatherStateRateBinMatrices(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin,gsi);
v2struct(StateRateBins);%unpacks RateMtxSpindlesE,RateMtxNDSpindlesE,RateMtxUPE,RateMtxSUPE,
                        %RateMtxWakeE,RateMtxREME,RateMtxMWakeE,RateMtxNMWakeE
disp('Bins Done')
%%% 

states = {'WakeE','MWakeE','NMWakeE','UPE','SUPE','NSUPE','SpindlesE','NDSpindlesE','REME'};
% Must match what's in GatherStateRateBinMatrices.m (above)

for a = 1:length(states)
%     if isempty(['RateMtx' states{a}])
%         eval([states{a} 'PCAAssData.Patterns = [];'])
%         eval([states{a} 'ICAAssData.Patterns = [];'])
% 
%     else
        h1 = [];
        h2 = [];
        eval(['[' states{a} 'PCAAssData,h1] = GetPCAAssembliesPrebinnedNoProj(RateMtx' states{a} ',secondsPerDetectionBin);'])
        if ~isempty(h1)
            AboveTitle([basename ' ' states{a} ' PCA Assemblies'])
            set(h1,'name',[basename '_' states{a} '_PCAAsemblies'])
        end
%         disp('Detected PCs')
        
        eval(['[' states{a} 'ICAAssData,h2] = GetICAAssembliesPrebinnedNoProj(RateMtx' states{a} ',secondsPerDetectionBin);'])
        if ~isempty(h2)
            AboveTitle([basename ' ' states{a} ' ICA Assemblies'])
            set(h2,'name',[basename '_' states{a} '_ICAAsemblies'])
        end
%         disp('Detected ICs')

        if ~isempty([h1 h2])
            savethesefigsas([h1 h2],'fig',fullfile(basepath,'Assemblies'))
            close ([h1 h2])
        end

        for b = 1:length(states);
            tpcaname = ['PCAAss' states{a} 'onto' states{b}];
            ticaname = ['ICAAss' states{a} 'onto' states{b}];

            eval(['[' tpcaname '] = ProjectAssembliesOntoBinnedMatrix_NoPlot(' states{a} 'PCAAssData,RateMtx' states{b} ');'])
            eval(['[' ticaname '] = ProjectAssembliesOntoBinnedMatrix_NoPlot(' states{a} 'ICAAssData,RateMtx' states{b} ');'])
            eval(['[' tpcaname '] = ProjectNonSigAssembliesOntoBinnedMatrix_NoPlot(' tpcaname ', RateMtx' states{b} ');'])
            eval(['[' ticaname '] = ProjectNonSigAssembliesOntoBinnedMatrix_NoPlot(' ticaname ', RateMtx' states{b} ');'])

            eval(['AllStateAssDataPCA.' tpcaname '=' tpcaname ';'])
            eval(['AllStateAssDataICA.' ticaname '=' ticaname ';'])

            eval(['clear ' tpcaname ' ' ticaname])
        end
%     end
    disp([states{a} ' done.'])
end

AllStateAssDataPCA.states = states;
AllStateAssDataICA.states = states;

AllStateAssDataPCA.secondsPerDetectionBin = secondsPerDetectionBin;
AllStateAssDataPCA.secondsPerProjectionBin = secondsPerProjectionBin;
AllStateAssDataICA.secondsPerDetectionBin = secondsPerDetectionBin;
AllStateAssDataICA.secondsPerProjectionBin = secondsPerProjectionBin;

save(fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_AllStateAssDataPCA_' num2str(secondsPerDetectionBin) 'sec.mat']),'AllStateAssDataPCA','-v7.3')
save(fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_AllStateAssDataICA'  num2str(secondsPerDetectionBin) 'sec.mat']),'AllStateAssDataICA','-v7.3')