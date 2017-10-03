function plot_boxAbyquartilesofB(A,B)

q_rnk = GetQuartilesByRank(B);

v1 = log10(A(q_rnk==1));
v2 = log10(A(q_rnk==2));
v3 = log10(A(q_rnk==3));
v4 = log10(A(q_rnk==4));
vect = cat(1,v1,v2,v3,v4);
groups = cat(1,ones(length(v1),1),2*ones(length(v2),1),3*ones(length(v3),1),4*ones(length(v4),1));
plot([0.5 4.5],[0 0],'k')
hold on
boxplot(vect,groups,'whisker',0,'boxstyle','filled');
delete(findobj('tag','Outliers'))
axis tight;  
yl = ylim;
ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)]);
ylabel(gca,'Post/Pre (proportion)')
xlabel(gca,'Quartile (by RANK)')
