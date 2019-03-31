function [r,p,yfit,coeffs] = PlotAndRegressLinearAndLog(x,y)
% plots x and y against each other on linear, semilogx, semilogy and loglog
% plots.  For each plot it generates and stores values for lines of best
% fits.  
% INPUTS
% x & y vectors of same length, to be plotted against each other
%
% OUTPUTS
% r - cell array of correlation r values for 1) linear vs linear, 2) 
%        semilogx, 3) semilogy and 4) loglog version of data
% p - cell array of correlation p values for 1) linear vs linear, 2) 
%        semilogx, 3) semilogy and 4) loglog version of data
% yfit - cell array of correlation y fit lines 1) linear vs linear, 2) 
%        semilogx, 3) semilogy and 4) loglog version of data
% r - cell array of correlation r values for 1) linear vs linear, 2) 
%        semilogx, 3) semilogy and 4) loglog version of data

%     [x,y] = ElimAnyNanInf(x,y);

xname = inputname(1);
yname = inputname(2);

x = x(:);
y = y(:);

if ~exist('color','var')
    color = [.5 .5 .5];
end

mama = max([x(x<inf);y(y<inf)]);
mimi = min([x(x>0);y(y>0)]);

if ~isempty(x) & ~isempty(y) & ~all(isnan(x)) & ~all(isnan(y)) & all(isreal(x)) & all(isreal(y)) 
% 
%     subplot(2,2,1) %linear plot
% %         plot(x,y,'marker','.','Line','none');
% %         [yfit{1},r{1},p{1},coeffs{1}] =  RegressAndFindR(x,y,1);
% %         hold on;plot(x,yfit{1},'r')
%         [slope, intercept,MSE, R, SlopeCI, P, S] = logfit_bw(x,y,'linear');
%         coeffs{1} = [slope intercept];
%         r{1} = R;
%         p{1} = P;
%         yfit{1}=[];
%         hold on
%         plot([0 mama],[0 mama],'color',[.5 .5 .5])
%         try
%             th = text(0.8*max(x),0.8*max(y),{['r=',num2str(R)];['p=',num2str(P)]});
%         end
%         if P<=0.05;set(th,'color',[1 0 0]);end
%         xlabel(xname)
%         ylabel(yname)
%         title('Linear')
%         
%     subplot(2,2,2) %semilogx
%         [slope, intercept,MSE, R, SlopeCI, P, S] = logfit_bw(x,y,'logx');
%         coeffs{2} = [slope intercept];
%         r{2} = R;
%         p{2} = P;
%         yfit{2}=[];
%         hold on
%         semilogx([mimi mama],[mimi mama],'color',[.5 .5 .5])
%         try
%             th = text(0.8*max(x),0.8*max(y),{['r=',num2str(R)];['p=',num2str(P)]});
%         end
%         if P<=0.05;set(th,'color',[1 0 0]);end
% %         xl = log10(x);
% %         xl = real(xl);
% %         badx = logical(isnan(xl) + isinf(xl));
% %         xl(badx) = [];
% %         y2 = y;
% %         y2(badx) = [];
% %         plot(xl,y2,'marker','.','Line','none');
% %         [yfit{2},r{2},p{2},coeffs{2}] =  RegressAndFindR(xl,y2,1);
% %         hold on;
% %         plot(xl,yfit{2},'r')
% %         try
% %             th = text(0.8*max(xl),0.8*max(y2),{['r=',num2str(r{2})];['p=',num2str(p{2})]});
% %         end
% %         if p{2}<=0.05;set(th,'color',[1 0 0]);end
%         xlabel(['log10' xname])
%         ylabel(yname)
%         title('Semilog X')
%         
%     subplot(2,2,3) %semilogy
%         [slope, intercept,MSE, R, SlopeCI, P, S] = logfit_bw(x,y,'logy');
%         coeffs{3} = [slope intercept];
%         r{3} = R;
%         p{3} = P;
%         yfit{3}=[];
%         hold on
%         semilogy([mimi mama],[mimi mama],'color',[.5 .5 .5])
%         try
%             th = text(0.8*max(x),0.8*max(y),{['r=',num2str(R)];['p=',num2str(P)]});
%         end
%         if P<=0.05;set(th,'color',[1 0 0]);end
% %         yl = log10(y);
% %         yl = real(yl);
% %         bady =  logical(isnan(yl) + isinf(yl));
% %         x2 = x;
% %         x2(bady) = [];
% %         plot(x,yl,'marker','.','Line','none');
% %         [yfit{3},r{3},p{3},coeffs{3}] =  RegressAndFindR(x,yl,1);
% %         hold on;
% %         plot(x,yfit{3},'r')
% %         try
% %             th = text(0.8*max([x2;0]),0.8*max([yl;0]),{['r=',num2str(r{3})];['p=',num2str(p{3})]});
% %         end
% %         if p{3}<=0.05;set(th,'color',[1 0 0]);end
% %         set(gca,'YTickLabel',10.^get(gca,'YTick'))
%         xlabel(xname)
%         ylabel(['log10' yname])
%         title('Semilog Y')
        
%     subplot(2,2,4) %loglog
        [slope, intercept,MSE, R, SlopeCI, P, S] = logfit_bw(x,y,'logx');
        coeffs = [slope intercept];
        r = R;
        p = P;
        yfit=[];
        hold on
        loglog([mimi mama],[1 1],'color',[.5 .5 .5])
        try
            th = text(0.8*max(x),0.8*max(y),{['r=',num2str(R)];['p=',num2str(P)]});
        end
        if P<=0.05;set(th,'color',color);end
%         xl = log10(x);
%         xl = real(xl);
%         badx = isnan(xl) + isinf(xl);
%         yl = log10(y);
%         yl = real(yl);
%         bady = isnan(yl) + isinf(yl);
%         badbad = logical(badx+bady);
%         xl(badbad) = [];
%         yl(badbad) = [];
%         plot(xl,yl,'marker','.','Line','none');
%         [yfit{4},r{4},p{4},coeffs{4}] =  RegressAndFindR(xl,yl,1);
%         hold on;
%         plot(xl,yfit{4},'r')
%         try
%             th = text(0.8*max([xl;0]),0.8*max([yl;0]),{['r=',num2str(r{4})];['p=',num2str(p{4})]});
%         end
%         if p{4}<=0.05;set(th,'color',[1 0 0]);end
%         set(gca,'XTickLabel',10.^get(gca,'XTick'))
%         set(gca,'YTickLabel',10.^get(gca,'YTick'))
        xlabel(['log10' xname])
        ylabel(['log10' yname])
%         title ('Loglog')
        
else
%     for a = 1:4
%         yfit{a} = [];
%         r{a} = [];
%         p{a} = [];
%         coeffs{a} = [];
%     end
    yfit = [];
    r = [];
    p = [];
    coeffs = [];
    axes
end