function StatsByLabel(LabelsCell,varargin)
% Plots stats for each anatomical region.  LabelsCell contains a list
% of labels.  Varargin will be vectors, each with as many
% elements as LabelsCell and with measurements corresponding to the 
% labels listed in LabelsCell.  Labeled groups will be collected based on 
% like label strings, which will then pull out corresponding values of the 
% vectors given in varargin.  
% For each vector a comparison plot will be made across anatomical regions.
% 
% Brendon Watson 2015

for a = 1:length(varargin);
    varnames{a} = inputname(a+1);
    A(a,:) = varargin{a}(:);
end

[anats,~,ixs] = unique(LabelsCell);

% figure
[vertplots,horizplots] = determinenumsubplots(length(varargin));


for a = 1:length(varargin)
    data = varargin{a};
    bins = cell(1,length(anats));
    for b = 1:length(anats)
        bins{b} = data(ixs==b);
    end

    subplot(vertplots,horizplots,a)
	plot_meanSEM(bins)
    set(gca,'XTick',[1:length(anats)])
%     set(gca,'XTickLabel',cat(2,' ',anats))
    set(gca,'XTickLabel',anats)
    title([varnames{a} '.  Mean +- SEM'])
end