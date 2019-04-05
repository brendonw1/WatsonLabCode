function ExecuteOnDatasets(executestring,varargin)

if isempty(varargin)
    SleepDataset_ExecuteOnDatasets(executestring)
else
    arginstring = '';
    for a = 1:length(varargin);
        eval(['v' num2str(a) ' = varargin{a};'])
        arginstring = strcat(arginstring,',v',num2str(a));
    end
    
    eval(['SleepDataset_ExecuteOnDatasets(executestring' arginstring ');'])
end