function h = PlotEIChangeVsOtherSameAxis(otherE,changeE,otherI,changeI)

otherE = otherE(:);
changeE = changeE(:);
otherI = otherI(:);
changeI = changeI(:);

n1 = 'Pre';
n2 = 'Change';

h = figure;

[Eslope, Eintercept, EMS, Er, ESlopeCI, Ep, ES] = logfit_bw(otherE,changeE,'loglog','markercolor',[.75 1 .75],'linecolor',[.1 .9 .1],'markersize',7);
hold on;
[Islope, Iintercept, IMS, Ir, ISlopeCI, Ip, IS] = logfit_bw(otherI,changeI,'loglog','markercolor',[1 .75 .75],'linecolor',[.9 .1 .1],'markersize',7);


if ~isempty(otherE) & ~isempty(Eslope)
    try
        mama = max([otherE(:);changeE(:);otherI(:);changeI(:)]);
        mimi = min([otherE(otherE>0);changeE(changeE>0);otherI(otherI>0);changeI(changeI>0)]);
        xlim([mimi mama])
        ylim([mimi mama])
        loglog([mimi mama],[1 1],'color',[.5 .5 .5])
        if ~isempty(ESlopeCI)
            text(0.00002*mama,0.5*mama,{['R = ' num2str(Er)];...
                ['p = ' num2str(Ep)];...
                ['Slope = ' num2str(Eslope) ' (' num2str(ESlopeCI(1,1)), '-' num2str(ESlopeCI(2,1)) ')']},...
                'color',[.1 .9 .1])
        else
            text(0.00002*mama,0.5*mama,{['R = ' num2str(Er)];...
                ['p = ' num2str(Ep)];...
                ['Slope = ' num2str(Eslope)]},...
                'color',[.1 .9 .1])
        end    
        if ~isempty(ISlopeCI)
            text(0.02*mama,0.5*mama,{['R = ' num2str(Ir)];...
                ['p = ' num2str(Ip)];...
                ['Slope = ' num2str(Islope) ' (' num2str(ISlopeCI(1,1)), '-' num2str(ISlopeCI(2,1)) ')']},...
                'color',[1 0 0])
        else
            text(0.02*mama,0.5*mama,{['R = ' num2str(Ir)];...
                ['p = ' num2str(Ip)];...
                ['Slope = ' num2str(Islope)]},...
                'color',[1 0 0])
        end    
    end
end


xlabel(n1)
ylabel(n2)
