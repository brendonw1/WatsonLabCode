function MovieMotionOneSessionBaslerHomecage(basepath)

if ~exist('basepath','var')
    basepath = cd;
end

ResampleFPS = 2;%frames per second to actually use
chunksz = 501;%chunks in number of frames at above timing (ie if ResampleFPS = 2 and chunk = 500, then chunks are every 250seconds)
IMOpenSize = 15;%only changes of at least this many contiguous pixels are counted
overwrite = 0;

d = getdir(basepath);
for a = 1:length(d);
    if d(a).isdir
        dd = getdir(fullfile(basepath,d(a).name));
        for b = 1:length(dd);%for each sub-recording
            if length(dd(b).name)>3
                if strcmp(dd(b).name(end-3:end),'.avi')
                    bool = exist(fullfile(basepath,d(a).name,'moviemotion.mat'),'file');
                    if bool & ~overwrite
                        continue
                    else
                        o = VideoReader(fullfile(basepath,d(a).name,dd(b).name));
                        AcquisitionFPS = o.FrameRate;
                        TotalFrameNum = o.Duration*o.FrameRate;
                        framesperskip = o.FrameRate/ResampleFPS;
                        vidHeight = o.Height;
                        vidWidth = o.Width;
                        %read using below because it actually works, but only above
                        %has framerate
                        videoObj    = vision.VideoFileReader(fullfile(basepath,d(a).name,dd(b).name));

                        tempvid = zeros(vidHeight,vidWidth,3,'single');
                        frcounter = 0;
                        FrameNumsUsed = [];
                        FrameMotions = [];
                        while ~isDone(videoObj)
                            frcounter = frcounter + 1;
                            t = step(videoObj);
                            if rem(frcounter-1,framesperskip) == 0 %if this is the Xth frame from 1
                                tempvid(:,:,:,end+1) = t;
                                FrameNumsUsed(end+1) = frcounter;

                                if size(tempvid,4) >= chunksz %if reached the size of a chunk, do calcualtions
                                    diffvideo = diff(tempvid,1,4);% get frame diffs

                                    threshdiffmovie = BinaryThresholdDiffMovie(diffvideo,IMOpenSize);%binarize movie, find only bigenough differences
                                    fm = squeeze(sum(sum(threshdiffmovie,1),2));%get total movement pixels per frame

                                    if isempty(FrameMotions)% if first chunk
                                        fm(1) = 0;
                                        FrameMotions = fm;
                                    else
                                        FrameMotions = cat(1,FrameMotions,fm);
                                    end
                                    tempvid = tempvid(:,:,:,end);%keep last frame as first frame of next chunk
                                end
                            end
                        end
                        if size(tempvid,4)>1%if any frames in last chunk, take care of that here
                            diffvideo = diff(tempvid,1,4);% get frame diffs

                            threshdiffmovie = BinaryThresholdDiffMovie(diffvideo,IMOpenSize);%binarize movie, find only bigenough differences
                            fm = squeeze(sum(sum(threshdiffmovie,1),2));%get total movement pixels per frame

                            if isempty(FrameMotions)% if first chunk
                                fm(1) = 0;
                                FrameMotions = fm;
                            else
                                FrameMotions = cat(1,FrameMotions,fm);
                            end
                            tempvid = tempvid(:,:,:,end);%keep last frame as first frame of next chunk
                        end                    


                        %at end of each movie/subrecording directory
                        MotionTimeStamps = FrameNumsUsed/AcquisitionFPS;
                        MovieName = videoObj.Filename;
                        moviemotion = v2struct(FrameMotions,MotionTimeStamps,ResampleFPS,AcquisitionFPS,FrameNumsUsed,TotalFrameNum,MovieName,vidHeight,vidWidth);
                        save(fullfile(basepath,d(a).name,'moviemotion.mat'),'moviemotion')
                    end
                end
            end
        end
    end
end


