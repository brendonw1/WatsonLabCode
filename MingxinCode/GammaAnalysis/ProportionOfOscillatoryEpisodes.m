function [PHighPower,PEpisode,AboveInt] = ProportionOfOscillatoryEpisodes(amp,freqlist,SamplingRate,ChisqCutoff,TimeCutoff)
ChisqX = chi2inv(ChisqCutoff,2);
for ii = 1:length(amp)
    y = log(mean(amp{ii}));
    y = reshape(y,[],1);
    X = [ones(length(freqlist),1) reshape(log(freqlist),[],1)];
%     X = reshape(X,[],2);
    params = X\y;
    yfit = X*params;
    Rsq = 1 - sum((y - yfit).^2)/sum((y - mean(y)).^2);
    PowerCutoff = exp(yfit)./2*ChisqX;
    for jj = 1:length(freqlist)
        PHighPower{ii}(jj) = length(find(amp{ii}(:,jj)>PowerCutoff(jj)))/size(amp{1},1);
        AboveInt{ii,jj} = continuousabove2(amp{ii}(:,jj),PowerCutoff(jj),TimeCutoff/freqlist(jj)*SamplingRate);
        if ~isempty(AboveInt{ii,jj})
            PEpisode{ii}(jj) = sum(AboveInt{ii,jj}(:,2)-AboveInt{ii,jj}(:,1))/size(amp{ii},1);
        else
            PEpisode{ii}(jj) = 0;
        end
    end
end
end