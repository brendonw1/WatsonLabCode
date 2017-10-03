function CellInstabilityGUI(basepath,basename,datasetformat,varargin)
% Right panel with dropdown to select cluster number
% top with shank instability
% middle with plot of total energy vs time for each spike
% with overlay of predicted instab of shank
%
% Default cell instability is based on coincidence between shank
% instability and instability of that particular cell.  
% Default shank instability is based on coincident periods of instability
% of the cells in that shank.
%
% Commands in Cell area:
% Click and Drag to estabilsh a new epoch of instability for that cell
% Rightclick a cell instability - it deletes
%
% Brendon Watson 2015

%% Hard defaults and inputs
binsecs = 30;%bin width
cutoffthresh = 0.33;%proportion of normal (median) rate each cell rate must be below
mindeviationprop = 0.01;%must be unstable at least this proportion of the total recording length
mindeviationtime = 300;%seconds it must be away from that rate
for a  = 1:length(varargin)
   switch a
       case 'binsecs'
           binsecs = varargin{a+1};
       case 'cutoffthresh'
           cutoffthresh = varargin{a+1};
       case 'mindeviationprop'
           mindeviationprop = varargin{a+1};
       case 'mindeviationtime'
           mindeviationtime = varargin{a+1};
   end           
end


%% Input handling/defaults
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
if ~exist('datasetformat','var')
    datasetformat = 'bw';
end

%% Load basics
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;
shank = t.shank;
cellIx = t.cellIx;
allusedshanks = unique(shank);
par = LoadPar(fullfile(basepath,[basename '.xml']));
            
%% Generate and store basic data for plotting.
%Generate and store binned spike counts for all cells
binwidth = 10;%for rate calcs sec;
tssampfreq = 1;%hz;
binsamps = binwidth*tssampfreq;
binnedSpikeCounts = Data(MakeQfromS(S,binsamps));%*
bintimes = ((1:size(binnedSpikeCounts,1))*binwidth)-binwidth/2;
numcells = length(S);%*
% totalfilesecs = GetFileSecsFromDir(basename);

%Generate and store cell spike times and spike energies
disp('Starting to gather cell spike times and energies')
if exist([basename '_CellSpikeTimesEnergiesMahals.mat'],'file') %if already did this, then load stored version
    load([basename '_CellSpikeTimesEnergiesMahals.mat']);
else% generate measures if necessary
    switch datasetformat
        case 'general'
%         below is more generalized code, but slow

% to make this actually generally I have to move spike time gathering in...
% actually it's already below (ttimes);
            loadedshanks = [];
            lastshank = 0;
            for tcnum = 1:length(shank); %store spike data for each cell
                tshank = shank(tcnum);
                tcidx = cellIx(tcnum);
                if tshank ~= lastshank %load fet data once for each shank
                    disp(['Starting Shank ' num2str(tshank) ' out of ' num2str(allusedshanks(end))])
                    tfet = LoadFet(fullfile(basepath,[basename,'.fet.',num2str(tshank)]));
                    tnfets = length(par.SpkGrps(tshank).Channels)*par.SpkGrps(tshank).nFeatures;
                    tclu = LoadClu(fullfile(basepath,[basename,'.clu.',num2str(tshank)]));
                end
                tspikeidxs = find(tclu == tcidx);        
                thiscellfet = tfet(tspikeidxs,:);
                ttimes = thiscellfet(:,end)/par.SampleRate;%last data in fet is spike time
                numChannelsThisShank = length(par.SpkGrps(tshank).Channels);
                featuresPerChannel = par.SpkGrps(tshank).nFeatures;
                numNonRedundantFeatures = numChannelsThisShank*featuresPerChannel;
                thiscellfet = tfet(tspikeidxs,1:numNonRedundantFeatures);

                tenergies = sum(thiscellfet,2);
                tmahals = mahal(thiscellfet,thiscellfet);
              
                
                celltimes{tcnum} = ttimes;
                cellenergies{tcnum} = tenergies;
                cellmahals{tcnum} = tmahals;
        
                %make binned versions of energies bintimes
                [~,idxs] = histc(ttimes,bintimes);
                for a = 1:length(bintimes);
                    binnedMahals(a,tcnum) = mean(tmahals(idxs==a));
                    binnedEnergies(a,tcnum) = mean(tenergies(idxs==a));
                end
                
                lastshank = tshank;
            end
            
        case 'bw'
            % faster code for BW Data type

            % get mahalanobis distances
            load([basename '_ClusterQualityMeasures.mat']);
            %get original indices of each cell 
            [~,origidxsofnondeleted] = AddDeletedIndices(ClusterQualityMeasures.allbadcells,1:length(S));
            
            for a = 1:length(S)
                celltimes{a} = Range(S{a},'s');
            end
            cellenergies = ClusterQualityMeasures.SpikeEnergiesCell(origidxsofnondeleted);
            cellmahals = ClusterQualityMeasures.SelfMahalDistancesCell(origidxsofnondeleted);
%            do a max deviation from mahal center per spike?
% some singular measure of direction of deviation frmo center... using first pc of fet file variance over time?
                
            binnedEnergies = Data(MakeSummedValQfromS(ClusterQualityMeasures.SpikeEnergies(origidxsofnondeleted),binsamps));
            binnedEnergies = binnedEnergies./binnedSpikeCounts;
            binnedMahals = Data(MakeSummedValQfromS(ClusterQualityMeasures.SelfMahalDistances(origidxsofnondeleted),binsamps));
            binnedMahals = binnedMahals./binnedSpikeCounts;
    end
    
    save([basename '_CellSpikeTimesEnergiesMahals'],'celltimes','cellenergies','cellmahals','binnedEnergies','binnedMahals')
end

% Calculate and store times where each shank tends to be unstable
disp('Starting to gather shank-wise instability times')
if exist([basename '_ShankwiseAutoInstabilities.mat'],'file') %if already did this, then load stored version
    t = load(fullfile(basepath,[basename '_ShankwiseAutoInstabilities.mat']));
    shankinstabilityints = t.shankinstabilityints;
    cellpastthreshbools = t.cellpastthreshbools;
    cellpastthreshints = t.cellpastthreshints;
else% generate measures if necessary
    for a = 1:length(allusedshanks)
        tshank = (allusedshanks(a));
        disp(['Starting Shank ' num2str(a) ' out of ' num2str(length(allusedshanks))])
        [shankinstabilityints{a},cellpastthreshbools{a}] = CellShankInstability(basename,tshank,'binsecs',binsecs,'cutoffthresh',cutoffthresh,'mindeviationprop',mindeviationprop,'mindeviationtime',mindeviationtime);
        cellsthisshank = find(shank==tshank);
        for b = 1:length(cellsthisshank)
            cellpastthreshints{a,b} = booltoint(cellpastthreshbools{a}(b,:));
        end
    end
    save([basename '_ShankwiseAutoInstabilities.mat'],'shankinstabilityints','cellpastthreshbools','cellpastthreshints')
end

% Gather default cell instabilities, based on overlap of that cell with
% shank instability
percentoverlapneeded = 0.5;
loopcellidx = 0;
lastshankidx = 0;
for a = 1:numcells
    thiscellints = [];
    tshank = find(allusedshanks==shank(a));
    
    if lastshankidx == tshank;
        loopcellidx = loopcellidx+1;
    else
        loopcellidx = 1;
    end
    tbool = cellpastthreshbools{tshank}(loopcellidx,:)';
    ttimes = 1:length(tbool);
%     tunstabints = booltoint(tbool);
    tshankinstabints = shankinstabilityints{tshank};
    
    %for each tshankinstabint, if it's at least 50% covered by tbool
    %points, keep it as a default for this cell
    for b = 1:size(tshankinstabints,1);
        tint = tshankinstabints(b,:);
        tshankbool = inttobool(tint,length(tbool))';
        test = sum(tshankbool.*tbool) >= percentoverlapneeded*(diff(tint)+1);
        if test
            thiscellints(end+1,:) = tint;
        end
    end
    
    cellinstabilityints{a} = thiscellints;
end

% Store data for gui
handles.basename = basename;
handles.basepath = basepath;
handles.Data = v2struct(shank,cellIx,allusedshanks, binnedSpikeCounts, bintimes,...
    celltimes, cellenergies,binnedEnergies,binnedMahals,...
    shankinstabilityints,cellpastthreshbools,cellpastthreshints,...
    cellinstabilityints);
handles.Data.originalcellints = cellinstabilityints;
handles.Data.originalshankints = shankinstabilityints;

%% Generate Figure
handles.fig = figure('position',[200 50 950 600],'name',[basename '_InstabilityGUI']);

handles.upperax = axes('Parent',handles.fig,'Position',[.05 .67 .75 .28],...
    'YTickLabel',[],'YTick',[],...
    'XGrid','on','XMinorTick','on','XMinorGrid','on',...
    'NextPlot','ReplaceChildren','ButtonDownFcn',@UpperAxClick);
handles.lowerax = axes('Parent',handles.fig,'Position',[.05 .05 .75 .57],...
    'YTickLabel',[],'YTick',[],...
    'XGrid','on','XMinorTick','on','XMinorGrid','on',...
    'NextPlot','ReplaceChildren','ButtonDownFcn',@LowerAxClick);

% cluster selection menu
handles.uipanelclu = uipanel('Parent',handles.fig,'Title','Cluster #',...
    'FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.83 .90 .15 .09],'hittest','off');
handles.clupopup = uicontrol('Style','popupmenu','parent',handles.uipanelclu,...
    'String',num2str((1:numcells)'),...
    'units','normalized','position',[.1 .25 .8 .5],...
    'Callback',@ChangeClu);
% shank selection menu
handles.uipanelshank = uipanel('Parent',handles.fig,'Title','Shank #',...
    'FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.83 .8 .15 .09],'hittest','off');
handles.shankpopup = uicontrol('Style','popupmenu','parent',handles.uipanelshank,...
    'String',num2str(allusedshanks),...
    'units','normalized','position',[.1 .25 .8 .5],...
    'Callback',@ChangeShank);
% clear all clu instab ints
handles.DeleteCluIntsBtn = uicontrol('Style','pushbutton',...
    'String','Delete Clu','units','normalized','position',[.81 .72 .08 .06],...
    'Callback',@DeleteCluInts);
handles.DeleteShankIntsBtn = uicontrol('Style','pushbutton',...
    'String','Delete Shank','units','normalized','position',[.91 .72 .08 .06],...
    'Callback',@DeleteShankInts);
% import instability intervals to cluster
handles.uipanelclu = uipanel('Parent',handles.fig,'Title','Import Ints to Clus',...
    'FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.83 .33 .15 .37],'hittest','off');
handles.ImportShankToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','ShankToClu','units','normalized','position',[.05 .86 .9 .1],...
    'Callback',@ImportShankToClu);
handles.ImportShankSingleToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','ShankSingleToClu','units','normalized','position',[.05 .72 .9 .1],...
    'Callback',@ImportShankSingleToClu);
handles.ImportShankToAllCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','ShankToAllClu','units','normalized','position',[.05 .58 .9 .1],...
    'Callback',@ImportShankToAllClu);
handles.ImportAllAutoToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','AllOwnAutoToClu','units','normalized','position',[.05 .44 .9 .1],...
    'Callback',@ImportAllOwnAutoToClu);
handles.ImportOneAutoToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','OneOwnAutoToClu','units','normalized','position',[.05 .30 .9 .1],...
    'Callback',@ImportOneOwnAutoToClu);
handles.ImportCluToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','CluToClu','units','normalized','position',[.05 .16 .9 .1],...
    'Callback',@ImportCluToClu);
handles.ImportOrigToCluBtn = uicontrol('Style','pushbutton','parent',handles.uipanelclu,...
    'String','OrigToClu','units','normalized','position',[.05 .02 .9 .1],...
    'Callback',@ImportOrigToClu);
% Transfer to Shank functionality
handles.uipanelshank = uipanel('Parent',handles.fig,'Title','Import Ints to Shanks',...
    'FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.83 .11 .15 .2],'hittest','off');
handles.ImportShankToShankBtn = uicontrol('Style','pushbutton','parent',handles.uipanelshank,...
    'String','ShankToShank','units','normalized','position',[.05 .70 .9 .28],...
    'Callback',@ImportShankToShank);
handles.ImportCluToShankBtn = uicontrol('Style','pushbutton','parent',handles.uipanelshank,...
    'String','CluToShank','units','normalized','position',[.05 .36 .9 .28],...
    'Callback',@ImportCluToShank);
handles.ImportOrigToShankBtn = uicontrol('Style','pushbutton','parent',handles.uipanelshank,...
    'String','OrigToShank','units','normalized','position',[.05 .02 .9 .28],...
    'Callback',@ImportOrigToShank);
% Save output
handles.SaveDataBtn = uicontrol('Style','pushbutton',...
    'String','SaveData','units','normalized','position',[.81 .025 .08 .06],...
    'Callback',@SaveDataBtn);
handles.SaveFigBtn = uicontrol('Style','pushbutton',...
    'String','SaveFig','units','normalized','position',[.91 .025 .08 .06],...
    'Callback',@SaveFigBtn);


handles.spikelines = [];
handles.spikebinlines = [];
handles.mahalbinlines = [];
handles.shankpatches = [];
handles.cellpatches = [];
handles.current.clu = 1;
handles.current.shankidx = 1;
handles.current.shankname = handles.Data.shank(1);

% left click - add 
% right click - remove

guidata(handles.fig,handles)

% Plotting
ChangeClu(handles.fig,[])%plot clu 1 at start


function ChangeClu(obj,~)
%plotting basic data for each clu and the correspoinding shank
handles = guidata(obj);

newclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(newclu);
usedshankix = find(handles.Data.allusedshanks == tshank);
clusthisshank = handles.Data.cellIx(handles.Data.shank==tshank);
thiscluixonthisshank = find(clusthisshank==handles.Data.cellIx(newclu));

%plot upper axes basic data
hold (handles.upperax,'off')
imagesc(~handles.Data.cellpastthreshbools{usedshankix},'parent',handles.upperax,'ButtonDownFcn',@ShankImageClick)
colormap('gray')
hold (handles.upperax,'on')
% line(1,thiscluixonthisshank,'Marker','>','color','r','MarkerSize',10,'parent',handles.upperax,'hittest','off')
xl = xlim(gca);
patch([xl(1) xl(1) xl(2) xl(2)],[thiscluixonthisshank+0.5 thiscluixonthisshank-0.5 thiscluixonthisshank-0.5 thiscluixonthisshank+0.5],...
    'g','edgecolor','g','parent',handles.upperax,'hittest','off','facealpha',0.5)
hold (handles.upperax,'off')
axis tight

% handles.cellpatches = [];
guidata(handles.fig,handles)
PlotShankInstability(obj,[])
handles = guidata(obj);

% plot lower axes
hold (handles.lowerax,'off')
delete(handles.spikelines)
delete(handles.spikebinlines)
delete(handles.mahalbinlines)
handles.spikelines = line(handles.Data.celltimes{newclu},handles.Data.cellenergies{newclu},...
    'marker','.','color','k','linestyle','none','parent',handles.lowerax,...
    'hittest','off');
hold (handles.lowerax,'on')
%binned spike counts at top
scalefact = max(handles.Data.cellenergies{newclu})/max(handles.Data.binnedSpikeCounts(:,newclu))/2;
shiftfact = max(handles.Data.cellenergies{newclu});
handles.spikebinlines = line(handles.Data.bintimes,scalefact*handles.Data.binnedSpikeCounts(:,newclu)+shiftfact,...
    'parent',handles.lowerax,'color',[.4 .4 .4],'hittest','off');
%binned mahal distances at bottom 
scalefact = max(handles.Data.cellenergies{newclu})/max(handles.Data.binnedMahals(:,newclu))/2;
shiftfact = min(handles.Data.cellenergies{newclu})*.2;
handles.mahalbinlines = line(handles.Data.bintimes,scalefact*handles.Data.binnedMahals(:,newclu)+shiftfact,...
    'parent',handles.lowerax,'color','c','hittest','off');
set(handles.lowerax,'xlim',[1 length(handles.Data.cellpastthreshbools{usedshankix})])
hold (handles.lowerax,'off')
axis tight

set(handles.shankpopup,'Value',usedshankix)
guidata(handles.fig,handles)
PlotCellInstability(obj,[])

function ChangeShank(obj,~)
%plotting basic data for each clu and the correspoinding shank
handles = guidata(obj);
tshank = get(handles.shankpopup,'Value');
tshankname = handles.Data.allusedshanks(tshank);
newclu = find(handles.Data.shank==tshankname,1,'first');

set(handles.clupopup,'Value',newclu)
guidata(handles.fig,handles)

ChangeClu(handles.fig,[])%plot clu 1 at start


function PlotShankInstability(obj,~)
handles = guidata(obj);

thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);
uints = handles.Data.shankinstabilityints{tshankidx};
if ishandle(handles.shankpatches)
    delete(handles.shankpatches);
    handles.shankpatches = [];
end
    delete(findobj('Type','patch','facecolor','magenta','parent',handles.upperax))

yl = get(handles.upperax,'ylim');
hold(handles.upperax,'on')
for a = 1:size(uints,1)
    handles.shankpatches(a) = patch([uints(a,1) uints(a,2) uints(a,2) uints(a,1)],[yl(1) yl(1) yl(2) yl(2)],...
        'magenta','edgecolor','magenta','facealpha',0.5,'parent',handles.upperax,...
        'ButtonDownFcn',@ShankPatchClick);
end

hold(handles.upperax,'off')
guidata(handles.fig,handles)



function PlotCellInstability(obj,~)
handles = guidata(obj);

thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);

if thisclu ~= handles.current.clu
    1;
end

uints = handles.Data.cellinstabilityints{thisclu};

if ishandle(handles.cellpatches)
%     delete(handles.cellpatches);
    handles.cellpatches = [];
end
    delete(findobj('Type','patch','facecolor','cyan','parent',handles.lowerax))

yl = get(handles.lowerax,'ylim');
hold(handles.lowerax,'on')
for a = 1:size(uints,1)
    handles.cellpatches(a) = patch([uints(a,1) uints(a,2) uints(a,2) uints(a,1)],[yl(1) yl(1) yl(2) yl(2)],...
        'cyan','edgecolor','cyan','facealpha',0.5,'parent',handles.lowerax,...
        'ButtonDownFcn',@CellPatchClick);
end
hold(handles.lowerax,'off')
    
handles.current.clu = thisclu;
handles.current.shankname = tshank;
handles.current.shankidx = tshankidx;

guidata(handles.fig,handles)


function ShankImageClick(obj,~)
point1 = get(gca,'CurrentPoint');    % button down detected

handles = guidata(obj);
newclu = round(point1(1,2));
clulist = find(handles.current.shankname==handles.Data.shank);
newclu = clulist(newclu);
set(handles.clupopup,'Value',newclu)
guidata(handles.fig,handles)

ChangeClu(handles.fig,[])%plot clu 1 at start




function LowerAxClick(obj,~)
%get user input
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1);
point2 = point2(1,1);

if point1 ~= point2 %if not simple click
    %gather gui data
    handles = guidata(obj);
    thisclu = get(handles.clupopup,'Value');
    % add new interval to old list
    uints = handles.Data.cellinstabilityints{thisclu};
    uints = cat(1,uints,sort([point1 point2]));
    handles.Data.cellinstabilityints{thisclu} = uints;
    guidata(handles.fig,handles);
    
    %re-plot cell intervals
    PlotCellInstability(handles.fig,[])
end

function ShankPatchClick(obj,~)
% handles = guidata(obj);


function CellPatchClick(obj,~)
point1 = get(gca,'CurrentPoint');    % button down detected
handles = guidata(obj);
seltype = get(handles.fig,'SelectionType');
switch seltype
    case 'alt' %if rightclick
        thisclu = get(handles.clupopup,'Value');
        p = point1(1,1);
        % remove clicked interval from interval list
        uints = handles.Data.cellinstabilityints{thisclu};
        [~,iidx,~]=InIntervals(p,uints);
        if iidx > 0
            uints(iidx,:) = [];
            handles.Data.cellinstabilityints{thisclu} = uints;
            guidata(handles.fig,handles);
            %re-plot cell intervals
            PlotCellInstability(handles.fig,[])
        end
end


%% DELETING INTERVALS
function DeleteCluInts(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
handles.Data.cellinstabilityints{thisclu} = [];
guidata(handles.fig,handles)
PlotCellInstability(obj,[])

function DeleteShankInts(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);
handles.Data.shankinstabilityints{tshankidx} = [];
guidata(handles.fig,handles)
PlotShankInstability(handles.fig,[]);

%% CHANGING CLU INTS
function ImportShankToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);
sints = handles.Data.shankinstabilityints{tshankidx};

uints = handles.Data.cellinstabilityints{thisclu};
uints = cat(1,uints,sints);
handles.Data.cellinstabilityints{thisclu} = uints;

guidata(handles.fig,handles);
PlotCellInstability(obj,[])


function ImportShankSingleToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);
sints = handles.Data.shankinstabilityints{tshankidx};

disp('Select purple interval from this shank to move to cell') 
[x,~] = ginput(1);
[~,iidx,inany]=InIntervals(x,sints);
if ~inany
    error('You clicked outside all intervals for this shank')
    return
elseif inany
    sints = sints(iidx,:);
end

uints = handles.Data.cellinstabilityints{thisclu};
uints = cat(1,uints,sints);
handles.Data.cellinstabilityints{thisclu} = uints;

guidata(handles.fig,handles);
PlotCellInstability(obj,[])


function ImportShankToAllClu(obj,~)
handles = guidata(obj);

thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);
sints = handles.Data.shankinstabilityints{tshankidx};

shankclus = find(handles.Data.shank == tshank);
for a = 1:length(shankclus)
    thisclu = shankclus(a);
    uints = handles.Data.cellinstabilityints{thisclu};
    uints = cat(1,uints,sints);
    handles.Data.cellinstabilityints{thisclu} = uints;
end

guidata(handles.fig,handles);
PlotCellInstability(obj,[])


function ImportAllOwnAutoToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);

tshankidx = find(handles.Data.allusedshanks==tshank);
cellsthisshank = find(handles.Data.shank == tshank);
cellshankidx = find(cellsthisshank==thisclu);
aints = handles.Data.cellpastthreshints{tshankidx,cellshankidx};

uints = handles.Data.cellinstabilityints{thisclu};
uints = cat(1,uints,aints);
handles.Data.cellinstabilityints{thisclu} = uints;

guidata(handles.fig,handles);
PlotCellInstability(obj,[])


function ImportOneOwnAutoToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);

tshankidx = find(handles.Data.allusedshanks==tshank);
cellsthisshank = find(handles.Data.shank == tshank);
cellshankidx = find(cellsthisshank==thisclu);

disp('Select black rectangle interval from this cell''s green-highlighted plot in upper axes') 
[x,y] = ginput(1);
aints = handles.Data.cellpastthreshints{tshankidx,cellshankidx};
[~,iidx,inany]=InIntervals(x,aints);
if round(y) ~= cellshankidx
    error('You must click in the row signifying the current cell (green)')
    return
elseif ~inany
    error('You clicked outside all intervals for this cell')
    return
elseif inany
    aints = aints(iidx,:);
end

uints = handles.Data.cellinstabilityints{thisclu};
uints = cat(1,uints,aints);
handles.Data.cellinstabilityints{thisclu} = uints;

guidata(handles.fig,handles);
PlotCellInstability(obj,[])


function ImportCluToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
clus = inputdlg({'Intervals From Clu #','Intervals to Clu #'},...
    'Transfer Instability Intervals',[1 30; 1 30],...
    {'' num2str(thisclu)});
if isempty(clus)
    return
end
fromclu = str2num(clus{1});
toclu = str2num(clus{2});
fints = handles.Data.cellinstabilityints{fromclu};
tints = handles.Data.cellinstabilityints{toclu};
tints = cat(1,tints,fints);
handles.Data.cellinstabilityints{toclu} = tints;

set(handles.clupopup,'Value',toclu)
guidata(handles.fig,handles);
ChangeClu(handles.fig,[])

function ImportOrigToClu(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');

oints = handles.Data.originalcellints{thisclu};
uints = handles.Data.cellinstabilityints{thisclu};
uints = cat(1,uints,oints);
handles.Data.cellinstabilityints{thisclu} = uints;

guidata(handles.fig,handles);
PlotCellInstability(obj,[])

%% CHANGING SHANK INTERVALS
function ImportShankToShank(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);

shanks = inputdlg({'Intervals From Shank #','Intervals to Shank #'},...
    'Transfer Instability Intervals',[1 30; 1 30],...
    {'' num2str(tshank)});
if isempty(shanks)
    return
end
fromshank = str2num(shanks{1});%will be in shank number, need to get idx
fromshankidx = find(handles.Data.allusedshanks==fromshank);
toshank = str2num(shanks{2});
toshankidx = find(handles.Data.allusedshanks==toshank);

fints = handles.Data.shankinstabilityints{fromshankidx};
tints = handles.Data.shankinstabilityints{toshankidx};
tints = cat(1,tints,fints);
handles.Data.shankinstabilityints{toshankidx} = tints;

newclu = find(handles.Data.shank==toshank,1,'first');

set(handles.shankpopup,'Value',toshankidx)
set(handles.clupopup,'Value',newclu)
guidata(handles.fig,handles);
PlotShankInstability(handles.fig,[])


function ImportCluToShank(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);

cs = inputdlg({'Intervals From Clu #','Intervals to Shank #'},...
    'Transfer Instability Intervals',[1 30; 1 30],...
    {'' num2str(tshank)});
if isempty(cs)
    return
end
fromclu = str2num(cs{1});
toshank = str2num(cs{2});
toshankidx = find(handles.Data.allusedshanks==toshank);

fints = handles.Data.cellinstabilityints{fromclu};
tints = handles.Data.shankinstabilityints{toshankidx};
tints = cat(1,tints,fints);
handles.Data.shankinstabilityints{toshankidx} = tints;

newclu = find(handles.Data.shank==toshank,1,'first');

set(handles.shankpopup,'Value',toshankidx)
set(handles.clupopup,'Value',newclu)
guidata(handles.fig,handles);
PlotShankInstability(handles.fig,[])


function ImportOrigToShank(obj,~)
handles = guidata(obj);
thisclu = get(handles.clupopup,'Value');
tshank = handles.Data.shank(thisclu);
tshankidx = find(handles.Data.allusedshanks==tshank);

handles.Data.shankinstabilityints{tshankidx} = handles.Data.originalshankints{tshankidx};
guidata(handles.fig,handles);
PlotShankInstability(handles.fig,[])


%% OUTPUT
function SaveDataBtn(obj,~)
handles = guidata(obj);
cellinstabilities = handles.Data.cellinstabilityints;
shankinstabilities = handles.Data.shankinstabilityints;
Instabilities = v2struct(cellinstabilities,shankinstabilities);
save(fullfile(handles.basepath,[handles.basename,'_Instabilities.mat']),'Instabilities')
disp(['Saved instability data to ' handles.basename,'_Instabilities.mat'])


function SaveFigBtn(obj,~)
handles = guidata(obj);
savefigsasname(handles.fig,'fig',fullfile(handles.basepath,[handles.basename,'_InstabilityGui.fig']))
disp(['Saved instability GUI fig to ' handles.basename,'_InstabilityGui.mat'])
