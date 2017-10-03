[ccgs,downccgs] = GatherAllSynapsesToMatrix;

numclusters = 8;
idx = kmeans(downccgs',numclusters);

for a = 1:numclusters
    clumeans(:,a) = mean(ccgs(:,idx==a),2);
    downclumeans(:,a) = mean(downccgs(:,idx==a),2);
end

figure;
for a = 1:numclusters
    subplot(numclusters,2,2*(a-1)+1)
    bar(downclumeans(:,a))
    ylabel(['n = ' num2str(sum(idx==a))]);
    axis tight
    
    subplot(numclusters,2,2*a)
    bar(clumeans(:,a))
    ylabel(['n = ' num2str(sum(idx==a))]);
    axis tight
end
AboveTitle('BasedOnBinValues')


%%
% numclusters = 8;


downinoutratios = log10(flipud(downccgs(1:3,:)) ./ downccgs(5:7,:));
inoutratios = log10(flipud(ccgs(1:12,:)) ./ ccgs(14:25,:));
idx = kmeans(downinoutratios',numclusters);


for a = 1:numclusters
    downinoutmeans(:,a) = mean(downinoutratios(:,idx==a),2);
    inoutmeans(:,a) = mean(inoutratios(:,idx==a),2);
end

figure;
for a = 1:numclusters
    subplot(numclusters,2,2*(a-1)+1)
    bar(downinoutmeans(:,a))
    ylabel(['n = ' num2str(sum(idx==a))]);
    axis tight

    subplot(numclusters,2,2*a)
    bar(inoutmeans(:,a))
    ylabel(['n = ' num2str(sum(idx==a))]);
    axis tight
end
AboveTitle('BasedOnInToOutBinRatios')

