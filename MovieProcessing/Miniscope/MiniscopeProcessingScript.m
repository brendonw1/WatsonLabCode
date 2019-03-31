video = readvideo('msCam1.avi');
video = double(video);

%image alignment
% try normxcorr2 http://www.mathworks.com/help/images/ref/normxcorr2.html

% %filter for size of cells
% filtvid = video;
% for a=1:size(video,3);
%     filtvid(:,:,a) = bwbpimage2(video(:,:,a),10,25);
% end
video = video;
for a = 1:size(video,3);%remove variance in background
    video(:,:,a) = video(:,:,a)./imfilter(video(:,:,a),ones(40),'symmetric');
end

rollingbackground = mean(mean(video));
video = video - repmat(rollingbackground,[size(video,1),size(video,2),1]);
df = video(:,:,2:end)-video(:,:,1:end-1);

filtdf = df;% Df from previous frame
for a = 1:size(df,3);
    filtdf(:,:,a) = imfilter(filtdf(:,:,a),ones(4));
end

final = df;
final = filtdf;
final = final-min(final(:));
final = final*(255/max(final(:)));
final = uint8(final);
implay(final)

%% Export to new .avi file
v = VideoWriter('msDfProcessed.avi');
v.FrameRate = 10;
open(v);

f = figure;
imagesc(final(:,:,1));
colormap('gray')
axis tight manual
set(gca,'NextPlot','replacechildren')

for k = 1:size(final,3);
    imagesc(final(:,:,k));
    frame = getframe;
    writeVideo(v,frame);
end
close(v);
close(f);