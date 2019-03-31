
%% Read data
b = dlmread('Rat Behavioral Correlates - UsedInFA _ONLYNUMBERS.csv');

%% Set so that all (-1)'s become NaN
nb = b;
nb(nb==-1)=NaN;

%% Lots of NaN's, so use a tolerant PCA method based on this:
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/149936

%Generate a correlation coeff 
[corrnb, p] = corrcoef(nb,'rows','pairwise');%get a correlation matrix that can handle NaN
%Run PCA
[coeff,latent,explained] = pcacov(corrnb);%compute PCA using covariance (correlation)

%% Get labels
[num,txt,raw] = xlsread('RatBehavCorrel_RatsK-P.xls');
for a = 1:size(b,2)
    labels{a}=txt{2,a+2};
end

%% Display explained percentages by each component
figure;pareto(explained)
title('Explained percentages by PCA component')

%% Output text summarizing componentwise and dimensionwise contributions
for a = 1:5;%default of first time 
    varianceexplainedtext = ['Component ',num2str(a),' explains ',num2str(explained(a),3),'% of variance'];
    disp(varianceexplained<.05 text)
    outputcell{1} = varianceexplainedtext;
    [sorted,idxs] = sort(abs(coeff(:,a)),'descend');%sort which orignal dimensions contribute most to PCA component1

    figure;
    bar(coeff(idxs,a));
    ylim([-1 1])
%     textydim = max(coeff(:,a))+.05;
    
    for c = 1:length(idxs);
        outputcell{c+1} = ['Coeff of ',labels{idxs(c)},': ',num2str(coeff(idxs(c),a))];
        textydim = abs(coeff(idxs(c),a))+0.05;
        text(c,textydim,labels{idxs(c)},'rotation',90)
    end
    titletext = ['Component ',num2str(a),' explains ',num2str(explained(a),3),'% of variance. Coefficients of each observation variable:'];
    title(titletext);
    set(gcf,'Name',['Component',num2str(a),'Coeffs'])
    saveas(gcf,[get(gcf,'Name'),'.fig'])
    
    disp(char(outputcell))
    disp(' ')
    disp(' ')
        
    texttitle = ['PCAComponent#',num2str(a),'CorrelatesWithMeasures.txt'];
    charcelltotext(outputcell,texttitle)
end

%% search for significant correlations (not bonferoni corrected!!)
[x,y] = find(triu(p)<.05 & triu(p)>0)
for a = 1:length(x);
    xdata = nb(:,x(a));
    ydata = nb(:,y(a));
    xplotlabel = labels{x(a)};
    yplotlabel = labels{y(a)};
    
    %fit polynomial
    poly = polyfit(xdata,ydata,1);
    maxx = max(xdata);
    minx = min(xdata);
    rangex = maxx - minx;
    spanx = [minx-rangex*.1 maxx+rangex*.1];

    maxy = max(ydata);
    miny = min(ydata);
    rangey = maxy - miny;
    spany = [miny-rangey*.1 maxy+rangey*.1];
    
    xforplotting = spanx(1):rangex/100:spanx(2);
    
    h = figure;plot(xdata,ydata,'.','MarkerSize',20)

    f = polyval(poly,xforplotting);
    hold on;
    plot(xforplotting,f,'--r','LineWidth',3)

    xlim(spanx);
    ylim(spany)
    
    xlabel(xplotlabel)
    ylabel(yplotlabel)
    
    title([yplotlabel,' vs ',xplotlabel,'. p = ',num2str(p(x(a),y(a)),3)]);
    set(h,'Name',[yplotlabel,' vs ',xplotlabel,'. p = ',num2str(p(x(a),y(a)),3)]);
    saveas(h,[yplotlabel,' vs ',xplotlabel,'.fig'])
    
    signifcorrelates{a} = [yplotlabel,' vs ',xplotlabel,'. p = ',num2str(p(x(a),y(a)),3)];
end
texttitle = ['SignificantCorrelationPairs.txt'];
charcelltotext(signifcorrelates,texttitle)

save('PCAIn&Out.mat','b','nb','corrnb','p','coeff','latent','explained')
