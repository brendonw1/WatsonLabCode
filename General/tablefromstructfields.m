function t = tablefromstructfields(s,exceptions)

fn = fieldnames(s);

v2struct(s); %need to extract fields as variables since "table" seems to use inputname.m to declare column names
tablecreatestring = 't = table(';

if ~exist('exceptions','var')
    exceptions = inf;
end
if ~isnumeric(exceptions)
   e = exceptions;
   exceptions = [];
   for a = 1:length(e)
       te = strfind(e{a},fn);
       if ~isempty(te)
           exceptions(end+1) = te;
       end
   end 
end

for a = 1:length(fn)
    if ~ismember(a,exceptions);
        tablecreatestring = strcat(tablecreatestring,fn{a},',');
    end
end

tablecreatestring = strcat(tablecreatestring(1:end-1),');');
eval(tablecreatestring);


