function CopyPMSandKKOutputToBorderline(ratname,recordingname,isisdrive,destdrive)

disp('CopyPMSandKKOutputToBorderline');
switch isisdrive
    case 'packmouse'
        sourcedir = fullfile('/mnt/packmouse/userdirs/brendon',ratname,recordingname);
    case 'isis3'
        sourcedir = fullfile('/mnt/isis3/brendon',ratname,recordingname);
    case 'isis2'
        sourcedir = fullfile('isis:/isis2/brendon',ratname,recordingname);
end
        
destdir = fullfile(destdrive,ratname,recordingname);
if strcmp(sourcedir(end),'/');
    sourcedir = sourcedir(1:end-1);
end

% fromisis = 0;
% if fromisis
%     destdir = ['borderline:' destdir];
% else
%     sourcedir = ['isis:' sourcedir];
% end

eval(['! sudo chmod 777 -R ' sourcedir])%make sure I don't miss any due to permissions
if strcmp(sourcedir(1:5),'isis:')
    eval(['! scp -rp ' sourcedir '/*.clu* ' destdir])
else
    eval(['! cp -rav ' sourcedir '/' recordingname '.clu* ' destdir])
end

    % eval(['! scp -rp ' sourcedir ' ' destdir])