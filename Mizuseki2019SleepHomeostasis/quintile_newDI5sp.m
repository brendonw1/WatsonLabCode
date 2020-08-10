% Creating Deflection index data and producing figures;
% Choose sortby='including' to include off state spikes in NREM. 
% Chosse sortby='excluding' to exclude off state spikes in NREM.
% For more info go to trisecFiringFunc.m.
% Main scripts written by Hiroyuki Miyawaki, modified by Tangyu Liu, 2020
%%
clear
sortby='including'; %include off state
% sortby='excluding'; %exclude off state
nDiv=5; %number of quintiles
nShuffle=2000; % number of shuffling
%%
baseDir=[pwd filesep];
coreName='sleep';
varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HL'
    ...'HLwavelet'
    ...'MA'
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'firing'
    ...'eventRate'
    'stableSleep'
    ...'stableWake'
    'stateChange'
    'trisecFiring'
    'trisecFiringSp'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    ...'pairCorr'
    ...'pairCorrHIGH'
    'timeNormFR'
    ...'timeNormFRsp'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end

% HL=HLfine;
dList=fieldnames(basics);

%%

%load([baseDir coreName '-' 'newDI5sp' '.mat'])
stateList={'nrem','rem','rem2nrem','nrem2rem','nrem2rem2nrem','rem2nrem2rem'};
funcCI=@(x) diff(x,1,2)./sum(x,2);

subsateList={'on'};


wakeString='quiet';

minDuration.nrem=150;
minDuration.rem=100;
minDuration.rem2nrem=[100,150];
minDuration.nrem2rem=[150,100];
minDuration.nrem2rem2nrem=[150,100,150];
minDuration.rem2nrem2rem=[100,150,100];



for subIdx=1:length(subsateList);
substate=subsateList{subIdx};
for stateIdx=1:length(stateList)
    state=stateList{stateIdx};
    display([datestr(now) ' started ' state])
    clear fr frFull

    stateNames=strsplit(state,'2');
    saveStateName=strrep(state,wakeString,'wake');

    % getting FR
    for dIdx=1:length(dList)
        dName=dList{dIdx};

        targetIdx=stateChange.(dName).(state);

        isLong=[];  %%epoch longer than requirement
        for tIdx=1:size(targetIdx,1)
            for epochIdx=1:size(targetIdx,2)
                isLong(tIdx,epochIdx)=diff(behavior.(dName).list(targetIdx(tIdx,epochIdx),1:2),1,2)>minDuration.(state)(epochIdx)*1e6;
            end
        end
        targetIdx=targetIdx(all(isLong,2),:);

        toUse=false(size(targetIdx,1),1);
        isFirst=false(size(targetIdx,1),1);
        isLast=false(size(targetIdx,1),1);
        for slpIdx=1:size(stableSleep.(dName).time,1)
            temp=false(size(targetIdx));
             for n=1:length(stateNames)
                temp(ismember(targetIdx(:,n),stableSleep.(dName).(stateNames{n}){slpIdx}),n)=true;
             end
             temp=all(temp,2);
             toUse(temp)=true;
             isFirst(find(temp,1,'first'))=true;
             isLast(find(temp,1,'last'))=true;
        end

        toUse(isFirst&isLast)=false;

        targetIdx(~toUse,:)=[];
        isFirst(~toUse)=[];
        isLast(~toUse)=[];

        fr(dIdx).isFirst.pyr=isFirst;
        fr(dIdx).isLast.pyr=isLast;
        fr(dIdx).isFirst.inh=isFirst;
        fr(dIdx).isLast.inh=isLast;

        for n=1:length(stateNames)
            if strcmpi(stateNames{n},wakeString)
                targetIdx(diff(behavior.(dName).list(targetIdx(:,n),1:2),1,2)<60e6,:)=[];
            end
        end

        for cType={'pyr','inh'}
            fr(dIdx).(cType{1})=double.empty(0,0,0);
            frFull(dIdx).(cType{1})=double.empty(0,0,0);

            if isempty(trisecFiring.(dName).(cType{1}).rate{1})
                continue
            end

            switch length(stateNames)
                case 1 %nrem / rem
                    if strcmpi(stateNames{1},'nrem')
                        temp1=cat(3,trisecFiringSp.(dName).(substate).(cType{1}){targetIdx(:,1)});
                    else
                        temp1=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                    end
                    temp1Full=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                    if isempty(temp1)
                        continue
                    end
                    fr(dIdx).(cType{1})=temp1(:,[1,end],:);
                    frFull(dIdx).(cType{1})=temp1Full(:,[1,end],:);
                case 2 %'rem2nrem','nrem2rem'
                    if strcmpi(stateNames{1},'nrem')
                        temp1=cat(3,trisecFiringSp.(dName).(substate).(cType{1}){targetIdx(:,1)});
                    else
                        temp1=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                    end
                    temp1Full=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                    if isempty(temp1)
                        continue
                    end
                    temp1=temp1(:,end,:);
                    temp1Full=temp1(:,end,:);
                    if strcmpi(stateNames{2},'nrem')
                        temp2=cat(3,trisecFiringSp.(dName).(substate).(cType{1}){targetIdx(:,2)});
                    else
                        temp2=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,2)});
                    end
                    temp2Full=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,2)});
                    if isempty(temp2)
                        continue
                    end
                    temp2=temp2(:,1,:);
                    temp2Full=temp2Full(:,1,:);
                    fr(dIdx).(cType{1})=cat(2,temp1,temp2);
                    frFull(dIdx).(cType{1})=cat(2,temp1Full,temp2Full);
                case 3 %'nrem2rem2nrem','rem2nrem2rem'
                    if strcmpi(stateNames{1},'nrem')
                        temp1=cat(3,trisecFiringSp.(dName).(substate).(cType{1}){targetIdx(:,1)});
                        if isempty(temp1)
                            continue
                        end
                        frac=repmat(cat(3,trisecFiringSp.(dName).(substate).fracTime{targetIdx(:,1)}),size(temp1,1),1,1)./ ...
                        repmat(sum(cat(3,trisecFiringSp.(dName).(substate).fracTime{targetIdx(:,1)}),2),size(temp1,1),3,1);
                        temp1=sum(temp1.*frac,2);
                    else
                        temp1=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                        if isempty(temp1)
                            continue
                        end
                        temp1=mean(temp1,2);
                    end
                    temp1Full=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,1)});
                    temp1Full=mean(temp1Full,2);

                    if strcmpi(stateNames{end},'nrem')
                        temp2=cat(3,trisecFiringSp.(dName).(substate).(cType{1}){targetIdx(:,end)});
                        if isempty(temp2)
                            continue
                        end
                        frac=repmat(cat(3,trisecFiringSp.(dName).(substate).fracTime{targetIdx(:,end)}),size(temp1,1),1,1)./ ...
                        repmat(sum(cat(3,trisecFiringSp.(dName).(substate).fracTime{targetIdx(:,end)}),2),size(temp1,1),3,1);
                        temp2=sum(temp2.*frac,2);
                    else
                        temp2=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,end)});
                        if isempty(temp2)
                            continue
                        end
                        temp2=mean(temp2,2);
                    end
                    temp2Full=cat(3,trisecFiring.(dName).(cType{1}).rate{targetIdx(:,end)});
                    temp2Full=mean(temp2Full,2);

                    fr(dIdx).(cType{1})=cat(2,temp1,temp2);
                    frFull(dIdx).(cType{1})=cat(2,temp1Full,temp2Full);
                otherwise
                    continue
            end

             if strcmpi(cType{1},'pyr')
                 zeroRich=squeeze(any(sum(fr(dIdx).(cType{1})==0)/size(fr(dIdx).(cType{1}),1)>1/nDiv,2));

                 while any(zeroRich)
                     zIdx=find(zeroRich,1,'first');

                     if fr(dIdx).isFirst.(cType{1})(zIdx)
                         if fr(dIdx).isLast.(cType{1})(zIdx+1)
                             fr(dIdx).isFirst.(cType{1})([zIdx,zIdx+1])=[];
                             fr(dIdx).isLast.(cType{1})([zIdx,zIdx+1])=[];
                             fr(dIdx).(cType{1})(:,:,[zIdx,zIdx+1])=[];
                             frFull(dIdx).(cType{1})(:,:,[zIdx,zIdx+1])=[];
                         else
                             fr(dIdx).isFirst.(cType{1})(zIdx+1)=true;
                             fr(dIdx).isFirst.(cType{1})(zIdx)=[];
                             fr(dIdx).isLast.(cType{1})(zIdx)=[];
                             fr(dIdx).(cType{1})(:,:,zIdx)=[];
                             frFull(dIdx).(cType{1})(:,:,zIdx)=[];
                         end
                     elseif fr(dIdx).isLast.(cType{1})(zIdx)
                         if fr(dIdx).isFirst.(cType{1})(zIdx-1)
                             fr(dIdx).isFirst.(cType{1})([zIdx-1,zIdx])=[];
                             fr(dIdx).isLast.(cType{1})([zIdx-1,zIdx])=[];
                             fr(dIdx).(cType{1})(:,:,[zIdx-1,zIdx])=[];
                             frFull(dIdx).(cType{1})(:,:,[zIdx-1,zIdx])=[];
                         else
                             fr(dIdx).isLast.(cType{1})(zIdx-1)=true;
                             fr(dIdx).isFirst.(cType{1})(zIdx)=[];
                             fr(dIdx).isLast.(cType{1})(zIdx)=[];
                             fr(dIdx).(cType{1})(:,:,zIdx)=[];
                             frFull(dIdx).(cType{1})(:,:,zIdx)=[];
                         end
                     else
                         fr(dIdx).isFirst.(cType{1})(zIdx)=[];
                         fr(dIdx).isLast.(cType{1})(zIdx)=[];
                         fr(dIdx).(cType{1})(:,:,zIdx)=[];
                         frFull(dIdx).(cType{1})(:,:,zIdx)=[];
                     end
                     zeroRich=squeeze(any(sum(fr(dIdx).(cType{1})==0)/size(fr(dIdx).(cType{1}),1)>=1/nDiv,2));
                 end
             end

        end
    end

    % getting CI on real and shuffled data
    shuffleMean=zeros(nShuffle,nDiv+1);
    for shIdx=1:nShuffle+1
        if mod(shIdx,100)==0
            %show progress
            display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
        end

        clear temp
        for n=1:nDiv+1
            temp{n}=[];
        end
        for dIdx=1:length(dList)
            for cType={'pyr','inh'}
                if size(fr(dIdx).(cType{1}),3)<2
                    continue
                end

            %pick previous or next index of transition randomly
            sesIdx=(randi(2,size(fr(dIdx).(cType{1}),3),1)*2-3);
%             sesIdx(1)=1;
%             sesIdx(end)=-1;
            sesIdx( fr(dIdx).isFirst.(cType{1}))=1;
            sesIdx( fr(dIdx).isLast.(cType{1}))=-1;
            sesIdx=(1:size(fr(dIdx).(cType{1}),3))'+sesIdx;


                % first run with real data
                if shIdx==1
                    target=fr(dIdx).(cType{1});
                    if strcmpi(sortby,'excluding')
                        sortTarget=fr(dIdx).(cType{1});
                    elseif strcmpi(sortby,'including')
                        sortTarget=frFull(dIdx).(cType{1});
                    else
                        error('sorting option must be excluding or including')
                    end
                else
                    %shuffle with adjacent
                    target=cat(2,fr(dIdx).(cType{1})(:,1,:),fr(dIdx).(cType{1})(:,1,sesIdx));
                    
                    if strcmpi(sortby,'excluding')
                        sortTarget=cat(2,fr(dIdx).(cType{1})(:,1,:),fr(dIdx).(cType{1})(:,1,sesIdx));
                    elseif strcmpi(sortby,'including')
                        sortTarget=cat(2,frFull(dIdx).(cType{1})(:,1,:),fr(dIdx).(cType{1})(:,1,sesIdx));
                    else
                        error('sorting option must be excluding or including')
                    end
                    
                    %flip randomly
                    cIdx=randi(2,size(target))-1;
                    cIdx(:,2,:)=1-cIdx(:,1,:);
                    cIdx=(1:size(target,1))'+size(target,1)*cIdx;
                    cIdx=reshape((0:size(target,3)-1)*size(target,1)*size(target,2),1,1,[])+cIdx;
                    target=target(cIdx);
                    sortTarget=sortTarget(cIdx);
                end

                if strcmpi(cType{1},'pyr')
                    %ordering within each epoch
                    [~,ranking]=sort(sortTarget);
                    offset=repmat(...
                                (0:size(ranking,2)-1)*size(target,1),...
                                size(target,1),1,size(target,3)...
                            )+...
                            permute(...
                                repmat(...
                                    (0:size(target,3)-1)*size(target,1)*size(target,2),...
                                    size(target,1),1,size(target,2)),...
                                [1,3,2]...
                            );
                    ranking(ranking+offset)=...
                        repmat((1:size(target,1))',1,size(target,2),size(target,3));
                    ranking=ceil(ranking/size(target,1)*nDiv);

                    for n=1:nDiv
                        meanFR=zeros(size(ranking,3),2);
                        for targetIdx=1:size(ranking,3)
                            meanFR(targetIdx,:)=mean(target(ranking(:,1,targetIdx)==n,:,targetIdx),1);
                        end
                        if size(meanFR,2)==1
                            meanFR=meanFR';
                        end
                        temp{n}=[temp{n};funcCI(meanFR)];
                    end
                else
                    % no ordering for inh
                    meanFR=squeeze(mean(target,1))';
                    if size(meanFR,2)==1
                        meanFR=meanFR';
                    end
                    temp{nDiv+1}=[temp{nDiv+1};funcCI(meanFR)];
                end
            end
        end

        if shIdx==1
            newCI5sp.(substate).(saveStateName).value=temp;
            newCI5sp.(substate).(saveStateName).mean=cellfun(@nanmean,temp);
            newCI5sp.(substate).(saveStateName).std=cellfun(@nanstd,temp);
%            newCI5sp.(substate).(saveStateName).ste=cellfun(@nanste,temp);
            newCI5sp.(substate).(saveStateName).shuffle=[];
            newCI5sp.(substate).(saveStateName).shuffleMean=[];
            newCI5sp.(substate).(saveStateName).confInt=[];
            newCI5sp.(substate).(saveStateName).p=[];
            newCI5sp.(substate).(saveStateName).param.nCell=cellfun(@(x) sum(~isnan(x)),temp);
            newCI5sp.(substate).(saveStateName).param.nState.pyr=sum(cellfun(@(x) size(x,3), {fr(:).pyr}) .* arrayfun(@(x) size(x.pyr,3)>1,fr));
            newCI5sp.(substate).(saveStateName).param.nState.inh=sum(cellfun(@(x) size(x,3), {fr(:).inh}) .* arrayfun(@(x) size(x.inh,3)>1,fr));
            newCI5sp.(substate).(saveStateName).param.nSession.pyr=sum(arrayfun(@(x) size(x.pyr,3)>1,fr));
            newCI5sp.(substate).(saveStateName).param.nSession.inh=sum(arrayfun(@(x) size(x.inh,3)>1,fr));
            newCI5sp.(substate).(saveStateName).param.nShuffle=nShuffle;
            newCI5sp.(substate).(saveStateName).param.nDiv=nDiv;
            newCI5sp.(substate).(saveStateName).param.minDuration=minDuration.(saveStateName);
            newCI5sp.(substate).(saveStateName).param.sortby=sortby;
            newCI5sp.(substate).(saveStateName).param.madeby=mfilename;
        else
            shuffleMean(shIdx-1,:)=cellfun(@nanmean,temp);
        end
    end

    %sorting shuffled data
    shuffleMean=sort(shuffleMean,1);
    newCI5sp.(substate).(saveStateName).shuffle=shuffleMean;
    newCI5sp.(substate).(saveStateName).shuffleMean=mean(shuffleMean,1);
    newCI5sp.(substate).(saveStateName).confInt=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);

    %get p-values
    p=ones(1,nDiv+1);
    for qIdx=1:nDiv+1
        n=find(shuffleMean(:,qIdx)<newCI5sp.(substate).(saveStateName).mean(qIdx),1,'last');
        if isempty(n); n=0;
        elseif n>size(shuffleMean,1)/2; n=size(shuffleMean,1)-n;end
        p(qIdx)=n/size(shuffleMean,1)*2;
    end
    newCI5sp.(substate).(saveStateName).p=p;

    newDI5sp.(substate).(saveStateName).mean=newCI5sp.(substate).(saveStateName).mean-newCI5sp.(substate).(saveStateName).shuffleMean;
    newDI5sp.(substate).(saveStateName).std=newCI5sp.(substate).(saveStateName).std;
    %newDI5sp.(substate).(saveStateName).ste=newCI5sp.(substate).(saveStateName).ste;

    newDI5sp.(substate).(saveStateName).shuffleMean=zeros(1,nDiv+1);
    newDI5sp.(substate).(saveStateName).confInt=newCI5sp.(substate).(saveStateName).confInt-newCI5sp.(substate).(saveStateName).shuffleMean;
    newDI5sp.(substate).(saveStateName).p=newCI5sp.(substate).(saveStateName).p;
    newDI5sp.(substate).(saveStateName).param=newCI5sp.(substate).(saveStateName).param;

    %pool FRs across epochs
    temp=arrayfun(@(x) reshape(permute(x.pyr,[1,3,2]),[],2),fr,'UniformOutput',false);
    temp=cat(1,temp{:});
    newFR5sp.(substate).(saveStateName).pyr=temp(any(temp>0,2),:);

    temp=arrayfun(@(x) reshape(permute(x.inh,[1,3,2]),[],2),fr,'UniformOutput',false);
    temp=cat(1,temp{:});
    newFR5sp.(substate).(saveStateName).inh=temp(any(temp>0,2),:);

    newFR5sp.(substate).(saveStateName).param.nCell=[size(newFR5sp.(substate).(saveStateName).pyr,1),...
                                        size(newFR5sp.(substate).(saveStateName).inh,1)];
    newFR5sp.(substate).(saveStateName).param.nState.pyr=sum(cellfun(@(x) size(x,3), {fr(:).pyr}) .* arrayfun(@(x) size(x.pyr,3)>1,fr));
    newFR5sp.(substate).(saveStateName).param.nState.inh=sum(cellfun(@(x) size(x,3), {fr(:).inh}) .* arrayfun(@(x) size(x.inh,3)>1,fr));
    newFR5sp.(substate).(saveStateName).param.nSession.pyr=sum(arrayfun(@(x) size(x.pyr,3)>1,fr));
    newFR5sp.(substate).(saveStateName).param.nSession.inh=sum(arrayfun(@(x) size(x.inh,3)>1,fr));
end
end
%%
save([baseDir coreName '-' 'newDI5sp' '.mat'],'newDI5sp','newCI5sp','newFR5sp','-v7.3')
%%
load([baseDir coreName '-' 'newDI5sp' '.mat'])


nShuffle=2000;
nDiv=5;


funcCI=@(x) diff(x,1,2)./sum(x,2);

minDuration.WakeSleepWake=[];
minDuration.FLnrem=150;
minDuration.wake2nrem=150;
minDuration.nrem2wake=150;
minDuration.rem2wake=100;

subsateList={'on'};


wakeString='quiet';

sortby='including';
% sortby='excluding';


for subIdx=1:length(subsateList);
    substate=subsateList{subIdx};
    for stateIdx=1:6
        clear fr frFull partner partnerFull
        if stateIdx==1
            continue
            %         saveStateName='WakeSleepWake';
            %         for dIdx=1:length(dList)
            %             dName=dList{dIdx};
            %
            %             fr(dIdx).pyr=double.empty(0,0,0);
            %             fr(dIdx).inh=double.empty(0,0,0);
            %             partner(dIdx).fr.pyr=double.empty(0,0,0);
            %             partner(dIdx).fr.inh=double.empty(0,0,0);
            %             partner(dIdx).cnt.pyr=[];
            %             partner(dIdx).cnt.inh=[];
            %
            %             spk.pyr=spikes.(dName)([spikes.(dName).quality]<4&cellfun(@all,{spikes.(dName).isStable}));
            %             spk.inh=spikes.(dName)([spikes.(dName).quality]==8&cellfun(@all,{spikes.(dName).isStable}));
            %
            %             for sIdx=1:size(stableSleep.(dName).time,1);
            %                 idx=[stableSleep.(dName).nrem{sIdx};
            %                     stableSleep.(dName).rem{sIdx}];
            %
            %                 bef=min(idx)-1;
            %                 aft=max(idx)+1;
            %
            %                 lastSlp=find(behavior.(dName).list(1:bef,3)<3,1,'last');
            %                 if isempty(lastSlp); lastSlp=0; end
            %
            %                 onset=max([behavior.(dName).list(lastSlp+1,1),behavior.(dName).list(bef,2)-600e6]);
            %                 tBin=fliplr((behavior.(dName).list(bef,2)-30e6):-60e6:(onset-30e6));
            %
            %                 if length(tBin)<3
            %                     continue
            %                 end
            %                 cnt=cellfun(@(x) hist(x,tBin),{spk.pyr.time},'UniformOutput',false);
            %                 cnt=cat(1,cnt{:});
            %                 wFR.pyr=cnt(:,2:end-1)/60;
            %
            %                 cnt=cellfun(@(x) hist(x,tBin),{spk.inh.time},'UniformOutput',false);
            %                 cnt=cat(1,cnt{:});
            %                 wFR.inh=cnt(:,2:end-1)/60;
            %
            %                 if bef<1 || aft>size(timeNormFR.(dName).offset.pyr,2)
            %                     continue
            %                 end
            %
            %                 if size(timeNormFR.(dName).offset.pyr{bef},2)==5 &&...
            %                         size(timeNormFR.(dName).onset.pyr{aft},2)==5 &&...
            %                         size(timeNormFR.(dName).offset.pyr{bef},1)>0
            %                     fr(dIdx).pyr(:,:,end+1)=[mean(timeNormFR.(dName).offset.pyr{bef},2),...
            %                         mean(timeNormFR.(dName).onset.pyr{aft},2)];
            %
            %                     slpIdx=size(fr(dIdx).pyr,3);
            %                     for pIdx=1:size(wFR.pyr,2)
            %                         partner(dIdx).fr.pyr(:,pIdx,slpIdx)=wFR.pyr(:,pIdx);
            %                     end
            %                     partner(dIdx).cnt.pyr(slpIdx)=size(wFR.pyr,2);
            %
            %                 end
            %
            %                 if size(timeNormFR.(dName).offset.inh{bef},2)==5 &&...
            %                         size(timeNormFR.(dName).onset.inh{aft},2)==5 && ...
            %                         size(timeNormFR.(dName).offset.inh{bef},1)>0
            %                     fr(dIdx).inh(:,:,end+1)=[mean(timeNormFR.(dName).offset.inh{bef},2),...
            %                         mean(timeNormFR.(dName).onset.inh{aft},2)];
            %
            %                     slpIdx=size(fr(dIdx).inh,3);
            %                     for pIdx=1:size(wFR.inh,2)
            %                         partner(dIdx).fr.inh(:,pIdx,slpIdx)=wFR.inh(:,pIdx);
            %                     end
            %                     partner(dIdx).cnt.inh(slpIdx)=size(wFR.inh,2);
            %
            %                 end
            %             end
            %         end
        elseif stateIdx==2
            saveStateName='FLnrem'; %%first last nrem
            for dIdx=1:length(dList)
                dName=dList{dIdx};
                
                fr(dIdx).pyr=double.empty(0,0,0);
                fr(dIdx).inh=double.empty(0,0,0);
                partner(dIdx).fr.pyr=double.empty(0,0,0);
                partner(dIdx).fr.inh=double.empty(0,0,0);
                partner(dIdx).cnt.pyr=[];
                partner(dIdx).cnt.inh=[];
                
                frFull(dIdx).pyr=double.empty(0,0,0);
                frFull(dIdx).inh=double.empty(0,0,0);
                partnerFull(dIdx).fr.pyr=double.empty(0,0,0);
                partnerFull(dIdx).fr.inh=double.empty(0,0,0);

                for sIdx=1:size(stableSleep.(dName).time,1);
                    
                    dur=diff(behavior.(dName).list(stableSleep.(dName).nrem{sIdx},1:2),1,2);
                    dur=find(dur>minDuration.FLnrem*1e6);
                    
                    if length(dur)<3
                        continue
                    end
                    
                    bef=stableSleep.(dName).nrem{sIdx}(dur(1));
                    aft=stableSleep.(dName).nrem{sIdx}(dur(end));
                    %                 if bef==aft
                    %                     continue
                    %                 end
                    partnerIdx=stableSleep.(dName).nrem{sIdx}(dur(2:end-1));
                    
                    if size(timeNormFR.(dName).offset.pyr{bef},1)>0
                        
                        fr(dIdx).pyr(:,:,end+1)=[...
                            sum(trisecFiringSp.(dName).(substate).pyr{bef} .* trisecFiringSp.(dName).(substate).fracTime{bef}/sum(trisecFiringSp.(dName).(substate).fracTime{bef}),2),...
                            sum(trisecFiringSp.(dName).(substate).pyr{aft} .* trisecFiringSp.(dName).(substate).fracTime{aft}/sum(trisecFiringSp.(dName).(substate).fracTime{aft}),2)...
                            ];
                        
                        frFull(dIdx).pyr(:,:,end+1)=[...
                            mean(trisecFiring.(dName).pyr.rate{bef},2),...
                            mean(trisecFiring.(dName).pyr.rate{aft},2)...
                            ];
                        
                        slpIdx=size(fr(dIdx).pyr,3);
                        for pIdx=1:length(partnerIdx)
                            partner(dIdx).fr.pyr(:,pIdx,slpIdx)=...
                                sum(trisecFiringSp.(dName).(substate).pyr{partnerIdx(pIdx)} .* trisecFiringSp.(dName).(substate).fracTime{partnerIdx(pIdx)}/sum(trisecFiringSp.(dName).(substate).fracTime{partnerIdx(pIdx)}),2);
                            partnerFull(dIdx).fr.pyr(:,pIdx,slpIdx)=...
                                mean(trisecFiring.(dName).pyr.rate{partnerIdx(pIdx)},2);
                            
                        end
                        partner(dIdx).cnt.pyr(slpIdx)=length(partnerIdx);
                    end
                    
                    if size(timeNormFR.(dName).offset.inh{bef},1)>0
                        %                     fr(dIdx).inh(:,:,end+1)=[trisecFiring.(dName).inh.rate{bef}(:,1),...
                        %                         trisecFiring.(dName).inh.rate{aft}(:,end)];
                        
                        fr(dIdx).inh(:,:,end+1)=[...
                            sum(trisecFiringSp.(dName).(substate).inh{bef} .* trisecFiringSp.(dName).(substate).fracTime{bef}/sum(trisecFiringSp.(dName).(substate).fracTime{bef}),2),...
                            sum(trisecFiringSp.(dName).(substate).inh{aft} .* trisecFiringSp.(dName).(substate).fracTime{aft}/sum(trisecFiringSp.(dName).(substate).fracTime{aft}),2)...
                            ];
                        frFull(dIdx).inh(:,:,end+1)=[...
                            mean(trisecFiring.(dName).inh.rate{bef},2),...
                            mean(trisecFiring.(dName).inh.rate{aft},2)...
                            ];
                        
                        slpIdx=size(fr(dIdx).inh,3);
                        for pIdx=1:length(partnerIdx)
                            partner(dIdx).fr.inh(:,pIdx,slpIdx)=...
                                sum(trisecFiringSp.(dName).(substate).inh{partnerIdx(pIdx)} .* trisecFiringSp.(dName).(substate).fracTime{partnerIdx(pIdx)}/sum(trisecFiringSp.(dName).(substate).fracTime{partnerIdx(pIdx)}),2);
                            partnerFull(dIdx).fr.inh(:,pIdx,slpIdx)=...
                                mean(trisecFiring.(dName).inh.rate{partnerIdx(pIdx)},2);
                            
                        end
                        partner(dIdx).cnt.inh(slpIdx)=length(partnerIdx);
                    end
                end
            end
        elseif stateIdx==3
            continue
            %         saveStateName='FLpacket';
            %         for dIdx=1:length(dList)
            %             dName=dList{dIdx};
            %             temp=mergePeriod(...,
            %                 behavior.(dName).list(behavior.(dName).list(:,3)==1,1:2),...
            %                 MA.(dName).time);
            %             packets=temp{2,1};
            %             packets(diff(packets,1,2)<10e6,:)=[];
            %
            %             spk.pyr=spikes.(dName)([spikes.(dName).quality]<4&cellfun(@all,{spikes.(dName).isStable}));
            %             spk.inh=spikes.(dName)([spikes.(dName).quality]==8&cellfun(@all,{spikes.(dName).isStable}));
            %
            %             fr(dIdx).pyr=double.empty(0,0,0);
            %             fr(dIdx).inh=double.empty(0,0,0);
            %             partner(dIdx).fr.pyr=double.empty(0,0,0);
            %             partner(dIdx).fr.inh=double.empty(0,0,0);
            %             partner(dIdx).cnt=[];
            %
            %             for sIdx=1:size(stableSleep.(dName).time,1)
            %
            % %                 idx(1)=find(packets(:,1)>=stableSleep.(dName).time(sIdx,1),1,'first');
            % %                 idx(2)=find(packets(:,2)<=stableSleep.(dName).time(sIdx,2),1,'last');
            %
            %                 idxList=find(packets(:,1)>=stableSleep.(dName).time(sIdx,1)&packets(:,2)<=stableSleep.(dName).time(sIdx,2));
            %
            %
            %                 for cTypeIdx=1:2
            %                     if cTypeIdx==1
            %                         cType='pyr';
            %                     elseif cTypeIdx==2
            %                         cType='inh';
            %                     else
            %                         continue
            %                     end
            %                     if isempty(spk.(cType))
            %                         continue
            %                     end
            %
            %                     temp=zeros(length(spk.(cType)),length(idxList));
            %                     for cIdx=1:length(spk.(cType))
            %                         for n=1:length(idxList)
            %                             temp(cIdx,n)=sum((spk.(cType)(cIdx).time>packets(idxList(n),1)& spk.(cType)(cIdx).time<packets(idxList(n),2)));
            %                         end
            %                     end
            %                     pFR=temp./diff(packets(idxList,:)/1e6,1,2)';
            %                     fr(dIdx).(cType)(:,:,end+1)=pFR(:,[1,end]);
            %                     slpIdx=size(fr(dIdx).pyr,3);
            %
            %                     for pIdx=1:size(pFR,2)-1
            %                         partner(dIdx).fr.(cType)(:,pIdx,slpIdx)=pFR(:,pIdx+1);
            %                     end
            %                     if strcmpi(cType,'pyr')
            %                         partner(dIdx).cnt(slpIdx)=size(pFR,2)-1;
            %                     end
            %                 end
            %             end
            %         end
        elseif stateIdx==4
            saveStateName='wake2nrem';
            
            for dIdx=1:length(dList)
                fr(dIdx).pyr=double.empty(0,0,0);
                fr(dIdx).inh=double.empty(0,0,0);
                partner(dIdx).fr.pyr=double.empty(0,0,0);
                partner(dIdx).fr.inh=double.empty(0,0,0);
                partner(dIdx).cnt.pyr=[];
                partner(dIdx).cnt.inh=[];
                
                frFull(dIdx).pyr=double.empty(0,0,0);
                frFull(dIdx).inh=double.empty(0,0,0);
                partnerFull(dIdx).fr.pyr=double.empty(0,0,0);
                partnerFull(dIdx).fr.inh=double.empty(0,0,0);

                dName=dList{dIdx};
                
                spk.pyr=spikes.(dName)([spikes.(dName).quality]==3&cellfun(@all,{spikes.(dName).isStable}));
                spk.inh=spikes.(dName)([spikes.(dName).quality]==8&cellfun(@all,{spikes.(dName).isStable}));
                
                targetIdx=stateChange.(dName).quiet2nrem;
                for pIdx=1:size(targetIdx,1)
                    bef=targetIdx(pIdx,1);
                    aft=targetIdx(pIdx,2);
                    
                    if diff(behavior.(dName).list(aft,1:2))<minDuration.(saveStateName)*1e6
                        continue
                    end
                    
                    lastSlp=find(behavior.(dName).list(1:bef,3)<3,1,'last');
                    if isempty(lastSlp); lastSlp=0; end
                    
                    onset=max([behavior.(dName).list(lastSlp+1,1),behavior.(dName).list(bef,2)-600e6]);
                    tBin=fliplr((behavior.(dName).list(bef,2)-30e6):-60e6:(onset-30e6));
                    
                    if length(tBin)<3
                        continue
                    end
                    cnt=cellfun(@(x) hist(x,tBin),{spk.pyr.time},'UniformOutput',false);
                    cnt=cat(1,cnt{:});
                    wFR.pyr=cnt(:,2:end-1)/60;
                    
                    cnt=cellfun(@(x) hist(x,tBin),{spk.inh.time},'UniformOutput',false);
                    cnt=cat(1,cnt{:});
                    wFR.inh=cnt(:,2:end-1)/60;
                    
                    if size(timeNormFR.(dName).offset.pyr{bef},2)==5 &&...
                            size(timeNormFR.(dName).offset.pyr{bef},1)>0
                        fr(dIdx).pyr(:,:,end+1)=[mean(timeNormFR.(dName).offset.pyr{bef},2),...
                            trisecFiringSp.(dName).(substate).pyr{aft}(:,1)];
                        frFull(dIdx).pyr(:,:,end+1)=[mean(timeNormFR.(dName).offset.pyr{bef},2),...
                            trisecFiring.(dName).pyr.rate{aft}(:,1)];
                        
                        slpIdx=size(fr(dIdx).pyr,3);
                        for pIdx=1:size(wFR.pyr,2)
                            partner(dIdx).fr.pyr(:,pIdx,slpIdx)=wFR.pyr(:,pIdx);
                            partnerFull(dIdx).fr.pyr(:,pIdx,slpIdx)=wFR.pyr(:,pIdx);
                        end
                        partner(dIdx).cnt.pyr(slpIdx)=size(wFR.pyr,2);
                    end
                    
                    if size(timeNormFR.(dName).offset.inh{bef},2)==5 &&...
                            size(timeNormFR.(dName).offset.inh{bef},1)>0
                        fr(dIdx).inh(:,:,end+1)=[mean(timeNormFR.(dName).offset.inh{bef},2),...
                            trisecFiringSp.(dName).(substate).inh{aft}(:,1)];
                        frFull(dIdx).inh(:,:,end+1)=[mean(timeNormFR.(dName).offset.inh{bef},2),...
                            trisecFiring.(dName).inh.rate{aft}(:,1)];
                        
                        slpIdx=size(fr(dIdx).inh,3);
                        for pIdx=1:size(wFR.inh,2)
                            partner(dIdx).fr.inh(:,pIdx,slpIdx)=wFR.inh(:,pIdx);
                            partnerFull(dIdx).fr.inh(:,pIdx,slpIdx)=wFR.inh(:,pIdx);
                        end
                        partner(dIdx).cnt.inh(slpIdx)=size(wFR.inh,2);
                    end
                    
                end
            end
            
        elseif stateIdx==5 || stateIdx==6
            if stateIdx==5
                saveStateName='nrem2wake';
                targetState='nrem';
            elseif stateIdx==6
                continue
                %             saveStateName='rem2wake';
                %             targetState='rem';
            else
                continue
            end
            
            for dIdx=1:length(dList)
                
                fr(dIdx).pyr=double.empty(0,0,0);
                fr(dIdx).inh=double.empty(0,0,0);
                partner(dIdx).fr.pyr=double.empty(0,0,0);
                partner(dIdx).fr.inh=double.empty(0,0,0);
                partner(dIdx).cnt.pyr=[];
                partner(dIdx).cnt.inh=[];
                
                frFull(dIdx).pyr=double.empty(0,0,0);
                frFull(dIdx).inh=double.empty(0,0,0);
                partnerFull(dIdx).fr.pyr=double.empty(0,0,0);
                partnerFull(dIdx).fr.inh=double.empty(0,0,0);
                
                dName=dList{dIdx};
                
                for sIdx=1:size(stableSleep.(dName).time,1)
                    targetIdx=stableSleep.(dName).(targetState){sIdx};
                    
                    targetIdx=targetIdx(diff(behavior.(dName).list(targetIdx,1:2),1,2)>=minDuration.(saveStateName)*1e6);
                    
                    if length(targetIdx)<2
                        continue
                    end
                    
                    if behavior.(dName).list(targetIdx(end),2)~=stableSleep.(dName).time(sIdx,2)
                        continue
                    end
                    
                    bef=targetIdx(end);
                    aft=bef+1;
                    if size(behavior.(dName).list,1)<aft
                        continue
                    end
                    
                    
                    
                    if size(timeNormFR.(dName).onset.pyr{aft},2)==5 &&...
                            size(timeNormFR.(dName).onset.pyr{bef},1)>0
                        fr(dIdx).pyr(:,:,end+1)=[...
                            trisecFiringSp.(dName).(substate).pyr{bef}(:,end)...
                            mean(timeNormFR.(dName).onset.pyr{aft},2)];
                        
                        frFull(dIdx).pyr(:,:,end+1)=[...
                            trisecFiring.(dName).pyr.rate{bef}(:,end)...
                            mean(timeNormFR.(dName).onset.pyr{aft},2)];
                        
                        slpIdx=size(fr(dIdx).pyr,3);
                        for pIdx=1:length(targetIdx)-1
                            partner(dIdx).fr.pyr(:,pIdx,slpIdx)=...
                                trisecFiringSp.(dName).(substate).pyr{targetIdx(pIdx)}(:,end);
                            partnerFull(dIdx).fr.pyr(:,pIdx,slpIdx)=...
                                trisecFiring.(dName).pyr.rate{targetIdx(pIdx)}(:,end);
                        end
                        partner(dIdx).cnt.pyr(slpIdx)=length(targetIdx)-1;
                    end
                    
                    if size(timeNormFR.(dName).onset.inh{aft},2)==5 &&...
                            size(timeNormFR.(dName).onset.inh{bef},1)>0
                        
                        fr(dIdx).inh(:,:,end+1)=[...
                            trisecFiringSp.(dName).(substate).inh{bef}(:,end),...
                            mean(timeNormFR.(dName).onset.inh{aft},2)];
                        frFull(dIdx).inh(:,:,end+1)=[...
                            trisecFiring.(dName).inh.rate{bef}(:,end),...
                            mean(timeNormFR.(dName).onset.inh{aft},2)];
                        
                        slpIdx=size(fr(dIdx).inh,3);
                        for pIdx=1:length(targetIdx)-1
                            partner(dIdx).fr.inh(:,pIdx,slpIdx)=...
                                trisecFiringSp.(dName).(substate).inh{targetIdx(pIdx)}(:,end);
                            partnerFull(dIdx).fr.inh(:,pIdx,slpIdx)=...
                                trisecFiring.(dName).inh.rate{targetIdx(pIdx)}(:,end);
                            
                        end
                        partner(dIdx).cnt.inh(slpIdx)=length(targetIdx)-1;
                        
                    end
                end
                
            end
        end
        
        
        for cType={'pyr'}%,'inh'}
            for dIdx=1:length(dList)
                okIdx=find(squeeze(all(sum(fr(dIdx).(cType{1})==0)/size(fr(dIdx).(cType{1}),1)<1/nDiv,2)));
                
                fr(dIdx).(cType{1})= fr(dIdx).(cType{1})(:,:,okIdx);
                frFull(dIdx).(cType{1})= frFull(dIdx).(cType{1})(:,:,okIdx);
                partner(dIdx).fr.(cType{1})= partner(dIdx).fr.(cType{1})(:,:,okIdx);
                partner(dIdx).cnt.(cType{1})=partner(dIdx).cnt.(cType{1})(okIdx);
                partnerFull(dIdx).fr.(cType{1})= partnerFull(dIdx).fr.(cType{1})(:,:,okIdx);
            end
            
            for dIdx=1:length(dList)
                if isempty(partner(dIdx).fr.(cType{1}))
                    continue
                end
                ngIdx=[];
                for sIdx=1:size(partner(dIdx).fr.(cType{1}),3)
                    okIdx=find(sum(partner(dIdx).fr.(cType{1})(:,:,sIdx)==0,1)/size(partner(dIdx).fr.(cType{1}),1)<1/nDiv);
                    
                    if isempty(okIdx)
                        ngIdx=[ngIdx,sIdx];
                    else
                        temp=partner(dIdx).fr.(cType{1})(:,okIdx,sIdx);
                        partner(dIdx).fr.(cType{1})(:,:,sIdx)=0;
                        partner(dIdx).fr.(cType{1})(:,1:length(okIdx),sIdx)=temp;
                        partner(dIdx).cnt.(cType{1})(sIdx)=length(okIdx);

                        temp=partnerFull(dIdx).fr.(cType{1})(:,okIdx,sIdx);
                        partnerFull(dIdx).fr.(cType{1})(:,:,sIdx)=0;
                        partnerFull(dIdx).fr.(cType{1})(:,1:length(okIdx),sIdx)=temp;
                    end
                end
                fr(dIdx).(cType{1})(:,:,ngIdx)=[];
                frFull(dIdx).(cType{1})(:,:,ngIdx)=[];
                partner(dIdx).fr.(cType{1})(:,:,ngIdx)=[];
                partner(dIdx).cnt.(cType{1})(ngIdx)=[];
                partnerFull(dIdx).fr.(cType{1})(:,:,ngIdx)=[];
                
            end
            
            for dIdx=1:length(dList)
                if isempty(fr(dIdx).(cType{1}))
                    fr(dIdx).(cType{1})=[];
                    partner(dIdx).fr.(cType{1})=[];
                    partner(dIdx).cnt.(cType{1})=[];
                    frFUll(dIdx).(cType{1})=[];
                    partnerFull(dIdx).fr.(cType{1})=[];
                end
            end
        end
        
        
        display([datestr(now) ' started ' saveStateName])
        
        shuffleMean=zeros(nShuffle,nDiv+1);
        for shIdx=1:nShuffle+1
            if mod(shIdx,100)==0
                display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
            end
            
            clear temp
            for n=1:nDiv+1
                temp{n}=[];
            end
            for dIdx=1:length(dList)
                %pick previous or next index of transition randomly
                %             sesIdx=(randi(2,size(fr(dIdx).pyr,3),1)*2-3);
                %             sesIdx(1)=1;
                %             sesIdx(end)=-1;
                %             sesIdx=(1:size(fr(dIdx).pyr,3))'+sesIdx;
                
                
                for cType={'pyr','inh'}
                    sesIdx=arrayfun(@(x) randperm(x,1),partner(dIdx).cnt.(cType{1}));
                    %                 if size(fr(dIdx).(cType{1}),3)<2
                    %                     continue
                    %                 end
                    if isempty(fr(dIdx).(cType{1}))
                        continue
                    end
                    
                    if shIdx==1
                        target=fr(dIdx).(cType{1});
                                       
                        if strcmpi(sortby,'excluding')
                            sortTarget=fr(dIdx).(cType{1});
                        elseif strcmpi(sortby,'including')
                            sortTarget=frFull(dIdx).(cType{1});                        
                        else
                            error('sorting option must be excluding or including')
                        end

                    else
                        %shuffle with adjacent
                        %target=cat(2,fr(dIdx).(cType{1})(:,1,:),fr(dIdx).(cType{1})(:,1,sesIdx));
                        
                        clear target sortTarget
                        if isempty(partner(dIdx).fr.(cType{1}));
                            target=double.empty(0,0,0);
                            sortTarget=double.empty(0,0,0);
                            continue
                        end
                        
                        for n=1:length(sesIdx)
                            target(:,:,n)=partner(dIdx).fr.(cType{1})(:,sesIdx(n),n);
                            if strcmpi(sortby,'excluding')
                                sortTarget(:,:,n)=partner(dIdx).fr.(cType{1})(:,sesIdx(n),n);
                            elseif strcmpi(sortby,'including')
                                sortTarget(:,:,n)=partnerFull(dIdx).fr.(cType{1})(:,sesIdx(n),n);                       
                            else
                                error('sorting option must be excluding or including')
                            end                            
                        end
                        target=cat(2,fr(dIdx).(cType{1})(:,1,:),target);
                        sortTarget=cat(2,fr(dIdx).(cType{1})(:,1,:),sortTarget);
                        
                        %flip randomly
                        cIdx=randi(2,size(target))-1;
                        cIdx(:,2,:)=1-cIdx(:,1,:);
                        cIdx=(1:size(target,1))'+size(target,1)*cIdx;
                        cIdx=reshape((0:size(target,3)-1)*size(target,1)*size(target,2),1,1,[])+cIdx;
                        target=target(cIdx);
                        sortTarget=sortTarget(cIdx);
                        
                    end
                    %                 ci=funcCI(target);
                    
                    if strcmpi(cType{1},'pyr')
                        %                     ranking=ceil(tiedrank(target)/size(target,1)*nDiv);
                        [~,ranking]=sort(sortTarget);
                        offset=repmat(...
                            (0:size(ranking,2)-1)*size(target,1),...
                            size(target,1),1,size(target,3)...
                            )+...
                            permute(...
                            repmat(...
                            (0:size(target,3)-1)*size(target,1)*size(target,2),...
                            size(target,1),1,size(target,2)),...
                            [1,3,2]...
                            );
                        ranking(ranking+offset)=...
                            repmat((1:size(target,1))',1,size(target,2),size(target,3));
                        ranking=ceil(ranking/size(target,1)*nDiv);
                        
                        %                     ranking=ranking(:,1,:);
                        %                     for n=1:nDiv
                        % %                         temp{n}=[temp{n};ci(ranking==n)];
                        %                         temp{n}=[temp{n};funcCI(mean(target(ranking==n),1))];
                        %                     end
                        %                 else
                        %                     temp{nDiv+1}=[temp{nDiv+1};ci(:)];
                        %                 end
                        for n=1:nDiv
                            %                         temp{n}=[temp{n};ci(ranking==n)];
                            meanFR=zeros(size(ranking,3),2);
                            for targetIdx=1:size(ranking,3)
                                meanFR(targetIdx,:)=mean(target(ranking(:,1,targetIdx)==n,:,targetIdx),1);
                            end
                            if size(meanFR,2)==1
                                meanFR=meanFR';
                            end
                            temp{n}=[temp{n};funcCI(meanFR)];
                        end
                    else
                        %                     temp{nDiv+1}=[temp{nDiv+1};ci(:)];
                        meanFR=squeeze(mean(target,1))';
                        if size(meanFR,2)==1
                            meanFR=meanFR';
                        end
                        temp{nDiv+1}=[temp{nDiv+1};funcCI(meanFR)];
                    end
                end
            end
            
            if shIdx==1
                newCI5sp.(substate).(saveStateName).value=temp;
                newCI5sp.(substate).(saveStateName).mean=cellfun(@nanmean,temp);
                newCI5sp.(substate).(saveStateName).std=cellfun(@nanstd,temp);
%                newCI5sp.(substate).(saveStateName).ste=cellfun(@nanste,temp);
                newCI5sp.(substate).(saveStateName).shuffle=[];
                newCI5sp.(substate).(saveStateName).shuffleMean=[];
                newCI5sp.(substate).(saveStateName).confInt=[];
                newCI5sp.(substate).(saveStateName).p=[];
                newCI5sp.(substate).(saveStateName).param.nCell=cellfun(@(x) sum(~isnan(x)),temp);
                %             newCI3.(saveStateName).param.nState.pyr=sum(cellfun(@(x) size(x,3), {fr(:).pyr}) .* arrayfun(@(x) size(x.pyr,3)>1,fr));
                %             newCI3.(saveStateName).param.nState.inh=sum(cellfun(@(x) size(x,3), {fr(:).inh}) .* arrayfun(@(x) size(x.inh,3)>1,fr));
                newCI5sp.(substate).(saveStateName).param.nState.pyr=sum(cellfun(@(x) size(x,3), {fr(:).pyr}));
                newCI5sp.(substate).(saveStateName).param.nState.inh=sum(cellfun(@(x) size(x,3), {fr(:).inh}));
                %             newCI3.(saveStateName).param.nSession.pyr=sum(arrayfun(@(x) size(x.pyr,3)>1,fr));
                %             newCI3.(saveStateName).param.nSession.inh=sum(arrayfun(@(x) size(x.inh,3)>1,fr));
                newCI5sp.(substate).(saveStateName).param.nSession.pyr=sum(arrayfun(@(x) size(x.pyr,3)>0,fr));
                newCI5sp.(substate).(saveStateName).param.nSession.inh=sum(arrayfun(@(x) size(x.inh,3)>0,fr));
                newCI5sp.(substate).(saveStateName).param.nShuffle=nShuffle;
                newCI5sp.(substate).(saveStateName).param.nDiv=nDiv;
                newCI5sp.(substate).(saveStateName).param.minDuration=minDuration.(saveStateName);
                newCI5sp.(substate).(saveStateName).param.sortby=sortby;
                newCI5sp.(substate).(saveStateName).param.madeby=mfilename;
            else
                shuffleMean(shIdx-1,:)=cellfun(@nanmean,temp);
            end
        end
        shuffleMean=sort(shuffleMean,1);
        newCI5sp.(substate).(saveStateName).shuffle=shuffleMean;
        newCI5sp.(substate).(saveStateName).shuffleMean=mean(shuffleMean,1);
        newCI5sp.(substate).(saveStateName).confInt=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
        
        p=ones(1,nDiv+1);
        for qIdx=1:nDiv+1
            n=find(shuffleMean(:,qIdx)<newCI5sp.(substate).(saveStateName).mean(qIdx),1,'last');
            if isempty(n); n=0;
            elseif n>size(shuffleMean,1)/2; n=size(shuffleMean,1)-n;end
            p(qIdx)=n/size(shuffleMean,1)*2;
        end
        newCI5sp.(substate).(saveStateName).p=p;
        
        newDI5sp.(substate).(saveStateName).mean=newCI5sp.(substate).(saveStateName).mean-newCI5sp.(substate).(saveStateName).shuffleMean;
        newDI5sp.(substate).(saveStateName).std=newCI5sp.(substate).(saveStateName).std;
%        newDI5sp.(substate).(saveStateName).ste=newCI5sp.(substate).(saveStateName).ste;
        
        newDI5sp.(substate).(saveStateName).shuffleMean=zeros(1,nDiv+1);
        newDI5sp.(substate).(saveStateName).confInt=newCI5sp.(substate).(saveStateName).confInt-newCI5sp.(substate).(saveStateName).shuffleMean;
        newDI5sp.(substate).(saveStateName).p=newCI5sp.(substate).(saveStateName).p;
        newDI5sp.(substate).(saveStateName).param=newCI5sp.(substate).(saveStateName).param;
        
        temp=arrayfun(@(x) reshape(permute(x.pyr,[1,3,2]),[],2),fr,'UniformOutput',false);
        temp=cat(1,temp{:});
        newFR5sp.(substate).(saveStateName).pyr=temp(any(temp>0,2),:);
        
        temp=arrayfun(@(x) reshape(permute(x.inh,[1,3,2]),[],2),fr,'UniformOutput',false);
        temp=cat(1,temp{:});
        newFR5sp.(substate).(saveStateName).inh=temp(any(temp>0,2),:);
        
        newFR5sp.(substate).(saveStateName).param.nCell=[size(newFR5sp.(substate).(saveStateName).pyr,1),...
            size(newFR5sp.(substate).(saveStateName).inh,1)];
        %     newFR3.(saveStateName).param.nState.pyr=sum(cellfun(@(x) size(x,3), {fr(:).pyr}) .* arrayfun(@(x) size(x.pyr,3)>1,fr));
        %     newFR3.(saveStateName).param.nState.inh=sum(cellfun(@(x) size(x,3), {fr(:).inh}) .* arrayfun(@(x) size(x.inh,3)>1,fr));
        %     newFR3.(saveStateName).param.nSession.pyr=sum(arrayfun(@(x) size(x.pyr,3)>1,fr));
        %     newFR3.(saveStateName).param.nSession.inh=sum(arrayfun(@(x) size(x.inh,3)>1,fr));
        
        newFR5sp.(substate).(saveStateName).param.nState=newCI5sp.(substate).(saveStateName).param.nState;
        newFR5sp.(substate).(saveStateName).param.nSession=newCI5sp.(substate).(saveStateName).param.nSession;
        
    end
end
%%
save([baseDir coreName '-' 'newDI5sp' '.mat'],'newDI5sp','newCI5sp','newFR5sp','-v7.3')
%%
figure('Position',[0 0 1920 1080]);
numfig=numel(fieldnames(newDI5sp.on));
transList=fieldnames(newDI5sp.on);
for i=1:numfig
subplot(sqrt(numfig),sqrt(numfig),i);
state=transList{i};
bar(newDI5sp.on.(state).mean)
title(state)
xticks([1 3 5 6])
xticklabels({'L','M','H','I'})
ylabel('Deflection Index')
hold on
er = errorbar(newDI5sp.on.(state).mean,newDI5sp.on.(state).std,'.');    
hold off
end
%%
% state='FLnrem';
% figure;bar(newDI5sp.on.(state).mean)
% title(state)
% xticks([1 3 5 6])
% xticklabels({'L','M','H','I'})
% ylabel('Deflection Index')
% hold on
% er = errorbar(newDI5sp.on.(state).mean,newDI5sp.on.(state).std,'.');    
% hold off