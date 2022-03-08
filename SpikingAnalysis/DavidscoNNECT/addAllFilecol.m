function [SeeEsVee] = addAllFilecol(nicvar,csv,sizes)
%this is just for the Reformatting function that Nicolette's data uses
    if nicvar
        allfilestartcol = array2table(NaN(max(sizes),1));
        allfilestartcol.Properties.VariableNames = {'AllFile_start'};
        csv = [csv allfilestartcol];
    end

    SeeEsVee = csv;
end