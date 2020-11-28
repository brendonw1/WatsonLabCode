function video = DiffResampledMovie(filename,framesamplerate)
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

for a=1:numframes;   
    
    try%short term solution(?) to prob that there are not as many frames in the .mpg as claimed in obj
        vid(:,:,:,a) = read(obj,a*framesinperframeout);
        if a>1
            video(:,:,:,a-1) = vid(:,:,:,a)-vid(:,:,:,a-1);
        end
        disp(['Frame # ',num2str(a),' done'])
    catch
        disp(['Frame # ',num2str(a),' unable to be read'])
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

