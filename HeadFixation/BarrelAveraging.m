function BarrelAveraging

% Image averaging for S1 barrel detection using high-power LED
% illumination, and skull transparency procedures.
%
%
%
% USAGE ___________________________________________________________________
% Step 1: Connect the PF_GEVPlayer to the camera; in Device Control, set
% imaging parameters (e.g., ROI, exposure, black level, gain). One can also
% use the Image Acquisition/Processing toolboxes to get a live pixel
% intensity histogram, which should look like unimodal Gaussian as much as
% possible, especially under red illumination
% (https://www.mathworks.com/help/imaq/examples/video-display-with-live-histogram.html)
%
% Step 2: Still in the PF_GEVPlayer, set the folder to store frames
% (Tools -> Save Images...) and save current image under green illumination
% to get the anatomical reference snapshot (with blood vessels).
%
% Step 3: Create a subfolder to store the "red" frames that will be
% averaged.
%
% Step 4: Switch the PF_GEVPlayer to Burst Trigger mode (40 frames at
% 10 Hz, alternating between piezo stimulation and inter-stimulus
% interval). Switch to red illumination, and run Bpod then BarrelPiezo.
%
% Step 5: Once BarrelPiezo is finished (20 sweeps), run BarrelAveraging
% from the relevant folder.
%
% LSBuenoJr, with inputs from RASwanson and NDJohnson _____________________



%% Gets the "green" snapshot, and sorts the "red" subfolder into piezo
% or inter-stimulus frames.
tic
FrameDir    = dir;FrameDir    = FrameDir(3:4);
GreenFrame  = imread(fullfile(FrameDir([FrameDir.isdir]==0).folder,...
    FrameDir([FrameDir.isdir]==0).name));
RedFolder   = dir(fullfile(FrameDir([FrameDir.isdir]==1).folder,...
    FrameDir([FrameDir.isdir]==1).name));RedFolder = RedFolder(3:1602);



%% Image averaging.
CurrSweep = repmat(zeros(size(GreenFrame)),1,1,1,20);
AllSweeps = repmat({repmat(zeros(size(GreenFrame)),1,1,1,20)},1,3);
k         = 1;
for j     = 0:80:length(RedFolder)-1
    for i = 1:80
        CurrSweep(:,:,:,i)    = imread(fullfile(RedFolder(i+j).folder,...
            RedFolder(i+j).name));
    end
        AllSweeps{1}(:,:,:,k) = mean(CurrSweep(:,:,:,1:40),4);
        AllSweeps{2}(:,:,:,k) = mean(CurrSweep(:,:,:,41:80),4);
        AllSweeps{3}(:,:,:,k) = AllSweeps{1}(:,:,:,k)-AllSweeps{2}(:,:,:,k);
        k = k + 1;
end
AllSweeps{1} = uint8(mean(AllSweeps{1},4));
AllSweeps{2} = uint8(mean(AllSweeps{2},4));
AllSweeps{3} = uint8(mean(AllSweeps{3},4));



%% Figure with three columns of subplots: during stimuli, between stimuli,
% and the difference. Top row is from red-illuminated frames. Bottom row is
% the same, but with the green frame overlaid for anatomical reference
% (blood vessels). The "difference" images, in particular, show centroids
% and ellipsoids.

% Top left: averaged red frames during stimuli
subplot('position',[0.06 0.86 0.24 0.12])
imhist(AllSweeps{1})
subplot('position',[0.06 0.44 0.24 0.36])
imagesc(AllSweeps{1})
ylabel('Averaged red frames','FontSize',14)
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('During stimuli','FontSize',14,'FontWeight','normal')

% Bottom left: as above, but merged with a green snapshot
subplot('position',[0.06 0.04 0.24 0.36]);colormap(gray)
imagesc(mean(cat(3,AllSweeps{1},GreenFrame),3))
ylabel('Green frame overlaid','FontSize',14)
xticklabels([]);xticks([]);yticklabels([]);yticks([]);

% Top center: averaged red frames between stimuli
subplot('position',[0.32 0.86 0.24 0.12])
imhist(AllSweeps{2})
subplot('position',[0.32 0.44 0.24 0.36])
imagesc(AllSweeps{2})
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('Between stimuli','FontSize',14,'FontWeight','normal')

% Bottom center: as above, but merged with a green snapshot
subplot('position',[0.32 0.04 0.24 0.36]);colormap(gray)
imagesc(mean(cat(3,AllSweeps{2},GreenFrame),3))
xticklabels([]);xticks([]);yticklabels([]);yticks([]);

% Top right: during-between subtraction, with centroids and ellipsoids
subplot('position',[0.64 0.86 0.24 0.12])
BinaryDiff = bwareaopen(bwmorph(imbinarize(...
    mean(AllSweeps{3},3),'adaptive'),'open'),5);
bar(sum(BinaryDiff))
xticklabels([]);xticks([])
subplot('position',[0.92 0.44 0.07 0.36])
barh(sum(BinaryDiff,2))
yticklabels([]);yticks([]);
subplot('position',[0.64 0.44 0.24 0.36])
imagesc(AllSweeps{3})
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('Difference','FontSize',14,'FontWeight','normal');axis on;hold on
CentroidsEllipsoids = regionprops(BinaryDiff);
for i      = 1:length(CentroidsEllipsoids)
    plot(CentroidsEllipsoids(i).Centroid(1),...
        CentroidsEllipsoids(i).Centroid(2),...
            'r+','MarkerSize',10,'LineWidth',2)
        rectangle('Position',CentroidsEllipsoids(i).BoundingBox,...
            'EdgeColor','r','Curvature',[1 1],'LineWidth',0.5)
end

% Bottom right: as above, but merged with a green snapshot
subplot('position',[0.64 0.04 0.24 0.36])
imagesc(mean(cat(3,AllSweeps{3},GreenFrame),3))
xticklabels([]);xticks([]);yticklabels([]);yticks([]);axis on;hold on
for i      = 1:length(CentroidsEllipsoids)
    plot(CentroidsEllipsoids(i).Centroid(1),...
        CentroidsEllipsoids(i).Centroid(2),...
            'r+','MarkerSize',10,'LineWidth',2)
        rectangle('Position',CentroidsEllipsoids(i).BoundingBox,...
            'EdgeColor','r','Curvature',[1 1],'LineWidth',0.5)
end

figure;imagesc(BinaryDiff);colormap(gray)
xticklabels([]);xticks([]);yticklabels([]);yticks([]);
title('Binary difference','FontSize',14,'FontWeight','normal')
toc

end