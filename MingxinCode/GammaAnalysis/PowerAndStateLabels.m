function [PowerStateIdx,PowerIdx,StateIdx,AboveInt,BelowInt,AboveInt_all,BelowInt_all] = ...
    PowerAndStateLabels(amp,states,samplingRate,zthreshold,freqlist)
% states: cell format
if ~iscell(amp)
    amp_orig = amp;
    amp = cell(1);
    amp{1} = amp_orig;
    clear amp_orig;
end
StateIdx = zeros(size(amp{1},1),1);%0,1,2,3,(4,5)
PowerStateIdx = cell(length(amp),1);%0,1,-1,2,-2,...
PowerIdx = cell(length(amp),1); %-1,1
% zs = cell(length(amp),1);
% zs_all = cell(length(amp),1);

for ii = 1:length(states)
    StateIdx(InIntervals((1:size(amp{1},1))/samplingRate,states{ii})) = ii;
end
StateIdx = int8(StateIdx);

for jj = 1:length(amp)
    zs = zeros(size(amp{jj}));
    PowerStateIdx{jj} = zeros(size(amp{jj}));
    for kk = 1:length(freqlist)
        for ii = 1:length(states)
            zs(StateIdx==ii,kk) = zscore(log(amp{jj}(StateIdx==ii,kk)));% log for normalizing power data??
        end
        for nn = 1:length(zthreshold)
            [AboveInt{jj,kk,nn},~] = continuousabove2(zs(:,kk),zthreshold(nn),1/freqlist(kk)*3*samplingRate);
            [BelowInt{jj,kk,nn},~] = continuousbelow2(zs(:,kk),-zthreshold(nn),1/freqlist(kk)*3*samplingRate);
        end
        for ll = 1:length(AboveInt{jj,kk,2})
            PowerStateIdx{jj}(AboveInt{jj,kk,2}(ll,1):AboveInt{jj,kk,2}(ll,2),kk) = StateIdx(AboveInt{jj,kk,2}(ll,1):AboveInt{jj,kk,2}(ll,2));
        end
        for mm = 1:length(BelowInt{jj,kk,2})
            PowerStateIdx{jj}(BelowInt{jj,kk,2}(mm,1):BelowInt{jj,kk,2}(mm,2),kk) = -StateIdx(BelowInt{jj,kk,2}(mm,1):BelowInt{jj,kk,2}(mm,2));
        end
    end
end
clear zs;

for jj = 1:length(amp)
    zs_all = zeros(size(amp{jj}));
    PowerIdx{jj} = zeros(size(amp{jj}));
    for kk = 1:length(freqlist)
        zs_all(:,kk) = zscore(log(amp{jj}(:,kk)));
        for nn = 1:length(zthreshold)
            [AboveInt_all{jj,kk,nn},~] = continuousabove2(zs_all(:,kk),zthreshold(nn),1/freqlist(kk)*3*samplingRate); %% need correction for some folders
            [BelowInt_all{jj,kk,nn},~] = continuousbelow2(zs_all(:,kk),-zthreshold(nn),1/freqlist(kk)*3*samplingRate);
        end
        for ll = 1:length(AboveInt_all{jj,kk,2})
            PowerIdx{jj}(AboveInt_all{jj,kk,2}(ll,1):AboveInt_all{jj,kk,2}(ll,2),kk) = 1;
        end
        for mm = 1:length(BelowInt_all{jj,kk,2})
            PowerIdx{jj}(BelowInt_all{jj,kk,2}(mm,1):BelowInt_all{jj,kk,2}(mm,2),kk) = -1;
        end        
    end
    PowerIdx{jj} = int8(PowerIdx{jj});
end
clear zs_all;

end