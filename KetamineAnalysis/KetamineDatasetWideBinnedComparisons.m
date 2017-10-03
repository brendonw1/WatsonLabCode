function [h,stats] = KetamineDatasetWideBinnedComparisons(int1label,int2label,centeringmetric)

if ~exist('centeringmetric','var')
    centeringmetric = '@median';
end
if ~strcmp(centeringmetric(1),'@');
    centeringmetric = ['@' centeringmetric];
end

stateNames = {'','WAKE','MA','NREM','REM'};

%% later for saving
savedir = fullfile(getdropbox,'Data','Analyses','BinnedDataByIntervalPairs');
namebase = [int1label '_V_' int2label '_by' upper(centeringmetric(2)) centeringmetric(3:end)];
matsavename = fullfile(savedir,[namebase,'.mat']);


%% Get list of datasets
[names,dirs]=GetKetamineDataset;
if ~exist(dirs{1},'dir')%if no laptop basically    
    folderpath = fullfile(getdropbox,'Data','KetamineDataset');
    d = getdir(folderpath);
    names = {};
    dirs = {};
    for a = 1:length(d);
        if d(a).isdir
            names{end+1} = d(a).name;
            dirs{end+1} = fullfile(folderpath,d(a).name);
        end
    end
end

%% Set up data we will want to study
int1data = {};
int2data = {};
keta = [];
sal = [];
mk = [];

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
%     disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
     
    filepath = fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']);
    if exist(filepath,'file')
        load(fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']));
        eval(['t = KetamineBinnedDataByIntervalState.' int1label ';'])
        int1data(end+1,:) = reshapeStateStructToStateCell(t,stateNames);
        eval(['t = KetamineBinnedDataByIntervalState.' int2label ';'])
        int2data(end+1,:) = reshapeStateStructToStateCell(t,stateNames);
        
        load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionType');
        switch lower(InjectionType)
            case 'ketamine'
                keta(end+1) = size(int2data,1);
            case 'saline'
                sal(end+1) = size(int2data,1);
            case 'mk801'
                mk(end+1) = size(int2data,1);
        end                
    end
end

[h,stats] = InjClassPrePostByState(int1data,int2data,{keta,sal,mk},centeringmetric,stateNames);
subplot(3,5,7);title('Ketamine','rotation',90,'position',[-3.9 1.35 1])
subplot(3,5,6);title('Saline','rotation',90,'position',[-1 .85 1])
subplot(3,5,11);title('MK801','rotation',90,'position',[-1 .5 1])
AboveTitle([int1label ' V ' int2label])
set(h,'name',namebase)

save(matsavename,'stats');
savefigsasindir(savedir,h);


function cellout = reshapeStateStructToStateCell(datain,stateNames)
if isfield(datain,'int1vals')
    for a = 1:length(stateNames);
        eval(['cellout{1,a} = datain.int1' stateNames{a} 'vals;']);
    end
elseif isfield(datain,'int2vals')
    for a = 1:length(stateNames);
        eval(['cellout{1,a} = datain.int2' stateNames{a} 'vals;']);
    end
end    


function [h,stats] = InjClassPrePostByState(in1,in2,injcell,centeringmetric,stateNames)
h = figure;
subplot(length(injcell),5,1);
nstates = 5;

counter = 0;
for a = 1:length(injcell)% for each kind of injection (d1)
    for b = 1:nstates %for all/wake/nrem/rem etc
        counter = counter+1;
        t1 = in1(injcell{a},b);
        t2 = in2(injcell{a},b);
        
%         for each pairwise comparison extract stats
%             - ranksum or ttest (look at distros to see if gaussian)
%             - put asterisk in color of the line if signif
        tp = [];
        for c = 1:length(t1);
            try
                tp(c) = ranksum(t1{c},t2{c});
            catch
                tp(c) = nan;
            end
        end
        RankPs{a,b} = tp;

        eval(['tt1c = cellfun(' centeringmetric ',t1);'])
        eval(['tt2c = cellfun(' centeringmetric ',t2);'])
        t1centers{a,b} = tt1c';
        t2centers{a,b} = tt2c';
        t1stdevs{a,b} = cellfun(@std,t1)';
        t2stdevs{a,b} = cellfun(@std,t2)';
        
        subplot(length(injcell),nstates,counter);
        hold on
        lines = plot([0.5*ones(1,length(tt1c));1.5*ones(1,length(tt2c))],[tt1c'; tt2c'],'o-');
        xlim([0 2])
        
        for c = 1:length(tp);
            if tp(c)<0.001;
                plot(1.75,tt2c(c),'*','color',get(lines(c),'color'))
            end
        end

        if isempty(stateNames{b})
            title('all')
        else
            title(stateNames{b})
        end
    end
end

stats = v2struct(t1centers,t2centers,t1stdevs,t2stdevs,RankPs);
1;

