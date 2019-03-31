function [video,modalimage] = BkgndSubtractResampledMovie(filename,framesamplerate)
% opens a video at the specified frame rate (in number of frames to sample per sec) and outputs a
% movie made of of subtraction from a modal frame.

% NB: the command below may get the crucial codecs for mpeg reading in linux
% sudo apt-get install gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gstreamer0.10-plugins-base gstreamer0.10-plugins-good gstreamer0.10-plugins-uglycd

disp('Gathering basic movie info')
obj = VideoReader(filename);

durationinsec = get(obj,'Duration');
nativeframerate = get(obj,'FrameRate');
nativetotalframes = obj.NumberOfFrames;

if rem(nativeframerate,framesamplerate)>0;
    error(['requested sample rate is not an integer divisor of the native frame rate (',num2str(nativeframerate),')']);
    return
end

% durationrounded = floor(durationinsec);
% numframes = floor(durationrounded*framesamplerate);
framesinperframeout = nativeframerate/framesamplerate; 

numoutputframes = floor(nativetotalframes/framesinperframeout);

for a = 1:numoutputframes;   
    try%short term solution(?) to prob that there are not as many frames in the .mpg as claimed in obj
        vid(:,:,:,a) = read(obj,a*framesinperframeout);
        if rem(a,100) == 0
            disp(['Read frame # ',num2str(a)])
        end
    catch
        disp(['Frame # ',num2str(a),' unable to be read'])
    end
end

% %B&W >> SEEMS LIKE IT MUST THROW AWAY INFORMATION
% bwvid = squeeze(bwvid);
% modalimage = mode(bwvid,3);
% diffrommode = bwvid-repmat(modalimage,[1 1 size(bwvid,3)]);

%COLOR
modalimage = mode(vid,4);
video = vid-repmat(modalimage,[1 1 1 size(vid,4)]);
