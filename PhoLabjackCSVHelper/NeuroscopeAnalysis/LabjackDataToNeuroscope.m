% LabjackDataToNeuroscope.m
% Converts Labjack data loaded from .csv files to a neuroscope .dat file (that can be opened in Neuroscope).


%% Prepare the data as 12-bit binary
% %temp = labjackTimeTable{:,2:end};
% %temp = labjackTimeTable{:,3:10};
% %temp = double(labjackTimeTable{:,3:10});
% %temp = double(labjackTimeTable{:,11:18});
% temp = double(labjackTimeTable{:,[1,11:18]})';
% mask = temp < 0;
% temp(mask) = 2^12 + temp(mask) ;
% binary = dec2bin(temp, 12);
% 
% fileID = fopen('OutputBinary.dat','w');
% fwrite(fileID, binary);
% fclose(fileID);



temp = double(labjackTimeTable{:,11:18});
mask = temp < 0;
temp(mask) = 2^12 + temp(mask) ;
binary = dec2bin(temp, 12);

fileID = fopen('OutputBinaryTempOnly.dat','w');
fwrite(fileID, binary);
fclose(fileID);