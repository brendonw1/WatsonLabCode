function ACGCCGGenerate(basepath,basename)
% Gets and saves CCGs, ACGs, ISIHistos for all cells across states
% specified in basename_StateIntervals.mat (which is from
% GatherStateIntervalSets.m)
% Brendon Watson 2015
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

% load(fullfile(basepath,[basename '_SStable.mat']));
load(fullfile(basepath,[basename '_SStable.mat']));
load(fullfile(basepath,[basename '_StateIntervals.mat']));


%% Parameters
%Static
CCGHalfWidthsinMs = [10 30 100 300 1000 3000];
numHalfBins = [50 60 50 60 1000 60];%static
SampleRate = 10000;%%Based on usual TSD object sample rate<< NEED TO GENERALIZE THIS, HAVEN'T FIGURED OUT HOW YET

%Calculated
msBinSizes = (CCGHalfWidthsinMs./numHalfBins);
numSampsBinSizes = msBinSizes*SampleRate/1000;
HalfWidthInS = CCGHalfWidthsinMs/1000;
BinSizeInS = CCGHalfWidthsinMs./numHalfBins/1000;
numcells = length(S);
%% Get full CCG/ACG/ISIHistos for all pairs 
[T,G] = oneSeries(S);
T = TimePoints(T);

for a = 1:length(CCGHalfWidthsinMs)
    [CCGs{a}, Times{a}] = CCG_noPairs(T, G, numSampsBinSizes(a), numHalfBins(a), SampleRate, unique(G), 'hz'); %calc cross correlograms, output as counts... 3D output array
    if length(unique(G))<size(S,1)%account for a cell not firing in a state
            missing = setdiff(1:length(S),unique(G));%find the missing cells
            CCGs{a} = fillinmissingccg(CCGs{a},missing);
%             missing = setdiff(1:length(S),unique(G));%find the missing cells
%             for b = 1:length(missing)
%                 extra = b-1;%offset in cell idx that will happen as we add (doesn't matter for b = 1
%                 filler = zeros(size(CCGs{a},1),size(CCGs{a},2));
%                 CCGs{a}=cat(3,CCGs{a}(:,:,1:missing(b)-1+extra),filler,CCGs{a}(:,:,missing(b)+extra:end));
%                 filler = zeros(size(CCGs{a},1),1,size(CCGs{a},2)+1);
%                 CCGs{a}=cat(2,CCGs{a}(:,1:missing(b)-1+extra,:),filler,CCGs{a}(:,missing(b)+extra:end,:));
%             end
    end
    for b = 1:size(CCGs{a},2)
        ACGs{a}(:,b) = CCGs{a}(:,b,b); 
    end
    ISIH{a} = ISIHistogram(S,HalfWidthInS(a),BinSizeInS(a))';
end

ACGCCGsAll = v2struct(CCGHalfWidthsinMs,numHalfBins,SampleRate,msBinSizes,numSampsBinSizes,...
    ACGs,ISIH,Times);
% ACGsAll = v2struct(CCGWidthsinMs,numHalfBins,SampleRate,msBinSizes,numSampsBinSizes,...
%     ACGs,Times);

%% Get state-wise acgs
stnames = fieldnames(StateIntervals);
[~,t]=ismember('OFFstates',stnames);
stnames(t)=[];
[~,t]=ismember('DNstates',stnames);
stnames(t)=[];
[~,t]=ismember('LowGamma',stnames);
stnames(t)=[];
for st = 1:length(stnames);
    clear ISIH CCGs ACGs
    eval(['thisS = Restrict(S,StateIntervals.' stnames{st} ');'])
    [T,G] = oneSeries(thisS);
    T = TimePoints(T);
    for a = 1:length(CCGHalfWidthsinMs)
        [CCGs{a}, Times{a}] = CCG_noPairs(T, G, numSampsBinSizes(a), numHalfBins(a), SampleRate, unique(G), 'hz'); %calc cross correlograms, output as counts... 3D output array
        if length(unique(G))<size(S,1)%account for a cell not firing in a state
                    missing = setdiff(1:length(S),unique(G));%find the missing cells
                    CCGs{a} = fillinmissingccg(CCGs{a},missing);
%             missing = setdiff(1:length(S),unique(G));%find the missing cells
%             for b = 1:length(missing)
%                 extra = b-1;%offset in cell idx that will happen as we add (doesn't matter for b = 1
%                 filler = zeros(size(CCGs{a},1),size(CCGs{a},2));
%                 CCGs{a}=cat(3,CCGs{a}(:,:,1:missing(b)-1+extra),filler,CCGs{a}(:,:,missing(b)+extra:end));
%                 filler = zeros(size(CCGs{a},1),1,size(CCGs{a},2)+1);
%                 CCGs{a}=cat(2,CCGs{a}(:,1:missing(b)-1+extra,:),filler,CCGs{a}(:,missing(b)+extra:end,:));
%             end
        end
        for b = 1:size(CCGs{a},2)
            ACGs{a}(:,b) = CCGs{a}(:,b,b); 
        end
        ISIH{a} = ISIHistogram(thisS,HalfWidthInS(a),BinSizeInS(a))';
    end
%     eval(['ACGCCGsAll.' stnames{st} 'CCGs = CCGs;'])
    eval(['ACGCCGsAll.' stnames{st} 'ACGs = ACGs;'])
    eval(['ACGCCGsAll.' stnames{st} 'ISIHs = ISIH;'])
end

if size(ACGCCGsAll.FSWSACGs{1},2) ~= size(ACGCCGsAll.FSWSISIHs{1},2)
    1;
end

save(fullfile(basepath,[basename '_ACGCCGsAll.mat']),'ACGCCGsAll')
1;



function incomparray = fillinmissingccg(incomparray,missing)
%adds missing elements into incomp array, 3d array (ie output from CCG)

origins = mergemissing(1:size(incomparray,2),missing);

filler = zeros(size(incomparray,1),1,size(incomparray,2));
o = [];
ccgnext = 1;
for a = 1:length(origins)
    if origins(a) == 1;
        o = cat(2,o,incomparray(:,ccgnext,:));
        ccgnext = ccgnext+1;
    elseif origins(a) == 2;
        o = cat(2,o,filler);
    end
    
end
incomparray = o;

filler = zeros(size(incomparray,1),size(incomparray,2),1);
o = [];
ccgnext = 1;
for a = 1:length(origins)
    if origins(a) == 1;
        o = cat(3,o,incomparray(:,:,ccgnext));
        ccgnext = ccgnext+1;
    elseif origins(a) == 2;
        o = cat(3,o,filler);
    end
end
incomparray = o;

