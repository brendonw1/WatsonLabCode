function trisecFiringFunc(varargin)
% trisecFiringFunc - Get sleep states firing rates in trisection.
%
% USAGE
%
%    trisecFiringFunc(varargin)
% 
% INPUTS
%
%    subsetCell     -vector subset of Cell IDs to load (Default: all I and E cells)
%    subsetTime     -vector subset of time interval to load (Default: all)
%    stableSleepThreshold     -Threshold for definition of stable sleep
%    (minutes), default: 20 minutes.
%    Directory     -Directory to execute the function default: pwd
% OUTPUTS
%    sleep-basics     -basic cell and channel info
%    sleep-behavior     -sleep state epoch
%    sleep-onOff     -UP and DN state epoch
%    sleep-spikes     -spike time for individual cell
%    sleep-stableSleep     -stable sleep epoch
%    sleep-stateChange     -different state transition
%    sleep-timeNormFR     -Different states has their intrinsic mean
%    periods, thus firing rates need to be normalized.
%    sleep-trisecFiring     -trisection firing rate
%    sleep-trisecFiringSp     -trisect firing rate without DN state spikes
% NOTES
%
% First usage recommendation:
% 
%   1. Run trisecFiringFunc;
%   2. (Optional) Run mergeSleepList in the parent folder if multiple recordings.
%   3. Run quintile_newDI5sp to get the deflection index.
% other examples:
%
%   trisecFiringFunc('subsetCell',[1:6],'subsetTime',[200,5000]); Cell 1-6 will be 
%   selected to calculate the trisection firing rate. Note that E and I cells will 
%   be categorized separately. Only interval between 200-5000sec will be calculated.
%
%
% Main scripts written by Hiroyuki Miyawaki, modified by Tangyu Liu, 2020
%% Deal With Inputs 
p = inputParser;
addParameter(p,'subsetCell',[],@isvector);
addParameter(p,'subsetTime',[],@isvector);
addParameter(p,'Directory',pwd,@isstr);
addParameter(p,'stableSleepThreshold',20,@isnumeric)
parse(p,varargin{:})

Directory = p.Results.Directory;
subsetCell = p.Results.subsetCell;
subsetTime = p.Results.subsetTime;
stableSleepThreshold = p.Results.stableSleepThreshold;
%%
baseDir=[Directory filesep];
coreName='sleep';
fname=bz_BasenameFromBasepath(pwd);
load([fname '.spikes.cellinfo.mat']);
spikeGroups='all';
if sum(spikes.cluID)==numel(spikes.UID)
    spikes.cluID=spike.UID;
    save([fname '.spikes.cellinfo.mat'],'spikes')
end
if ~isfield(spikes,'region')
    spikes.region=NaN;
    save([fname '.spikes.cellinfo.mat'],'spikes');
end
if strcmp(fname,'c3po_160208')
    spikeGroups=[7:12];
    spikes = bz_GetSpikes('spikeGroups',spikeGroups);
end
spikesb=spikes;
UIDstart=spikes.UID(1);
UIDend=spikes.UID(end);
%spikes = bz_GetSpikes;

load([fname '.SleepState.states.mat']);
if exist([fname '.UPDOWNIntervals.mat'],'file')
    ud=load([fname '.UPDOWNIntervals.mat']);
    UPInts=ud.UPDOWNIntervals.UPInts;
    DNInts=ud.UPDOWNIntervals.DNInts;
else
    load([fname '.SlowWaves.events.mat']);
    UPInts=SlowWaves.ints.UP;
    DNInts=SlowWaves.ints.DOWN;
end
if exist([fname '_CellIDs.mat'],'file')
    load([fname '_CellIDs.mat']);
else
    load([fname '.CellClass.cellinfo.mat']);
    CellIDs=CellClass;
    CellIDs.IAll=find(CellClass.pI~=0)';
    CellIDs.IAll=CellIDs.IAll(find(CellIDs.IAll>=spikes.UID(1)));
    CellIDs.EAll=find(CellClass.pE~=0)';
    CellIDs.EAll=CellIDs.EAll(find(CellIDs.EAll>=spikes.UID(1)));
end
UIDstart=spikes.UID(1);
%% nrem=1, rem=2, wake=3
%% remove MA
%%
basics.(fname)=struct;
varList={'basics'};
basics.(fname)=spikesb;
basics.(fname) = rmfield(basics.(fname),'times');
if isfield(basics.(fname),'spindices')
basics.(fname) = rmfield(basics.(fname),'spindices');
end
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end

onOff.(fname)=struct;
varList={'onOff'};
onOff.(fname).on=UPInts*1e6;
onOff.(fname).off=DNInts*1e6;
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end

spikes=struct;
spikes.(fname)=struct;
qual_temp=zeros(1,UIDend-UIDstart+1);
if isempty(subsetCell)
qual_temp(CellIDs.EAll-UIDstart+1)=3;
qual_temp(CellIDs.IAll-UIDstart+1)=8;
else
subsetCell(ismember(subsetCell,CellIDs.EAll-UIDstart+1))=3;
subsetCell(ismember(subsetCell,CellIDs.IAll-UIDstart+1))=8;
end
% qual_temp(CellClass.pE==1)=3;
% qual_temp(CellClass.pE==0)=8;
for i=1:length(spikesb.UID)
spikes.(fname)(i).time=spikesb.times{i}'*1e6;
spikes.(fname)(i).isStable=1;
spikes.(fname)(i).quality=qual_temp(i);
end
varList={'spikes'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end

epochn=[SleepState.ints.NREMstate*1e6 ones(size(SleepState.ints.NREMstate,1),1)];
epochr=[SleepState.ints.REMstate*1e6 2*ones(size(SleepState.ints.REMstate,1),1)];
epochw=[SleepState.ints.WAKEstate(diff(SleepState.ints.WAKEstate,[],2)>=40,:)*1e6];
epochw=[epochw 3*ones(size(epochw,1),1)];
%epochm=[SleepState.ints.WAKEstate(diff(SleepState.ints.WAKEstate,[],2)>=40,:)*1e6 4*ones(size(SleepState.ints.WAKEstate,1),1)];
%epoch=sortrows([epochn;epochr;epochw;epochm]);
epoch=sortrows([epochn;epochr;epochw]);
%%%if a particular time interval is specified
epoch1=[];
if ~isempty(subsetTime)
    epoch1=epoch(find(epoch(:,1)>=subsetTime(1)*1e6,1,'first'):find(epoch(:,2)<=subsetTime(2)*1e6,1,'last'),:);
    
end
epoch=epoch1;
%%%
epoch1=[];
for i=1:size(epoch,1)
    if epoch(i,1)~=epoch(i,2)
        epoch1=[epoch1;epoch(i,:)];
    end
end
epoch=epoch1;
epoch1=[];
ind=1;
repeat=0;
for i=1:size(epoch,1)-1
    if epoch(i,3)==epoch(i+1,3)
        repeat=repeat+1;
        epoch1(ind,:)=[epoch(i+1-repeat,1) epoch(i+1,2) epoch(i,3)];
    else
        if repeat~=0
            ind=ind+1;
            %epoch1(ind,:)=epoch(i,1:3);
            repeat=0;
        else
            epoch1(ind,:)=epoch(i,1:3);
            ind=ind+1;
        end
        
    end
end
epoch=epoch1;

behavior.(fname)=struct;
behavior.(fname).name={'nrem','rem','wake'};
behavior.(fname).list=epoch;
varList={'behavior'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end
%%

stablesleep=[];
nremsleep={};
remsleep={};
j=1;
repeat=0;
for i=1:size(epoch,1)-1
    if epoch(i,3)~=3 | (epoch(i,3)==3 & diff(epoch(i,1:2),[],2)<2*60*1e6)       
repeat=repeat+1;
stablesleep(j,1)=epoch(i+1-repeat,1);
        if epoch(i+1,3)==3 & diff(epoch(i+1,1:2),[],2)>2*60e6
            istart=i+1-repeat;
            iend=i;
            stablesleep(j,2)=epoch(iend,2);
            nremsleep{j}=(epoch(istart:iend,3)==1)+istart-1;
            remsleep{j}=(epoch(istart:iend,3)==2)+istart-1;
            j=j+1;
            repeat=0;
        end
    end
end

stablesleep(diff(stablesleep,[],2)<60*stableSleepThreshold*1e6,:)=[];
stableSleep=struct;
stableSleep.(fname)=struct;
stableSleep.(fname).time=stablesleep;

states=behavior.(fname).list;
for i=1:size(stablesleep,1)
stableSleep.(fname).nrem{i}=find(states(:,1)>=stablesleep(i,1) & states(:,2)<=stablesleep(i,2) & states(:,3)==1);
stableSleep.(fname).rem{i}=find(states(:,1)>=stablesleep(i,1) & states(:,2)<=stablesleep(i,2) & states(:,3)==2);
end

varList={'stableSleep'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end
%% timeNormFR
timeNormFR.(fname).onset.pyr=cell(1,size(epoch,1));
timeNormFR.(fname).offset.pyr=cell(1,size(epoch,1));
timeNormFR.(fname).onset.inh=cell(1,size(epoch,1));
timeNormFR.(fname).offset.inh=cell(1,size(epoch,1));
varList={'timeNormFR'};
%%% nrem=1, rem=2, wake=3
spikest=spikes;
for i=1:size(epoch,1)
    for j=1:size(spikes.(fname),2)
        FRtemp=[];
        switch behavior.(fname).list(i,3)
            case 1 %NREM 30 division
                spiket=spikest.(fname)(j).time;
                ind=find(spiket>epoch(i,1) & spiket<epoch(i,2));
                spikett=spiket(ind);
                if ~isempty(spikett)
                    spikest.(fname)(j).time=spikest.(fname)(j).time(ind(end)+1:end); % delete used spikes
                    timediv=(epoch(i,2)-epoch(i,1))/30;
                    for k=epoch(i,1):timediv:epoch(i,2)-timediv
                        FRtemp(end+1)=sum((spikett>k & spikett<k+timediv))/timediv;
                    end
                else
                    FRtemp=zeros(1,30);
                end
                if spikes.(fname)(j).quality==3
                    timeNormFR.(fname).onset.pyr{i}(end+1,:)=FRtemp*1e6;
                    timeNormFR.(fname).offset.pyr{i}(end+1,:)=FRtemp*1e6;
                elseif spikes.(fname)(j).quality==8
                    timeNormFR.(fname).onset.inh{i}(end+1,:)=FRtemp*1e6;
                    timeNormFR.(fname).offset.inh{i}(end+1,:)=FRtemp*1e6;
                end
                
            case 2 %REM 10 division
                spiket=spikest.(fname)(j).time;
                ind=find(spiket>epoch(i,1) & spiket<epoch(i,2));
                spikett=spiket(ind);
                if ~isempty(spikett)
                    spikest.(fname)(j).time=spikest.(fname)(j).time(ind(end)+1:end);
                    timediv=(epoch(i,2)-epoch(i,1))/10;
                    for k=epoch(i,1):timediv:epoch(i,2)-timediv
                        FRtemp(end+1)=sum((spikett>k & spikett<k+timediv))/timediv;
                    end
                else
                    FRtemp=zeros(1,10);
                end
                if spikes.(fname)(j).quality==3
                    timeNormFR.(fname).onset.pyr{i}(end+1,:)=FRtemp*1e6;
                    timeNormFR.(fname).offset.pyr{i}(end+1,:)=FRtemp*1e6;
                elseif spikes.(fname)(j).quality==8
                    timeNormFR.(fname).onset.inh{i}(end+1,:)=FRtemp*1e6;
                    timeNormFR.(fname).offset.inh{i}(end+1,:)=FRtemp*1e6;
                end
            case 3 %WAKE 5 division for first/last 1 min for onset/offset
                spiket=spikest.(fname)(j).time;
                ind=find(spiket>epoch(i,1) & spiket<epoch(i,1)+60e6);
                spikett=spiket(ind);
                if ~isempty(spikett)
                    spikest.(fname)(j).time=spikest.(fname)(j).time(ind(end)+1:end);
                    timediv=60e6/5;
                    for k=epoch(i,1):timediv:epoch(i,1)+60e6-timediv
                        FRtemp(end+1)=sum((spikett>k & spikett<k+timediv))/timediv;
                    end
                else
                    FRtemp=zeros(1,5);
                end
                if spikes.(fname)(j).quality==3
                    timeNormFR.(fname).onset.pyr{i}(end+1,:)=FRtemp*1e6;
                elseif spikes.(fname)(j).quality==8
                    timeNormFR.(fname).onset.inh{i}(end+1,:)=FRtemp*1e6;
                end
                FRtemp=[];
                ind=find(spiket>epoch(i,2)-60e6 & spiket<epoch(i,2));
                spikett=spiket(ind);
                if ~isempty(spikett)
                    spikest.(fname)(j).time=spikest.(fname)(j).time(ind(end)+1:end);
                    timediv=60e6/5;
                    for k=epoch(i,2)-60e6:timediv:epoch(i,2)-timediv
                        FRtemp(end+1)=sum((spikett>k & spikett<k+timediv))/timediv;
                    end
                else
                    FRtemp=zeros(1,5);
                end
                if spikes.(fname)(j).quality==3
                    timeNormFR.(fname).offset.pyr{i}(end+1,:)=FRtemp*1e6;
                elseif spikes.(fname)(j).quality==8
                    timeNormFR.(fname).offset.inh{i}(end+1,:)=FRtemp*1e6;
                end
                
        end
    end
end
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end
%%
stateChange.(fname)=struct;
states=behavior.(fname).list(:,3);
statest=states(1:end-1);
stateChange.(fname).nrem=find(statest==1);
stateChange.(fname).rem=find(statest==2);
stateChange.(fname).quiet=find(statest==3);
% quiet2nrem
transit=[];
ini=stateChange.(fname).quiet;
fin=1;
for i=1:size(ini,1)
    if states(ini(i)+1)==fin
        transit=[transit;ini(i) ini(i)+1];
    end
end
stateChange.(fname).quiet2nrem=transit;
% nrem2quiet
transit=[];
ini=stateChange.(fname).nrem;
fin=3;
for i=1:size(ini,1)
    if states(ini(i)+1)==fin
        transit=[transit;ini(i) ini(i)+1];
    end
end
stateChange.(fname).nrem2quiet=transit;
% rem2quiet
transit=[];
ini=stateChange.(fname).rem;
fin=3;
for i=1:size(ini,1)
    if states(ini(i)+1)==fin
        transit=[transit;ini(i) ini(i)+1];
    end
end
stateChange.(fname).rem2quiet=transit;
% nrem2rem
transit=[];
ini=stateChange.(fname).nrem;
fin=2;
for i=1:size(ini,1)
    if states(ini(i)+1)==fin
        transit=[transit;ini(i) ini(i)+1];
    end
end
stateChange.(fname).nrem2rem=transit;
% rem2nrem
transit=[];
ini=stateChange.(fname).rem;
fin=1;
for i=1:size(ini,1)
    if states(ini(i)+1)==fin
        transit=[transit;ini(i) ini(i)+1];
    end
end
stateChange.(fname).rem2nrem=transit;

% 3 states
statest=states(1:end-2);
stateChange.(fname).nrem=find(statest==1);
stateChange.(fname).rem=find(statest==2);
stateChange.(fname).quiet=find(statest==3);
% nrem2rem2nrem
transit=[];
ini=stateChange.(fname).nrem;
mid=2;
fin=1;
for i=1:size(ini,1)
    if states(ini(i)+1)==mid & states(ini(i)+2)==fin
        transit=[transit;ini(i) ini(i)+1 ini(i)+2];
    end
end
stateChange.(fname).nrem2rem2nrem=transit;
% rem2nrem2rem
transit=[];
ini=stateChange.(fname).rem;
mid=1;
fin=2;
for i=1:size(ini,1)
    if states(ini(i)+1)==mid & states(ini(i)+2)==fin
        transit=[transit;ini(i) ini(i)+1 ini(i)+2];
    end
end
stateChange.(fname).rem2nrem2rem=transit;

varList={'stateChange'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end
%%
% coreName='sleep';
baseDir=[pwd filesep];

varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'HL'
    'onOff'
    ...'MA'
    ...'HLfine'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    ...'pfcEeg'
    'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'sleepPeriod'
    ...'trisec'
    }';


for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end

dList=fieldnames(basics);
%%
for  dIdx=1:length(dList)
     dName=dList{dIdx};
    onOff.(dName).off(diff(onOff.(dName).off,1,2)<75e3,:)=[];
end

clear nPeriod
% nPeriod.rem=10;
% nPeriod.nrem=3*nPeriod.rem;
nPeriod.nrem=3;

wakeDur=60e6;
wakeNumBin=5;
wakeBinSize=wakeDur/wakeNumBin;
% 
% for dIdx=1:length(dList)
%     fprintf('%s start session %d/%d\n', datestr(now), dIdx,length(dList))
%     
%     dName=dList{dIdx};
%     spk.pyr={spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable})).time};
%     spk.inh={spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable})).time};
%     cTypeList=fieldnames(spk);
%     
%     nremTime=behavior.(dName).list(behavior.(dName).list(:,3)==1,1:2);
%     
%     
%     temp=mergePeriod(onOff.(dName).on,nremTime);
%     subset.on=temp{2,2};
%     
%     temp=mergePeriod(onOff.(dName).off,nremTime);
%     subset.off=temp{2,2};
%     
%     temp=mergePeriod(MA.(dName).time,nremTime);
%     subset.low=temp{2,2};
%     subset.high=temp{1,2};
%     
%     for sIdx=1:size(behavior.(dName).list,1)
%         sName=behavior.(dName).name{behavior.(dName).list(sIdx,3)};
%         
%         if ~isfield(nPeriod,sName)
%             continue
%         end
%         
%         fprintf('  %s state %d/%d \n', datestr(now), sIdx,size(behavior.(dName).list,1))
%         
%         %         tBorder=behavior.(dName).list(sIdx,1)+diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName)*(0:nPeriod.(sName));
%         tBinSize=diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName);
%         tBorder=behavior.(dName).list(sIdx,1):tBinSize:behavior.(dName).list(sIdx,2);
%         
%         clear spkSubset
%         spkSubset.pyr=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.pyr,'UniformOutput',false);
%         spkSubset.inh=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.inh,'UniformOutput',false);
%         
%         subsetList={'on','off','low','high'};
%         fprintf('    ')
%         for subIdx=1:length(subsetList);
%             subsetName=subsetList{subIdx};
%             fprintf('%s %s ;', datestr(now), subsetName)
%             
%             for cTypeIdx=1:2
%                 switch cTypeIdx
%                     case 1
%                         cType='pyr';
%                     case 2
%                         cType='inh';
%                     otherwise
%                         continue
%                 end
%                 
%                 frac=zeros(1,nPeriod.(sName));
%                 tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
%                 
%                 for tBinIdx=1:nPeriod.(sName)
%                     temp=mergePeriod(subset.(subsetName),tBorder(tBinIdx+(0:1)));
%                     target=temp{2,2};
%                     tempCnt=zeros(size(spkSubset.(cType)));
%                     for tIdx=1:size(target,1)
%                         tempCntCell=cellfun(@(x) sum(x>target(tIdx,1)&x<target(tIdx,2)),spkSubset.(cType),'UniformOutput',false);
%                         tempCnt=tempCnt+[tempCntCell{:}];
%                     end
%                     dur=sum(diff(target/1e6,1,2));
%                     tnFR(:,tBinIdx)=tempCnt./dur;
%                     frac(tBinIdx)=dur/tBinSize*100;
%                 end
%                 trisecFiringSp.(dName).(subsetName).(cType){sIdx}=tnFR;
%                 trisecFiringSp.(dName).(subsetName).fracTime{sIdx}=frac;
%             end
%         end
%         fprintf('\n');
%     end
%     
%     
%     trisecFiringSp.(dName).param.nBin=nPeriod;
%     trisecFiringSp.(dName).param.madeby=mfilename;
%     
% end


for dIdx=1:length(dList)
    fprintf('\n%s start session %d/%d', datestr(now), dIdx,length(dList))
    
    dName=dList{dIdx};
    spk.pyr={spikes.(dName)([spikes.(dName).quality]==3 & cellfun(@all,{spikes.(dName).isStable})).time};
    spk.inh={spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable})).time};
    cTypeList=fieldnames(spk);
    
    nremTime=behavior.(dName).list(behavior.(dName).list(:,3)==1,1:2);
    
    
%     temp=mergePeriod(onOff.(dName).on,nremTime);
    
%     temp=mergePeriod(onOff.(dName).off,nremTime);
%     subset.off=temp{2,2};
%     subset.on=temp{1,2};
        subset.off=onOff.(dName).off;
    subset.on=onOff.(dName).on;
    
% %     temp=mergePeriod(MA.(dName).time,HLfine.(dName).low);
% %     temp=sortrows([temp{1,2};temp{2,1};temp{2,2}]);
% %     temp=removeTransient(temp,eps,eps,false);    
% %     temp=mergePeriod(temp,nremTime);
% %     subset.low=temp{2,2};
% %     subset.high=temp{1,2};
    
    for sIdx=1:size(behavior.(dName).list,1)
        sName=behavior.(dName).name{behavior.(dName).list(sIdx,3)};
        
        if ~isfield(nPeriod,sName)
            continue
        end
        
        fprintf('\n  %s state %d/%d ', datestr(now), sIdx,size(behavior.(dName).list,1))
        
        %         tBorder=behavior.(dName).list(sIdx,1)+diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName)*(0:nPeriod.(sName));
        tBinSize=diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName);
        tBorder=behavior.(dName).list(sIdx,1):tBinSize:behavior.(dName).list(sIdx,2);
        
        clear spkSubset
        spkSubset.pyr=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.pyr,'UniformOutput',false);
        spkSubset.inh=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.inh,'UniformOutput',false);
        
        subsetList={'on','off'};
        fprintf('    ')
        %         for subIdx=1:length(subsetList);
        %             subsetName=subsetList{subIdx};
        %             fprintf('%s %s ;', datestr(now), subsetName)
        %
        %             for cTypeIdx=1:2
        %                 switch cTypeIdx
        %                     case 1
        %                         cType='pyr';
        %                     case 2
        %                         cType='inh';
        %                     otherwise
        %                         continue
        %                 end
        %
        %                 frac=zeros(1,nPeriod.(sName));
        %                 tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
        %
        %                 for tBinIdx=1:nPeriod.(sName)
        %                     temp=mergePeriod(subset.(subsetName),tBorder(tBinIdx+(0:1)));
        %                     target=temp{2,2};
        %                     tempCnt=zeros(size(spkSubset.(cType)));
        %                     for tIdx=1:size(target,1)
        %                         tempCntCell=cellfun(@(x) sum(x>target(tIdx,1)&x<target(tIdx,2)),spkSubset.(cType),'UniformOutput',false);
        %                         tempCnt=tempCnt+[tempCntCell{:}];
        %                     end
        %                     dur=sum(diff(target/1e6,1,2));
        %                     tnFR(:,tBinIdx)=tempCnt./dur;
        %                     frac(tBinIdx)=dur/tBinSize*100;
        %                 end
        %                 timeNormFRsp.(dName).(subsetName).(cType){sIdx}=tnFR;
        %                 timeNormFRsp.(dName).(subsetName).fracTime{sIdx}=frac;
        %             end
        %         end
        for subIdx=1:length(subsetList)
            subsetName=subsetList{subIdx};
            fprintf('%s %s ;', datestr(now), subsetName)
            target=[];
            nFrac=zeros(1,nPeriod.(sName));
            frac=zeros(1,nPeriod.(sName));
            dur=zeros(1,nPeriod.(sName));
            clear temp
            for tBinIdx=1:nPeriod.(sName)
                temp=subset.(subsetName)(subset.(subsetName)(:,1)<tBorder(tBinIdx+1)&subset.(subsetName)(:,2)>tBorder(tBinIdx),:);
                if isempty(temp)
                    continue
                end
                if(temp(1,1)<tBorder(tBinIdx)); temp(1,1)=tBorder(tBinIdx); end
                if(temp(end,2)>tBorder(tBinIdx+1)); temp(end,2)=tBorder(tBinIdx+1); end
                
                
                nFrac(tBinIdx)=size(temp,1);
                dur(tBinIdx)=sum(diff(temp/1e6,1,2));
                temp=temp';
                target=[target;temp(:)];
            end
            
            for cTypeIdx=1:2
                switch cTypeIdx
                    case 1
                        cType='pyr';
                    case 2
                        cType='inh';
                    otherwise
                        continue
                end
                
                if isempty(spkSubset.(cType))
                    trisecFiringSp.(dName).(subsetName).(cType){sIdx}=[];
                    continue
                end
                
                if isempty(target)
                    trisecFiringSp.(dName).(subsetName).(cType){sIdx}=ones(size(spk.(cType),2),nPeriod.(sName))*nan;
                else
                    cnt=cellfun(@(x) histcounts(x,target),spkSubset.(cType),'uniformoutput',false);
                    cnt=cat(1,cnt{:});
                    cnt=cnt(:,1:2:end);
                    idxBorder=cumsum([0,nFrac]);
                    tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
                    for idx=1:nPeriod.(sName)
                        tnFR(:,idx)=sum(cnt(:,idxBorder(idx)+1:idxBorder(idx+1)),2);
                    end
                    tnFR=tnFR./dur;
                    trisecFiringSp.(dName).(subsetName).(cType){sIdx}=tnFR;
                end
            end
            trisecFiringSp.(dName).(subsetName).fracTime{sIdx}=dur/(tBinSize/1e6)*100;
        end
    end    

    trisecFiringSp.(dName).param.nBin=nPeriod;
    trisecFiringSp.(dName).param.madeby=mfilename;

end

varList={'trisecFiringSp'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end

%% trisecFiring

%%

% for  dIdx=1:length(dList)
%      dName=dList{dIdx};
%     onOff.(dName).off(diff(onOff.(dName).off,1,2)<75e3,:)=[];
% end
% onOff.(dName).off=[];

clear nPeriod
nPeriod.rem=3;
% nPeriod.nrem=3*nPeriod.rem;
nPeriod.nrem=3;
nPeriod.wake=3;

wakeDur=60e6;
wakeNumBin=5;
wakeBinSize=wakeDur/wakeNumBin;
% 
% for dIdx=1:length(dList)
%     fprintf('%s start session %d/%d\n', datestr(now), dIdx,length(dList))
%     
%     dName=dList{dIdx};
%     spk.pyr={spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable})).time};
%     spk.inh={spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable})).time};
%     cTypeList=fieldnames(spk);
%     
%     nremTime=behavior.(dName).list(behavior.(dName).list(:,3)==1,1:2);
%     
%     
%     temp=mergePeriod(onOff.(dName).on,nremTime);
%     subset.on=temp{2,2};
%     
%     temp=mergePeriod(onOff.(dName).off,nremTime);
%     subset.off=temp{2,2};
%     
%     temp=mergePeriod(MA.(dName).time,nremTime.rate);
%     subset.low=temp{2,2};
%     subset.high=temp{1,2};
%     
%     for sIdx=1:size(behavior.(dName).list,1)
%         sName=behavior.(dName).name{behavior.(dName).list(sIdx,3)};
%         
%         if ~isfield(nPeriod,sName)
%             continue
%         end
%         
%         fprintf('  %s state %d/%d \n', datestr(now), sIdx,size(behavior.(dName).list,1))
%         
%         %         tBorder=behavior.(dName).list(sIdx,1)+diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName)*(0:nPeriod.(sName));
%         tBinSize=diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName);
%         tBorder=behavior.(dName).list(sIdx,1):tBinSize:behavior.(dName).list(sIdx,2);
%         
%         clear spkSubset
%         spkSubset.pyr=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.pyr,'UniformOutput',false);
%         spkSubset.inh=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.inh,'UniformOutput',false);
%         
%         subsetList={'on','off','low','high'};
%         fprintf('    ')
%         for subIdx=1:length(subsetList);
%             subsetName=subsetList{subIdx};
%             fprintf('%s %s ;', datestr(now), subsetName)
%             
%             for cTypeIdx=1:2
%                 switch cTypeIdx
%                     case 1
%                         cType='pyr';
%                     case 2
%                         cType='inh';
%                     otherwise
%                         continue
%                 end
%                 
%                 frac=zeros(1,nPeriod.(sName));
%                 tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
%                 
%                 for tBinIdx=1:nPeriod.(sName)
%                     temp=mergePeriod(subset.(subsetName),tBorder(tBinIdx+(0:1)));
%                     target=temp{2,2};
%                     tempCnt=zeros(size(spkSubset.(cType)));
%                     for tIdx=1:size(target,1)
%                         tempCntCell=cellfun(@(x) sum(x>target(tIdx,1)&x<target(tIdx,2)),spkSubset.(cType),'UniformOutput',false);
%                         tempCnt=tempCnt+[tempCntCell{:}];
%                     end
%                     dur=sum(diff(target/1e6,1,2));
%                     tnFR(:,tBinIdx)=tempCnt./dur;
%                     frac(tBinIdx)=dur/tBinSize*100;
%                 end
%                 trisecFiring.(dName).(subsetName).(cType){sIdx}=tnFR;
%                 trisecFiring.(dName).(subsetName).fracTime{sIdx}=frac;
%             end
%         end
%         fprintf('\n');
%     end
%     
%     
%     trisecFiring.(dName).param.nBin=nPeriod;
%     trisecFiring.(dName).param.madeby=mfilename;
%     
% end


for dIdx=1:length(dList)
    fprintf('\n%s start session %d/%d', datestr(now), dIdx,length(dList))
    
    dName=dList{dIdx};
    spk.pyr={spikes.(dName)([spikes.(dName).quality]==3 & cellfun(@all,{spikes.(dName).isStable})).time};
    spk.inh={spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable})).time};
    cTypeList=fieldnames(spk);
    
    nremTime=behavior.(dName).list(behavior.(dName).list(:,3)==1,1:2);
    
    
%     temp=mergePeriod(onOff.(dName).on,nremTime);
    
%     temp=mergePeriod(onOff.(dName).off,nremTime);
%     subset.off=temp{2,2};
%     subset.on=temp{1,2};
        subset.off=onOff.(dName).off;
    subset.on=onOff.(dName).on;
    
% %     temp=mergePeriod(MA.(dName).time,HLfine.(dName).low);
% %     temp=sortrows([temp{1,2};temp{2,1};temp{2,2}]);
% %     temp=removeTransient(temp,eps,eps,false);    
% %     temp=mergePeriod(temp,nremTime);
% %     subset.low=temp{2,2};
% %     subset.high=temp{1,2};
    
    for sIdx=1:size(behavior.(dName).list,1)
%    for sIdx=1:size(behavior.(dName).list,1)-2 %for c3po_160302????
        sName=behavior.(dName).name{behavior.(dName).list(sIdx,3)};
        
        if ~isfield(nPeriod,sName)
            continue
        end
        
        fprintf('\n  %s state %d/%d ', datestr(now), sIdx,size(behavior.(dName).list,1))
        
        %         tBorder=behavior.(dName).list(sIdx,1)+diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName)*(0:nPeriod.(sName));
        tBinSize=diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName);
        tBorder=behavior.(dName).list(sIdx,1):tBinSize:behavior.(dName).list(sIdx,2);
        
        clear spkSubset
        spkSubset.pyr=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.pyr,'UniformOutput',false);
        spkSubset.inh=cellfun(@(x) x(x>tBorder(1)&x<tBorder(end)),spk.inh,'UniformOutput',false);
        
        subsetList={'on'};
        fprintf('    ')
        %         for subIdx=1:length(subsetList);
        %             subsetName=subsetList{subIdx};
        %             fprintf('%s %s ;', datestr(now), subsetName)
        %
        %             for cTypeIdx=1:2
        %                 switch cTypeIdx
        %                     case 1
        %                         cType='pyr';
        %                     case 2
        %                         cType='inh';
        %                     otherwise
        %                         continue
        %                 end
        %
        %                 frac=zeros(1,nPeriod.(sName));
        %                 tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
        %
        %                 for tBinIdx=1:nPeriod.(sName)
        %                     temp=mergePeriod(subset.(subsetName),tBorder(tBinIdx+(0:1)));
        %                     target=temp{2,2};
        %                     tempCnt=zeros(size(spkSubset.(cType)));
        %                     for tIdx=1:size(target,1)
        %                         tempCntCell=cellfun(@(x) sum(x>target(tIdx,1)&x<target(tIdx,2)),spkSubset.(cType),'UniformOutput',false);
        %                         tempCnt=tempCnt+[tempCntCell{:}];
        %                     end
        %                     dur=sum(diff(target/1e6,1,2));
        %                     tnFR(:,tBinIdx)=tempCnt./dur;
        %                     frac(tBinIdx)=dur/tBinSize*100;
        %                 end
        %                 timeNormFRsp.(dName).(subsetName).(cType){sIdx}=tnFR;
        %                 timeNormFRsp.(dName).(subsetName).fracTime{sIdx}=frac;
        %             end
        %         en
            target=[];
            nFrac=zeros(1,nPeriod.(sName));
            frac=zeros(1,nPeriod.(sName));
            dur=zeros(1,nPeriod.(sName));
            clear temp
            for tBinIdx=1:nPeriod.(sName)
                temp=behavior.(dName).list(behavior.(dName).list(:,1)<tBorder(tBinIdx+1) & behavior.(dName).list(:,2)>tBorder(tBinIdx),1:2);
                if isempty(temp)
                    continue
                end
                if(temp(1,1)<tBorder(tBinIdx)); temp(1,1)=tBorder(tBinIdx); end
                if(temp(end,2)>tBorder(tBinIdx+1)); temp(end,2)=tBorder(tBinIdx+1); end
                
                
                nFrac(tBinIdx)=size(temp,1);
                dur(tBinIdx)=sum(diff(temp/1e6,1,2));
                temp=temp';
                target=[target;temp(:)];
            end
            
            for cTypeIdx=1:2
                switch cTypeIdx
                    case 1
                        cType='pyr';
                    case 2
                        cType='inh';
                    otherwise
                        continue
                end
                
                if isempty(spkSubset.(cType))
                    trisecFiring.(dName).(cType).rate{sIdx}=[];
                    continue
                end
                
                if isempty(target)
                    trisecFiring.(dName).(cType).rate{sIdx}=ones(size(spk.(cType),2),nPeriod.(sName))*nan;
                else
                    cnt=cellfun(@(x) histcounts(x,target),spkSubset.(cType),'uniformoutput',false);
                    cnt=cat(1,cnt{:});
                    cnt=cnt(:,1:2:end);
                    idxBorder=cumsum([0,nFrac]);
                    tnFR=zeros(size(spk.(cType),2),nPeriod.(sName));
                    for idx=1:nPeriod.(sName)
                        tnFR(:,idx)=sum(cnt(:,idxBorder(idx)+1:idxBorder(idx+1)),2);
                    end
                    tnFR=tnFR./dur;
                    trisecFiring.(dName).(cType).rate{sIdx}=tnFR;
                end
            end
            trisecFiring.(dName).fracTime{sIdx}=dur/(tBinSize/1e6)*100;
    end    

    trisecFiring.(dName).param.nBin=nPeriod;
    trisecFiring.(dName).param.madeby=mfilename;

end

varList={'trisecFiring'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end

