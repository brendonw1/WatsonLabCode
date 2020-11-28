function PlotRateAndStates
basepath = cd;
[~,basename,~] = fileparts(cd);
load(fullfile(basepath,[basename,'_SStable.mat']));
load(fullfile(basepath,[basename,'-states.mat']));
load(fullfile(basepath,[basename,'TimeSeparations.mat']));
for i = 1:length(S)
    clf;
    plot(MakeQfromS(S(i),20));
    hold on
    for j = 1:6
        x = [Time(j) Time(j)];
        y = ylim;
        plot(x,y,'r','LineWidth',1.2);
    end
    plotIntervalsStrip(gca,states);
    axis tight
    cellname = strcat('Shank',num2str(shank(i)),'_Cell',num2str(cellIx(i)));
    title(cellname,'Interpreter','none');
    savefig(fullfile(basepath,'/PlaceField',cellname,[cellname '_Rate-States']));
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    print(gcf,fullfile(basepath,'PlaceField/OutputFig/Rate-States',[cellname '_Rate-States']),'-dpng','-r0');
end

