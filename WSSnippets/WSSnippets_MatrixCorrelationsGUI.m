function WSSnippets_MatrixCorrelationsGUI
load WSSnippetMatrix.mat

[R,P,RConfIntLo,RConfIntHi] = corrcoef(WSMatrix,'rows','pairwise');

f = figure('position',[400 400 800 400]);
plax = axes('parent',f,'position',[.45 .10 .42 .875]);
xselect = uicontrol('parent',f,'Style','Listbox',...
    'Units','normalized','position',[0.02 0.05 .17 .9],...
    'String',labels,'Callback',@xyplotcallback);
yselect = uicontrol('parent',f,'Style','Listbox',...
    'Units','normalized','position',[0.21 0.05 .17 .9],...
    'String',labels,'Callback',@xyplotcallback);
statsdisplay = uicontrol('parent',f,'Style','text',...
    'Units','normalized','position',[0.89 0.55 .09 .4]);
logselectx = uicontrol('parent',f,'Style','radiobutton',...
    'Units','normalized','position',[0.89 0.05 .09 .05],...
    'string','Log10 - X','callback',@xyplotcallback);
logselecty = uicontrol('parent',f,'Style','radiobutton',...
    'Units','normalized','position',[0.89 0.12 .09 .05],...
    'string','Log10 - Y','callback',@xyplotcallback);

handles = v2struct(f,plax,xselect,yselect,statsdisplay,logselectx,logselecty);
warning off
gd = v2struct(handles,R,P,WSMatrix,labels);
warning on 
guidata(f,gd);


function xyplotcallback(obj,ev)
gd = guidata(obj);
%get indices indicated by user with selectors
idx1 = get(gd.handles.xselect,'Value');
idx2 = get(gd.handles.yselect,'Value');

% set to log values if indicated by user
logxbool = get(gd.handles.logselectx,'value');
logybool = get(gd.handles.logselecty,'value');
if logxbool
    x = log10(gd.WSMatrix(:,idx1));
else
    x = gd.WSMatrix(:,idx1);
end
if logybool
    y = log10(gd.WSMatrix(:,idx2));
else
    y = gd.WSMatrix(:,idx2);
end

plot(x,y,'.k')
warning off
lsline
[~,r,p,~] =  RegressAndFindR(abs(x),abs(y),1);
warning on

dispstring = {['R = ' num2str(r)];['P = ' num2str(p)]};
set(gd.handles.statsdisplay,'string',dispstring)

xlabel(gd.labels(idx1));
ylabel(gd.labels(idx2));




%% For plotting by max R... but too many problematic ones
% labelsmtx1 = repmat(labels,[length(labels) 1]);
% labelsmtx2 = labelsmtx1';
% labelsvect1 = labelsmtx1(:);%linearized
% labelsvect2 = labelsmtx2(:);% linearized
% 
% [R,P,RConfIntLo,RConfIntHi] = corrcoef(WSMatrix,'rows','pairwise');
% R = triu(R,1);
% P = triu(P,1);
% aR = abs(R);
% 
% [~,RsortIX] = sort(aR(:));
% RsortIX = flipud(RsortIX);%put largest first (not last)
% RSortedR = R(RsortIX);%R linearized and sorted based on R rank
% RSortedP = P(RsortIX);%P linearized and sorted based on R rank
% RSortedLabels1 = labelsmtx1(RsortIX);
% RSortedLabels2 = labelsmtx2(RsortIX);
% 
% bad = isnan(RSortedR) | abs(RSortedR) > 0.8;
% RSortedR(bad) = [];
% RSortedP(bad) = [];
% RSortedLabels1(bad) = [];
% RSortedLabels2(bad) = [];
% 
% 
% numtoplot = 10;
% for a = 1:numtoplot
%     labs{a} = {RSortedLabels1{a};RSortedLabels2{a}};
% end
% figure;bar(RSortedR(1:numtoplot))
% hText = xticklabel_rotate(1:numtoplot,90,labs);
