function UPDownOnOffRatios(basepath,basename,binwidthsecs)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
if ~exist('binwidthsecs','var')
    binwidthsecs = 10;
end

%prep up/down/on/off data at ms timescale
load(fullfile(basepath,[basename '_UPDOWNIntervals']))
ubools = inttobool(StartEnd(UPInts,'ms'));%millisecond timescale UP state status
dbools = inttobool(StartEnd(DNInts,'ms'));%Down states
nbools = inttobool(StartEnd(ONInts,'ms'));% On states
fbools = inttobool(StartEnd(OFFInts,'ms'));% OFF states
maxms = max([length(ubools) length(dbools) length(nbools) length(fbools)]);

ubools = padvecttolength(ubools,maxms);
ubools(isnan(ubools)) = 0;
dbools = padvecttolength(dbools,maxms);
dbools(isnan(dbools)) = 0;
nbools = padvecttolength(nbools,maxms);
nbools(isnan(nbools)) = 0;
fbools = padvecttolength(fbools,maxms);
fbools(isnan(fbools)) = 0;

% set up bins
binstartends = 1:binwidthsecs:round(maxms/1000);
binstartends(end+1) = binstartends(end)+binwidthsecs;
if binstartends(end) == binstartends(end-1)
    binstartends(end) = [];
end
bincentertimes = mean([binstartends(1:end-1)' binstartends(2:end)'],2);

up_pct = zeros(length(bincentertimes),1);
dn_pct = zeros(length(bincentertimes),1);
on_pct = zeros(length(bincentertimes),1);
off_pct = zeros(length(bincentertimes),1);
upvdn_pct = nan(length(bincentertimes),1);
onvoff_pct = nan(length(bincentertimes),1);
nonud_pct = nan(length(bincentertimes),1);
nonnf_pct = nan(length(bincentertimes),1);

% calculate ratios
for a = 1:(length(bincentertimes)-1);
    stu = sum(ubools(binstartends(a)*1000 : binstartends(a+1)*1000-1));
    std = sum(dbools(binstartends(a)*1000 : binstartends(a+1)*1000-1));
    up_pct(a) = stu/(1000*binwidthsecs);
    dn_pct(a) = std/(1000*binwidthsecs);
    nonud_pct(a) = 1-nanmax([0 up_pct(a)])-nanmax([0 dn_pct(a)]);
    if stu && std
        upvdn_pct(a) = stu/(stu+std);
    end
    
    stn = sum(nbools(binstartends(a)*1000 : binstartends(a+1)*1000-1));
    stf = sum(fbools(binstartends(a)*1000 : binstartends(a+1)*1000-1));
    on_pct(a) = stn/(1000*binwidthsecs);
    off_pct(a) = stf/(1000*binwidthsecs);
    nonnf_pct(a) = 1-nanmax([0 on_pct(a)])-nanmax([0 off_pct(a)]);
    if stn && stf
        onvoff_pct(a) = stn/(stn+stf);
    end
end

UPDownOnOffRatios = v2struct(binwidthsecs,bincentertimes,...
    up_pct,dn_pct,on_pct,off_pct,upvdn_pct,onvoff_pct,nonud_pct,nonnf_pct);
save(fullfile(basepath,[basename '_UPDownOnOffRatios.mat']),'UPDownOnOffRatios')
% save(fullfile(basepath,[basename '_UPDownOnOffRatios.mat']),'UPDownOnOffRatios','issi','-v7.3');
