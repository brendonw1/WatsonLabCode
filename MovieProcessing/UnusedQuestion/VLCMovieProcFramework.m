filenumbers = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27'};

GenerateVLCMotionTextLog
Batch_ReadVLCMotionTextLog

sessionInfo = getDatAndVideoSessionInfo(filebase);

allresamp = [];
for a=1:length(sessionInfo.metaInfo.durationInSec);
    durations(a)=floor(sessionInfo.metaInfo.durationInSec{a});
    oldvectname = ['movementvector_' filenumbers{a}];
    newvectname = ['resampmovementvector_' filenumbers{a}];
    eval([newvectname '= decimate(' oldvectname ',10);'])%necessary because numbers are too big to "resample" without decimating first
    eval([newvectname '= resample(' newvectname ',durations(a),length(' newvectname '));'])%make so has right number of samples for StateEditor (floor of num of seconds of eeg)
    eval([newvectname '(' newvectname '<0) = 0;'])%cancel out errors generated by resample/interpolation
    eval(['allresamp = cat(2,allresamp,' newvectname '(:)'');'])
end