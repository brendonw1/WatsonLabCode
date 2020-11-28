function Explore3DCellClassification

warning off
% Get traditional measures
CompleteCellIDs = SleepDataset_GetCellClassIDs;

StateRates = SpikingAnalysis_GatherAllStateRates;
% R = log10(StateRates.AllWSWakeRates);
R = (StateRates.AllWSWakeRates);

% Get BurstShoulderMetric
% [names,dirs] = GetDefaultDataset;
% BSM = [];
% for a = 1:length(dirs);
%     p = load(fullfile(dirs{a},[names{a} '_BurstShoulder.mat']));
%     BSM = cat(1,BSM,p.BSM(:));
% end
% BSM(isnan(BSM)) = 1;%assume 0/0
% BSM(BSM==Inf) = max(BSM(~isinf(BSM)));%assume x/0
% BSM(BSM==-Inf) = min(BSM(~isinf(BSM)));%assume x/0

CompleteCellIDs = cat(2,CompleteCellIDs,R);

edcells = CompleteCellIDs(:,2)==2;
elcells = CompleteCellIDs(:,2)==1;
idcells = CompleteCellIDs(:,2)==-2;
ilcells = CompleteCellIDs(:,2)==-1;

colored = repmat([0 .7 0],sum(edcells),1);
colorel = repmat([0 1 0],sum(elcells),1);
colorid = repmat([1 0 .7],sum(idcells),1);
coloril = repmat([.5 0 .7],sum(ilcells),1);
% 
% h = figure('position',[100 100 600 600],'name','AllCellWaveformProperties');
% scatter3sph(CompleteCellIDs(elcells,3),CompleteCellIDs(elcells,4),log10(CompleteCellIDs(elcells,5)),'color',colorel,'size',0.01);
% hold on
% scatter3sph(CompleteCellIDs(ilcells,3),CompleteCellIDs(ilcells,4),log10(CompleteCellIDs(ilcells,5)),'color',coloril,'size',0.01);
% scatter3sph(CompleteCellIDs(edcells,3),CompleteCellIDs(edcells,4),log10(CompleteCellIDs(edcells,5)),'color',colored,'size',0.01);
% scatter3sph(CompleteCellIDs(idcells,3),CompleteCellIDs(idcells,4),log10(CompleteCellIDs(idcells,5)),'color',colorid,'size',0.01);
% xlabel('PeakTrough')
% ylabel('TotalWidth')
% zlabel('Burst:Shoulder Ratio')
% camlight
% grid on
% view(45,15)
sz = 20;
fnamestr = 'AllCellPropertiesWRate3D';
h = figure('position',[100 100 600 600],'name',fnamestr);
scatter3(CompleteCellIDs(elcells,3),CompleteCellIDs(elcells,4),CompleteCellIDs(elcells,5),sz,colorel(1,:),'MarkerFaceColor',colorel(1,:));
hold on
scatter3(CompleteCellIDs(ilcells,3),CompleteCellIDs(ilcells,4),CompleteCellIDs(ilcells,5),sz,coloril(1,:),'MarkerFaceColor',coloril(1,:));
scatter3(CompleteCellIDs(edcells,3),CompleteCellIDs(edcells,4),CompleteCellIDs(edcells,5),sz,colored(1,:),'MarkerFaceColor',colored(1,:));
scatter3(CompleteCellIDs(idcells,3),CompleteCellIDs(idcells,4),CompleteCellIDs(idcells,5),sz,colorid(1,:),'MarkerFaceColor',colorid(1,:));
xlabel('PeakTrough')
ylabel('TotalWidth')
zlabel('FiringRate')
camlight
grid on

tp = [0 0.8];
wi = [2.4 0.4];
bs = [0 35];

x = [tp(1) tp(2) tp(2) tp(1)];
y = [wi(1) wi(2) wi(2) wi(1)];
z = [bs(1) bs(1) bs(2) bs(2)];

fill3(x,y,z,[.3 .3 .3])

view(40,15)
set(h,'name',[fnamestr,'_ICellView'])
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/CellClassification',h,'fig')

view(58,10)
set(h,'name',[fnamestr,'_ECellView'])
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/CellClassification',h,'fig')

1;


1;
% SINGLE RECORDING VERSION:
% if ~exist('basepath','var')
%     [~,basename,~] = fileparts(cd);
%     basepath = cd;
% end
% 
% load(fullfile(basepath,[basename '_CellClassificationOutput.mat']))
% v2struct(CellClassificationOutput)
% 
% cellnums = CellClassOutput(:,1);
% x = CellClassOutput(:,2);%trough to peak time in ms
% y = CellClassOutput(:,3);%full trough time in ms
% 
% load(fullfile(basepath,[basename '_ACGCCGsAll.mat']))
% acgs = ACGCCGsAll.ACGs{2};%30ms
% times = ACGCCGsAll.Times{2};
% bursttimes = times>=8 & times<=12;
% shouldertimes = times>25 & times<30;
% z = mean(acgs(bursttimes,:))./mean(acgs(shouldertimes,:));
% 
% % figure;scatter3(x,y,z,'.')
% % xlabel('PeakTrough')
% % ylabel('TotalWidth')
% % zlabel('Burst:Shoulder Ratio')
% 
% figure;scatter3sph(x,y,z)
% xlabel('PeakTrough')
% ylabel('TotalWidth')
% zlabel('Burst:Shoulder Ratio')
% camlight
% grid on
% % 
% % plot(x, y,'k.');
% % hold on
% xx = [0 0.8];
% yy = [2.4 0.4];
% m = diff( yy ) / diff( xx );
% b = yy( 1 ) - m * xx( 1 );  % y = ax+b
% xb = get(gca,'XLim');
% yb = get(gca,'YLim');
% plot(xb,[m*xb(1)+b m*xb(2)+b])
% % xlim(xb)
% % ylim(yb)
% % 
% % plot(PyrBoundary(:,1),PyrBoundary(:,2),'k')
% % 
% % plot(x(cellnum),y(cellnum),'m*');
% 
% 1;
% 
% 
% % plot3
