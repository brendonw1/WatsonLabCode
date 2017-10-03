function PlotGammaAndIERatio (basename,spectrogramnum)

% t = load([basename,'_BasicMetaData.mat']);
% % basename = t.basename;
% KetamineTimeStamp =  t.KetamineTimeStamp;

t =  load([basename,'_SStable.mat']);
S = t.S;

t =  load([basename,'_CellIDs.mat']);
CellIDs = t.CellIDs;

t =  load([basename,'_Intervals.mat']);
intervals = t.intervals;


IERatioSecondsPerBin = 1;
[IERatio,ECount,ICount] = CalcIERatio(S,CellIDs,IERatioSecondsPerBin);

gammapower = KetamineSpectrographicAnalysis_PlotGammaPowerByBinnedTime(basename,spectrogramnum);



%Check for length diffs... ideally would use convolution-based lag setting
lg = length(gammapower);
li = length(IERatio);
if lg ~= li
    ml = min([lg,li]);
    ier = IERatio(1:ml);
    gp = gammapower(1:ml);
end

smoothseconds = 100;
thisfilt = ones(1,smoothseconds)/smoothseconds;
iers = conv(ier,thisfilt);
gps = conv(gp,thisfilt);
es = conv(ECount,thisfilt);
is = conv(ICount,thisfilt);

figure;
ah = axes; hold on;
plot(iers,'k','LineWidth',2)
plot(gps/1000,'b','LineWidth',2)
plot(es/200,'g');
plot(is/200,'r');
plotIntervalsStrip(ah,intervals,1/10000);
yl = get(ah,'ylim')
% plot([KetamineTimeStamp KetamineTimeStamp],[yl(1) yl(2)],'k')
