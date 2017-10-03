function plotIntervalsStrip(ax,ints,scalingfactor)
% Plots colorized states (from StateEditor) on the top of the current
% graph.  From stateintervals variable in _StateIDM.mat files.
% ax - axes on which to plot
% intervals - intervals from ConvertStatesVectorToIntervalSets
% scaling factor = samples per second (baseline is 1, not 10000)

if isempty(ints)
    return
end

if ~exist('scalingfactor','var')
    scalingfactor = 1;
end

hold on

yl = get(ax,'YLim');
linewidth = abs(diff(yl))*0.15;
y = yl(2);
ylim([yl(1) yl(2)+linewidth])


switch class(ints)
    case('struct')
    colorwheel = [[0 0 0];...
        [6, 113, 148]/255;...
        [207, 46, 49]/255];
        for a = 1:3 %for each class of interval
            switch a
                case 1
                    if isfield(ints,'WakeInts')
                        ti = ints.WakeInts;
                    elseif isfield(ints,'WAKEstate')
                        ti = ints.WAKEstate;
                        ti = intervalSet(ti(:,1),ti(:,2));
                    end
                case 2
                    if isfield(ints,'SWSPacketInts')
                        ti = ints.SWSPacketInts;
                    elseif isfield(ints,'NREMstate')
                        ti = ints.NREMstate;
                        ti = intervalSet(ti(:,1),ti(:,2));
                    end
                case 3
                    if isfield(ints,'REMEpisodeInts')
                        ti = ints.REMEpisodeInts;
                    elseif isfield(ints,'REMepisode')
                        ti = ints.REMepisode;
                        ti = intervalSet(ti(:,1),ti(:,2));
                    end

            end
            for b = 1:length(length(ti));
                thisint = scalingfactor*[StartEnd(subset(ti,b),'s')];
                patch([thisint(1) thisint(1) thisint(2) thisint(2)],[y y+linewidth y+linewidth  y],colorwheel(a,:),'edgecolor',colorwheel(a,:))
            end
        end
    case {'cell', 'double'}
        if strcmp(class(ints),'double')
            ints = IDXtoINT_ss(ints);
        end
        colorwheel = [[0 0 0];...
            [255, 236, 79]/255;...
            [6, 113, 148]/255;...
            [19, 166, 50]/255;...
            [207, 46, 49]/255];
        for a = 1:5 %for each class of interval
            ti = ints{a}; 
            if strcmp(class(ti),'intervalSet')
                ti = StartEnd(ti);
            end
            if ~isempty(ti)
                for b = 1:size(ti,1)
                    thisint = scalingfactor*ti(b,:);
                    patch([thisint(1) thisint(1) thisint(2) thisint(2)],[y y+linewidth y+linewidth  y],colorwheel(a,:),'edgecolor',colorwheel(a,:))
                end
            end
        end
%     case {'cell'}
%         if strcmp(class(ints),'double')
%             ints = IDXtoINT(ints);
%         end
%         colorwheel = [[0 0 0];...
%             [255, 236, 79]/255;...
%             [6, 113, 148]/255;...
%             [19, 166, 50]/255;...
%             [207, 46, 49]/255];
%         for a = 1:5 %for each class of interval
%             ti = ints{a}; 
%             for b = 1:length(length(ti));
%                 thisint = scalingfactor*[StartEnd(subset(ti,b),'s')];
%                 patch([thisint(1) thisint(1) thisint(2) thisint(2)],[y y+linewidth y+linewidth  y],colorwheel(a,:),'edgecolor',colorwheel(a,:))
%             end
%         end
end