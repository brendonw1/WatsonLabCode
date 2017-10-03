function PlotDivisionwiseChanges(measurement,divs,rankbasis)
% ie prepostproportion as measurement, divs is either a number of divisions
% to make on rankbasis, or divs is a vector of which division each element
% goes into.
% Brendon Watson 2015

if ~exist('divs','var')
    numdivs = 6;
elseif exist('rankbasis','var')
    if numel(divs) == numel(rankbasis)%if divs is a vector of which element goes in which quartile
        qrng = divs;
        qrnk = divs;
    else % if divs exists and is not as long as rankbasis
        numdivs = max(divs);
    end
end

if exist('numdivs','var')
    q_rng = GetQuartilesByRange(rankbasis,numdivs);
    q_rnk = GetQuartilesByRank(rankbasis,numdivs);
end


RngIDPlotVect=[];
RnkIDPlotVect=[];
lbls = {};
for a = 1:numdivs
    q_rng_increasers{a} = find(measurement(q_rng==a)>0);
    q_rng_decreasers{a} = find(measurement(q_rng==a)<0);
    q_rng_NC{a} = find(measurement(q_rng==a)==1);
    RngIDPlotVect=cat(2,RngIDPlotVect,[length(q_rng_decreasers{a}) length(q_rng_NC{a}) length(q_rng_increasers{a}) 0 0 ]);

    q_rnk_increasers{a} = find(measurement(q_rnk==a)>0);
    q_rnk_decreasers{a} = find(measurement(q_rnk==a)<0);
    q_rnk_NC{a} = find(measurement(q_rnk==a)==1);
    RnkIDPlotVect=cat(2,RnkIDPlotVect,[length(q_rnk_decreasers{a}) length(q_rnk_NC{a}) length(q_rnk_increasers{a}) 0 0 ]);
    
    q_rng_IncreasersDecrasersRatio(a) = length(q_rng_increasers{a})/length(q_rng_decreasers{a});
    q_rnk_IncreasersDecrasersRatio(a) = length(q_rnk_increasers{a})/length(q_rnk_decreasers{a});
    
    lbls = cat(1,lbls,{'Dec'},{'NC'},{'Inc'},{'__'},{''});
end

pause(1)

% h(end+1) = figure('name',[VsString '_PctChgsVsInitialQuartiles'],'Position',[0 2 400 800]);
subplot(3,2,1)
%     hax = plot_nanmedianSD_bars(measurement(q_rnk==1),measurement(q_rnk==2),measurement(q_rnk==3),measurement(q_rnk==4));
    vect = [];
    groups = [];
    for a = 1:numdivs
        v{a} = measurement(q_rng==a);
        vect = cat(1,vect,v{a});
        groups = cat(1,groups,a*ones(length(v{a}),1));
        
try
        %stats per group
%         if median(v{a})>0
            [p_rng(a,1),~,stats_rng{a,1}] = signrank(v{a},0,'tail','right');
%         elseif median(v{a})<0
            [p_rng(a,2),~,stats_rng{a,2}] = signrank(v{a},0,'tail','left');
%         elseif median(v{a}) == 0
%             [p(a),~,stats(a)] = signrank(v{a},0,'tail','both');
%         end
end

    end
    plot([0.5 numdivs+.5],[0 0],'k')
    hold on
    boxplot(vect,groups);
    delete(findobj('tag','Outliers'))
    axis tight;  
    for a = 1:numdivs
        if min(p_rng(a,:))<0.05
            plot(a,median(v{a}),'m*')
        end
    end
    yl = ylim;
    ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)])
    hax = gca;
    ylabel(hax,'log10(Post/Pre)')
    xlabel(hax,'PercentileDivision (by RANGE)')
%     title(hax,'Median Post v Pre proportion per RANK quartile','fontweight','normal'))
    siaxh = AxesInsetImage_In(gca,.6,1,.8,1,p_rng');
subplot(3,2,2)
%     hax = plot_nanmedianSD_bars(measurement(q_rnk==1),measurement(q_rnk==2),measurement(q_rnk==3),measurement(q_rnk==4));
    vect = [];
    groups = [];
    for a = 1:numdivs
        v{a} = measurement(q_rnk==a);
        vect = cat(1,vect,v{a});
        groups = cat(1,groups,a*ones(length(v{a}),1));
        
        %stats per group
%         if median(v{a})>0
            [p_rnk(a,1),~,stats_rnk{a,1}] = signrank(v{a},0,'tail','right');
%         elseif median(v{a})<0
            [p_rnk(a,2),~,stats_rnk{a,2}] = signrank(v{a},0,'tail','left');
%         elseif median(v{a}) == 0
%             [p(a),~,stats(a)] = signrank(v{a},0,'tail','both');
%         end
    end
    plot([0.5 numdivs+.5],[0 0],'k')
    hold on
    boxplot(vect,groups);
    delete(findobj('tag','Outliers'))
    axis tight;  
    for a = 1:numdivs
        if min(p_rnk(a,:))<0.05
            plot(a,median(v{a}),'m*')
        end
    end
    yl = ylim;
    ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)])
    hax = gca;
    ylabel(hax,'log10(Post/Pre)')
    xlabel(hax,'PercentileDivision (by RANK)')
%     title(hax,'Median Post v Pre proportion per RANK quartile','fontweight','normal'))
    siaxh = AxesInsetImage_In(gca,.6,1,.8,1,p_rnk');

subplot(3,2,3)
    bar(RngIDPlotVect);
    set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
    xticklabel_rotate
    ylabel(gca,'# Increasers or Decreaers')
    xlabel(gca,'PercentileDivision (by RANGE)')
subplot(3,2,4)
    bar(RnkIDPlotVect);
    set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
    xticklabel_rotate
    ylabel(gca,'# Increasers or Decreaers')
    xlabel(gca,'PercentileDivision (by RANK)')
subplot(3,2,5)
    bar(log10(q_rng_IncreasersDecrasersRatio))
    axis tight
    xlabel(gca,'PercentileDivision (by RANGE)')
    ylabel(gca,'Log10 of Increaser:Decreaser Ratio')
subplot(3,2,6)
    bar(log10(q_rnk_IncreasersDecrasersRatio))
    axis tight
    xlabel(gca,'PercentileDivision (by RANK)')
    ylabel(gca,'Log10 of Increaser:Decreaser Ratio')
    
1;
    
    
function axh = AxesInsetImage_In(h,xstart,xstop,ystart,ystop,mtxdata)
% function axh = AxesInsetImage(h,ratio,mxtdata)
% Puts an inset image (axes) into the upper right of the given axes.  
%  INPUTS
%  h = handle of reference axes
%  ratio = Size of inset relative to original plot
%  mtxdata = data to plot, 2d matrix or colormatrix that will plot with
%  imagesc
% 
%  OUTPUTS
%  axh = handle of inset axes

figpos = get(h,'Position');

newpos = [figpos(1)+xstart*figpos(3) figpos(2)+ystart*figpos(4) (xstop-xstart)*figpos(3) (ystop-ystart)*figpos(4)];
% if length(ratio) == 1;
%     newpos = [figpos(1)+(1-ratio)*figpos(3) figpos(2)+(1-ratio)*figpos(4) ratio*figpos(3) ratio*figpos(4)];
% elseif length(ratio) == 2;
%     newpos = [figpos(1)+(1-ratio(1))*figpos(3) figpos(2)+(1-ratio(1))*figpos(4) ratio(2)*figpos(3) ratio(2)*figpos(4)];
% end

axh = axes('Position',newpos,'xtick',[]);

imagesc(mtxdata,[0 1]);