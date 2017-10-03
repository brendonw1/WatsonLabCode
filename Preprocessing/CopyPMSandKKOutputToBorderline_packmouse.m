function CopyPMSandKKOutputToBorderline_packmouse(ratname,recordingname,destdrive)

% ratname = 'Dino';
% recordingname = 'Dino_062514';
% destdrive = '/mnt/brendon6/';

sourcedir = fullfile('/mnt/packmouse/userdirs/brendon',ratname,recordingname,recordingname);
destdir = fullfile(destdrive,ratname,recordingname);
if strcmp(sourcedir(end),'/');
    sourcedir = sourcedir(1:end-1);
end

% fromisis = 0;
% if fromisis
%     destdir = ['borderline:' destdir];
% else
    sourcedir = ['isis:' sourcedir];
% end

eval(['! scp -rp ' sourcedir ' ' destdir])