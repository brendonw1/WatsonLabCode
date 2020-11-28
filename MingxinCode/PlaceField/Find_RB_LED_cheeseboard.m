function whl = Find_RB_LED_cheeseboard(file)
manualROI = 1;
% This code tests an approximate median filter for separating out the red
% and blue leds mounted on top of the subjects head
% I was using the DataMax system, which was synced using a red LED. Hence,
% I am tracking the x,y position of the animal as well as when the sync
% light comes on.
% Brendon Watson 2015

%file       = 'Mouse12-120808-01.mpg';
[pathstr,name,~] = fileparts(file);
% Create Text file for writing out LED locations and sync trigger
%fid        = fopen(sprintf('%s.whl',name),'w+');
% Creater readerobj of file
readerobj  = VideoReader(file);
width      = readerobj.Width;
height     = readerobj.Height;
NOF        = readerobj.NumberOfFrames;
%NOF        = 300;
threshF    = 150;    % threshold on foreground pixel intensity
% Initial frame
Fint       = 1;

% Initialize grid for locating centroid of LED
%[X,Y] = meshgrid(1:width,1:height);
%frame = imadjust(rgb2gray(read(readerobj,Fint)));
%if manualROI
 %   ok = 0;
 %   figure(1),clf

 %   while ~ok
  %      clf,imshow(frame)
  %      fprintf('Define your ROI. Click ''enter'' when finished\n')
  %      [x,y] = ginput;
  %      inArea = inpolygon(X(:),Y(:),x,y);
  %      inArea = double(reshape(inArea,[height width]));
  %      frame(~inArea) = 0;

  %      clf,imshow(frame)

 %       reply = input('OK with the result? Y/N [Y]:','s');
  %      if ~strcmp(reply,'N')
  %          ok = 1;
  %      end
 %   end
%end


% Initialize fr in case first frame reading returns error
fr  = zeros(height,width,3,'uint8');
fr_r = zeros(height,width);
fr_b = zeros(height,width);
frame1 = read(readerobj,1);
clf,imshow(frame1);title('Select Door Region')
rect_door = getrect;
rect_door = int16(rect_door);
title('Select Reward Points')
[reward_pts(:,1) reward_pts(:,2)] = getpts;
title('Select Cheeseboard Center')
[center(1) center(2)] = getpts;

[X,Y] = meshgrid(1:width,1:height);
clf,imshow(frame1);title('Define LED Region. Click ''enter'' when finished')
[x,y] = ginput;
inArea = inpolygon(X(:),Y(:),x,y);
inArea = uint8(reshape(inArea,[height width]));
frame1(:,:,1) = frame1(:,:,1).*inArea;
frame1(:,:,2) = frame1(:,:,2).*inArea;
frame1(:,:,3) = frame1(:,:,3).*inArea;

clf,imshow(frame1)

% reply = input('OK with the result? Y/N [Y]:','s');
% if ~strcmp(reply,'N')
%         ok = 1;
% end

% Initialize whl matrix
whl.p = [];
whl.trial = [];
positions = zeros(NOF,4);

Red = [-1 -1];
Blue = [-1 -1];

for i = Fint:NOF
%     % Initialize red and blue LEDS as missing (=> -1)
    
    
    %fprintf('%i',i);
    
    % Access frame of interest - if error (mostly for the last frames,
    % don't know why), will analyze previous frame...
    try
        fr    = read(readerobj,i);
%        zeros(fr(~inArea,:));
    end
    fr_bw = im2bw(fr,0.35);
    door_region = fr_bw(rect_door(2):rect_door(2)+rect_door(4),rect_door(1):rect_door(1)+rect_door(3));
    door(i) = mean2(door_region);
    
    
    if door(i) < 0.4
    % Spatial filter
        filt = fspecial('average',10);
        frs = imfilter(fr,filt);
        fr2 = fr-frs;

        filt = fspecial('average',5);
        fr3 = imfilter(fr2, filt);
        
        fr_r = double(fr2(:,:,1).*inArea);
        fr_b = double(fr2(:,:,3).*inArea);

        % convert frame to thresholdable
    %     fr_bw = rgb2gray(fr);
%         if x==1
%             imshow(fr);title('Select LED Region')
%             rect_LED = getrect;
%             rect_LED = int16(rect_LED);
%             fr_r = zeros(height,width);
%             fr_b = zeros(height,width);
%             fr_r(rect_LED(2):rect_LED(2)+rect_LED(4),rect_LED(1):rect_LED(1)+rect_LED(3)) = double(fr2(rect_LED(2):rect_LED(2)+rect_LED(4),rect_LED(1):rect_LED(1)+rect_LED(3),1));
%             fr_b(rect_LED(2):rect_LED(2)+rect_LED(4),rect_LED(1):rect_LED(1)+rect_LED(3)) = double(fr2(rect_LED(2):rect_LED(2)+rect_LED(4),rect_LED(1):rect_LED(1)+rect_LED(3),3));
%             x = 0;
%         else
%             fr_r = double(fr2(:,:,1));
%             fr_b = double(fr2(:,:,3));
%         end
        template = zthreshimage(rgb2gray(fr2),0.75);%pixels that aren't too dim after filtering... ie worth paying attention to
        %template(~inArea)=0;
        fr_r_ok = fr_r;
        fr_b_ok = fr_b;
        fr_b_ok(find(~template)) = 0;
        fr_r_ok(find(~template)) = 0;

        rbdiff = fr_r.^2-fr_b;%)./fr_r;
        brdiff = fr_b.^2-fr_r.^2;
        %would have to brightness threshold first
        rbratio = log(fr_r_ok.^5./fr_b_ok);
        brratio = log(fr_b_ok./fr_r_ok);

        % bright enough in each color
        zbright_r = zthreshimage(fr_r,7);
        zbright_b = zthreshimage(fr_b,8);
        absbright_r = threshimage(fr_r,50);    
        absbright_b = threshimage(fr_b,70);

        % color selective enough by diff
        zdiffsel_r = zthreshimage(rbdiff,9);% diff above z score
        zdiffsel_b = zthreshimage(brdiff,18);
        absdiffsel_r = threshimage(rbdiff,2500);% diff above absolute level 
        absdiffsel_b = threshimage(brdiff,5500);%7000

        % color selective enough by ratio
        zratsel_r = zthreshimage(rbratio,1.8);% diff above z score
        zratsel_b = zthreshimage(brratio,0.6);%1.4

    %     ratsel_r = im2bw(rbratio,.51);% above 55st %ile ratio
    %     ratsel_b = im2bw(brratio,.51);% above 51st %ile ratio

        % bright and selective enough
    %     combo_r = diffsel_r.*ratsel_r.*bright_r;
    %     combo_b = diffsel_b.*ratsel_r.*bright_b;
        combo_r = zbright_r.*absbright_r.*zdiffsel_r.*absdiffsel_r.*zratsel_r;
        combo_b = zbright_b.*absbright_b.*zdiffsel_b.*absdiffsel_b.*zratsel_b;

    % keep only the largest object in each thresholded image
        % blue
        [l_b,numobjs_b] = bwlabel(combo_b);
        if numobjs_b>0
            numeach_b = zeros(1,numobjs_b);
            pBlue = zeros(numobjs_b,2);
            possib_b = zeros(1,numobjs_b);
            for b = 1:numobjs_b
                numeach_b(b) = sum(l_b(:)==b);
                rgroup_b = b;
                pl_b = regionprops(l_b,'PixelList');
                pBlue(b,:) = round(mean(pl_b(rgroup_b).PixelList,1));
                if i==1 || Blue(1)==-1 ||Blue(2)==-1
                    possib_b(b) = numeach_b(b);
                else
                    possib_b(b)=numeach_b(b)/exp((abs(pBlue(b,1)-Blue(1))+abs(pBlue(b,2)-Blue(2)))/10);
                end
            end
            [~,I] = max(possib_b);
            Blue = pBlue(I,:);
        end
        % red
        [l_r,numobjs_r] = bwlabel(combo_r);
        if numobjs_r>0
            numeach_r = zeros(1,numobjs_r);
            pRed = zeros(numobjs_r,2);
            possib_r = zeros(1,numobjs_r);
            for r = 1:numobjs_r
                numeach_r(r) = sum(l_r(:)==r);
                rgroup_r = r;
                pl_r = regionprops(l_r,'PixelList');
                pRed(r,:) = round(mean(pl_r(rgroup_r).PixelList,1));
                if i==1 || Red(1)==-1 ||Red(2)==-1 
                    if abs(pRed(r,1)-Blue(1))+abs(pRed(r,2)-Blue(2))>30
                        possib_r(r) = numeach_r(r)/exp((abs(pRed(r,1)-Blue(1))+abs(pRed(r,2)-Blue(2)))/10);
                    else
                        possib_r(r) = numeach_r(r);
                    end
                else
                    possib_r(r)=numeach_r(r)/exp((abs(pRed(r,1)-Red(1))+abs(pRed(r,2)-Red(2)))/10);
                end
            end
            [~,I]= max(possib_r);
            Red = pRed(I,:);
        end
        if abs(Red(1)-Blue(1))+abs(Red(2)-Blue(2)) > 30
             Red = [-1 -1];%NaN(1,2);
        end

            %[~,rgroup] = max(numeach);
            %pl = regionprops(l,'PixelList');
            %Red = round(mean(pl(rgroup).PixelList,1));
        %end

        %[~,bgroup] = max(numeach);
        %pl = regionprops(l,'PixelList');
        %Blue = round(mean(pl(bgroup).PixelList,1));

%        possib = zeros(numobjs_b,numobjs_r);
%         for m = 1:numobjs_b
%             for n = 1:numobjs_r
%                 possib(m,n) = possib_b(m)*possib_r(n)/exp((abs(pRed(n,1)-pBlue(m,1))+abs(pRed(n,2)-pBlue(m,2)))/10);
%             end    
%         end
%         [~,I] = max(possib(:));
%         [I_b,I_r] = ind2sub(size(possib),I);
%         Blue = pBlue(I_b,:);
%         Red = pRed(I_r,:);   
%         if abs(Red(1)-Blue(1))+abs(Red(2)-Blue(2)) > 40
%             Red = [-1 -1];
%             Blue = [-1 -1];
%         end
        positions(i,:) = [Red(1),Red(2),Blue(1),Blue(2)];

        %if whl(i,1) == -1
        %    whl(i,1:2) = NaN;
        %end
        %if whl(i,3) == -1
        %    whl(i,3:4) = NaN;
        %end
    end
    
    % End processing time, now outputting/plotting
    if i==NOF %|| mod(i,2000)==0 || & i<10000
        ixr = positions(i-NOF+1:i,1);%(i-1999:i,1);
        
        ixr = ixr==-1;
        ixb = positions(i-NOF+1:i,3);%(i-1999:i,3);
        ixb = ixb==-1;%isnan(ixb);
        ok = (1-ixr).*(1-ixb);
        figure(1),clf,
        subplot(3,1,1);imshow(uint8(fr));title('If looks wrong, Ctrl+C and change threshold \!!')

        subplot(3,3,5);imagesc(cat(3,combo_r,zeros(size(combo_r)),combo_b));
        xlim([0 size(fr,1)])
        ylim([0 size(fr,2)])
        axis equal

        subplot(3,3,8)
            plot(positions(i-NOF+1:i,1),positions(i-NOF+1:i,2),'r.')%(whl(i-1999:i,1),whl(i-1999:i,2),'r.')
            hold on
            plot(positions(i-NOF+1:i,3),positions(i-NOF+1:i,4),'b.')%(whl(i-1999:i,3),whl(i-1999:i,4),'b.')
            mx = mean([positions(i-NOF+find(ok),1) positions(i-NOF+find(ok),3)],2);%([whl(i-2000+find(ok),1) whl(i-2000+find(ok),3)],2);                
            my = mean([positions(i-NOF+find(ok),2) positions(i-NOF+find(ok),4)],2);                
            plot(mx,my,'Marker','.','color',[0.5 0.5 0.5],'LineStyle','none')
            xlim([0 size(fr,1)])
            ylim([0 size(fr,2)])
            axis equal
            viscircles(reward_pts,[15;15;15]);
        fail_r = sum(ixr);
        fail_b = sum(ixb);
        fprintf('Detection of Red LED failed %i times (%i times for the blue LED) in %i frames.\n',fail_r,fail_b,NOF);   
    end
    if i == 1;
        h = waitbar(i/NOF);
    else
        waitbar(i/NOF,h);
    end
end
whl = DefineTrials(positions);
save(fullfile(pathstr,['track_' name(32:39) '_v2']),'whl','fail_r','fail_b');
save(fullfile(pathstr,['other_properties_' name(32:39)]),'reward_pts','center');
close(h)