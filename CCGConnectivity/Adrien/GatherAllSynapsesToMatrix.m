function ccgs = GatherAllSynapsesToMatrix

[dirs,names] = DatasetDropboxSleep;

%% parameter setting
spanofinterestms = 6;%keep +- this many ms
desiredresolutionms = 2; %decimate to this resolution

%% main function
ccgs = [];
for a = 1:length(dirs);
    basepath = dirs{a};
    basename = names{a};
    
    load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']))
    
    if ~isempty(funcsynapses.ConnectionsE) & ~isempty(funcsynapses.ConnectionsI)
        allcnxns = cat(1,funcsynapses.ConnectionsE,funcsynapses.ConnectionsI);
    elseif isempty(funcsynapses.ConnectionsE)
        allcnxns = funcsynapses.ConnectionsI;
    elseif isempty(funcsynapses.ConnectionsI)
        allcnxns = funcsynapses.ConnectionsE;
    end
    
    allcnxns = EliminatePalindromeRows(allcnxns);
    
    if ~isempty(allcnxns)
        tR = funcsynapses.CCGbins;
        tccgs = [];
        for b = 1:size(allcnxns,1);
            tccgs = cat(2,tccgs,funcsynapses.fullCCGMtx(:,allcnxns(b,1),allcnxns(b,2)));
        end

    %% Reshaping bins
        %keep only milliseconds of interest
        keep = [find(tR>=-spanofinterestms,1,'first') find(tR<=spanofinterestms,1,'last')];
        tccgs = tccgs(keep(1):keep(2),:);
        % normalize each ccg... zscore
        tccgs = zscore(tccgs);
        %average neighboring bins
        middlepoint = ceil(size(tccgs,1)/2);
        decimationfactor = desiredresolutionms/funcsynapses.BinMs;
        if rem(decimationfactor,floor(decimationfactor))==0
            clear t1 t2
            for b = 1:decimationfactor 
                t1(:,:,b) = tccgs(b:decimationfactor:floor(size(tccgs,1)/2),:);
                t2(:,:,b) = tccgs(middlepoint+b:decimationfactor:size(tccgs,1),:);
            end
            t1 = sum(t1,3);
            t2 = sum(t2,3);
            tccgs = cat(1,t1,tccgs(middlepoint,:),t2);
        else
    %         resample %this will use filtering)
        end

        ccgs = cat(2,ccgs,tccgs);
    end
end