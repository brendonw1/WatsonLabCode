function StatesByClock(basepath, basename)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

LightOnTime = 6;

load(fullfile(basepath,[basename,'-states.mat']));
load(fullfile(basepath,[basename,'.eegstates.mat']));
% load(fullfile(basepath,[basename,'_Ripples.mat']),'RippleData'); % change file name if multiple channels were used for ripple detection
load(fullfile(basepath,[basename,'_Ripples_Ch79.mat']),'RippleData'); 
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionTimestamp')
% load(fullfile(basepath,[basename,'_Ripples_Ch13.mat']),'RippleData');
% RecSec = RecordingSecondVectors.RecordingSeconds;
% LightOnSec = RecordingSecondVectors.LightOn_ClockSeconds;

% StatesByClock.states = states(round(RecSec)<=length(states));
% StatesByClock.timestamp = LightOnSec(round(RecSec)<=length(states));

InjectionTimestampByClock = InjectionTimestamp.InClockSecondsFromZeitgeber/3600+LightOnTime;
statesInt = IDXtoINT(states);
for i = 1:length(statesInt)
    for j = 1:length(statesInt{i})
%         StateTimestamps{i}(j,1) = LightOnSec(find(round(RecSec)==statesInt{i}(j,1),1))/3600+LightOnTime;
%         StateTimestamps{i}(j,2) = LightOnSec(find(round(RecSec)==statesInt{i}(j,2),1,'last'))/3600+LightOnTime;
        
        StateTimestamps{i}(j,1) = RecordingTimeToClockTime(statesInt{i}(j,1))/3600+LightOnTime;
        StateTimestamps{i}(j,2) = RecordingTimeToClockTime(statesInt{i}(j,2))/3600+LightOnTime;
    end
end

% Ripple Occurance
RippleOccFre = Frequency(RippleData.ripples(:,1),'binSize',10,'limits',[0 length(states)],'smooth',5);
RippleOccFreTimestampsByClock = RecordingTimeToClockTime(RippleOccFre(:,1))/3600+LightOnTime;

% Ripple peak frequency
RippleOccTimestampsByClock = RecordingTimeToClockTime(RippleData.ripples(:,1))/3600+LightOnTime;
smoothPeakFre = Smooth(RippleData.data.peakFrequency,10);
% Ripple peak amplitude
smoothPeakAmp = Smooth(RippleData.data.peakAmplitude,10);
% Ripple duration
smoothDuration = Smooth(RippleData.data.duration,10);
% motion
MotionTimestamps = RecordingTimeToClockTime(1:length(StateInfo.motion))/3600+LightOnTime;
smoothMotion = Smooth(StateInfo.motion,10);

%% Plot
% FigByClock = figure; 
% ha = tight_subplot(5,1);
% axes(ha(1));
% plot(RippleOccFreTimestampsByClock,RippleOccFre(:,2)); 
% hold on;plotIntervalsStrip(gca,StateTimestamps);
% hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
% ylabel('Ripple Occurance');
% 
% axes(ha(2));
% plot(RippleOccTimestampsByClock,smoothPeakFre);
% hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
% ylabel('Peak Frequency');
% 
% axes(ha(3));
% plot(RippleOccTimestampsByClock,smoothPeakAmp);
% hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
% ylabel('Peak Amplitude');
% 
% axes(ha(4));
% plot(RippleOccTimestampsByClock,smoothDuration);
% hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
% ylabel('Ripple Duration');
% set(ha(1:4),'XTickLabel','');
% 
% axes(ha(5));
% plot(MotionTimestamps,smoothMotion); 
% hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
% ylabel('Motion');
% set(gca,'xTick',round(min(RippleOccTimestampsByClock)):round(max(RippleOccTimestampsByClock)));
% Xlabels = round(min(RippleOccTimestampsByClock)):round(max(RippleOccTimestampsByClock));
% Xlabels(Xlabels>24) = Xlabels(Xlabels>24)-24;
% set(gca, 'xTickLabel',Xlabels);

% for i = 1:4
%     axes(ha(i));
%     hold on;plot(InjectionTimestamp.InClockSecondsFromZeitgeber/3600+LightOnTime,ylim);
% end
% 



FigByClock = figure; 
ha = tight_subplot(5,1);
axes(ha(1));
plot(RippleOccFreTimestampsByClock,RippleOccFre(:,2),'LineWidth',1); 
% set(gca,'ylim',[0 2])
hold on;plotIntervalsStrip(gca,StateTimestamps);
hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
ylabel('Ripple Occurance');
axis tight;
% set(gca,'YAxisLocation','left');
% ax1 = gca;
% ax1_pos = ax1.Position;
% ax2 = axes('Position',ax1_pos,...
%     'YAxisLocation','right',...
%     'Color','r');
% line(MotionTimestamps,smoothMotion,'Parent',ax2,'Color','r')
% ylabel(ax2,'Motion');
% set(ax2,'ylim',[-1 2])

axes(ha(2));
plot(MotionTimestamps,smoothMotion); 
hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
ylabel('Motion');
axis tight;

axes(ha(3));
plot(RippleOccTimestampsByClock,smoothPeakFre,'.');
hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
ylabel('Peak Frequency');
axis tight;

axes(ha(4));
plot(RippleOccTimestampsByClock,smoothPeakAmp,'.');
hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
ylabel('Peak Amplitude');
set(ha(1:4),'XTickLabel','');
axis tight;

axes(ha(5));
plot(RippleOccTimestampsByClock,smoothDuration,'.');
hold on;plot(repmat(InjectionTimestampByClock,2),ylim);
ylabel('Ripple Duration');
axis tight;

set(gca,'xTick',round(min(RippleOccTimestampsByClock)):round(max(RippleOccTimestampsByClock)));
Xlabels = round(min(RippleOccTimestampsByClock)):round(max(RippleOccTimestampsByClock));
Xlabels(Xlabels>24) = Xlabels(Xlabels>24)-24;
set(gca, 'xTickLabel',Xlabels);

savefig(FigByClock,fullfile(basepath,[basename '_ByClock.fig']));
print(FigByClock,fullfile(basepath,[basename '_ByClock']),'-dpng','-r0');
end


function TimestampsByClock = RecordingTimeToClockTime(timestamps)
[~,basename,~] = fileparts(cd);
basepath = cd;
load(fullfile(basepath,[basename,'_RecordingSecondVectors.mat']));
StartsFrRecOnByClock = RecordingSecondVectors.RecordingStartsFromRecordingOnByClock;
EndsFrRecOnByClock = RecordingSecondVectors.RecordingEndsFromRecordingOnByClock;

TimestampsByClock = timestamps;
for ii = 1:(length(EndsFrRecOnByClock)-1)
    TimestampsByClock(TimestampsByClock>EndsFrRecOnByClock(ii)) = TimestampsByClock(TimestampsByClock>EndsFrRecOnByClock(ii))+StartsFrRecOnByClock(ii+1)-EndsFrRecOnByClock(ii);
end
TimestampsByClock = TimestampsByClock+RecordingSecondVectors.RecordingStartsFromLightOnByClock(1);

end

