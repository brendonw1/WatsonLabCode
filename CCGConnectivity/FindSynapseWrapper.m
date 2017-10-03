function funcsynapses = FindSynapseWrapper(Sbf,Sraw,shank,cellIx)
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


funcsynapses = Make_FindSynapse_bw(Sbf,shank,cellIx);%a wrapper which uses the usual lab CCG.m rather than yours and stores away a few parameters into a struct
funcsynapses = Make_FindZeroLagCorr_bw(Sbf,shank,funcsynapses);%to find zero-lag interactions

funcsynapses = FindSynapseToStruct(funcsynapses);%interprets FindSynapse.m output to classify connections and cells as E or I

funcsynapses = FindSynapse_GetRawCCGMtx(funcsynapses,Sraw);

if ~isempty(funcsynapses.ConnectionsE) | ~isempty(funcsynapses.ConnectionsI)
    FindSynapse_ReviewOutput(funcsynapses,Sraw,'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end

if ~isempty(funcsynapses.ConnectionsE) | ~isempty(funcsynapses.ConnectionsI)
   
    % wait for the prior step to finish
    h = figure('Visible','Off','Name','BWWaitFig');
    waitfor(h,'Name','DELETEMENOW')% once FindSynapse_ReviewOutput is done... (ie once it renames this figure)
    delete(h)%... close the figure and proceed

%     FindSynapse_ReviewZeroAndWide(funcsynapses, 'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end