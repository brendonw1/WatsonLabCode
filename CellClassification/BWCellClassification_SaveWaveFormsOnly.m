% function  [CellClassOutput, PyrBoundary] = BWCellClassification (fileBase, SpkWvform_all, SpkWvform_idx, Cells, ECells, ICells)
function  BWCellClassification_SaveWaveFormsOnly (basepath, basename, cellshanknums, shanks)
% 
% Mixture of functions from Shigeyoshi Fujisawa (WaveShapeClassification),
% Adrien Peyrache (wavelet-based determination of spike width) and Eran Stark (wfeatures, spikestats).
% 
% OUTPUT
% CellClassOutput(:,1) = cellnums;
% CellClassOutput(:,2) = trough to peak time in ms
% CellClassOutput(:,3) = full trough time in ms
% CellClassOutput(:,4) = -1 for int-like cells, 1 for exc-like cells
% CellClassOutput(:,5) = 1 for CCG-confirmed E cells, -1 for CCG-confirmed I cells;
% Brendon Watson 2014

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

% Par = LoadPar([basename '.xml']);
load(fullfile(basepath,[basename '_BasicMetaData.mat']));
Par = bmd.Par;
% if isfield(bmd,'masterpath')
%     fpath = bmd.masterpath;
% else
%     fpath = bmd.basepath;
% end
fpath = basepath;

if isfield(bmd,'mastername')
    fname = bmd.mastername;
else
    fname = bmd.basename;
end

if ~exist('cellshanknums','var')
    t = load(fullfile(basepath,[basename '_SStable']));
    cellshanknums = t.cellIx;
end
if ~exist('shanks','var')
    t = load(fullfile(basepath,[basename '_SStable']));
    shanks = t.shank;
end
cellnums = 1:length(shanks);

% for a = 1:size(Par.SpkGrps,2);
%     ShankMap{a} = Par.SpkGrps(a).Channels; % cell array of which clustering groups had which numbers of
% % elements
% end
%
%Wdepth    = 0.2;% the depth at which you measure the width of waveform - as a proportion of the peak height
% Wdepth    = 0.5;% the depth at which you measure the width of waveform - as a proportion of the peak height
% CenterT   = round(Par.SampleRate * 0.003)+1; % center point, defined by 'AllSpkWaveform.m'
OneMs = round(Par.SampleRate/1000);
% Center2ms = [(CenterT-OneMs):(CenterT+OneMs)]; %time points of center 2ms
% 
% if nargin<3; PlotWaves=0;end
% if nargin<4; ECells=[];ICells=[];end
% if nargin<6; PyrBoundary=[];end

% %% get the waveform on the maximal channel... from Shige
% for ii=1:length(Cells)
%    mycell  = SpkWvform_idx(SpkWvform_idx(:,1)==Cells(ii),1);
%    myshank = SpkWvform_idx(SpkWvform_idx(:,1)==Cells(ii),2);
% 
%    channels_of_myshank = ShankMap{myshank}+1; %+1 compensates for channel numbers starting at 0
%    mywaveall = []; 
%    mytroughall = []; 
%    mypeakall = []; 
%    mypeaksizeall = [];
%    
%    for kk=1:length(channels_of_myshank)
%       mywaveall(:,kk)  = shiftdim(SpkWvform_all(mycell,channels_of_myshank(kk),:),2);
%       mytroughall(kk)  = min(mywaveall(Center2ms,kk));
%       mypeakall(kk)    = max(mywaveall(Center2ms,kk));
%       mypeaksizeall(kk)= mypeakall(kk) - mytroughall(kk);
%    end
%    mychannel = channels_of_myshank(mypeaksizeall==max(mypeaksizeall));
% 
% %% save max waves
%    waves(:,ii)     = shiftdim(SpkWvform_all(mycell,mychannel,:),2);
% end
MaxWaves = [];
MaxWaveChannelIdxsB0 = [];
allshanks = unique(shanks);
for a = 1:length(allshanks);
    thisshank = allshanks(a);
    AllWaves{thisshank} = [];%separated AllWaves in case each shank has diff number of sites
%     theseChannels = Par.SpkGrps(thisshank).Channels;
    numChannels = length(Par.SpkGrps(thisshank).Channels);
    tShankChans = Par.SpkGrps(thisshank).Channels;
    nSamples = Par.SpkGrps(thisshank).nSamples;
    spkname = fullfile(fpath,[fname '.spk.' num2str(thisshank)]);
    
    cellsthisshank = cellnums(shanks==thisshank);
    intrashankclunums = cellshanknums(shanks == thisshank);
    cluname = fullfile(fpath,[fname '.clu.' num2str(thisshank)]);
    clu = LoadClu(cluname);
    for b = 1:length(cellsthisshank)
        spikesthiscell = find(clu == intrashankclunums(b));        
        if ~isempty(spikesthiscell)
            Waveforms = LoadSpikeWaveforms_BW(spkname,numChannels,nSamples,spikesthiscell);%load one cell at a time
            meanwaves = squeeze(mean(Waveforms,1));
            AllWaves{thisshank}(:,:,end+1) = meanwaves;
            [~,tmaxwaveidx] = max(abs(max(meanwaves,[],2)-min(meanwaves,[],2)));
            MaxWaves(:,end+1) = meanwaves(tmaxwaveidx,:);
            MaxWaveChannelIdxsB0(end+1) = tShankChans(tmaxwaveidx);
        else
            1;
        end
    end
    disp(['Shank ',num2str(a),' (Orig#:' num2str(thisshank) ') Done'])
    AllWaves{thisshank}(:,:,1) = [];
end
    
%     >> LOaded all spikes from shank
%     go thru each cell using clu, get indices, grab and average spikes then ...
%     waves(:,a) = mean(waveforms,1);
% end
% % %% get trough to peak (Eran Code)
% % [ hw, asy, tp] = wfeatures(waves, 0); 
% 
% %% get trough to peak time
for a = 1:length(cellnums)
    thiswave = MaxWaves(:,a);
    [minval,minpos] = min(thiswave);
    minpos = minpos(1);
    [maxval,maxpos] = max(thiswave);
%     if abs(maxval) > abs(minval)%if it's an upsidedown spike... flip everything
%         try
%             [dummy,minpos] = min(thiswave(maxpos+1:end));
%             minpos = maxpos+minpos;
%             tp(a) = minpos-maxpos;
%         catch
%             [dummy,maxpos] = max(thiswave(minpos+1:end));
%             maxpos = maxpos+minpos;
%             tp(a) = maxpos-minpos;
%         end
%     else %if min is larger deviation than the max deviation... ie normal spike
        [dummy,maxpos] = max(thiswave(minpos+1:end));
        maxpos=maxpos(1);
        maxpos = maxpos+minpos;
        tp(a) = maxpos-minpos;
%     end

end

%% get spike width by taking inverse of max frequency in spectrum (based on Adrien's use of Eran's getWavelet)
for a = 1:size(MaxWaves,2)
    w = MaxWaves(:,a);
    w = [w(1)*ones(1000,1);w;w(end)*ones(1000,1)];
    [wave f t] = getWavelet(w,20000,500,3000,128);
    %We consider only the central portion of the wavelet because we
    %haven't filtered it before hand (e.g. with a Hanning window)
    wave = wave(:,int16(length(t)/4):3*int16(length(t)/4));
    %Where is the max frequency?
    [maxPow ix] = max(wave);
    [dumy mix] = max(maxPow);
    ix = ix(mix);
    spkW(a) = 1000/f(ix);
end

%% Generate separatrix for cells 
x = tp'/OneMs;%trough to peak in ms
y = spkW';%width in ms of wavelet representing largest feature of spike complex... ie the full trough including to the tip of the peak

% xx = [0 0.8];
% yy = [2.4 0.4];
% m = diff( yy ) / diff( xx );
% b = yy( 1 ) - m * xx( 1 );  % y = ax+b
% RS = y>= m*x+b;
% INT = ~RS;

%% Plot for manual selection of boundary, with display of separatrix as a guide.
% h = figure;
% title('Discriminate pyr and int (select Pyramidal; left click to draw boundary, center click to complete)');
% fprintf('\nDiscriminate pyr and int (select Pyramidal)');
% xlabel('Trough-To-Peak Time (ms)')
% ylabel('Wave width (via inverse frequency) (ms)')
% [ELike,PyrBoundary] = ClusterPointsBoundaryOutBW([x y],ESynapseCells,ISynapseCells,m,b);

%% Mean waveforms output
TroughPeakMs = x;
SpikeWidthMs = y;
MeanWaveforms = v2struct(AllWaves,MaxWaves,cellnums,cellshanknums,shanks,basename,TroughPeakMs,SpikeWidthMs,MaxWaveChannelIdxsB0);
save(fullfile(basepath,[basename,'_MeanWaveforms.mat']),'MeanWaveforms')

% %% Ready output variable
% CellClassOutput(:,1) = cellnums;
% CellClassOutput(:,2) = x;%trough to peak time in ms
% CellClassOutput(:,3) = y;%full trough time in ms
% CellClassOutput(:,4) = -1;%ilike, based on user click (outside polygon)
% CellClassOutput(ELike,4) = 1;%elike, inside polygon
% CellClassOutput(:,5) = zeros(size(cellnums));
% CellClassOutput(ISynapseCells,5) = -1;%ICells, based on funcsynapse input
% CellClassOutput(ESynapseCells,5) = 1;%Ecells, based on funcsynapse output
