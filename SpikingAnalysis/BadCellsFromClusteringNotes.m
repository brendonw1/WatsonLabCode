function manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx)

manualbadcells = [];
renumbool = questdlg('Did you renumber and save in Klusters?');
switch renumbool
    case 'Yes'
        renumbool = 1;
    case 'No'
        renumbool = 0;
end

if exist([basename '_ClusteringNotes.csv'],'file')
    tx = read_mixed_csv([basename '_ClusteringNotes.csv'],',');
    % Par = LoadPar([basename '.xml']);

    titles = tx(1,:);
    empties = [];
    for a = 1:length(titles)
        if isempty(titles{a})
            empties(end+1) = a; 
        end
    end
    titles(empties) = [];
    
    ucol = strmatch('Unstable',titles);
    ucol = ucol + sum(empties<ucol);
    
    shankcol = strmatch('ClusterGroup',titles);
    shankcol = shankcol + sum(empties<shankcol);

    switch renumbool
        case 1
        cellidcol = strmatch('KlustersID',titles);
        case 0
        cellidcol = strmatch('KlustaViewaID',titles);
    end
    cellidcol = cellidcol + sum(empties<cellidcol);

    for a = 2:size(tx,1)%go thru each cell
        thistx = lower(tx{a,ucol});
        if isempty(thistx) 
            negative = 1;
        elseif strcmp(thistx,'n') | strcmp(thistx,'no') | strcmp(thistx,'0')% 0 and n are negative answers, all others considered positive
            negative = 1;
        else 
            negative = 0;
        end
        if ~negative    %Check if anything other than some negative or empty answers in unstable column;
            if strcmp(lower(tx{a,cellidcol}),'all')    %if it says "all" in id column, label all
                                                %cells in that column
                sh = str2num(tx{a,shankcol});
                allc = find(shank==sh);
                manualbadcells = cat(1,manualbadcells,allc);
            else
                sh = str2num(tx{a,shankcol});
                ci = str2num(tx{a,cellidcol});
%                 try 
                    bc = find([shank==sh] .* [cellIx==ci]);
                    if isempty(bc)
                        error(['Possible error in ClusteringNotes at line ' num2str(a)]);
                    end
                    manualbadcells = cat(1,manualbadcells,bc);
%                 catch
%                     warning(['Warning row ' num2str(a) 'did not get assigned as expected']) 
%                 end
            end
        end
    end
else
    warning('No ClusteringNotes.csv');
end
