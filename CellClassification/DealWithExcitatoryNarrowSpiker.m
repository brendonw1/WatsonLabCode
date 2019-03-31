function [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker...
    (excitnarrow, CellIDs, CellClassificationOutput, funcsynapses)
% function [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker...
%     (excitnarrow, CellIDs, CellClassificationOutput, funcsynapses)
% test for by looking for 
% excitnarrow = union(funcsynapses(1).ECells,find(CellClassOutput(:,4));
% if ~isempty(excitnarrow);
%     [CellIDs,CellClassOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(basename, CellIDs,CellClassOutput,funcsynapses);
% end


% 1. display cnxns of those cells using FindSynapses_Review...
invisfig = FindSynapse_ReviewOutput(funcsynapses,[],'fs2',excitnarrow);

% 2. display full population
figure;
x = CellClassificationOutput.CellClassOutput(:,2);
y = CellClassificationOutput.CellClassOutput(:,3);
xx = [0 0.8];
yy = [2.4 0.4];
m = diff( yy ) / diff( xx );
b = yy( 1 ) - m * xx( 1 );  % y = ax+b
ClusterPointsBoundaryOutBW_NOCLICK([x y],excitnarrow,[],m,b);
for a = 1:length(excitnarrow)
    text(x(excitnarrow(a)),y(excitnarrow(a)),num2str(excitnarrow(a)))
end
title ('Green are cells in question.  No need to click, just for examination')

% 3. inputdlg: "Which cells are really I Cells?"
p = 'Which cells should be switched to I Cell Status?  (Enter space-separated numbers):';
options.Resize = 'on';options.WindowStyle = 'normal';
chglist = inputdlg(p, 'Swap cell labels', 2,{num2str(excitnarrow)},options);
chglist = str2num(chglist{:}); 
% [~,chgidx] = ismember(chglist,excitnarrow); 
% chgvect = zeros(size(excitnarrow));
% chgvect(chgidx) = 1;

% 4. Using I or E decisions, alter CellClassOutput,CellIDs,funcsynapses
% for I cells, change funcsyn cnxns to bad, change CellIDs to ILike/IAll,
% change CellClassOutput (:,5) to 0
% for E cells, keep funcsyn, change CellIDs to EDef/EAll, change
% CellClassOutput(:,5) to 1
badcnxns = [];
for a = 1:length(excitnarrow)%for each F
    thiscell = excitnarrow(a);
    if ismember(thiscell,chglist);%if supposed to change this away from "excitatory"
        %get rid of bad Econnections from this cell in funcsynapses struct
        %using badcnxns later in FindSynapseToStruct
        badrows = find(funcsynapses.ConnectionsE(:,1)==thiscell);
        badcnxns = cat(1,badcnxns,funcsynapses.ConnectionsE(badrows,:));
        funcsynapses.ECells(funcsynapses.ECells==thiscell) = [];
        
        %change rating of classification by syanpse in CellClassifcationOutput
        if ismember(thiscell,funcsynapses.ICells)
            CellClassificationOutput.CellClassOutput(thiscell,5) = -1;%... to i cell
            %call inhibitory, not excitatory in CellIDs
            CellIDs = ChangeStatusInCellIDs(thiscell,CellIDs,'IDef');
        else
            CellClassificationOutput.CellClassOutput(thiscell,5) = 0;%else, to neutral
            %call inhibitory, not excitatory in CellIDs
            CellIDs = ChangeStatusInCellIDs(thiscell,CellIDs,'ILike');
        end
    else %if to leave this cell as excitatory
        %call excitatory in CellIDs
        CellIDs = ChangeStatusInCellIDs(thiscell,CellIDs,'EDef');
        %change rating of classification by syanpse to E, in
        %CellClassifcationOutput, if there is synaptic evidence for it
        if ismember(thiscell,funcsynapses.ECells)%I think this is unnecessary
            CellClassificationOutput.CellClassOutput(thiscell,5) = 1;
        else
            CellClassificationOutput.CellClassOutput(thiscell,5) = 0;%to neutral
        end
    end
end

funcsynapses = FindSynapseToStruct(funcsynapses,badcnxns,[]);

if ishandle(invisfig)
    ifd = get(invisfig,'UserData');
    for a = 1:length(ifd.allreviewfigs);
        if ishandle(ifd.allreviewfigs(a))
            delete(ifd.allreviewfigs(a))
        end
    end
    delete(invisfig);
end
