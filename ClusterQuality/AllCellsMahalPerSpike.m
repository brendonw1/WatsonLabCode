function distances = AllCellsMahalPerSpike(S,shank,cellIx,basename)
% Calculates Mahalonobis distance for each spike from each cell from the
% center of the cluster that spike is in
% Assumes .clu and .fet files are in the current directory



loadedshanks = [];

for a = 1:size(S,1)%for each cell
%     disp(a);
    thisshank =  shank(a);
    thisid = cellIx(a);
    if ~ismember(thisshank,loadedshanks)
       eval(['[Fet',num2str(thisshank),', nFeatures',num2str(thisshank),'] = LoadFet([basename,''.fet.',num2str(thisshank),''']);'])
       eval(['[Clu',num2str(thisshank),', nClusters',num2str(thisshank),'] = LoadClu([basename,''.clu.',num2str(thisshank),''']);'])
       loadedshanks = cat(1,loadedshanks,thisshank);
    end
    eval(['thesespikeindices = Clu',num2str(thisshank),' == thisid;'])
    eval(['thesefets = Fet',num2str(thisshank),'(thesespikeindices,1:end-5);'])

    mahald = mahal(thesefets,thesefets);

    distances {a} = mahald;
end

