function [openpercent,centerpercent,nonclosedpercent,closedpercent] = EPMMarkerlessProcessing(BinThreshMovie,open1lims,open2lims,closed1lims,closed2lims,centerlims)
% Calculates time in open/closed/center areas of elevated plus maze.
% Assumes contrast somewhere around rat or in rats markings.
% Takes a binary thresholded movie from BinaryThresholdDiffMovie and
% manually entered x,y coords of elevated plus maze arms ([open arm 1 x1,
% open arm 1 x2, open arm 1 y1, open arm 1 y2],...).  Outputs are percent
% times detected in open arms, center, open+center and closed, as a percent
% of all frames where a spot was detected in that frame.
% >>> Assumes diff from background, not framebyframe diff!

numframes = size(BinThreshMovie,3);
blanktemplate = logical(zeros(size(BinThreshMovie,1),size(BinThreshMovie,2)));

% open1lims = [242 360 184 251];
open1template = blanktemplate;
open1x = sort([open1lims(1) open1lims(2)]);
open1y = sort([open1lims(3) open1lims(4)]);
open1x(1) = max(open1x(1),1);%set the first value to 1, not 0
open1y(1) = max(open1y(1),1);%set the first value to 1, not 0
open1template(open1y(1):open1y(2),open1x(1):open1x(2)) = 1;

% open2lims = [389 514 182 251];
open2template = blanktemplate;
open2x = sort([open2lims(1) open2lims(2)]);
open2y = sort([open2lims(3) open2lims(4)]);
open2x(1) = max(open2x(1),1);%set the first value to 1, not 0
open2y(1) = max(open2y(1),1);%set the first value to 1, not 0
open2template(open2y(1):open2y(2),open2x(1):open2x(2)) = 1;

% closed1lims = [349 400 79 203];
closed1template = blanktemplate;
closed1x = sort([closed1lims(1) closed1lims(2)]);
closed1y = sort([closed1lims(3) closed1lims(4)]);
closed1x(1) = max(closed1x(1),1);%set the first value to 1, not 0
closed1y(1) = max(closed1y(1),1);%set the first value to 1, not 0
closed1template(closed1y(1):closed1y(2),closed1x(1):closed1x(2)) = 1;

% closed2lims = [348 402 231 354];
closed2template = blanktemplate;
closed2x = sort([closed2lims(1) closed2lims(2)]);
closed2y = sort([closed2lims(3) closed2lims(4)]);
closed2x(1) = max(closed2x(1),1);%set the first value to 1, not 0
closed2y(1) = max(closed2y(1),1);%set the first value to 1, not 0
closed2template(closed2y(1):closed2y(2),closed2x(1):closed2x(2)) = 1;

% centerlims = [360 389 203 231];
centertemplate = blanktemplate;
centerx = sort([centerlims(1) centerlims(2)]);
centery = sort([centerlims(3) centerlims(4)]);
centertemplate(centery(1):centery(2),centerx(1):centerx(2)) = 1;

foundanimal = logical(zeros(1,numframes));
scores = zeros(1,numframes);
for a  = 1:numframes; %(could run this cycle above in previous loop)    
    thisframe = BinThreshMovie(:,:,a);
    if sum(sum(thisframe))>0
        foundanimal(a) = 1;
    end
    
    if 0<sum(sum(open1template.*thisframe))%if in left open arm
        scores(a) = max(scores(a),2);%give 2pts
    end
    if 0<sum(sum(open2template.*thisframe))%if in right open arm
        scores(a) = max(scores(a),2);%give 2pts
    end
    if 0<sum(sum(centertemplate.*thisframe))%if in center
        scores(a) = max(scores(a),1);%give 1pt
    end
end

%     if 0<sum(sum(closedtoptemplate.*thisframe))
%         scores(a) = max(scores(a),0);
%     end
%     if 0<sum(sum(closedbottomtemplate.*thisframe))
%         scores(a) = max(scores(a),0);
%     end

legitscores = scores(foundanimal);%this is where diff from background is assumed rather than diff from previous... if diff from previous, would assume it was where it was in previous frame.

totalopenframes = sum(legitscores==2);
totalcenterframes = sum(legitscores==1);
totalnonclosedframes = totalopenframes + totalcenterframes;
totalclosedframes = sum(legitscores==0);

openpercent = totalopenframes/length(legitscores);
centerpercent = totalcenterframes/length(legitscores);
nonclosedpercent = openpercent+centerpercent;
closedpercent = totalclosedframes/length(legitscores);