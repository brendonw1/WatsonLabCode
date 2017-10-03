function SubdivideICells

Ipt = [];
Iwd = [];
Iwvs = [];
[names,dirs] = GetDefaultDataset;

warning off

[ISpFast,ISpSlow] = ICellsBySpindleRate(1);%find I cells faster/slower than 1Hz during spindles
StateRates = SpikingAnalysis_GatherAllStateRates;
ISpindle = StateRates.ISpindleRates;


%% Gather info
for a = 1:length(dirs);
    basepath = dirs{a};
    basename = names{a};
%     cd(basepath)
    
    %waveforms
    wv = load(fullfile(basepath,[basename,'_MeanWaveforms.mat']));
    
    %waveform metrics
    c = load(fullfile(basepath,[basename, '_CellClassificationOutput.mat']));
    pt = c.CellClassificationOutput.CellClassOutput(:,2);    
    wd = c.CellClassificationOutput.CellClassOutput(:,3);
    
    c = load(fullfile(basepath,[basename, '_CellIDs']));
    i = c.CellIDs.IAll;
    e = c.CellIDs.EAll;
 
    Ipt = cat(1,Ipt,pt(i));
    Iwd = cat(1,Iwd,wd(i));
    Iwvs = cat(2,Iwvs,wv.MeanWaveforms.MaxWaves(:,i));
    
    ni(a) = length(i);
    ne(a) = length(e);
end

%% Normalize waves
[im,imi]= min(Iwvs,[],1);

iw = [];
for a = 1:length(imi)
    if imi(a)>16.5
        iw(:,a) = Iwvs(2:32,a);
    elseif imi(a)<16.5
        iw(:,a) = Iwvs(1:31,a);
    end
end
Iwvs = iw./repmat(-im,31,1);

meanpost = mean(Iwvs(20:25,:));
val23 = Iwvs(23,:);



%% Basic visualization
figure;plot3(ISpindle,Ipt,Iwd,'.')
xlabel('ISpindle(Hz)')
ylabel('IPeak-Trough')
zlabel('IWidth')

%% Try a new one
figure;plot3(ISpindle,Ipt,meanpost,'.')
xlabel('ISpindle(Hz)')
ylabel('IPeak-Trough')
zlabel('Meanpost')

%% Try another
figure;plot3(ISpindle,Ipt,val23,'.')
xlabel('ISpindle(Hz)')
ylabel('IPeak-Trough')
zlabel('Val23')

%% Try another
figure;plot3(val23,Ipt,Iwd,'.')
xlabel('Val23')
ylabel('IPeak-Trough')
zlabel('IWidth')

%% Separate by 
IspFwvs = Iwvs(:,ISpFast);
IspSwvs = Iwvs(:,ISpSlow);


%% get cells of interest
badcells = [3,20,115];
s = SpikingAnalysis_GatherAllStateRates;
badcellsessions = s.SessNumPerICell(badcells);
badcellsessionsIStableID = s.SessCellNumPerICell(badcells);
for a = 1:length(badcells)
    basepath = dirs{badcellsessions(a)};
    basename = names{badcellsessions(a)};

    load(fullfile(basepath,[basename,'_CellIDs.mat']));
    badcellsessionsOverallStableID(a,1) = CellIDs.IAll(badcellsessionsIStableID(a));
    
    ss = load(fullfile(basepath,[basename,'_SStable.mat']));
    badcellshanks(a,1) = ss.shank(badcellsessionsOverallStableID(a));
    badcellshanksCellNum(a,1) = ss.cellIx(badcellsessionsOverallStableID(a));
end
disp(['bad I cells'])
disp(['sessnum shanknum shankcellnum'])
disp([badcellsessions badcellshanks badcellshanksCellNum])

%% get E cells of interest
badcells = [121];
s = SpikingAnalysis_GatherAllStateRates;
badcellsessions = s.SessNumPerECell(badcells);
badcellsessionsEStableID = s.SessCellNumPerECell(badcells);
for a = 1:length(badcells)
    basepath = dirs{badcellsessions(a)};
    basename = names{badcellsessions(a)};

    load(fullfile(basepath,[basename,'_CellIDs.mat']));
    badcellsessionsOverallStableID(a,1) = CellIDs.EAll(badcellsessionsEStableID(a));
    
    ss = load(fullfile(basepath,[basename,'_SStable.mat']));
    badcellshanks(a,1) = ss.shank(badcellsessionsOverallStableID(a));
    badcellshanksCellNum(a,1) = ss.cellIx(badcellsessionsOverallStableID(a));
end
disp(['bad E cells'])
disp(['sessnum shanknum shankcellnum'])
disp([badcellsessions badcellshanks badcellshanksCellNum])

