function [p,r,slope,SlopeCI, intercept, yfit] = ScatterWStats(v1,v2,plotmode,textmode,idlinemode,color)
% plotmode 
%                  loglog-> log, log
%                  logx -> log, linear
%                  logy -> linear, log
%                  linear -> linear, linear
warning off

v1 = v1(:);
v2 = v2(:);
n1 = inputname(1);
n2 = inputname(2);
alpha = 0.05;%signif test
if ~exist('plotmode','var')% linear, logx,logy or loglog
    plotmode = 'linear';
end
if ~exist('textmode','var')% max,min,off
    textmode = 'max';
end
if ~exist('idlinemode','var');
    idlinemode = plotmode;
end
if ~exist('color','var')
    color = 'red';
end

[slope, intercept, MSE, r, SlopeCI, p, S, yfit] = logfit_bw(v1,v2,plotmode,'linecolor',color);
if isempty(SlopeCI)
    SlopeCI = nan;
end

hold on
if ~isempty(v1) & ~isempty(slope)
    try
%% axes and plotting
        mama = max([v1;v2]);
        mimi = min([v1;v2]);
        xlim([mimi mama])
        ylim([mimi mama])
%% plotting idenity line
        switch lower(idlinemode)
            case 'linear'
                plot([mimi mama],[0 mama],'color',[.7 .7 .7])
            case 'logx'
                mimi = min([v1(v1>0);v2(v2>0)]);
                semilogx([mimi mama],[0 mama],'color',[.7 .7 .7])
            case 'logy'
                mimi = min([v1(v1>0);v2(v2>0)]);
                semilogy([0 mama],[mimi mama],'color',[.7 .7 .7])
            case 'loglog'
                mimi = min([v1(v1>0);v2(v2>0)]);
                loglog([mimi mama],[mimi mama],'color',[.7 .7 .7])
            case 'none'
                1;
        end
        hold on

%% Text of stats
        switch lower(textmode)
            case 'max'
                texttext = {['R = ' num2str(r)];...
                ['p = ' num2str(p)];...
                ['Slope = ' num2str(slope) ' (' num2str(SlopeCI(1,1)), '-' num2str(SlopeCI(2,1)) ')']};
            case 'med'
                texttext = ['R=' num2str(r) ' P=' num2str(p) ' SLOPE=' num2str(slope) ':(' num2str(SlopeCI(1,1)), '-' num2str(SlopeCI(2,1)) ')'];
            case 'min'
                rs = num2str(r);
                rs = rs(1:3);
                if p<0.01
                    ps = '<0.01';
                else
                    ps = num2str(p);
                    ps = ['=' ps(1:3)];
                end
%                 ss = num2str(slope);
%                 ss = ss(1:3);
                smis = num2str(SlopeCI(1));
                smis = smis(1:3);
                smas = num2str(SlopeCI(2));
                smas = smas(1:3);
                texttext = ['R=' rs ' P' ps ' SL=' smis, '-' smas ''];
            otherwise
                texttext = [];
        end
        if ~isempty(texttext) 
            switch lower(plotmode)
                case 'linear'
                    textx = min(v1)+0.001*(range(v1));
                    texty = min(v2)+0.9*range(v2);
                case 'logx'
                    m1 = min(v1(v1>0));
                    textx = m1+0.001*(range(v1));
                    texty = min(v2)+0.9*range(v2);
                case 'logy'
                    m2 = min(v2(v2>0));
                    textx = min(v1)+0.001*(range(v1));
                    texty = m2+0.9*range(v2);
                case 'loglog'
                    m1 = min(v1(v1>0));
                    m2 = min(v2(v2>0));
                    textx = m1+0.001*(range(v1));
                    texty = m2+0.9*range(v2);
            end
                    
            th = text(textx,texty,texttext,'fontsize',6);
            if p<alpha
                set(th,'color','red')
            end
            if ~[SlopeCI(2)<1 && SlopeCI(1)>1]% if CI does not include 1
                set(th,'BackgroundColor',[.7 1 1 ])
            end
        end
    end
end
axis tight

xlabel(n1)
ylabel(n2)
