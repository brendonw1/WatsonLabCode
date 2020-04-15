function PCAandCorrelationAnalysis(filename)
%ie csv files
% - Assumes that data are numbers only.  Accepts only cells that have no
% letter values
% - Assumes columns represent measure types and rows represent individual
% animals/cities etc.
% - Eliminates columns that have no numbers-only entries
% - 

%% Read data
% b = dlmread(filename);
rawcsv = read_mixed_csv(filename);

%% Set so that all (-1)'s become NaN
% nb = b;
% nb(nb==-1)=NaN;


%% Extract numbers-only cells
numonlybool = logical(size(rawcsv));
for i = 1:size(rawcsv,1)
    for j = 1:size(rawcsv,2);
        numonlybool(i,j) = logical(sum(isletter(rawcsv{i,j})));
    end
end
%toss out rows and columns that are likely labels
nonumcolumns = logical(prod(numonlybool,1));%column 
nonumrows = logical(prod(numonlybool,2));
dm = rawcsv;
dm(nonumrows,:) = [];
dm(:,nonumcolumns) = [];

%convert to normal numeric array from cell array of strings
for i = 1:size(dm,1)
    for j = 1:size(dm,2)
        try
            datamatrix(i,j) = str2num(dm{i,j});
        catch
            datamatrix(i,j) = nan;
        end
    end
end

% x = regexp(b,'\d+(\.)?(\d+)?','match');
% out=str2double([x{:}]);

%% Lots of NaN's, so use a tolerant PCA method based on this:
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/149936

%Generate a correlation coeff 
[corrdata, corrdata_ps] = corrcoef(datamatrix,'rows','pairwise');%get a correlation matrix that can handle NaN
%Run PCA
[coeff,latent,explained] = pcacov(corrdata);%compute PCA using covariance (correlation)

%% Get labels
% [num,txt,raw] = xlsread('RatBehavCorrel_RatsK-P.xls');
% for a = 1:size(rawcsv,2)
%     labels{a}=txt{2,a+2};
% end

labels = rawcsv(1,:);
labels(nonumcolumns) = [];

%% Basic correlation plot
%figure('name','Raw Correlation Rs','position',[243 378 1121 420]);
figure('name','Raw Correlation Rs');
imagesc(corrdata)
colorbar
title('Correlations across all variables (Pearson r values)')
% legend(labels,'location','eastoutside')
saveas(gcf,[get(gcf,'Name'),'.fig'])
saveas(gcf,[get(gcf,'Name'),'.png'])

%% Display explained percentages by each component
figure('name','ExplainedByComponent');
pareto(explained)
title('Explained percentages by PCA component')
saveas(gcf,[get(gcf,'Name'),'.fig'])
saveas(gcf,[get(gcf,'Name'),'.png'])

%% Output text summarizing component-wise and dimensionwise contributions
for a = 1:5%default of first time 
    varianceexplainedtext = ['Component ',num2str(a),' explains ',num2str(explained(a),3),'% of variance'];
    %disp('varianceexplained<.05' txt);
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
    saveas(gcf,[get(gcf,'Name'),'.png'])
    
    disp(char(outputcell))
    disp(' ')
    disp(' ')
        
    texttitle = ['PCAComponent#',num2str(a),'CorrelatesWithMeasures.txt'];
    charcelltotext(outputcell,texttitle)
end

%% search for significant correlations (not bonferoni corrected!!)
[x,y] = find(triu(corrdata_ps)<.05 & triu(corrdata_ps)>0);
for a = 1:length(x);
    xdata = datamatrix(:,x(a));
    ydata = datamatrix(:,y(a));
    xplotlabel = labels{x(a)};
    yplotlabel = labels{y(a)};
    
    %fit polynomial
    nans = any([isnan(xdata),isnan(ydata)],2);
    xforfit = xdata(~nans);
    yforfit = ydata(~nans);
    
    poly = polyfit(xforfit,yforfit,1);
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

    
    yfit = polyval(poly,xforplotting);
    hold on;
    plot(xforplotting,yfit,'--r','LineWidth',3)

    xlim(spanx);
    ylim(spany)
    
    xlabel(xplotlabel)
    ylabel(yplotlabel)
    
    title([yplotlabel,' vs ',xplotlabel,'. p = ',num2str(corrdata_ps(x(a),y(a)),3)]);
    set(h,'Name',[yplotlabel,' vs ',xplotlabel,'. p = ',num2str(corrdata_ps(x(a),y(a)),3)]);
    saveas(h,[yplotlabel,' vs ',xplotlabel,'.fig'])
    saveas(h,[yplotlabel,' vs ',xplotlabel,'.png'])
    
    signifcorrelates{a} = [yplotlabel,' vs ',xplotlabel,'. p = ',num2str(corrdata_ps(x(a),y(a)),3)];
end
texttitle = ['SignificantCorrelationPairs.txt'];
charcelltotext(signifcorrelates,texttitle)

save('PCA&CorrelationData.mat','datamatrix','labels','corrdata','corrdata_ps','coeff','latent','explained')
