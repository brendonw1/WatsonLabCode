function ClusterPointsBoundaryOutBW_NOCLICK(Data, ECells, ICells,m,b,interestcells,ENames,INames)
% function [In,pl] = ClusterPointsBoundaryOut(Data, IfPlot,nClusters)
%
% --This is from Anton's 'ClusterPoints.m'
%   The only difference is that you can also output the boundary information (pl)
%
% Data is two column matrix of coordinates, IfPlot =1 if you want Data to
% be ploted by this function (0, if they are plotter already in current
% axes).
% ECells and ICells are lists of E or I cells (ie by synaptic
% interactions).  They may be empty.
% m & b are slope and intersect of separatrix
%
% starts clustering manual interface like in klusters
% - left click - new line
%   right click - one back
%   middle click - close the polygon.
% don't click too fast -it wrongly interprets double click I guess.
%  returns In - binary vector where ones corresopond to caught fish :))

hold on
plot(Data(:,1), Data(:,2),'k.');
if ~isempty(ECells)
    plot(Data(ECells,1),Data(ECells,2),'.','color',[.2 .8 .2],'markersize',12)
end
if ~isempty(ICells)
    plot(Data(ICells,1),Data(ICells,2),'.','color','r','markersize',12)
end
xb = get(gca,'XLim');
yb = get(gca,'YLim');
plot(xb,[m*xb(1)+b m*xb(2)+b])
xlim(xb)
ylim(yb)

hold off;


