function [CrossStateActsPCA,CrossStateActsICA] = Assemblies_GatherCrossStateMeans(secondsperbin)

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
CrossStateActsPCA.SessionNames = {};
CrossStateActsPCA.RatNames = {};
CrossStateActsPCA.Anatomies = {};
CrossStateActsPCA.NumRats = 0;

CrossStateActsICA.SessionNames = {};
CrossStateActsICA.RatNames = {};
CrossStateActsICA.Anatomies = {};
CrossStateActsICA.NumRats = 0;

% CrossStateActs.NumWakeEAssemblies = [];
% CrossStateActs.NumMWakeEAssemblies = [];
% CrossStateActs.NumNMWakeEAssemblies = [];
% CrossStateActs.NumUPEAssemblies = [];
% CrossStateActs.NumSUPEAssemblies = [];
% CrossStateActs.NumSpindleEAssemblies = [];
% CrossStateActs.NumNDSpindleEAssemblies = [];
% CrossStateActs.NumREMEAssemblies = [];

% 
% fn = fieldnames(UPSpindlTemplateData);
% fn = fn(6:end);
% nf = length(fn);

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    pfname = fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesPCA_' num2str(secondsperbin) 'sec.mat']);
    ifname = fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesICA_' num2str(secondsperbin) 'sec.mat']);
    
    if exist(pfname,'file') && exist(ifname,'file')
       
       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        CrossStateActsPCA.SessionNames{end+1} = basename;
        CrossStateActsPCA.Anatomies{end+1} = anat;
        CrossStateActsPCA.RatNames{end+1} = ratname;

        CrossStateActsICA.SessionNames{end+1} = basename;
        CrossStateActsICA.Anatomies{end+1} = anat;
        CrossStateActsICA.RatNames{end+1} = ratname;

        %% Load data for this session
        tp = load(pfname);
        ti = load(ifname);
        states = tp.CrossStateAssembliesPCA.states;

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
%             fnp = fieldnames(tp.CrossStateAssembliesPCA);
%             for b = 1:length(fnp)
%                 eval(['CrossStateActsPCA.' fnp{b} ' = [];'])
%             end
%             fni = fieldnames(ti.CrossStateAssembliesICA);
%             for b = 1:length(fni)
%                 eval(['CrossStateActsICA.' fni{b} ' = [];'])
%             end
            CrossStateActsPCA.states = tp.CrossStateAssembliesPCA.states;
            CrossStateActsICA.states = ti.CrossStateAssembliesICA.states;
            for b = 1:length(states)
                tst = states{b};
                eval(['CrossStateActsPCA.' tst 'ActsOverRateNorm_PCA = [];'])
                eval(['CrossStateActsICA.' tst 'ActsOverRateNorm_ICA = [];'])
            end
        end
        
        counter = counter+1;
        
        for b = 1:length(states)
            tst = states{b};
            eval(['CrossStateActsPCA.' tst 'ActsOverRateNorm_PCA = cat(1,CrossStateActsPCA.' tst 'ActsOverRateNorm_PCA,tp.CrossStateAssembliesPCA.' tst 'ActsOverRateNorm_PCA);'])
            eval(['CrossStateActsICA.' tst 'ActsOverRateNorm_ICA = cat(1,CrossStateActsICA.' tst 'ActsOverRateNorm_ICA,ti.CrossStateAssembliesICA.' tst 'ActsOverRateNorm_ICA);'])
%             for c = 1:length(states);
%                 tpcaname = ['PCAAss' states{b} 'onto' states{c}];
%                 ticaname = ['ICAAss' states{b} 'onto' states{c}];
            eval(['CrossStateActsPCA.num' tst 'Ass(counter) = size(tp.CrossStateAssembliesPCA.' tst 'ActsOverRateNorm_PCA,1);'])
            eval(['CrossStateActsICA.num' tst 'Ass(counter) = size(ti.CrossStateAssembliesICA.' tst 'ActsOverRateNorm_ICA,1);'])
        end
    end
end

CrossStateActsPCA.NumRats = length(unique(CrossStateActsPCA.RatNames));
CrossStateActsICA.NumRats = length(unique(CrossStateActsICA.RatNames));
% 
% savestr = ['UPSpindlTemplateData',date];
% 
% if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
%     mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
% end
% save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
