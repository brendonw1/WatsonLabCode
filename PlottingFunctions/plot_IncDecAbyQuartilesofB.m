function plot_IncDecAbyQuartilesofB(A,B)

q_rnk = GetQuartilesByRank(B);
RnkIDPlotVect=[];
lbls = {};
for a = 1:4
    q_rnk_increasers{a} = find(A(q_rnk==a)>1);
    q_rnk_decreasers{a} = find(A(q_rnk==a)<1);
    q_rnk_NC{a} = find(A(q_rnk==a)==1);
    RnkIDPlotVect=cat(2,RnkIDPlotVect,[length(q_rnk_increasers{a}) length(q_rnk_NC{a}) length(q_rnk_decreasers{a}) 0 0 ]);
    
    lbls = cat(1,lbls,{'Inc'},{'NC'},{'Dec'},{'__'},{''});
end

bar(RnkIDPlotVect);
set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
xticklabel_rotate
ylabel(gca,'# Increasers or Decreaers')
xlabel(gca,'Quartile (by RANK)')

