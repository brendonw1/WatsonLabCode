function ConvertAllCnxnsToBurstFilter_Subfunc(basename,basepath,S,shank,cellIx,oldfuncsynapses)

cd(basepath)

% burst filter
Sbf = burstfilter(S,6);
save([basename,'_SBurstFiltered.mat'],'Sbf');

% move old funcsynapses over
% oldfs = fullfile(basepath,[basename,'_funcsynapses.mat']);
oldCnxnFigsDir = fullfile(basepath,'ConnectionFigs');
oldZeroDir = fullfile(basepath,'ZeroLagAndWideFigs');

alreadyZeroDir = fullfile(basepath,'ZeroLagAndWideFigs_preBF');
alreadyCnxnFigsDir = fullfile(basepath,'ConnectionFigs_preBF');

% if exist(oldfs,'file')
%     copyfile(oldfs,fullfile(basepath,[basename '_funcsynapses_preBF.mat']));
% end
if exist(alreadyCnxnFigsDir,'dir') && exist(oldCnxnFigsDir,'dir')
    try
        eval(['! rm -R ' oldCnxnFigsDir])
    catch
        disp('couldn''t rm oldCnxnsDir')
    end
end
if exist(alreadyZeroDir,'dir') && exist(oldZeroDir,'dir')
    try
        eval(['! rm -R ' oldZeroDir])
    catch
        disp('couldn''t rm oldZeroDir')
    end
end

if exist(oldCnxnFigsDir,'dir')
    movefile(oldCnxnFigsDir,fullfile(basepath,'ConnectionFigs_preBF'))
end
if exist(oldZeroDir,'dir')
    movefile(oldZeroDir,fullfile(basepath,'ZeroLagAndWideFigs_preBF'))
end


% read bad cnxns from original (already loaded)

% generate funcconections now
funcsynapses = Make_FindSynapse_bw(S,shank,cellIx);%a wrapper which uses the usual lab CCG.m rather than yours and stores away a few parameters into a struct
funcsynapses = Make_FindZeroLagCorr_bw(S,shank,funcsynapses);%to find zero-lag interactions
funcsynapses = FindSynapseToStruct(funcsynapses);%interprets FindSynapse.m output to classify connections and cells as E or I

% get old versions of badcnxns and widecnxns (should be stable, refer to
% cell id's)
badcnxns = oldfuncsynapses.BadConnections;
widecnxns = oldfuncsynapses.WideConnections;
if isfield(oldfuncsynapses,'OriginalConnectivity')
    if isfield(oldfuncsynapses.OriginalConnectivity,'BadConnections')
        badcnxns = cat(1,badcnxns,oldfuncsynapses.OriginalConnectivity.BadConnections);
        widecnxns = cat(1,widecnxns,oldfuncsynapses.OriginalConnectivity.WideConnections);
        badcnxns = unique(badcnxns,'rows');
        widecnxns = unique(widecnxns,'rows');
    end
end
if isfield(oldfuncsynapses,'MostRecentConnectivity')
    if isfield(oldfuncsynapses.MostRecentConnectivity,'BadConnections')
        badcnxns = cat(1,badcnxns,oldfuncsynapses.MostRecentConnectivity.BadConnections);
        widecnxns = cat(1,widecnxns,oldfuncsynapses.MostRecentConnectivity.WideConnections);
        badcnxns = unique(badcnxns,'rows');
        widecnxns = unique(widecnxns,'rows');
    end
end
funcsynapses = FindSynapseToStruct(funcsynapses,badcnxns,widecnxns);    


% Review each day's output
if ~isempty(funcsynapses.ConnectionsE) | ~isempty(funcsynapses.ConnectionsI)
    FindSynapse_ReviewOutput(funcsynapses, 'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end
if ~isempty(funcsynapses.ZeroLag.EPairs) | ~isempty(funcsynapses.ZeroLag.IPairs)
    if ~isempty(get(0,'children'))
        % wait for the prior step to finish
        h = figure('Visible','Off','Name','BWWaitFig');
        waitfor(h,'Name','DELETEMENOW')% once FindSynapse_ReviewOutput is done... (ie once it renames this figure)
        delete(h)%... close the figure and proceed
    end
    
    FindSynapse_ReviewZeroAndWide(funcsynapses, 'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end



% %save edited connectivity figs
% d = dir('ConnectionsPresynCell*.fig');
% if ~exist(fullfile(basepath,'ConnectionFigs'),'dir')
%     mkdir(fullfile(basepath,'ConnectionFigs'))
% end
% temppath = (fullfile(basepath,'ConnectionFigs'));
% for a = 1:length(d)
%     movefile(d(a).name,fullfile(temppath,d(a).name))
% end

save([basename '_funcsynapses'],'funcsynapses')
close all