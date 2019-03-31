function [binbounds_lin,ylin,binbounds_log,ylog]= RateDistributionsLinearAndLog(varargin)
%same as PlotRateDistributionsLinearAndLog but no plotting

distros = varargin;
numbins = 25;
% color = 'b';
% vertnumsubplots = 2;
% smoothwidth = 1;
binbounds_lin = [];
binbounds_log = [];

for a = length(varargin):-1:1;
    if isstr(varargin{a})
        switch varargin{a}
            case 'numbins'
                numbins = varargin{a+1};
                distros(a+1) = [];
                distros(a) = [];
%             case 'color'
%                 color = varargin{a+1};
%                 distros(a+1) = [];
%                 distros(a) = [];
%             case 'vertnumsubplots'
%                 vertnumsubplots = varargin{a+1};
%                 distros(a+1) = [];
%                 distros(a) = [];
%             case 'smoothwidth'
%                 smoothwidth = varargin{a+1};
%                 distros(a+1) = [];
%                 distros(a) = [];
            case 'binbounds_lin'
                binbounds_lin = varargin{a+1};
                distros(a+1) = [];
                distros(a) = [];
            case 'binbounds_log'
                binbounds_log = varargin{a+1};
                distros(a+1) = [];
                distros(a) = [];
        end
    end
end

if ~exist('binbounds_lin','var')
    [binbounds_lin,~] = GetBinBounds(distros);
end
if ~exist('binbounds_lin','var')
    [~,binbounds_log] = GetBinBounds(distros);
end

numdistros = length(distros);

% h = figure;
for a=1:numdistros;
    thisset = distros{a};
%     columncount = (a-1)*2+1;
    
%     subplot(vertnumsubplots,numdistros,a)
    [ylin] = histc(thisset,binbounds_lin{a});%Total spiking overall
%     plot(binbounds_lin{a},smooth(ylin,smoothwidth))

    
%     subplot(vertnumsubplots,numdistros,(numdistros+a))
    minbin = log10(min(thisset));
    if minbin == -Inf || ~isreal(minbin)
        minbin = log10(min(thisset(thisset>0)));
    end
    if ~isempty(minbin)
        try
            [ylog] =histc(thisset,binbounds_log{a});
%             plot(log10(binbounds_log{a}),smooth(ylog,smoothwidth),'color',color,'LineWidth',1);%semilogx doesn't work since this is base10
            %     bar(log10(x),y);
        %     set(gca,'Xticklabel',10.^get(gca,'Xtick'))
%             if min(binbounds_log{a}) == max(binbounds_log{a});
%                 xlim([min(binbounds_log{a})-1 min(binbounds_log{a})+1])
%             else
%                 xlim(log10([min(binbounds_log{a})/1.4 max(binbounds_log{a})*1.4]))
%             end
            goodymax = max(ylog(2:end));
%             ylim([0 goodymax*1.2])
        catch
            disp('Some Error in plotting log hist')
            binbounds_log{a} = [];
            ylog = [];
        end
    else
        binbounds_log{a} = [];
        ylog = [];
    end

end

% hp = findobj(gcf,'Type','patch');
% set(hp,'FaceColor',color);
% % if length(binlocations)>30
%     set(hp,'EdgeColor',color);
% % end