function diffvideo = FrameDiffMovie(video)
% does framewise subtractinos of color movie frame data.

diffvideo = video(:,:,:,2:end)-video(:,:,:,1:end-1);

%% below doesn't really work since doesn't account properly for overlap yet... see "GetMovieMovementVector" for inspiration
% diffvideo = zeros(size(video(:,:,:,size(video,4)-1)));
% chunksz = 500;
% numchunks = ceil(numframesout/chunksz);
% for b = 1:numchunks;
%     startframe = (b-1)*chunksz+1;
%     endframe = b*chunksz;
%     
%     tvid = video(:,:,:,startframe:endframe);
%     clear diffvideo    
%     
%     dvideo(:,:,:,startframe:endframe) = tvid(:,:,:,2:end)-tvid(:,:,:,a:end-1);
%     diffvideo(:,:,:,startframe:endframe) = tvid(:,:,:,2:end)-tvid(:,:,:,a:end-1);
% end