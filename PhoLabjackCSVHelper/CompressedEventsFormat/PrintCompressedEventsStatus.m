function [counts,total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps)
%PRINTCOMPRESSEDEVENTSSTATUS PRints the number of elements in OutputDeltasTimestamps
%   Detailed explanation goes here
    fields = fieldnames(OutputDeltasTimestamps);
    counts = zeros(numel(fields),1);
    dateMin = datetime(3000,01,01); % The min is set to the year 3000 so anything will replace it (for another 1000 years or so)
    dateMax = datetime(2000,01,01); % The max is set to the year 2000 so anything will replace it
    for i = 1:numel(fields)
        counts(i) = length(OutputDeltasTimestamps.(fields{i}));
        disp(['    ' fields{i},': ', num2str(counts(i))])
        seriesDateMin = min(OutputDeltasTimestamps.(fields{i}));
        seriesDateMax = max(OutputDeltasTimestamps.(fields{i}));
        dateMin = min(seriesDateMin, dateMin);
        dateMax = max(seriesDateMax, dateMax);
    end
    total = sum(counts);
    disp(['    = total: ' num2str(total)])
    disp(dateMin);
    disp(dateMax);

end

