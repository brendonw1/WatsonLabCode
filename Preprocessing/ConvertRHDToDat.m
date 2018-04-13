% to the folder with your .rhd... make sure folder has the right name -
% folder named after basename of the file

%set file parameters
basepath = cd;
%get basename from folder name
if strcmp(basepath(end),filesep);
    filename = basepath(1:end-1);
end
[~,filename] = fileparts(basepath);
% filename = 'Mother_Naive_180320_135852';


%read rhd file
[amplifier_channels, notes, aux_input_channels, spike_triggers,...
board_dig_in_channels, supply_voltage_channels, frequency_parameters ] =...
read_Intan_RHD2000_file(basepath,[filename '.rhd']);

%write .dat file (just amplifier input)
fid = fopen([filename '.dat'],'w');
towrite = amplifier_data(:);
fwrite(fid,towrite,'int16');
fclose(fid);