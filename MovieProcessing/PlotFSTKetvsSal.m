function PlotFSTKetvsSal(KetGroup1, Dates)
SalGroup1 = setdiff(1:8,KetGroup1);
Ket = [];
Sal = [];
load('FSTData.mat');
if length(Dates)<2
    for i = 1:length(KetGroup1)
        Ket(i,:) = FSTData(KetGroup1(i),Dates,:);
        Sal(i,:) = FSTData(SalGroup1(i),Dates,:);
    end
else
    for i = 1:length(KetGroup1)
        Ket(i,:) = FSTData(KetGroup1(i),Dates,:);
        Sal(i,:) = FSTData(SalGroup1(i),Dates,:);
    end
    for i = 1:length(SalGroup1)
        Ket(i+length(KetGroup1),:) = FSTData(SalGroup1(i),Dates,:);
        Sal(i+length(KetGroup1),:) = FSTData(KetGroup1(i),Dates,:);
    end
end

    
    % for i = 1:(length(KetGroup1(:,1))+length(SalGroup1(:,1)))
    %     if i<length(KetGroup1(:,1))+1
    %         KetFoldernames(i,:) = strcat(KetGroup1(i,:),'_',Date1);
    %         SalFoldernames(i,:) = strcat(SalGroup1(i,:),'_',Date1);
    %     else
    %         KetFoldernames(i,:) = strcat(SalGroup1(i-length(KetGroup1(:,1)),:),'_',Date2);
    %         SalFoldernames(i,:) = strcat(KetGroup1(i-length(KetGroup1(:,1)),:),'_',Date2);
    %     end
    %     if exist(KetFoldernames(i,:))
    %         file = dir(fullfile(KetFoldernames(i,:), '*FSTScoring.mat'));
    %         load(file.name,'BehaviorChunkCounts');
    %         Ket(i,:) = BehaviorChunkCounts;
    %     end
    %     if exist(SalFoldernames(i,:))
    %         file = dir(fullfile(SalFoldernames(i,:), '*FSTScoring.mat'));
    %         load(file.name,'BehaviorChunkCounts');
    %         Sal(i,:) = BehaviorChunkCounts;
    %     end
    % end
    bar(mean(Ket(:,1)),mean(Sal(:,1)));
    
    
    
