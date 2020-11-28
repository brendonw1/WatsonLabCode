function [GoodUnitShanks,neighborShanks,neighborShanksEachCell] = SelectNeighboringShank(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

if exist(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'file')
    load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Shanks','Channels');
else
    error('No gamma channel info.');
end
LfpShanks = Shanks;

load(fullfile(basepath,[basename '_SStable.mat']),'shank');
GoodUnitShanks = unique(shank);
neighborShanks = cell(length(GoodUnitShanks),1);
for i = 1:length(GoodUnitShanks)
    if ismember(GoodUnitShanks(i)-1,LfpShanks)
        neighborShanks{i}(end+1) = GoodUnitShanks(i)-1;
    end
    if ismember(GoodUnitShanks(i)+1,LfpShanks)
        neighborShanks{i}(end+1) = GoodUnitShanks(i)+1;
    end
end

neighborShanksEachCell = cell(length(shank),1);
for i = 1:length(shank)
    if ismember(shank(i)-1,LfpShanks)
        neighborShanksEachCell{i}(end+1) = shank(i)-1;
    end
    if ismember(shank(i)+1,LfpShanks)
        neighborShanksEachCell{i}(end+1) = shank(i)+1;
    end
end
save(fullfile(basepath,[basename '_NeighboringShanks.mat']),'GoodUnitShanks','neighborShanks','neighborShanksEachCell');
end