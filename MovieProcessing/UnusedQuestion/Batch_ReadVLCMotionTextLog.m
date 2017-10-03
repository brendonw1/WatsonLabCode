basename = 'BWRat20_101513';
filenumbers = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27'};

for a = 1:length(filenumbers);
    filename = [basename '-' filenumbers{a}];
    movname = [filename '.mpg'];
    logname = [filename '_vlcmotionlog.txt'];
    outname = ['movementvector_' filenumbers{a}];
    eval([outname ' = ReadVLCMotionTextLog(''' logname ''');'])
    
%     tempvar = ReadVLCMotionTextLog(logname);
%     eval([filename,'_motion = tempvar']) 
end