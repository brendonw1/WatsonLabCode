function [openpercent,centerpercent,nonclosedpercent,closedpercent] = EPMMarkerlessProcessingSuite(filename)

obj = VideoReader(filename);
frame = read(obj,1);
figure;imagesc(frame);

% [x,y] = ginput;
% disp('Hit Return when finished selecting points')


prompt = {'Enter X1, X2, Y1, Y2 of Open Arm 1 (spaces between)',...
'Enter X1, X2, Y1, Y2 of Open Arm 2 (spaces between)',...
'Enter X1, X2, Y1, Y2 of Closed Arm 1 (spaces between)',...
'Enter X1, X2, Y1, Y2 of Closed Arm 2 (spaces between)',...
'Enter X1, X2, Y1, Y2 of Center Area (spaces between)'};
dlgtitle = 'Arms Coordinates Input';
defaultanswer = {'','','','',''};
options.WindowStyle='normal';

coords = inputdlg(prompt, dlgtitle, 1,defaultanswer,options);

open1lims = str2num(coords{1});
open2lims = str2num(coords{2});
closed1lims = str2num(coords{3});
closed2lims = str2num(coords{4});
centerlims = str2num(coords{5});

video = BkgndSubtractResampledMovie(filename,2);
threshmovie = BinaryThresholdDiffMovie(video);

[openpercent,centerpercent,nonclosedpercent,closedpercent] = EPMMarkerlessProcessing(threshmovie,open1lims,open2lims,closed1lims,closed2lims,centerlims);

outmat = {'openpercent' openpercent; 'centerpercent' centerpercent; 'nonclosedpercent' nonclosedpercent; 'closedpercent' closedpercent};
[nrows,ncols]= size(outmat);
[pathstr,name,ext]=fileparts(filename);
fid = fopen([name,'_EPMAnalysis.txt'],'w');
for row=1:nrows
    fprintf(fid, '%s %f %f %f\n', outmat{row,:});
end
fclose(fid);
