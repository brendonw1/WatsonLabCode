function BarrelAveraging

% Image averaging for S1 barrel detection high-power LED illumination, and
% skull transparency procedures.
%
%
%
% USAGE ___________________________________________________________________
% Step 1: Connect the PF_GEVPlayer to the camera; in Device Control, set
% imaging parameters (e.g., ROI, exposure, black level, gain).
%
% Step 2: Still in the PF_GEVPlayer, set the folder to store frames
% (Tools -> Save Images...) and save current image under green illumination
% to get the anatomical reference snapshot (with blood vessels).
%
% Step 3: Create two subfolders: "\Piezo" and "\ISI".
%
% Step 4: Switch the PF_GEVPlayer to Burst Trigger mode, switch to red
% illumination, and run Bpod then BarrelPiezo.
%
% Step 5: Run BarrelAveraging.
%
% LSBuenoJr, with inputs from RASwanson and NDJohnson _____________________



%% Gets Piezo and ISI subfolders.
if ~isfolder([cd '\Piezo']) || ~isfolder([cd '\ISI'])
    error(['Working directory must contain two folders (Piezo and ISI)' ...
        ' and one image (GreenSnapshot.bmp)'])
else
    PiezoFrames    = dir([cd '\Piezo']);
    ISIFrames      = dir([cd '\ISI']);
    GreenReference = mean(imread('GreenSnapshot.bmp'),3);
end



%% Asks for the gray threshold to be used with im2bw
GrayThreshold = ...
    'Gray threshold for image binarization (0-1 range): ';
GrayThreshold = input(GrayThreshold);tic



%% Image averaging and subtraction.
AvgPiezo     = zeros(size(GreenReference,1),size(GreenReference,2),...
    length(PiezoFrames)-2);
for i        = 3:length(PiezoFrames)
    AvgPiezo(:,:,i) = mean(imread([PiezoFrames(i).folder '\' ...
        PiezoFrames(i).name]),3);
end;AvgPiezo = mean(AvgPiezo,3);

AvgISI       = zeros(size(GreenReference,1),size(GreenReference,2),...
    length(ISIFrames)-2);
for i        = 3:length(ISIFrames)
    AvgISI(:,:,i)   = mean(imread([ISIFrames(i).folder '\' ...
        ISIFrames(i).name]),3);
end;AvgISI   = mean(AvgISI,3);

PiezoISIDiff = AvgPiezo - AvgISI;



%% Figure with three columns of subplots: during stimuli, between stimuli,
% and the difference. Top row is from red-illuminated frames. Bottom row is
% the same, but with the green frame overlaid for anatomical reference
% (blood vessels). The "difference" images, in particular, show centroids
% and ellipsoids.

% Top left: averaged red frames during stimuli
colormap(gray)
subplot('position',[0.08 0.54 0.23 0.40])
imagesc(AvgPiezo)
ylabel('Averaged red frames','FontSize',14)
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('During stimuli','FontSize',14,'FontWeight','normal')

% Bottom left: as above, but merged with a green snapshot
subplot('position',[0.08 0.06 0.23 0.40])
imagesc(mean(cat(3,AvgPiezo,GreenReference),3))
ylabel('Green frame overlaid','FontSize',14)
xticklabels([]);xticks([]);yticklabels([]);yticks([]);

% Top center: averaged red frames between stimuli
subplot('position',[0.36 0.54 0.23 0.40])
imagesc(AvgISI)
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('Between stimuli','FontSize',14,'FontWeight','normal')

% Bottom center: as above, but merged with a green snapshot
subplot('position',[0.36 0.06 0.23 0.40])
imagesc(mean(cat(3,AvgISI,GreenReference),3))
xticklabels([]);xticks([]);yticklabels([]);yticks([]);

% Top right: during-between subtraction, with centroids and ellipsoids
subplot('position',[0.72 0.54 0.23 0.40])
imagesc(PiezoISIDiff)
xticklabels([]);xticks([]);yticklabels([]);yticks([])
title('Difference','FontSize',14,'FontWeight','normal');axis on;hold on
BinPiezoISIDiff     = bwareaopen(bwmorph(im2bw(...
    PiezoISIDiff,GrayThreshold),'open'),5); %#ok<IM2BW>
CentroidsEllipsoids = regionprops(BinPiezoISIDiff);
for i   = 1:length(CentroidsEllipsoids)
    plot(CentroidsEllipsoids(i).Centroid(1),CentroidsEllipsoids(i).Centroid(2),...
            'r+','MarkerSize',10,'LineWidth',2)
        rectangle('Position',CentroidsEllipsoids(i).BoundingBox,...
            'EdgeColor','r','Curvature',[1 1],'LineWidth',0.5)
end

% Bottom right: as above, but merged with a green snapshot
subplot('position',[0.72 0.06 0.23 0.4])
imagesc(mean(cat(3,PiezoISIDiff,GreenReference),3))
xticklabels([]);xticks([]);yticklabels([]);yticks([]);axis on;hold on
for i   = 1:length(CentroidsEllipsoids)
    plot(CentroidsEllipsoids(i).Centroid(1),CentroidsEllipsoids(i).Centroid(2),...
            'r+','MarkerSize',10,'LineWidth',2)
        rectangle('Position',CentroidsEllipsoids(i).BoundingBox,...
            'EdgeColor','r','Curvature',[1 1],'LineWidth',0.5)
end;toc

figure;imagesc(BinPiezoISIDiff);colormap(gray)
xticklabels([]);xticks([]);yticklabels([]);yticks([]);

end