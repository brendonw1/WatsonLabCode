function funcsynapses = FindSynapseReDoWrapper(basepath,basename)
% Interrupting in the middle requires delete(get(0,'children')) to close an
% invisible figure
% 
% Inputs (Code for how to get these is below): 
% Sbf - a tsdArray of all spike trains in TSToolbox format.  In this case they have been  burst filtered (ie get rid of spikes within 6 ms of each other)
% Sraw - same as above, but not burst filtered
% shank -  vector, specifies shank number for each cell
% cellIx -  vector, specifies within-shank cell ID number for each cell.
% 
% Outputs:
% funcsynapses - a struct array with just about everything you'd ever need to know about the functional connectivity of your current session including E connections, I connections, lags, amplitudes etc etc.
% 
% To get inputs
% [Sraw,shank,cellIx] = LoadSpikeData(basename,goodshanks);
% Sbf = burstfilter(Sraw,6);%burst filter at 6ms for looking at connections
%
% Brendon Watson 2014

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

% Load: Sbf,Sraw,shank,cellIx
t = load(fullfile(basepath,[basename '_SBurstFiltered.mat']));
Sbf = t.Sbf;
t = load(fullfile(basepath,[basename '_SStable.mat']));
Sraw = t.S;
shank = t.shank;
cellIx = t.cellIx;
% t = load(fullfile(basepath,[basename '_funcsynapses.mat']));
% funcsynapses = t.funcsynapses;
clear t

funcsynapses = FindSynapseWrapper(Sbf,Sraw,shank,cellIx);
% MoveFile old funcsynapses, save new version
movefile(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']),fullfile(basepath,[basename '_funcsynapsesMoreStringentPreReview.mat']))
save(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']),'funcsynapses')