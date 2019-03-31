function SynapseByStateAll = SpikeTransfer_GatherAllSpikeTransferByState

[names,dirs]=GetDefaultDataset;

ERatios = [];
IRatios = [];
EERatios = [];
EIRatios = [];
IERatios = [];
IIRatios = [];
EDiffs = [];
IDiffs = [];
EEDiffs = [];
EIDiffs = [];
IEDiffs = [];
IIDiffs = [];

numep = [];
numip = [];
numeep = [];
numeip = [];
numiep = [];
numiip = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    load(fullfile(basepath,'FuncSyns',[basename ,'_FuncSynByState.mat']),'SynapseByState')
    
    if ~isempty(SynapseByState)
        if ~exist('StateNames','var')
            StateNames = SynapseByState.StateNames;
        end
        
        numep(a) = size(SynapseByState.EPairs,1);
        numip(a) = size(SynapseByState.IPairs,1);
        numeep(a) = size(SynapseByState.EEPairs,1);
        numeip(a) = size(SynapseByState.EIPairs,1);
        numiep(a) = size(SynapseByState.IEPairs,1);
        numiip(a) = size(SynapseByState.IIPairs,1);
        
        er = SynapseByState.StrengthByRatio(SynapseByState.EPairIdxs,:);
        ir = SynapseByState.StrengthByRatio(SynapseByState.IPairIdxs,:);
        eer = SynapseByState.StrengthByRatio(SynapseByState.EEPairIdxs,:);
        eir = SynapseByState.StrengthByRatio(SynapseByState.EIPairIdxs,:);
        ier = SynapseByState.StrengthByRatio(SynapseByState.IEPairIdxs,:);
        iir = SynapseByState.StrengthByRatio(SynapseByState.IIPairIdxs,:);
        
        ed = SynapseByState.StrengthByRateDiff(SynapseByState.EPairIdxs,:);
        id = SynapseByState.StrengthByRateDiff(SynapseByState.IPairIdxs,:);
        eed = SynapseByState.StrengthByRateDiff(SynapseByState.EEPairIdxs,:);
        eid = SynapseByState.StrengthByRateDiff(SynapseByState.EIPairIdxs,:);
        ied = SynapseByState.StrengthByRateDiff(SynapseByState.IEPairIdxs,:);
        iid = SynapseByState.StrengthByRateDiff(SynapseByState.IIPairIdxs,:);

        ERatios = cat(1,ERatios,er);
        IRatios = cat(1,IRatios,ir);
        EERatios = cat(1,EERatios,eer);
        EIRatios = cat(1,EIRatios,eir);
        IERatios = cat(1,IERatios,ier);
        IIRatios = cat(1,IIRatios,iir);
        
        EDiffs = cat(1,EDiffs,ed);
        IDiffs = cat(1,IDiffs,id);
        EEDiffs = cat(1,EEDiffs,eed);
        EIDiffs = cat(1,EIDiffs,eid);
        IEDiffs = cat(1,IEDiffs,ied);
        IIDiffs = cat(1,IIDiffs,iid);
    end
end

%% Save data
SynapseByStateAll = v2struct(StateNames,ERatios,IRatios,EDiffs,IDiffs,...
    EERatios,EIRatios,EEDiffs,EIDiffs,IERatios,IIRatios,IEDiffs,IIDiffs,...
    numep,numip,numeep,numeip,numiep,numiip);
MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/ByState',SynapseByStateAll)

1;
