function [names,dirs] = SleepAnalysis_GetDatasetNameDirsFromKetamineSessionMatrix(ketamine,saline,mk801)
% Gives dirs (basepaths/directory paths) and names (basenames) for all
% sessions meeitng the given criteria.  Always includes criteria of
% useforsleep, but may also include status of the following columns: ws,
% synapses, spindles, new, sleepdep, upsundone.
% Brendon Watson 2015


% Defaults
if ~exist('ketamine','var')
    ketamine = 0;
end
if ~exist('saline','var')
    saline = 0;
end
if ~exist('mk801','var')
    mk801 = 0;
end

% 
names = [];
dirs = [];

%
tx = GetKetamineSessionMatrix;
titles = tx(1,:);

for a = 1:size(titles,2)
    if strcmp('Session Name',titles{a})
        namecol = a;
        continue
    end
    if strcmp('Home Folder',titles{a})
        dircol = a;
        continue
    end
    if strcmp('Implant',titles{a})
        implantcol = a;
        continue
    end
    if strcmp('Ketamine',titles{a})
        ketaminecol = a;
        continue
    end
    if strcmp('Saline',titles{a})
        salinecol = a;
        continue
    end
    if strcmp('mk801',lower(titles{a}))
        mk801col = a;
        continue
    end
end


%% cycle through each session and assess whether to keep
for a = 2:size(tx,1)

    ketaminecolval = getnumericvaluefromtx(tx,a,ketaminecol);
    salinecolval = getnumericvaluefromtx(tx,a,salinecol);
    mk801colval = getnumericvaluefromtx(tx,a,mk801col);
    if (ketaminecolval+salinecolval+mk801colval)%if at least one of these
        go = zeros(1,3);
        if ~ketamine%if not required
            go(1) = 1;%give green light
        else%otherwise test for some non-zero value
            if ketaminecolval
                go(1) = 1;
            end
        end
        if ~saline%if not required, go ahead
            go(2) = 1;
        else%if required, check if go
            if salinecolval
                go(2) = 1;
            end
        end
        if ~mk801%if not required, go ahead
            go(3) = 1;
        else%if required, check if go
            if mk801colval
                go(3) = 1;
            end
        end

    %%        
        if prod(go)
            tname = tx{a,namecol};
            if isempty(tname);
                error(['Empty name slot at row ' num2str(a)])
                break
            end
            tdir = tx{a,dircol};
            if isempty(tdir);
                error(['Empty dir slot at row ' num2str(a)])
                break
            end
            names{end+1} = tname;
            dirs{end+1} = tdir;
        else
            1;
        end       
    end
end


function val = getnumericvaluefromtx(tx,rownum,colnum)
% Gets out a numeric value from a given column or row, if not a numeric
% there, defaults to zero

val = 0;
x = tx{rownum,colnum};
if ~isempty(x)
    x = str2num(x);
    if ~isempty(x)
        val = x;
    end
end        
                