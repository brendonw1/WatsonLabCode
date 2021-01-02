function Data = RenameDIOsFromLUT(Data,dispenserLUT)


%Assume column 1 is where the WATSON-BB-XX entries are
BBStartCol = 1;

% Assumptions of where the DIO lookups are in the table (December 2020)
DIORow = 2;
DIO0Col = 4;
DIO1Col = 6;
DIO2Col = 5;
DIO3Col = 7;

%find row for this BB
tbb = Data.BBName;
tstring = ['WATSON-BB-' tbb];

for a = 1:size(dispenserLUT,1)
    rowidxs(a) = contains(dispenserLUT{a,1},tstring);
end
ThisBBRow = find(rowidxs,1,'first');

fns = fieldnames(Data.DeltaIdxs);

for a = 1:length(fns)
    tfn = fns{a};
    
    eval(['tname = dispenserLUT{ThisBBRow,' tfn(1:4) 'Col};'])%use "DIO" from name
    newname = [tname tfn(5:end)];
    eval(['Data.DeltaIdxs = setfield(Data.DeltaIdxs,newname,Data.DeltaIdxs.' tfn ');'])
    eval(['Data.DeltaIdxs = rmfield(Data.DeltaIdxs,''' tfn ''');'])
    
    eval(['Data.DeltaTimestamps = setfield(Data.DeltaTimestamps,newname,Data.DeltaTimestamps.' tfn ');'])
    eval(['Data.DeltaTimestamps = rmfield(Data.DeltaTimestamps,''' tfn ''');'])
    
end 
  

            
    
    

