function whl = Find_RB_LED_open_field(file)
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
% NOF        = 320;
threshF    = 150;    % threshold on foreground pixel intensity
% Initial frame
Fint       = 180;

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
frame1 = read(readerobj,Fint);
% clf,imshow(frame1);title('Select LED Region')
% rect = getrect;
% inArea = [rect(1) rect(2); rect(1)+rect(3) rect(2); rect(1) rect(2)+rect(4); rect(1)+rect(3) rect(2)+rect(4)];
% inArea = int16(reshape(inArea,[height width]));
% imshow(frame1);title('Select LED Region')
% rect_LED = getrect;
% rect_LED = int16(rect_LED);

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
whl = zeros(NOF,4);

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
    %     fr_bw = im2bw(fr,0.35);
    %     door_region = fr_bw(rect_door(2):rect_door(2)+rect_door(4),rect_door(1):rect_door(1)+rect_door(3));
    %     door(i) = mean2(door_region);
    
    
    % if door(i) < 0.4
    % Spatial filter
    filt = fspecial('average',10);
    frs = imfilter(fr,filt);
    fr2 = fr-frs;
    
    filt = fspecial('average',5);
    fr3 = imfilter(fr2, filt);
    
    fr_r = double(fr3(:,:,1).*inArea);
    fr_b = double(fr3(:,:,3).*inArea);
%     fr_g = double(fr3(:,:,2).*inArea);
    
    %         fr_r = double(fr2(:,:,1).*inArea);
    %         fr_b = double(fr2(:,:,3).*inArea);
    
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
    %         template = zthreshimage(rgb2gray(fr2),0.75);%pixels that aren't too dim after filtering... ie worth paying attention to
    %template(~inArea)=0;
    %         fr_r_ok = fr_r;
    %         fr_b_ok = fr_b;
    %         fr_b_ok(find(~template)) = 0;
    %         fr_r_ok(find(~template)) = 0;
    
            rbdiff = fr_r-fr_b;
            brdiff = fr_b-fr_r;
    %         %would have to brightness threshold first
    %         rbratio = log(fr_r_ok.^5./fr_b_ok);
    %         brratio = log(fr_b_ok./fr_r_ok);
    
    % bright enough in each color
    %         zbright_r = zthreshimage(fr_r,13);
    %         zbright_b = zthreshimage(fr_b,7);
    %         zbright_g = zthreshimage(fr_g,14);
    absbright_r = threshimage(fr_r,25);
    absbright_b = threshimage(fr_b,37);
%     absbright_g = threshimage(fr_g,26);
    
    %         % color selective enough by diff
%             zdiffsel_r = zthreshimage(rbdiff,2);% diff above z score
            zdiffsel_b = zthreshimage(brdiff,15);
    %         absdiffsel_r = threshimage(rbdiff,2500);% diff above absolute level
    %         absdiffsel_b = threshimage(brdiff,5500);%7000
    %
    %         % color selective enough by ratio
    %         zratsel_r = zthreshimage(rbratio,1.8);% diff above z score
    %         zratsel_b = zthreshimage(brratio,0.6);%1.4
    
    %     ratsel_r = im2bw(rbratio,.51);% above 55st %ile ratio
    %     ratsel_b = im2bw(brratio,.51);% above 51st %ile ratio
    
    % bright and selective enough
    %     combo_r = diffsel_r.*ratsel_r.*bright_r;
    %     combo_b = diffsel_b.*ratsel_r.*bright_b;
    %         combo_r = zbright_r.*absbright_r;
    %         combo_b = zbright_b.*absbright_b;
    %         combo_g = zbright_g.*absbright_g;
    %         combo = combo_r.*combo_g;
    %         combo = combo_r.*combo_b.*combo_g;
    combo_b = zdiffsel_b.*absbright_b;
    combo_r = absbright_r;
%     combo_r = zdiffsel_r.*absbright_r;
    
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
        else
            Blue = [-1 -1];
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
        else 
            Red = [-1 -1];
        end
        if abs(Red(1)-Blue(1))+abs(Red(2)-Blue(2)) > 30 && Blue(1) ~= -1
             Red = [-1 -1];
        end
        
        
%     % find largest 2
%     [l,numobjs] = bwlabel(combo);
%     
%     numeach = zeros(1,numobjs);
%     pLED = zeros(numobjs,2);
%     possib = zeros(1,numobjs);
%     for j = 1:numobjs
%         numeach(j) = sum(l(:)==j);
%         rgroup = j;
%         pl = regionprops(l,'PixelList');
%         pLED(j,:) = round(mean(pl(rgroup).PixelList,1));
%         possib(j) = numeach(j);
%     end
%     detection = 0;
%     if numobjs>1
%         [~,I] = sort(possib,'descend');
%         for m = 1:numobjs-1
%             for n = m+1:numobjs
%                 if (10 < sum(abs(pLED(I(m),:)-pLED(I(n),:)))) && (sum(abs(pLED(I(m),:)-pLED(I(n),:))) < 50) && (numeach(I(m))>20) && (numeach(I(n))>20)
%                     if LED1(1) ~= -1  &&  LED2(1) ~= -1
%                         if sum(abs(pLED(I(m),:)+pLED(I(n),:)-LED1-LED2)) < 60
%                             LED1 = pLED(I(m),:);
%                             LED2 = pLED(I(n),:);
%                             detection = 1;
%                             break
%                         end
%                     elseif i==1
%                         LED1 = pLED(I(m),:);
%                         LED2 = pLED(I(n),:);
%                         detection = 1;
%                         break
%                     else
%                         lastp = find(whl(1:i-1,1)~=-1,1,'last');
%                         if (i-lastp<3 && sum(abs(whl(lastp,1:2)+whl(lastp,3:4)-pLED(I(m),:)-pLED(I(n),:)))/2<150) || i-lastp>=3
%                             LED1 = pLED(I(m),:);
%                             LED2 = pLED(I(n),:);
%                             detection = 1;
%                             break
%                         end
%                     end
%                     
%                 end
%             end
%         end
%     elseif numobjs==1 && numeach(1)>20
%         d1 = abs(pLED(1,1)-LED1(1))+abs(pLED(1,2)-LED1(2));
%         d2 = abs(pLED(1,1)-LED2(1))+abs(pLED(1,2)-LED2(2));
%         if (d1 < 30) && (d1 < d2) && (LED1(1) ~= -1)
%             LED1 = pLED(1,:);
%             LED2 = [-1 -1];
%             detection = 1;
%         elseif (d2 < 30) && (LED2(1) ~= -1)
%             LED1 = [-1 -1];
%             LED2 = pLED(1,:);
%             detection = 1;
%         end
%     end
%     if ~detection
%         LED1 = [-1 -1];
%         LED2 = [-1 -1];
%     end
    
    whl(i,:) = [Red(1) Red(2) Blue(1) Blue(2)];
    
    
    % End processing time, now outputting/plotting
    if i==NOF %|| mod(i,2000)==0 || & i<10000
        ix_LED1 = whl(i-NOF+1:i,1);%(i-1999:i,1);
        ix_LED1 = ix_LED1==-1;
        ix_LED2 = whl(i-NOF+1:i,3);%(i-1999:i,3);
        ix_LED2 = ix_LED2==-1;%isnan(ixb);
        ok = (1-ix_LED1).*(1-ix_LED2);
        figure(1),clf,
        subplot(3,1,1);imshow(uint8(fr));title('If looks wrong, Ctrl+C and change threshold \!!')
        
                subplot(3,3,5);imagesc(cat(3,combo_r,zeros(size(combo_r)),combo_b));
                xlim([0 size(fr,1)])
                ylim([0 size(fr,2)])
                axis tight
        
        subplot(3,3,8)
        plot(whl(i-NOF+1:i,1),whl(i-NOF+1:i,2),'r.')%(whl(i-1999:i,1),whl(i-1999:i,2),'r.')
        hold on
        plot(whl(i-NOF+1:i,3),whl(i-NOF+1:i,4),'b.')%(whl(i-1999:i,3),whl(i-1999:i,4),'b.')
        mx = mean([whl(i-NOF+find(ok),1) whl(i-NOF+find(ok),3)],2);%([whl(i-2000+find(ok),1) whl(i-2000+find(ok),3)],2);
        my = mean([whl(i-NOF+find(ok),2) whl(i-NOF+find(ok),4)],2);
        plot(mx,my,'Marker','.','color',[0.5 0.5 0.5],'LineStyle','none')
        xlim([0 size(fr,1)])
        ylim([0 size(fr,2)])
        axis normal
        fail_LED1 = sum(ix_LED1);
        fail_LED2 = sum(ix_LED2);
        fprintf('Detection of Red LEDs failed %i times; Detection of Blue LEDs failed %i times;   in total %i frames. \n',fail_LED1,fail_LED2,NOF);
    end
    if i == Fint;
        h = waitbar(i/NOF);
    else
        waitbar(i/NOF,h);
    end
end
save(fullfile(pathstr,['track_' name(32:46)]),'whl','fail_LED1','fail_LED2');
close(h)