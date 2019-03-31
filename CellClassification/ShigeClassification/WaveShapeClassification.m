function  [CellsQuality, PyrBoundary, varargout] = WaveShapeClassification (fileBase, SpkWvform_all, SpkWvform_idx, Cells, PlotWaves, ECells, ICells, PyrBoundary)
% By Shigeyoshi Fujisawa
% Algorithmic generalizations and these comments by Brendon Watson
% Function to allow manual placement of a boundary between waveforms of
% inhibitory and excitatory cells... potentially guided by the marking of
% already-identified cells (ie by connectivity analysis) which can be
% entered via the ECells/ICells input... or by previously used boundaries
% "PyrBoundary".  Parameters used are param1:time from spike to "afterpeak"
% and param2: spike width at 20% height.
%
% INPUTS
% fileBase = basename of all files for this dataset
% Cells = vector of cells to try to classify
% % ShankMap = cell array of which clustering groups had which numbers of
% elements, ie from Par.ElecGp
% PlotWaves = Boolean (1 or 0) determinig whether or not to plot
% ECells = vector list of ID of already-ID'd excitatory cells (ie based on
% connectivity analysis)
% ICells = same as ECells for inihibitory cells
% PyrBoundary = any previously-known boundary distinguishing pyramidal
% cells, ie from other experiment or from conglomeration of data.
% 
% OUTPUTS
% CellsQuality = Matrix with row for each cell, columns as follows:
%   Cell#  Param1  Param2  NewID(Exc=1,Inh=-1) PriorID(0=none,1=Exc,-1=Inh)
%                Param1:time from spike to "afterpeak" (peak-trough)
%                Param2: spike width at 20% height
% PyrBoundary = boundary line for pyramidal cells here
% Param = optional output in varargout: list of all measurements for each cell


% load(['AllSpikeWavs_' fileBase '.mat']);
% load([fileBase '_AllSpikeWavs.mat'])
Par = LoadPar([fileBase '.xml']);

for a = 1:size(Par.SpkGrps,2);
    ShankMap{a} = Par.SpkGrps(a).Channels; % cell array of which clustering groups had which numbers of
% elements
end

%Wdepth    = 0.2;% the depth at which you measure the width of waveform - as a proportion of the peak height
Wdepth    = 0.5;% the depth at which you measure the width of waveform - as a proportion of the peak height
CenterT   = round(Par.SampleRate * 0.003)+1; % center point, defined by 'AllSpkWaveform.m'
OneMs = round(Par.SampleRate/1000);
Center2ms = [(CenterT-OneMs):(CenterT+OneMs)]; %time points of center 2ms

if nargin<3; PlotWaves=0;end
if nargin<4; ECells=[];ICells=[];end
if nargin<6; PyrBoundary=[];end

for ii=1:length(Cells)
%% get the waveform on the maximal channel
   mycell  = SpkWvform_idx(find(SpkWvform_idx(:,1)==Cells(ii)),1);
   myshank = SpkWvform_idx(find(SpkWvform_idx(:,1)==Cells(ii)),2);

   channels_of_myshank = ShankMap{myshank}+1; %+1 compensates for channel numbers starting at 0
   mywaveall = []; mytroughall = []; mypeakall = []; mypeaksizeall = [];
   
   for kk=1:length(channels_of_myshank)
      mywaveall(:,kk)  = shiftdim(SpkWvform_all(mycell,channels_of_myshank(kk),:),2);
      mytroughall(kk)  = min(mywaveall(Center2ms,kk));
      mypeakall(kk)    = max(mywaveall(Center2ms,kk));
      mypeaksizeall(kk)= mypeakall(kk) - mytroughall(kk);
   end
   mychannel = channels_of_myshank(find(mypeaksizeall==max(mypeaksizeall)));

%% got wave, take derivatives
   wave     = shiftdim(SpkWvform_all(mycell,mychannel,:),2);
   derwave  = diff(wave);     %derivative
   der2wave = diff(derwave); %second derivative

   troughT    = find(wave == min(wave(Center2ms)),1);         % time of trough of wave
       if troughT<Center2ms(1); troughT=CenterT; end % to avoid error
   derpeakT   = find(derwave == max(derwave(troughT:(CenterT+OneMs))),1);  % time of peak of second half of derivative
       if derpeakT<=troughT; derpeakT=troughT+2; end % to avoid error
   findder0   = find(derwave(derpeakT:end)<=0, 1);          % ID'ing AHP("afterpeak") (first derivative<=0 after deriv peak)
   if ~length(findder0);findder0=length(derwave(derpeakT:end));end  % if no peak, take the end point
   afterpeakT = derpeakT+findder0-1;%correcting to put AHP time in same time frame as trough
      a1=abs(derwave(afterpeakT)-0);%grabbing value    
      a2=abs(derwave(afterpeakT-1)-0);%...and at point before
      afterpeakT=afterpeakT-a1/(a1+a2);   % interpolationof derivative curve at AHP...

   baseline1 = mean(wave(2*OneMs:3*OneMs));%baseline in last ms of wave

   h1 = baseline1 - Wdepth * (baseline1 - wave(troughT));%figure the height of 20% of the way to peak
   findh1 = find(wave(Center2ms)<h1);%grab the two points where this is crossed
   leftT  = findh1(1);
   rightT = findh1(end);
     l1 = abs(wave(Center2ms(leftT))-h1);
     l2 = abs(wave(Center2ms(leftT)-1)-h1);
     r1 = abs(wave(Center2ms(rightT))-h1);
     r2 = abs(wave(Center2ms(rightT)+1)-h1);
   leftT =leftT-l1/(l1+l2);     % interpolation
   rightT=rightT+r1/(r1+r2);    % interpolation
   width1 = rightT-leftT;
   
%% Param1: Time between sClusterpike deflection and AHP ("trough to afterpeak"), in ms
   Param(ii,1) = (afterpeakT - troughT)/OneMs; 
%% Param2: Spike width at 20% of max, in ms
   Param(ii,2) = width1/OneMs;                 
   Param(ii,3) = Cells(ii);
   if PlotWaves==1
      figure(ceil(ii/25))
      mod25=mod(ii,25);
      if mod25==0;mod25=25;end
      subplot(5,5,mod25)
      height=max(wave)-min(wave);
      plot(wave);set(gca,'Xlim',[0,length(wave)]);set(gca,'Ylim',[min(wave)-0.15*height,max(wave)+0.15*height])
      %line(afterpeakT,wave(afterpeakT),'marker','^')
      %line(troughT,wave(troughT),'marker','o')
      text(20,max(wave),num2str(Cells(ii)))
   end
end


f1000 = figure(1000);
a1000 = axes;%plot basic rate changes for All, E and I cells[CellsQuality, PyrBoundary, CellSpikeMeasures] = WaveShapeClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, 1, ccgjitteroutput(1).ECells, ccgjitteroutput(1).ICells);


plot3(Param(:,1),Param(:,2),Param(:,3),'linestyle','none','marker','.','color',[0.5 0.5 0.5]);

if ECells
   findE=ismember(Cells,ECells);
   line(Param(findE,1),Param(findE,2),Param(findE,3),'linestyle','none','marker','^',...
        'markerfacecolor','r','markeredgecolor','r');
end
if ICells
   findI=ismember(Cells,ICells);
   line(Param(findI,1),Param(findI,2),Param(findI,3),'linestyle','none','marker','o',...
        'markerfacecolor','b','markeredgecolor','b');
end
view(0,90)
xlabel('')
ylabel('')
title('')

%%%%  Pyr-Int Descrimination
% if PlotWaves==1
%   keyin = input('\n\n Do you want to descriminate Pyr and Int (yes/no)? ', 's');
% elseif length(PyrBoundary)>0
%   keyin='yes';
% else
%   keyin = [];
% end
keyin = 'yes';

if strcmp(keyin,'yes')
   if exist('PyrBoundary','var')     % In case you use the input
      PyramidalSpots = inpolygon(Param(:,1), Param(:,2), PyrBoundary(:,1),PyrBoundary(:,2));
   else               % In case you use the graph
      f1001 = figure(1001);
      title('Discriminate pyr and int (select Pyramidal)');
      fprintf('\nDiscriminate pyr and int (select Pyramidal)');
      [PyramidalSpots,PyrBoundary] = ClusterPointsBoundaryOut(Param(:,1:2),1);
      close(f1001);
      line(PyrBoundary(:,1),PyrBoundary(:,2),'Parent',a1000);%plot new boundary on plotted 
   end
else
   PyramidalSpots=[];
end

if nargout>0;
   CellsQuality(:,1)  = Cells;
   CellsQuality(:,2:3)= Param(:,1:2);
   CellsQuality(:,4)  = zeros(size(Cells));
   if sum(PyramidalSpots)>0
      CellsQuality(PyramidalSpots,4) =1;
      CellsQuality(~PyramidalSpots,4)=-1;
   end
   CellsQuality(:,5)  = zeros(size(Cells));
   CellsQuality(ismember(Cells,ECells),5)=1;
   CellsQuality(ismember(Cells,ICells),5)=-1;
end
if nargout>1;
   PyrBoundary=PyrBoundary;
end

varargout{1} = Param;