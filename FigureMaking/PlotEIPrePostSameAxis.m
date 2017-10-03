function h = PlotEIPrePostSameAxis(preE,postE,preI,postI)
preE = preE(:);
postE = postE(:);
preI = preI(:);
postI = postI(:);

n1 = 'Early';
n2 = 'Late';

h = figure;

[Eslope, Eintercept, EMS, Er, ESlopeCI, Ep, ES] = logfit_bw(preE,postE,'loglog','markercolor',[0 1 0],'linecolor',[0 1 0]);
hold on;
[Islope, Iintercept, IMS, Ir, ISlopeCI, Ip, IS] = logfit_bw(preI,postI,'loglog','markercolor',[1 0 0],'linecolor',[1 0 0]);


if ~isempty(preE) & ~isempty(Eslope)
    try
        mama = max([preE(:);postE(:);preI(:);postI(:)]);
        mimi = min([preE(preE>0);postE(postE>0);preI(preI>0);postI(postI>0)]);
        xlim([mimi mama])
        ylim([mimi mama])
        loglog([mimi mama],[mimi mama],'color',[.5 .5 .5])
        if ~isempty(ESlopeCI)
            text(0.01*mama,0.5*mama,{['R = ' num2str(Er)];...
                ['p = ' num2str(Ep)];...
                ['Slope = ' num2str(Eslope) ' (' num2str(ESlopeCI(1,1)), '-' num2str(ESlopeCI(2,1)) ')']},...
                'color',[0 1 0])
        else
            text(0.01*mama,0.5*mama,{['R = ' num2str(Er)];...
                ['p = ' num2str(Ep)];...
                ['Slope = ' num2str(Eslope)]},...
                'color',[0 1 0])
        end    
        if ~isempty(ISlopeCI)
            text(0.01*mama,0.1*mama,{['R = ' num2str(Ir)];...
                ['p = ' num2str(Ip)];...
                ['Slope = ' num2str(Islope) ' (' num2str(ISlopeCI(1,1)), '-' num2str(ISlopeCI(2,1)) ')']},...
                'color',[1 0 0])
        else
            text(0.01*mama,0.1*mama,{['R = ' num2str(Ir)];...
                ['p = ' num2str(Ip)];...
                ['Slope = ' num2str(Islope)]},...
                'color',[1 0 0])
        end    
    end
end


xlabel(n1)
ylabel(n2)
