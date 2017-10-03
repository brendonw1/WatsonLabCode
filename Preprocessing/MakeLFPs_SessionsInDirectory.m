function MakeLFPs_SessionsInDirectory(upperpath)
%assumes you are in or pointed to a directory containing subdirectories for
% various recording files from a single session


% basic session name and and path
if ~exist('upperpath','var')
    upperpath = cd;
end

u = getdir(upperpath);
[~,animalname] = fileparts(upperpath);

for v = 1:length(u);
    if u(v).isdir 

        dirpath = fullfile(upperpath,u(v).name);
        [~,basename] = fileparts(dirpath);
        disp(basename);

        datname = fullfile(dirpath,[basename,'.dat']);
        if ~exist(datname,'file')
            disp([basename ': no ' basename '.dat found, skipping recording'])
        else
            eegname = fullfile(dirpath,[basename,'.lfp']);
            if ~exist(eegname,'file')
                xmlname = fullfile(dirpath,[basename,'.xml']);
                parameters = LoadPar(xmlname);        
                ResampleBinary(datname,eegname,parameters.nChannels,1,16)
            end
        end
    end
end

    
    