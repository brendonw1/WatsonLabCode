function [movementsecs,varargout] = FilterAndBinaryDetectMotion(basepath,basename,motion,filttype,filtwidth,plotting)
% Takes motion signal at 1second resolution (ie from StateEditor) and
% zscores/filters/subtracts to allow for binary detection of motion on a
% smooth background
% INPUT
% motion: vector of 1 second long bins of motion measure
%
% OUTPUT
% movementsecs - logical output of 1's where movement detected (at
%                0.75*sd), 0s where no movement

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('motion','var')
    if exist([fullfile(basepath,[basename '.eegstates.mat'])],'file')
        t = load([fullfile(basepath,basename) '.eegstates.mat']);
        motion = t.StateInfo.motion;
        clear t
    elseif exist([fullfile(basepath,[basename '_Motion.mat'])],'file')
        load([fullfile(basepath,basename) '_Motion.mat'],'motiondata')
        motion = motiondata.motion;
        clear motiondata
%     elseif exist([fullfile(basepath,[basename '_EMGCorr.mat'])],'file')
%         tfile = fullfile(basepath,[basename '_EMGCorr.mat']);
    end
end

if ~exist('filttype','var')
    filttype = 'clean';%default
end
if ~exist('filtwidth','var')
    filtwidth = 20;%default, in timepoints(seconds if 1hz file)
end

if ~exist('plotting','var')
    plotting = 1;
end

fm = filtermotionsig(motion,filtwidth);

switch filttype
    case 'clean'
        % hardthresh = -mean(zf(zf<0));
        tm = fm>.75;
    case 'noisybaseline'
                %gonna zscore in a weird way: first use mode, not mean, then divide by sd
        %of noise below that modal value... assumes symmetrical noise
        fm = fm-mode(fm);%subtract mode
        negdist = fm(fm<0);%get negative part of distribution
        negdist = cat(1,negdist,-negdist);%make a reflection about zero to double this half-gaussian
        snd = std(negdist);%get the SD of this noise
        zf = fm/snd;%divide the signal by the sd of this noise

        % hardthresh = -mean(zf(zf<0));
        tm = zf>10;
        tm = tm + [0;tm(2:end)];
        % tm = tm>=2;
end
        
movementsecs = tm;

if plotting
    h = figure;
    zm = zscore(motion);
    plot(zm);
    hold on;
    plot(movementsecs,'r')
    if nargout ==2;
        varargout{1} = h;
    end
end

%% ask user if this method was appropriate
strs = {'Clean (Baseline fluct OK)';'High Freq Noise'};
[s,v] = listdlg('PromptString','Keep clean baseline assumption?','SelectionMode','single','ListString',strs);

strs2 = {'clean','noisybaseline'};
postreviewfilttype = strs2(s);

%% If necessary, refilter using mode asked by user
if ~strcmp(postreviewfilttype,filttype)
    close(h)
    movementsecs = FilterAndBinaryDetectMotion(basepath,basename,motiondata.motion,motiondata.filttype,20,1);
end

%%
title([basename,' ',postreviewfilttype,'.  Final Detection'])

%% Find periods of non-movement for at least 10sec
move5sepochs = continuousabove2(movementsecs,0.5,5);
move5sepochsecs = inttobool(move5sepochs,length(movementsecs));

nonmove10sepochs = continuousbelow2(movementsecs,0.5,10);
nonmove10sepochsecs = inttobool(nonmove10sepochs,length(movementsecs));

%% save
motiondata.motion = motion;
motiondata.filttype = postreviewfilttype;
motiondata.thresholdedsecs = movementsecs;
motiondata.move5sepochsecs = move5sepochsecs;
motiondata.nonmove10sepochsecs = nonmove10sepochsecs;

save([fullfile(basepath,basename) '_Motion.mat'],'motiondata')
%     motiondata.thresholdedsecs = movementsecs;


function motion = LoadTimeStampValuePairs(tos,fname,varname);
if ~exist('varname','var')
    t = load(fname);
else
    t = load(fname,varname);
end
fn = fieldnames(t);
t = getfield(t,fn{1});
vals = t(:,2);
times = t(:,1);
motion = ResampleTolerant(vals,length(tos),length(times));


