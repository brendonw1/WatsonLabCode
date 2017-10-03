function fm = filtermotionsig(motion,filtwidth)
% Takes motion signal at 1second resolution (ie from StateEditor) and
% zscores/filters/subtracts to  smooth background
% INPUT
% motion: vector of 1 second long bins of motion measure
%
% OUTPUT
% fm - filtered motion



motion = motion(:);
motion(isnan(motion))=0;

if ~exist('filtwidth','var')
    filtwidth = 20;%default, in timepoints(seconds if 1hz file)
end
zm = zscore(motion);
sm = smooth(zm,filtwidth);
dm = zm-sm;


env = hilbertenvelope(dm);
senv = smooth(-env,filtwidth);
fm = dm-senv;
% thm = dm>0;
% motionsampfreq = 1;
% [b,a] = butter(4,([.1/(0.5*motionsampfreq)]),'high');%create highpass filter for high gamma >100Hz
% fm = filtfilt(b,a,zm);
