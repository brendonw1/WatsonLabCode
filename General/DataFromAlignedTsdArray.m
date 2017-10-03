function datamtx = DataFromAlignedTsdArray(tsda)
%assumes each tsd inside a tsdArray has the same number of elements and
%comes from the same timepoints.  MakeQfromS does not work as expected.

switch class(tsda)
    case 'tsd'
        datamtx = Data(tsda);
    case 'tsdArray'
    nstreams = length(tsda);
    for a = 1:nstreams
        datamtx(:,a) = Data(tsda{a});
    end
end