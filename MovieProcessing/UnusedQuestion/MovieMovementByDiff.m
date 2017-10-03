function [allsimplevect,allthreshvect] = MovieMovementByDiff_BWRat20(filename,framesamplerate)
% opens a video at the specified frame rate (in number of frames to sample per sec) and outputs a
% movie made of frame by frame subtraction.

% NB: the command below may get the crucial codecs for mpeg reading in linux
% sudo apt-get install gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gstreamer0.10-plugins-base gstreamer0.10-plugins-good gstreamer0.10-plugins-uglycd 


disp('Gathering basic movie info')
obj = VideoReader(filename);

durationinsec = get(obj,'Duration');
nativeframerate = get(obj,'FrameRate');

if rem(nativeframerate,framesamplerate)>0;
    error(['requested sample rate is not an integer divisor of the native frame rate (',num2str(nativeframerate),')']);
    return
end

durationrounded = floor(durationinsec);
numframes = durationrounded*framesamplerate;
framesinperframeout = nativeframerate/framesamplerate; 

if numframes < 500;
    for a=1:numframes;   
        try%short term solution(?) to prob that there are not as many frames in the .mpg as claimed in obj
            vid(:,:,:,a) = read(obj,a*framesinperframeout);
            if a>1
                video(:,:,:,a-1) = vid(:,:,:,a)-vid(:,:,:,a-1);
            end
            grayvideo(:,:,a) = rgb2gray(video(:,:,:,a))
            simplemovementvector = squeeze(sum(sum(abs(grayvideo),2),1));
            
            threshdiffmovie = BinaryThresholdDiffMovie_BWRat20(video);
            threshmovementvector = squeeze(sum(sum(threshdiffmovie,1),2));
            disp(['Frame # ',num2str(a),' done'])
        catch
            disp(['Frame # ',num2str(a),' unable to be read'])
        end
    end
    19
else
    chunksz = 500;
    numchunks = ceil(numframes/chunksz);
    chunksizes = chunksz*ones(1,numchunks);
    chunksizes(end) = rem(numframes,chunksz);
    chunkstops = cumsum(chunksizes);
    chunkstarts = [1 cumsum(chunksizes(1:end-1))];

    allsimplevect = [];
    allthreshvect = [];

    for b = 1:numchunks;
        counter = 0;
        for a = chunkstarts(b):chunkstops(b)
            counter = counter+1;
            try
                vid(:,:,:,counter) = read(obj,a*framesinperframeout);
            catch 
                disp(['Frame # ',num2str(a),' unable to be read'])
                continue;
            end
                
            if b==1 && a==1 %skip first frame of chunk 1, nothing to diff
                continue %skip to next frame
            elseif b>1 && counter==1%if first frame of another chunk, subtract from last frame of last chunk (which was saved)
                video(:,:,:,counter) = vid(:,:,:,counter)-lastframe;
%                 counter = a;
%             elseif b>1 && a>1
%                 diffframe = vid(:,:,:,a)-vid(:,:,:,a-1);
%                 counter = a;
%             elseif b==1 && a>1
%                 diffframe = vid(:,:,:,a)-vid(:,:,:,a-1);
%                 counter = a-1;
            else                
                video(:,:,:,counter) = vid(:,:,:,counter)-vid(:,:,:,counter-1);
            end
%                 video(:,:,:,a-1) = vid(:,:,:,a)-vid(:,:,:,a-1);
%             grayvideo(:,:,counter) = rgb2gray(video(:,:,:,counter));            
        end
%         simplemovementvector = squeeze(sum(sum(abs(diff(grayvideo,1,3)),1),2));

        threshdiffmovie = BinaryThresholdDiffMovie_BWRat20(video);
        threshmovementvector = squeeze(sum(sum(threshdiffmovie,1),2));
        
        lastframe = vid(:,:,:,end);
%         allsimplevect = cat(1,allsimplevect,simplemovementvector);
        allthreshvect = cat(1,allthreshvect,threshmovementvector);
        
        disp(['Chunk # ',num2str(b),' out of ',num2str(numchunks),' done'])
    end
end

% 
% % %B&W >> SEEMS LIKE IT MUST THROW AWAY INFORMATION
% % bwvid = squeeze(bwvid);
% % modalimage = mode(bwvid,3);
% % diffrommode = bwvid-repmat(modalimage,[1 1 size(bwvid,3)]);
% 
% %COLOR
% modalimage = mode(video,4);
% diffrommode = video-repmat(modalimage,[1 1 1 size(video,4)]);
% for a = 1:numframes;
%     bwdiffrommode(:,:,a) = rgb2gray(diffrommode(:,:,:,a));
%     level = graythresh(bwdiffrommode(:,:,a));
%     tempimage = im2bw(bwdiffrommode(:,:,a),level);
%     threshdiffrommode(:,:,a) = bwareaopen(tempimage,40);
% end

