function ExecuteOnKetamineDatasets(executestring,varargin)

if isempty(varargin)
    SleepDataset_ExecuteOnExpandedDatasets(executestring)
else
    arginstring = '';
    for a = 1:length(varargin);
        eval(['v' num2str(a) ' = varargin{a};'])
        arginstring = strcat(arginstring,',v',num2str(a));
    end
    
    eval(['KetamineDataExecuteOnKetamineDatasets(executestring' arginstring ');'])
end