function [Energies,SelfDistances,LRatios,IsoDistances,ISIIndices] = ClusterQualityMetrics(S,shank,cellIx,basename,Par)
% Calculates cluster a number of cluster quality and spike quality metrics
% for all clusters (and in some cases all spikes).
% total spike energy for each spike from each cell from the
% center of the cluster that spike is in
% Assumes .clu and .fet files are in the current directory
% Just uses component 1 for each channel (to simplify and avoid weighting
% issues)

% loadedshanks = [];
loadedshanks = 0;

% [allres,allclu] = oneSeries(S);
% allres = TimePoints(allres);

for cidx = 1:size(S,1)%for each cell

%     disp(a);
    thisshank =  shank(cidx);
    thisid = cellIx(cidx);
    disp(['Starting Cell ',num2str(cidx), ' out of ', num2str(size(S,1))]);
    
%     theseixs = find(shank == thisshank);
%     shankcellixs = ismember(allclu, theseixs);
%     thisclu = allclu(shankcellixs);
%     thisres = allres(shankcellixs);

%% OLD VERSION... crashes with big files     
%     if sum(loadedshanks==thisshank) == 0;
%        disp(['Starting Shank ',num2str(thisshank)]);
%        eval(['[Fet',num2str(thisshank),', nFeatures',num2str(thisshank),'] = LoadFet([basename,''.fet.',num2str(thisshank),''']);'])
% %        res = TimePoints(res);
%         eval(['[Res',num2str(thisshank),',Clu',num2str(thisshank),',dummy,dummy]=LoadCluRes(basename,thisshank);']);
%         eval(['[Clu',num2str(thisshank),', nClusters',num2str(thisshank),'] = LoadClu([basename,''.clu.',num2str(thisshank),''']);'])
%         loadedshanks = cat(1,loadedshanks,thisshank);
%     end
%     eval(['thisclu = Clu',num2str(thisshank),';'])
%     eval(['thisfet = Fet',num2str(thisshank),';'])
%     eval(['thisres = Res',num2str(thisshank),';'])
%     eval(['clear([Fet',num2str(thisshank),';'])
%     thesespikeindices = thisclu == thisid;
%     thiscellfet = thisfet(thesespikeindices,:);
% %     thesespikeindices = allclu == a;
%% NEW VERSION, only opens one cluster at a time... slower for sure - SUPER CONSERVATIVE
%     [thisres,dummy,dummy,dummy]=LoadCluRes(basename,thisshank);
%     [thisclu,dummy] = LoadClu([basename,'.clu.',num2str(thisshank)]);
%     thesespikeindices = find(thisclu == thisid);     
%     thiscellfet = LoadFetSubset([basename '.fet.' num2str(thisshank)], thesespikeindices); 
%% NEWEST VERSION... moderately conservative (doesn't do "ismember" on every sample read, but still reads every fet sample for every cell
%     [thiscellfet,dummy] = LoadFet([basename,'.fet.',num2str(thisshank)],inf,thisid);
%     [thisres,dummy,dummy,dummy]=LoadCluRes(basename,thisshank);
%     [thisclu,dummy] = LoadClu([basename,'.clu.',num2str(thisshank)]);
%% USING this version since calcClusterQuality needs the full fet (also will be faster as long as ok for ram)
    if loadedshanks~=thisshank
       disp(['Starting Shank ',num2str(thisshank)]);
       [thisfet,dummy] = LoadFeatures([basename,'.fet.',num2str(thisshank)]);
       [thisres,thisclu,dummy,dummy]=LoadCluRes(basename,thisshank);
       [thisclu,dummy] = LoadClu([basename,'.clu.',num2str(thisshank)]);
       loadedshanks = thisshank;
    end
    thesespikeindices = thisclu == thisid;
    thiscellfet = thisfet(thesespikeindices,:);

    numChannelsThisShank = length(Par.SpkGrps(thisshank).Channels);
    featuresPerChannel = Par.SpkGrps(thisshank).nFeatures;
    numNonRedundantFeatures = numChannelsThisShank*featuresPerChannel;
    thiscellfet = thiscellfet(:,1:numNonRedundantFeatures);
    thiscellfet2 = thiscellfet(:,1:3:numNonRedundantFeatures);%just taking the amplitudes of the first components

    Energies{cidx} = (sum(thiscellfet2.^2,2)).^.5;
        
    try
        mahald = mahal(thiscellfet,thiscellfet);
        SelfDistances {cidx} = mahald;
    catch
        SelfDistances {cidx} = nan(size(thiscellfet,1),1);
    end
    
    [Lratio_all, ID_all, ISIindex_all] = calcClusterQuality(thisclu, thisres, thisfet, thisid);
    
    quarter1idx = find(thisres<max(thisres)/4,1,'last');
    quarter2idx = find(thisres<max(thisres)/2,1,'last');
    quarter3idx = find(thisres<max(thisres)*0.75,1,'last');
    
    quarter1res = thisres(1:quarter1idx);
    quarter1clu = thisclu(1:quarter1idx);
    quarter1fet = thisfet(1:quarter1idx,1:end-5);
    [Lratio1, ID1, ISIindex1 ] = calcClusterQuality(quarter1clu, quarter1res, quarter1fet, thisid);

    quarter2res = thisres(quarter1idx+1:quarter2idx);
    quarter2clu = thisclu(quarter1idx+1:quarter2idx);
    quarter2fet = thisfet(quarter1idx+1:quarter2idx,1:end-5);
    [Lratio2, ID2, ISIindex2 ] = calcClusterQuality(quarter2clu, quarter2res, quarter2fet, thisid);

    quarter3res = thisres(quarter2idx+1:quarter3idx);
    quarter3clu = thisclu(quarter2idx+1:quarter3idx);
    quarter3fet = thisfet(quarter2idx+1:quarter3idx,1:end-5);
    [Lratio3, ID3, ISIindex3 ] = calcClusterQuality(quarter3clu, quarter3res, quarter3fet, thisid);

    quarter4res = thisres(quarter3idx+1:end);
    quarter4clu = thisclu(quarter3idx+1:end);
    quarter4fet = thisfet(quarter3idx+1:end,1:end-5);
    [Lratio4, ID4, ISIindex4 ] = calcClusterQuality(quarter4clu, quarter4res, quarter4fet, thisid);

    if isempty(Lratio_all);Lratio_all=nan;end
    if isempty(Lratio1);Lratio1=nan;end
    if isempty(Lratio2);Lratio2=nan;end
    if isempty(Lratio3);Lratio3=nan;end
    if isempty(Lratio4);Lratio4=nan;end
    if isempty(ID_all);ID_all=nan;end
    if isempty(ID1);ID1=nan;end
    if isempty(ID2);ID2=nan;end
    if isempty(ID3);ID3=nan;end
    if isempty(ID4);ID4=nan;end
    if isempty(ISIindex_all);ISIindex_all=nan;end
    if isempty(ISIindex1);ISIindex1=nan;end
    if isempty(ISIindex2);ISIindex2=nan;end
    if isempty(ISIindex3);ISIindex3=nan;end
    if isempty(ISIindex4);ISIindex4=nan;end
    LRatios(cidx,1:5) = [Lratio_all Lratio1 Lratio2 Lratio3 Lratio4];
    IsoDistances(cidx,1:5) = [ID_all ID1 ID2 ID3 ID4];
    ISIIndices(cidx,1:5) = [ISIindex_all ISIindex1 ISIindex2 ISIindex3 ISIindex4];
end

