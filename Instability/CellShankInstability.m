function [shankinstabilityints,cellpastthreshbools] = CellShankInstability(basename,shanknum,varargin)

%Parameters
% should do zscore... outside of abs(zscore)...

%Defaults
binsecs = 30;%bin width
cutoffthresh = 0.33;%proportion of normal (median) rate each cell rate must be below
mindeviationprop = 0.05;%must be unstable at least this proportion of the total recording length
mindeviationtime = 300;%seconds it must be away from that rate
for a  = 1:length(varargin)
   switch a
       case 'binsecs'
           binsecs = varargin{a+1};
       case 'cutoffthresh'
           cutoffthresh = varargin{a+1};
       case 'mindeviationprop'
           mindeviationprop = varargin{a+1};
       case 'mindeviationtime'
           mindeviationtime = varargin{a+1};
   end           
end

par = LoadPar([basename '.xml']);
totalfilesecs = GetFileSecsFromDir(basename);
samprate = par.SampleRate;%sampling rate of fet file
binsamps = binsecs * samprate;%calculated samples per bin
binoversamprate = 5;%how densely to oversample the bins... 1/this determines how much to slide bin over by
smoothingnumbins = 5;%will smooth spike rate by this much

mindeviationtime = max([mindeviationtime mindeviationprop*totalfilesecs]);

interbininterval = binsecs/binoversamprate;
mindeviationnumbins = ceil(mindeviationtime/interbininterval);

shankstr = num2str(shanknum);
fet = LoadFet([basename,'.fet.',shankstr]);
clu = LoadClu([basename,'.clu.',shankstr]);

allclunums = unique(clu);
cluabove1idx = find(allclunums>1,1,'first');
goodclunums = allclunums(cluabove1idx:end);
t = load([basename,'_SStable']);%don't analyze "bad clus" as determined in "BigScript" functions
externalgoodclus = t.cellIx(t.shank==shanknum);
goodclunums = intersect(goodclunums,externalgoodclus);
nclus = length(goodclunums);

% nindepfeatures = length(par.SpkGrps(shanknum).Channels)*par.SpkGrps(a).nFeatures;
maxtime = fet(end,end);
slidebins(:,1) = (0:binsamps:maxtime+binsamps)';
for a = 2:binoversamprate
    slidebins(:,a) = slidebins(:,1)+binsamps*(a-1)/binoversamprate;
end
% binstarts = cat(2,bins1,bins2,bins3,bins4,bins5);
binstarts = reshape(slidebins',numel(slidebins),1);
binstarts = binstarts./samprate;
binstarts(1) = 1;

%% Aggregate a matrix of showing whether each cell was unstable for each bin
cellpastthreshbools = zeros(nclus,ceil(totalfilesecs));
binpastthreshbools = zeros(nclus,length(binstarts));
for a = 1:length(goodclunums)
    tclu = goodclunums(a);
    tidxs = find(clu==tclu);
    ttimes = fet(tidxs,end);
    
    clear cts
    for b = 1:binoversamprate
        cts(:,b) = histc(ttimes,slidebins(:,b));
    end
    cts = reshape(cts',numel(cts),1);%number of spikes per bin
    cts = smooth(cts,smoothingnumbins);%smooth
    
    tcenter = median(cts(cts>0));%median of the non-zero values of counts... may be bad for low rate cells
%     tsd = std(cts);
%     tzdev = abs(cts-tcenter)/tsd;%abs of deviation from mean... to look for either high or low periods
    % could replace line below with something showing too great a deviance,
    % by looking at a z score, take abs of that and look at anything too
    % high for too long
%     tcenter = median(cts(cts>0));%median of the non-zero values of counts... may be bad for low rate cells
%     tsd = std(cts);
%     tzdev = abs(cts-tcenter)/tsd;%abs of deviation from mean... to look for either high or low periods
%     unstabints = continuousabove2(tzdev,cutoffthresh,ceil(mindeviationtime/binsamps)*5,inf);
    unstabints = continuousbelow2(cts,tcenter*cutoffthresh,mindeviationnumbins,inf);
    for b = 1:size(unstabints,1);
       cellpastthreshbools(a,binstarts(unstabints(b,1)):binstarts(unstabints(b,2)))=1;
       binpastthreshbools(a,unstabints(b,1):unstabints(b,2))=1;
    end
end

%% 
unstabunitsperbin = sum(cellpastthreshbools,1);
center = median(unstabunitsperbin);%estimate of center... somewhat resilient to bimodality
zsd = 2*std(unstabunitsperbin(unstabunitsperbin<center));%std of part below mean, then double it to estimate full noise
overallcutoff = max(3,center+2*zsd);

shankinstabilityints = continuousabove2(unstabunitsperbin,overallcutoff,mindeviationnumbins,inf);

%% reformat a tsdarray of cellpastthreshbins for output
% for a = 1:size(cellpastthreshbools,1)
%     ttsd{a} = tsd(binstarts,binpastthreshbools(a,:)');
% end
% cellpastthreshtsds = tsdArray(ttsd);
