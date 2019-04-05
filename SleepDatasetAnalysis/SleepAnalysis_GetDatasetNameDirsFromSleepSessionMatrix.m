function [names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(ws,synapses,spindles,new,sleepdep,upsundone,hippocampus)
% Gives dirs (basepaths/directory paths) and names (basenames) for all
% sessions meeitng the given criteria.  Always includes criteria of
% useforsleep, but may also include status of the following columns: ws,
% synapses, spindles, new, sleepdep, upsundone.
% Brendon Watson 2015


% Defaults
if ~exist('ws','var')
    ws = 0;
end
if ~exist('synapses','var')
    synapses = 0;
end
% if ~exist('spindles','var')
%     spindles = 0;
% end
if ~exist('new','var')
    new = 0;
end
if ~exist('SleepDep','var')
    sleepdep = 0;
end
if ~exist('upsundone','var')
    upsundone = 0;
end
if ~exist('hippocampus','var')
    hippocampus = 0;
end

% 
names = [];
dirs = [];

%
tx = SleepAnalysis_GetSleepSessionMatrix;
titles = tx(1,:);

for a = 1:size(titles,2)
    if strcmp('Session Name',titles{a})
        namecol = a;
        continue
    end
    if strcmp('Use for Sleep',titles{a})
        useforsleepcol = a;
        continue
    end
    if strcmp('Use for Spindles',titles{a})
        useforspindlescol = a;
        continue
    end
    if strcmp('# Cnxns',titles{a})
        cnxnscol = a;
        continue
    end
    if strncmp('Good WS',titles{a},7)
        wscol = a;
        continue
    end
    if strcmp('Home Folder',titles{a})
        dircol = a;
        continue
    end
    if strcmp('New',titles{a})
        newcol = a;
        continue
    end
    if strcmp('Sleep Dep',titles{a})
        sleepdepcol = a;
        continue
    end
    if strcmp('UPs Undone',titles{a})
        upsundonecol = a;
        continue
    end
    if strcmp('Hippocampus',titles{a})
        hippocampuscol = a;
        continue
    end
end


%% cycle through each session and assess whether to keep
for a = 2:size(tx,1)
    go = zeros(1,3);
%     if a == 68
%         1;
%     end
    useforsleep = getnumericvaluefromtx(tx,a,useforsleepcol);
    if useforsleep && ~isempty(tx{a,useforsleepcol}) 
%     if ~useforsleep && ~isempty(tx{a,useforsleepcol}) 
        if ~synapses%if not required
            go(1) = 1;%give green light
        elseif synapses%otherwise test for some non-zero value
            numcnxns = getnumericvaluefromtx(tx,a,cnxnscol);
            if numcnxns
                go(1) = 1;
            end
        end
        if ~ws%if not required
            go(2) = 1;%give green light
        elseif ws%otherwise test for some non-zero value
            wsstatus = getnumericvaluefromtx(tx,a,wscol);
            if wsstatus
                go(2) = 1;
            end
        end
%         if ~spindles
%             go(3) = 1;
%         elseif spindles
%             useforspindles = getnumericvaluefromtx(tx,a,useforspindlescol);
%             if useforspindles
                go(3) = 1;
%             end
%         end
        if ~new%if not required, go ahead
            go(4) = 1;
        elseif new%if required, check if go
            usefornew = getnumericvaluefromtx(tx,a,newcol);
            if usefornew
                go(4) = 1;
            end
        end
        if ~sleepdep%if not required, go ahead
            go(5) = 1;
        elseif sleepdep%if required, check if go
            useforsleepdep = getnumericvaluefromtx(tx,a,sleepdepcol);
            if useforsleepdep
                go(5) = 1;
            end
        end
        if ~upsundone%if not required, go ahead
            go(6) = 1;
        elseif upsundone%if required, check if go
            useforupsundone = getnumericvaluefromtx(tx,a,upsundonecol);
            if useforupsundone
                go(6) = 1;
            end
        end
        if ~hippocampus%if not required, go ahead
            go(7) = 1;
        elseif hippocampus%if required, check if go
            useforhippocampus = getnumericvaluefromtx(tx,a,hippocampuscol);
            if useforhippocampus
                go(7) = 1;
            else
                go(7) = 0;
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
                