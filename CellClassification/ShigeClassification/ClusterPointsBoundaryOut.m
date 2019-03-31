function [In,pl] = ClusterPointsBoundaryOut(Data, varargin);
% function [In,pl] = ClusterPointsBoundaryOut(Data, IfPlot,nClusters)
%
% --This is from Anton's 'ClusterPoints.m'
%   The only difference is that you can also output the boundary information (pl)
%
% Data is two column matrix of coordinates, IfPlot =1 if you want Data to
% be ploted by this function (0, if they are plotter already in current
% axes).
% starts clustering manual interface like in klusters
% - left click - new line
%   right click - one back
%   middle click - close the polygon.
% don't click too fast -it wrongly interprets double click I guess.
%  returns In - binary vector where ones corresopond to caught fish :))

[IfPlot, nClusters] = DefaultArgs(varargin,{0,1});

if IfPlot
    plot(Data(:,1), Data(:,2),'.');
end

hold on

for nc=1:nClusters
linepos=1;
pl=[];%matrix of polyline coords
h_lastline=[];

    zoomoff = 1;
    while 1
        [x y button]=PointInput(1);
        res = button*zoomoff;      title('Discriminate pyr and int (select Pyramidal)');

        switch res
            case 1 % left button
                pl(linepos,:)=[x y];
                if linepos>1
                    h_lastline(end+1) = line([pl(linepos-1,1),pl(linepos,1)],[pl(linepos-1,2),pl(linepos,2)]);
                    set(h_lastline(end),'Color','k');
                end;
                linepos=linepos+1;
            case 2% middle button
                if linepos>2
                    pl(linepos,:)=pl(1,:);
                    h_lastline(end+1) = line([pl(linepos-1,1),pl(linepos,1)],[pl(linepos-1,2),pl(linepos,2)]);
                    set(h_lastline(end),'Color','k');
                    break;
                end
            case 3 %right button
                if linepos>2
                    linepos=linepos-1;
                    delete(h_lastline(end));
                    h_lastline(end)=[];
                    pl(end,:)=[];

                end;

            case 0 %pressed a key or iz in zoom state
                curchar = get(gcf,'CurrentCharacter');
                if button==0 & strcmp(curchar,'z')
                    zoomoff= ~zoomoff;
                    continue
                end
                if ~zoomoff
                    switch button
                        case 1
                            zoom(1.5);
                        case 3
                            zoom(0.5);      title('Discriminate pyr and int (select Pyramidal)');

                    end
                end
            otherwise
                fprintf('uups\n');
        end
    end
    if nClusters==1
        In = inpolygon(Data(:,1), Data(:,2), pl(:,1),pl(:,2));
    else
        In(inpolygon(Data(:,1), Data(:,2), pl(:,1),pl(:,2))) = nc;
    end

end



if nargout<1
    plot(Data(In,1),Data(In,2),'r*');
end


hold off;


