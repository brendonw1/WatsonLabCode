basename = 'BWRat20_101513';
filenumbers = {'01';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27'};

for a = 1:length(filenumbers);
    filename = [basename '-' filenumbers{a}];
    movname = [filename '.mpg'];
    logname = [filename '_vlcmotionlog.txt'];

    eval(['! vlc -vvv --video-filter=motiondetect --play-and-exit --extraintf=http:logger --verbose=2 --file-logging --logfile=' logname ' --rate 3 ' movname]);
    
%     tempvar = ReadVLCMotionTextLog(logname);
%     eval([filename,'_motion = tempvar']) 
end