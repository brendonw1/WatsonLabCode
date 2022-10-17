% This makes the sleepstate window struct called ints! In this program
% it'll be used for making a hypnogram
function [ints] = makeints(ratname)
    cd(['/analysis/Dayvihd/',ratname]);
    wakeints = table2array(readtable([cd '/' ratname ' Wake Windows.csv']));
    nremints = table2array(readtable([cd '/' ratname ' NREM Windows.csv']));
    remints = table2array(readtable([cd '/' ratname ' REM Windows.csv']));

    ints = struct('WAKEstate',wakeints,'NREMstate',nremints,'REMstate',remints);
end