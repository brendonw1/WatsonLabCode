function [AboveInt,BelowInt,AboveInt_all,BelowInt_all] = ZScoreIntervals(amp,states,samplingRate,zthreshold,freqlist)
% states: cell format
StateIdx = zeros(size(amp{1},1),1);%0,1,2,3,(4,5)

for ii = 1:length(states)
    StateIdx(InIntervals((1:size(amp{1},1))/samplingRate,states{ii})) = ii;
end
StateIdx = int8(StateIdx);

for jj = 1:length(amp)
    zs = zeros(size(amp{jj}));
    %     PowerStateIdx{jj} = zeros(size(amp{jj}));
    for kk = 1:length(freqlist)
        for ii = 1:length(states)
            zs(StateIdx==ii,kk) = zscore(log(amp{jj}(StateIdx==ii,kk)));% log for normalizing power data??
        end
        for ll = 1:length(zthreshold)
            [AboveInt{jj,kk,ll},~] = continuousabove2(zs(:,kk),zthreshold(ll),1/freqlist(kk)*3*samplingRate);
            [BelowInt{jj,kk,ll},~] = continuousbelow2(zs(:,kk),-zthreshold(ll),1/freqlist(kk)*3*samplingRate);
        end
    end
end
clear zs;

for jj = 1:length(amp)
    zs_all = zeros(size(amp{jj}));
    for kk = 1:length(freqlist)
        zs_all(:,kk) = zscore(log(amp{jj}(:,kk)));
        for ll=1:length(zthreshold)
            [AboveInt_all{jj,kk,ll},~] = continuousabove2(zs_all(:,kk),zthreshold(ll),1/freqlist(kk)*3*samplingRate); %% need correction for some folders
            [BelowInt_all{jj,kk,ll},~] = continuousbelow2(zs_all(:,kk),-zthreshold(ll),1/freqlist(kk)*3*samplingRate);
        end
    end
end
clear zs_all;

end