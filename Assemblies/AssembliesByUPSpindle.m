t = load([basename '_AssemblyBasicData.mat'])
v2struct(t.AssemblyBasicData);%unpacks  binsecs,binpoints, SBinned, 
            % BinnedMatrix, opts, Patterns, Threshold, cellnum, assemblynum, 
            % AssemblyCells, AssemblyActivities, AssemblyCellActivites
            
numAss = size(Patterns,2);

%% plotting for a sec
% h = figure;
% 
% cc = colorcube;
% colorrows = round(linspace(1,size(cc,1),numAss));
% 
% smoothing = 1000;
% for a = 1:numAss;
%     smo(:,a) = zscore(smooth(AssemblyCellActivites(:,a),smoothing));
%     plot(smo(:,a),'color',cc(colorrows(a),:))
%     hold on
% end
% 
% figure;
% imagesc(smo')

