function [measured, surrmeasured] = OrigVsReshuffPairwiseCellSharing(origbools,surrbools,type)

plotting = 1;
if ~exist('type','var')
    type = 1;
end
switch type
    case 1
        metric = 'SharedOverUnion';
    case 2;
        metric = 'SharedOverAllCells';
end


% Make a matrix of all pairwise combos... look at distro of that
numints = size(origbools,1);
numcells = size(origbools,2);
nshuffs = size(surrbools,3);

eval(['measured = ' metric '(origbools);'])
% for a = 1:numints
%     for b = a:numints
%         eval(['measured(a,b) = ' metric '(origbools(a,:),origbools(b,:));'])            
%     end
% %     if rem(a,100) == 0;
% %         disp(['Compared ' num2str(a) ' out of ' num2str(numints) ' events to all others'])
% %     end
% end
if plotting
    figure;
    imagesc(measured)
    title(['Event to Event similarity as measured by ' metric]);
end
% get mean
tidxs = triu(ones(numints),1);
measuredlin = measured(find(tidxs==1));
meanmeasured = mean(measuredlin);%proportionshared

for a = 1:nshuffs%for each shuffle
    % now go thru and get mean pairwise comparison
    eval(['surrmeasured = ' metric '(surrbools(:,:,a));'])

    tidxs = triu(ones(numints),1);
    surrmeasuredlin = surrmeasured(find(tidxs==1));
    surrmeanmeasured(a) = mean(surrmeasuredlin);%proportionshared
    if rem(a,10) == 0
        disp(['Shuffle ' num2str(a) ' out of ' num2str(nshuffs) ' done'])
    end
end

figure;hist(surrmeanmeasured,50)
hold on;plot(meanmeasured,1,'*r')

for a = 1:numcells;
    t = mean(surrbools(:,a,:),1);
    surrrates(a,:) = t(:);
end
means = mean(surrrates,2);
mins = min(surrrates,[],2);
maxs = max(surrrates,[],2);
figure;
errorbar(1:numcells,means,mins,maxs,'.');
hold on
plot(mean(origbools,1),'.r')
1;


        