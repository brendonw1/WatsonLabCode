function tsdac = catTsdArray(tsda1,tsda2)
% Makes a new tsdArray by concatenating each time element of two arrays 
% with the same number of measured elements (ie same number of cells)

for a = 1:size(tsda1,1)
    tsdac{a} = cat(tsda1{a},tsda2{a});
end
tsdac = tsdArray(tsdac);