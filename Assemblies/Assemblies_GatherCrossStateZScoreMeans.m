function [CrossStateZActsPCA,CrossStateZActsICA] = Assemblies_GatherCrossStateZScoreMeans(secondperbin)

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
CrossStateZActsPCA.SessionNames = {};
CrossStateZActsPCA.RatNames = {};
CrossStateZActsPCA.Anatomies = {};
CrossStateZActsPCA.NumRats = 0;

CrossStateZActsICA.SessionNames = {};
CrossStateZActsICA.RatNames = {};
CrossStateZActsICA.Anatomies = {};
CrossStateZActsICA.NumRats = 0;

% CrossStateZActs.NumWakeEAssemblies = [];
% CrossStateZActs.NumMWakeEAssemblies = [];
% CrossStateZActs.NumNMWakeEAssemblies = [];
% CrossStateZActs.NumUPEAssemblies = [];
% CrossStateZActs.NumSUPEAssemblies = [];
% CrossStateZActs.NumSpindleEAssemblies = [];
% CrossStateZActs.NumNDSpindleEAssemblies = [];
% CrossStateZActs.NumREMEAssemblies = [];

% 
% fn = fieldnames(UPSpindlTemplateData);
% fn = fn(6:end);
% nf = length(fn);

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:10%length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    pfname = fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesZScorePCA_' num2str(secondsperbin) 'sec']);
    ifname = fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesZScoreICA_' num2str(secondsperbin) 'sec']);
    
    if exist(pfname,'file') && exist(ifname,'file')
       
       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        CrossStateZActsPCA.SessionNames{end+1} = basename;
        CrossStateZActsPCA.Anatomies{end+1} = anat;
        CrossStateZActsPCA.RatNames{end+1} = ratname;

        CrossStateZActsICA.SessionNames{end+1} = basename;
        CrossStateZActsICA.Anatomies{end+1} = anat;
        CrossStateZActsICA.RatNames{end+1} = ratname;

        %% Load data for this session
        tp = load(pfname);
        ti = load(ifname);

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
%             fnp = fieldnames(tp.CrossStateAssembliesZScorePCA);
%             for b = 1:length(fnp)
%                 eval(['CrossStateZActsPCA.' fnp{b} ' = [];'])
%             end
%             fni = fieldnames(ti.CrossStateAssembliesZScoreICA);
%             for b = 1:length(fni)
%                 eval(['CrossStateZActsICA.' fni{b} ' = [];'])
%             end
            states = tp.CrossStateAssembliesZScorePCA.states;
            CrossStateZActsPCA.states = tp.CrossStateAssembliesZScorePCA.states;
            CrossStateZActsICA.states = ti.CrossStateAssembliesZScoreICA.states;
            for b = 1:length(states)
                tst = states{b};
                eval(['CrossStateZActsPCA.' tst 'AbsoluteActsNormOverRate_PCA = [];'])
                eval(['CrossStateZActsICA.' tst 'AbsoluteActsNormOverRate_ICA = [];'])
            end
        end
        
        counter = counter+1;
        
        for b = 1:length(states)
            tst = states{b};
            eval(['CrossStateZActsPCA.' tst 'AbsoluteActsNormOverRate_PCA = cat(1,CrossStateZActsPCA.' tst 'AbsoluteActsNormOverRate_PCA,tp.CrossStateAssembliesZScorePCA.' tst 'AbsoluteActsNormOverRate_PCA);'])
            eval(['CrossStateZActsICA.' tst 'AbsoluteActsNormOverRate_ICA = cat(1,CrossStateZActsICA.' tst 'AbsoluteActsNormOverRate_ICA,ti.CrossStateAssembliesZScoreICA.' tst 'AbsoluteActsNormOverRate_ICA);'])
%             for c = 1:length(states);
%                 tpcaname = ['PCAAss' states{b} 'onto' states{c}];
%                 ticaname = ['ICAAss' states{b} 'onto' states{c}];
            eval(['CrossStateZActsPCA.num' tst 'Ass(counter) = size(tp.CrossStateAssembliesZScorePCA.' tst 'AbsoluteActsNormOverRate_PCA,2);'])
            eval(['CrossStateZActsICA.num' tst 'Ass(counter) = size(ti.CrossStateAssembliesZScoreICA.' tst 'AbsoluteActsNormOverRate_ICA,2);'])
        end
    end
end

CrossStateZActsPCA.NumRats = length(unique(CrossStateZActsPCA.RatNames));
% 
% savestr = ['UPSpindlTemplateData',date];
% 
% if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
%     mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
% end
% save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
