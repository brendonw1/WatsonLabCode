function h=SpikingAnalysis_PairsPlotsWMedianLinearAndLog(series1,series2,colormode,col)

series1 = series1(:);
series2 = series2(:);

if ~exist('colormode','var')
    colormode = 'bysextiles';
end
    
switch colormode
    case 'externalsort'  %col must be input, and it is assumed series1 and series2 are sorted as they need from the outset;  
        % col should be an nx3 color vector with n being equal to the
        % number of elements in series1, which is the same as the numel
        % series2
        1;%actually nothing to do
    case 'bysextiles'
        tcol = RainbowColors(6);
        [series1,idx] = sort(series1);
        series2 = series2(idx);
        q_rnk = GetQuartilesByRank(series1,6);
        col = [];
        for a = 1:6;
            t = repmat(tcol(a,:),[sum(q_rnk==a),1]);
            col = cat(1,col,t);
        end
        %sort series
    case 'bychange'
        pvpp = ConditionedProportion(series1,series2);
        [~,idx] = sort(pvpp);
        series1 = series1(idx);
        series2 = series2(idx);
        col = OrangeColors(length(series1));%rank based, not range based colorization
end

% col = col(idx,:);
%% left plot

h = figure;
subplot(1,2,1);
hold on
r = randperm(length(series1));%randomize plot sequence so aren't biased by one end of distro plotting on tops
for a = 1:length(series1);
    t = r(a);
    if exist('q_rnk','var')
        if q_rnk(t) == 1 || q_rnk(t) == 6%plot only first and last sextiles
            plot([series1(t) series2(t)]','Marker','o','color',col(t,:));
        end
    else
        plot([series1(t) series2(t)]','Marker','o','color',col(t,:));
    end
end
xlim([0.5 2.5])
errorbar([0.75 2.25],[median(series1) median(series2)],[std(series1) std(series2)],...
    'Color','k','Marker','.','LineStyle','none')

% title({'Individual RS Cell firing rates in First (Left) vs Last (Right) SWS episodes';...
%     'Mean in black, Errors bars offset to allow visualization'})


%% right plot
subplot(1,2,2);
hold on

series1(series1==0) = min(series1);
series2(series2==0) = min(series2);
% 
% s1 = log(series1);
% s2 = log(series2);


% hh = ploterr([0.75 2.25], [mean(realnoninfonly(log(series1))) mean(realnoninfonly(log(series2)))],...
%     [], [std(realnoninfonly(log(series1))) std(realnoninfonly(log(series2)))], ...
%     'logy')
% series1 = series1;
if sum(series1>0) > 1
    series1(series1==0) = min(series1(series1>0));
end
% series2 = series2;
if sum(series2>0) > 1
    series2(series2==0) = min(series2(series2>0));
end
x = [0.75 2.25];
[~,bady1] = realnoninfposonly(series1);
[~,bady2] = realnoninfposonly(series2);
allbad = logical(bady1+bady2);
globalmin = min([series1(~allbad);series2(~allbad)]);
try 
    series1(allbad) = globalmin;
    series2(allbad) = globalmin;
    for a = 1:length(series1)
        t = r(a);
        if exist('q_rnk','var')
            if q_rnk(t) == 1 || q_rnk(t) == 6%plot only first and last sextiles
                plot([series1(t) series2(t)]','Marker','o','color',col(t,:));
            end
        else
            plot([series1(t) series2(t)]','Marker','o','color',col(t,:));
        end
    end
    xlim([0.5 2.5])
    y = [median(series1) median(series2)];
    er = [geostd(series1) geostd(series2)];
    warning off
        errorbar(x,y,er,'Color','k','Marker','.','LineStyle','none')
    warning on
    plot([x(1) x(1)],[y(1) y(1)+er(1)],'k')
    plot([x(2) x(2)],[y(2) y(2)+er(2)],'k')
end


% semilogy([series1 series2]','Marker','o');
set(gca,'YScale','Log')
1;