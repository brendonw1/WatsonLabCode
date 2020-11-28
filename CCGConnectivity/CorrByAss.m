CorrByAss(basepath,basename)
% I think it looks at correlation strength dependent on whether assemblies
% are on... only for connections where both cells are in the assembly
% ... never been tried.

actthresh = 2;

if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

t = load(fullfile(basepath,'Assemblies','WholeBasedPCA',['AssemblyBasicData.mat']));
acts = t.AssemblyBasicData.AssemblyActivities;
acs = t.AssemblyBasicData.AssemblyCells;
numass = size(acts,1);

f = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent']));
epairs = f.funcsynapses.ConnectionsE;
ipairs = f.funcsynapses.ConnectionsI;

t = load(fullfile(basepath,[basename '_SStable']));
S = t.S;

for a = 1:size(epairs,1)
    tpair = epairs(a,:);
    for b = 1:numass
        if sum(ismember(tpair,acs{b})) == 2
            tact = zscore(acts(b,:));
            tS = tsdArray({S{tpair(1)},S{tpair(2)}});
            ontime = continuousabove2(tact,actthresh,1,Inf);
            offtime = continuousbelow2(tact,actthresh,1,Inf);
            onInterval = intervalSet(ontime(:,1)*10000,ontime(:,2)*10000);
            offInterval = intervalSet(offtime(:,1)*10000,offtime(:,2)*10000);
            onS = Restrict(tS,onInterval);
            offS = Restrict(tS,offInterval);
            
            binSec = 0.005;
            tstart = abs(f.funcsynapses.CnxnStartTimesVsRefSpk);
            tstop = abs(f.funcsynapses.CnxnEndTimesVsRefSpk);
            cw = f.funcsynapses.ConvolutionWidthInBins;
            cw = cw*binSec;
            preshank = f.funcsynapses.CellShanks(tpair(1));
            postshank = f.funcsynapses.CellShanks(tpair(2));
            
            [onstrengthbyratio, onstrengthbyratechg, onccg, onmeasured, onexpected] = ...
                SpikeTransfer_Norm(onS{1},onS{2},binSec,0.03,[tstart tstop],cw,[preshank == postshank],10000);
            [offstrengthbyratio, offstrengthbyratechg, offccg, offmeasured, offexpected] = ...
                SpikeTransfer_Norm(offS{1},offS{2},binSec,0.03,[tstart tstop],cw,[preshank == postshank],10000);
            
            figure;
            plot(onccg,'g')
            hold on;
            plot(offccg,'r')
        
            % Store/Remember These
        end
    end
end
