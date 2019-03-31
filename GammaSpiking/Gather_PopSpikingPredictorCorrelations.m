function Gather_PopSpikingPredictorCorrs(folderpath)

if ~exist('folderpath','var')
    folderpath = fullfile('/','proraid','GammaDataset');
end

%% Get list of datasets
d = getdir(folderpath);
names = {};
dirs = {};
for count = 1:length(d);
    if d(count).isdir
        names{end+1} = d(count).name;
        dirs{end+1} = fullfile(folderpath,d(count).name);
    end
end

%% Variable setup
for iidx = 1:2
    if iidx == 1;
        celltype = 'E';
    elseif iidx == 2
        celltype = 'I';
    end
    %linear or log of output
    for ll1 = 1:2;
        if ll1 == 1;
            ll1name = 'linear';
        else
            ll1name = 'log';
        end
        %linear or log of inputs
        for ll2 = 1:2;
            if ll2 == 1;
                ll2name = 'linear';
            else
                ll2name = 'log';
            end
            
            tname = [ll2name 'PredictorsVs' ll1name celltype 'PopSpikes'];
            eval(['out.' tname '.Rs = [];']);
            eval(['out.' tname '.Ps = [];']);
        end
    end
end


%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};
    
    load(fullfile(basepath,[basename '_PopSpikingPredictorCorrVals.mat']))
    t = PopSpikePredictorCorrVals;
    clear PopSpikePredictorCorrVals

    for iidx = 1:2
        if iidx == 1;
            celltype = 'E';
        elseif iidx == 2
            celltype = 'I';
        end
        %linear or log of output
        for ll1 = 1:2;
            if ll1 == 1;
                ll1name = 'linear';
            else
                ll1name = 'log';
            end
            %linear or log of inputs
            for ll2 = 1:2;
                if ll2 == 1;
                    ll2name = 'linear';
                else
                    ll2name = 'log';
                end
                %now have ins and out... go to town
    
                tname = [ll2name 'PredictorsVs' ll1name celltype 'PopSpikes'];
                eval(['tprevR = out. ' tname '.Rs;'])
                eval(['tnewR = t.' tname '.Rs;'])
                tR = cat(2,tprevR,tnewR);
                eval(['out.' tname '.Rs = tR;'])
                
                eval(['tprevP = out. ' tname '.Ps;'])
                eval(['tnewP = t.' tname '.Ps;'])
                tP = cat(2,tprevP,tnewP);
                eval(['out.' tname '.Ps = tP;'])
            end
        end
    end
    out.PredictorNames{fidx} = t.PredictorNames;
    
end

%% Get some basic params
PopSpikingPredictorCorrs = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','PopSpikingPredictorCorrs.mat'),'PopSpikingPredictorCorrs')

%% 
   1;
