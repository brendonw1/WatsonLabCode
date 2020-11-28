function [returnVar,msg] = InvertSomeChannelsOnDat(fname,nbChan,ChanIx)

% USAGE:
%     RemoveDCfromDat(fbasename,shankIx,chanIx)
%     This function inverts files recorded incorretly (inverted), by
%     flipping them about their means (which are calcluated using the the 
%     first 1e6 samples (or less if file is smaller)
% INPUTS:
%     fname: dat file name
%     nbChan: total number of channels in dat file
%     chanIx: vectors of channel indices
% 
% Essentially entirely based on Adrien Peyrache's function"RemoveDcFromDat"
% Adrien Peyrache 2011, Brendon Watson 2012

fprintf('Inverting channels in %s\n',fname)
%try
    infoFile = dir(fname);
    
    chunk = 1e6;
    nbChunks = floor(infoFile.bytes/(nbChan*chunk*2));
    warning off
    if nbChunks==0
        chunk = infoFile.bytes/(nbChan*2);
    end
    m = memmapfile(fname,'Format','int16','Repeat',chunk*nbChan,'writable',true);
    d = m.Data;
    d = reshape(d,[nbChan chunk]);
    meanD = mean(d,2);
    d = d-int16(meanD*ones(1,chunk));
    m.Data = d(:);
    clear d m
    
    for ix=1:nbChunks-1
        m = memmapfile(fname,'Format','int16','Offset',ix*chunk*nbChan*2,'Repeat',chunk*nbChan,'writable',true);
        d = m.Data;
        d = reshape(d,[nbChan chunk]);%reshaped to be channels x numsamples
        d = d-int16(meanD*ones(1,chunk));%subtract channel mean
        d(ChanIx,:) = -d(ChanIx,:);
        m.Data = d(:);
        clear d m
        h=waitbar(ix/(nbChunks));
    end
    
    %% for remainder chunk after other chunks are taken in loop
    newchunk = infoFile.bytes/(2*nbChan)-nbChunks*chunk;
    if newchunk
        m = memmapfile(fname,'Format','int16','Offset',nbChunks*chunk*nbChan*2,'Repeat',newchunk*nbChan,'writable',true);
        d = m.Data;
        d = reshape(d,[nbChan newchunk]);
        d = -d;
        d = d-int16(meanD*ones(1,newchunk));
        d(ChanIx,:) = -d(ChanIx,:);
        m.Data = d(:);
        clear d m
        h=waitbar(1);
    end
    close(h)
    warning on
    returnVar = 1;
    msg = '';
    
%catch
%    keyboard
%    returnVar = 0;
%    msg = lasterr; 
%end
clear m
