function testSpindles(num_CH, spi_CH)

origdir = cd;
num_CH = 135;
spi_CH = 35;

FreqRange = [0 150];
spindleband = [9 20];%frequency band
belowspindleband = [0 spindleband(1)];
abovespindleband = [spindleband(2) FreqRange(2)];
% smoothing = 100;%ms
% smoothing = round(smoothing* lfpsamplerate/1000);%num points


%% Load LFP assuming to load the .lfp or .eeg in the current directory
filename = dir('*.lfp');
if isempty(filename)
    filename = dir('*.eeg');
end
if isempty(filename)
    error('No .lfp or .eeg file found.  Aborting')
    return
end

[pathstr, fbasename, fileSuffix] = fileparts(filename.name);
clear filename
% nchannels = num_CH;
% spindle_channel = spi_CH;  
lfp = LoadLfp([fbasename,fileSuffix],num_CH,spi_CH); 
disp('Loaded LFP')

lfpsamplerate = 10000/mode(diff(TimePoints(lfp)));


%% get spectrogram and band powers
% lfpsamplerate = 10000/mode(diff(TimePoints(lfp)));
% timechunk = 0.05;%seconds... how long a window to use
% % spectrapersec = 10;
% windowlength = lfpsamplerate*timechunk;
% FreqRange = [0 150];
% [spectrogram,f,t]=mtcsglong(lfpdata,2048,lfpsamplerate,windowlength,0,[],'linear',[],FreqRange);
% disp('Spectrogram Done')
% % lfpsamplerate = 1250;
% % timechunk = .1;
% % [spectrogram,t,f] = MTSpectrogram(lfpforFMA,'frequency',lfpsamplerate,...
% %     'window',timechunk,'overlap',0,'step',timechunk);
% % % ?? change overlap/steps?
% 
% % get spectrogram-based powers
% spindleband = [9 20];%frequency band
% spindleidx1 = find(f>=spindleband(1),1,'first');
% spindleidx2 = find(f<=spindleband(2),1,'last');
% spindlepower = sum(spectrogram(:,spindleidx1:spindleidx2),2);
% 
% abovespindleband = [spindleband(2) FreqRange(2)];
% aspindleidx1 = find(f>abovespindleband(1),1,'first');
% aspindleidx2 = find(f<=abovespindleband(2),1,'last');
% aspindlepower = sum(spectrogram(:,aspindleidx1:aspindleidx2),2);
% 
% belowspindlebad = [0.1 spindleband(1)];
% bspindleidx1 = find(f>belowspindlebad(1),1,'first');
% bspindleidx2 = find(f<=belowspindlebad(2),1,'last');
% bspindlepower = sum(spectrogram(:,bspindleidx1:bspindleidx2),2);
% 
% totalpower = sum(spectrogram,2);
% ztotalpower = zscore(totalpower);
% 
% spindletotalratio = spindlepower./totalpower;
% spindleaboveratio = spindlepower./aspindlepower;
% spindlebelowratio = spindlepower./bspindlepower;

%% Filter data
datatimes = Range(lfp, 's');
datavalues = double(Data(lfp));

spindlepower = FilterLFP([datatimes datavalues], 'passband', spindleband);
spindlepowerraw = spindlepower(:,2);
% spindlepower = convtrim(abs(spindlepowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
spindlepower = hilbertenvelope(spindlepowerraw);

aspindlepower = FilterLFP([datatimes datavalues], 'passband', abovespindleband);
aspindlepowerraw = aspindlepower(:,2);
% aspindlepower = convtrim(abs(aspindlepowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
aspindlepower = hilbertenvelope(aspindlepowerraw);

bspindlepower = FilterLFP([datatimes datavalues], 'passband', belowspindleband);
bspindlepowerraw = bspindlepower(:,2);
% bspindlepower = convtrim(abs(bspindlepowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
bspindlepower = abs(bspindlepowerraw);

thetapower = FilterLFP([datatimes datavalues], 'passband', 'theta');
thetapowerraw = thetapower(:,2);
% thetapower = convtrim(abs(thetapowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
thetapower = abs(thetapowerraw);

deltapower = FilterLFP([datatimes datavalues], 'passband', 'delta');
deltapowerraw = deltapower(:,2);
% deltapower = convtrim(abs(deltapowerraw),(1/smoothing)*ones(smoothing,1));%rolling avg
deltapower = abs(deltapowerraw);

totalpower = abs(datavalues);

%% zscore
zspindlepower = zscore(spindlepower);
zaspindlepower = zscore(aspindlepower);
zbspindlepower = zscore(bspindlepower);
zthetapower = zscore(thetapower);
zdeltapower = zscore(deltapower);
ztotalpower = zscore(totalpower);

%% power ratios
spindletotalratio = spindlepower./totalpower;
spindleaboveratio = spindlepower./aspindlepower;
spindlebelowratio = spindlepower./bspindlepower;
spindlethetaratio = spindlepower./thetapower;
spindledeltaratio = spindlepower./deltapower;

%% Callibrating spindle detection

% load events that were manually detected
cd /mnt/brendon4/BWRat19/BWRat19_032513_Supradir/BWRat19_032513/Spindles
events = LoadEvents('BWRat19_032513.evt.bws');

bss = [];
bse = [];
bws = [];

for a = 1:length(events.time);
    if strcmp(events.description{a},'bss');
        bss(end+1) = events.time(a);
    elseif strcmp(events.description{a},'bse');
        bse(end+1) = events.time(a);
    end
end

for a = 1:length(bss);
    ts = bss(a);
    te = bse(find(bse>ts,1,'first'));
    if (te - ts) > .1
        bws(end+1,:) = [ts te];
    end
end

cd(origdir);

%% Grab non-spindle times
numbws = length(bws);
recordinglengthinsamples = length(lfp);

othersamps = [];
for idx = 1:10;
    a = 1;
    while a<=numbws
    %     ts = bws(a,1)*lfpsamplerate;
        thisdur = bws(a,2)-bws(a,1);
        newstart = round(rand * recordinglengthinsamples);
        newstart = newstart/lfpsamplerate;
        newend = newstart + thisdur;

        ok = 1;
        if newend > recordinglengthinsamples/lfpsamplerate
            ok = 0;
        end
        
        for b = 1:size(bws,1)
            if newstart < bws(b,2) && bws(b,1) < newend
                ok = 0;
            end
        end

        if ok
            othersamps(end+1,:) = [newstart newend];
            a = a+1;
        end
    end
end

%% Get characteristics of BWSpindle vs other random times

for a = 1:length(bws);
%     ts = round(bws(a,1)*1/timechunk);
%     te = round(bws(a,2)*1/timechunk);
    ts = round(bws(a,1)*lfpsamplerate);
    te = round(bws(a,2)*lfpsamplerate);

    bwtotalpower = mean(totalpower(ts:te));
    bwztotalpower = mean(ztotalpower(ts:te));
    
    bwspindlepower(a) = mean(spindlepower(ts:te));
    bwzspindlepower(a) = mean(zspindlepower(ts:te));
    
    bwaspindlepower(a) = mean(aspindlepower(ts:te));
    bwbspindlepower(a) = mean(bspindlepower(ts:te));
    bwthetapower(a) = mean(thetapower(ts:te));
    bwdeltapower(a) = mean(deltapower(ts:te));

    bwzaspindlepower(a) = mean(zaspindlepower(ts:te));
    bwzbspindlepower(a) = mean(zbspindlepower(ts:te));
    bwzthetapower(a) = mean(zthetapower(ts:te));
    bwzdeltapower(a) = mean(zdeltapower(ts:te));

    bwspindletotalratio(a) = mean(spindletotalratio(ts:te));
    bwspindleaboveratio(a) = mean(spindleaboveratio(ts:te));
    bwspindlebelowratio(a) = mean(spindlebelowratio(ts:te));
    bwspindlethetaratio(a) = mean(spindlethetaratio(ts:te));
    bwspindledeltaratio(a) = mean(spindledeltaratio(ts:te));
end

for a = 1:length(othersamps);
%     ts = round(othersamps(a,1)*1/timechunk);
%     te = round(othersamps(a,2)*1/timechunk);
    ts = round(othersamps(a,1)*lfpsamplerate);
    te = round(othersamps(a,2)*lfpsamplerate);

    othertotalpower = mean(totalpower(ts:te));
    otherztotalpower = mean(ztotalpower(ts:te));

    otherspindlepower(a) = mean(spindlepower(ts:te));
    otherzspindlepower(a) = mean(zspindlepower(ts:te));
    
    otheraspindlepower(a) = mean(aspindlepower(ts:te));
    otherbspindlepower(a) = mean(bspindlepower(ts:te));
    otherthetapower(a) = mean(thetapower(ts:te));
    otherdeltapower(a) = mean(deltapower(ts:te));
    
    otherzaspindlepower(a) = mean(zaspindlepower(ts:te));
    otherzbspindlepower(a) = mean(zbspindlepower(ts:te));
    otherzthetapower(a) = mean(zthetapower(ts:te));
    otherzdeltapower(a) = mean(zdeltapower(ts:te));

    otherspindletotalratio(a) = mean(spindletotalratio(ts:te));
    otherspindleaboveratio(a) = mean(spindleaboveratio(ts:te));
    otherspindlebelowratio(a) = mean(spindlebelowratio(ts:te));
    otherspindlethetaratio(a) = mean(spindlethetaratio(ts:te));
    otherspindledeltaratio(a) = mean(spindledeltaratio(ts:te));
end



%% plot
% figure;;
% hist(otherspindlepower);
% hold on;
% hist(bwspindlepower);

figure
subplot(2,1,1)
plot(otherspindlepower,othertotalpower,'r.')
hold on;
plot(bwspindlepower,bwtotalpower,'g.')
title('Total vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Mean Total (0-150Hz)')
subplot(2,1,2)
plot(otherzspindlepower,otherztotalpower,'r.')
hold on;
plot(bwzspindlepower,bwztotalpower,'g.')
xlabel('Zscore of Spindle Band (9-20Hz)')
ylabel('Zscore of Total (0-150Hz)')


figure
subplot(2,1,1)
plot(otherspindlepower,otheraspindlepower,'r.')
hold on;
plot(bwspindlepower,bwaspindlepower,'g.')
title('Above vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Mean Above-Spindle Band (20-150Hz)')
subplot(2,1,2)
plot(otherzspindlepower,otherzaspindlepower,'r.')
hold on;
plot(bwzspindlepower,bwzaspindlepower,'g.')
xlabel('Zscore of Spindle Band (9-20Hz)')
ylabel('Zscore of Above-Spindle Band (20-150Hz)')

figure
subplot(2,1,1)
plot(otherspindlepower,otherbspindlepower,'r.')
hold on;
plot(bwspindlepower,bwbspindlepower,'g.')
title('Below vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Mean Below-Spindle Band (0-9Hz)')
subplot(2,1,2)
plot(otherzspindlepower,otherzbspindlepower,'r.')
hold on;
plot(bwzspindlepower,bwzbspindlepower,'g.')
xlabel('Zscore of Spindle Band (9-20Hz)')
ylabel('Zscore of Below-Spindle Band (0-9Hz)')

figure
subplot(2,1,1)
plot(otherspindlepower,otherdeltapower,'r.')
hold on;
plot(bwspindlepower,bwdeltapower,'g.')
title('Delta vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Mean Delta Band (0-9Hz)')
subplot(2,1,2)
plot(otherzspindlepower,otherzdeltapower,'r.')
hold on;
plot(bwzspindlepower,bwzdeltapower,'g.')
xlabel('Zscore of Spindle Band (9-20Hz)')
ylabel('Zscore of Delta Band (0-9Hz)')

figure
subplot(2,1,1)
plot(otherspindlepower,otherthetapower,'r.')
hold on;
plot(bwspindlepower,bwthetapower,'g.')
title('Theta vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Mean Theta Band (0-9Hz)')
subplot(2,1,2)
plot(otherzspindlepower,otherzthetapower,'r.')
hold on;
plot(bwzspindlepower,bwzthetapower,'g.')
xlabel('Zscore of Spindle Band (9-20Hz)')
ylabel('Zscore of Theta Band (0-9Hz)')

%
figure
subplot(2,1,1)
semilogy(otherspindlepower,otherspindletotalratio,'r.')
hold on;
semilogy(bwspindlepower,bwspindletotalratio,'g.')
title('Spindle:Total vs Spindle')
xlabel('Mean Spindle Band (9-20Hz)')
ylabel('Spindle Power:Total Power (0-150Hz)')
subplot(2,1,2)
semilogy(otherzspindlepower,otherspindletotalratio,'r.')
hold on;
semilogy(bwzspindlepower,bwspindletotalratio,'g.')
xlabel('ZScore of Spindle Band (9-20Hz)')
ylabel('Spindle Power:Total Power (0-150Hz)')

figure;
subplot(2,1,1)
semilogy(otherspindlepower,otherspindleaboveratio,'r.')
hold on;
semilogy(bwspindlepower,bwspindleaboveratio,'g.')
title('Spindle:Above vs Spindle')
xlabel('Mean Power in Spindle Band (9-20Hz)')
ylabel('Spindle:Above-Spindle Band (20-150Hz)')
subplot(2,1,2)
semilogy(otherzspindlepower,otherspindleaboveratio,'r.')
hold on;
semilogy(bwzspindlepower,bwspindleaboveratio,'g.')
xlabel('ZScore of Mean Power in Spindle Band (9-20Hz)')
ylabel('Spindle:Above-Spindle Band (20-150Hz)')

figure
subplot(2,1,1)
semilogy(otherspindlepower,otherspindlebelowratio,'r.')
hold on;
semilogy(bwspindlepower,bwspindlebelowratio,'g.')
title('spindle:below vs spindle')
xlabel('Mean Power in Spindle Band (9-20Hz)')
ylabel('Spindle:Below-Spindle Band (0-9Hz)')
subplot(2,1,2)
semilogy(otherzspindlepower,otherspindlebelowratio,'r.')
hold on;
semilogy(bwzspindlepower,bwspindlebelowratio,'g.')
xlabel('ZScore of Mean Power in Spindle Band (9-20Hz)')
ylabel('Spindle:Below-Spindle Band (0-9Hz)')

% %
% figure
% subplot(2,1,1)
% semilogy(otherspindlepower,1./otherspindletotalratio,'r.')
% hold on;
% semilogy(bwspindlepower,1./bwspindletotalratio,'g.')
% title('spindle:total vs spindle')
% xlabel('Mean Power in Spindle Band (9-20Hz)')
% ylabel('Total:Spindle Power (0.1-150Hz)')
% subplot(2,1,2)
% semilogy(otherzspindlepower,1./otherspindletotalratio,'r.')
% hold on;
% semilogy(bwzspindlepower,1./bwspindletotalratio,'g.')
% title('spindle:total vs spindle')
% xlabel('ZScore of Mean Power in Spindle Band (9-20Hz)')
% ylabel('Total:Spindle Power (0.1-150Hz)')
% 
% figure;
% subplot(2,1,1)
% semilogy(otherspindlepower,1./otherspindleaboveratio,'r.')
% hold on;
% semilogy(bwspindlepower,1./bwspindleaboveratio,'g.')
% title('spindle:above vs spindle')
% xlabel('Mean Power in Spindle Band (9-20Hz)')
% ylabel('Above-Spindle Band:Spindle Power (0.1-9Hz)')
% subplot(2,1,2)
% semilogy(otherzspindlepower,1./otherspindleaboveratio,'r.')
% hold on;
% semilogy(bwzspindlepower,1./bwspindleaboveratio,'g.')
% title('spindle:total vs spindle')
% xlabel('ZScore of Mean Power in Spindle Band (9-20Hz)')
% ylabel('Above-Spindle Band:Spindle Power (0.1-9Hz)')
% 
% figure
% subplot(2,1,1)
% semilogy(otherspindlepower,1./otherspindlebelowratio,'r.')
% hold on;
% semilogy(bwspindlepower,1./bwspindlebelowratio,'g.')
% title('spindle:below vs spindle')
% xlabel('Mean Power in Spindle Band (9-20Hz)')
% ylabel('Below-Spindle Band:Spindle Power (0.1-9Hz)')
% subplot(2,1,2)
% semilogy(otherzspindlepower,1./otherspindlebelowratio,'r.')
% hold on;
% semilogy(bwzspindlepower,1./bwspindlebelowratio,'g.')
% title('spindle:total vs spindle')
% xlabel('ZScore of Mean Power in Spindle Band (9-20Hz)')
% ylabel('Below-Spindle Band:Spindle Power (0.1-9Hz)')

%% Constrain by looking for coincident parameters
constrained = zspindlepower>0.1 & zaspindlepower>0 & spindlebelowratio < 1.2 & spindletotalratio>0.2;
minsamps = 2;% x 100ms
tryspinds = continuousabove2(constrained,1,3,Inf);
tryspindsms = tryspinds * 1000; %convert to ms for event writing


WriteEventFileFromTwoColumnEvents (tryspindsms,[fbasename '.try.evt'])




% 
% figure;
% plot3(otherspindlepower,otherspindletotalratio,otherspindleaboveratio,'r.')
% hold on;
% plot3(bwspindlepower,bwspindletotalratio,bwspindleaboveratio,'g.')
% title('above vs total vs spindle')
% 
% figure;
% plot3(otherspindlepower,otheraspindlepower,otherbspindlepower,'r.')
% hold on;
% plot3(bwspindlepower,bwaspindlepower,bwbspindlepower,'g.')
% title('below vs total vs spindle')


% 
% 
% %% visualize
% figure;
% logTransformed = log(spectrogram);
% PlotColorMap(logTransformed',1,'x',t,'y',f);
% hold on
% plot(totalpower/100,'c')
% plot(spindlepower/100,'b')
% plot(spindletotalratio/100,'k')
% plot(spindleaboveratio/100,'g')
% plot(spindlebelowratio/100,'r')
% 
% %% Get ahold of Spindles
% minspindlesec = 0.3;%seconds
% minspindlebins = minspindlesec/timechunk;%in bins
% maxspindlesec = 4;%seconds
% maxspindlebins = maxspindlesec/timechunk;%in bins
% 
% detectionsignal = zscore(spindletotalratio);
% 
% [starts,stops] = continuousabove2(detectionsignal,2,minspindlebins,maxspindlebins);
% 
% starts = t(starts);
% stops = t(stops);
% 
% %% Now get boundaries
% spindlefiltered = FilterLFP([1:length(lfp)/lfpsamplerate lfp], 'passband', spindleband);
% deltafiltered = FilterLFP([1:length(lfp)/lfpsamplerate lfp], 'passband', [0.5 2]);
% 
% %? maybe filter lfp directly as in spindledetect, then look at local power?
% % zscore
% % Look at first above that is prior and last above that is after for bounds
% % Maybe use 
% 
% % or do another filtered at delta and take local ratio of powers
% 
% 
% %% Extract measures
% for a = 1:length(starts);    
%     thisspindle = lfp(starts(a):stops(a)); 
%     [spectrum,f,dummy] = MTSpectrogram(lfp,'frequency',lfpsamplerate,...
%          'window',timechunk,'overlap',0,'step',timechunk);
%     [maxval,maxind] = max(spectrum);
%     maxfreq(a) = f(maxind);
%     
%     thisfilteredspindle = spindlefiltered(starts(a):stops(a));
%     h = hilbert(thisfilteredspindle(:,2));
%     amplitude(a) = max(abs(h));
% end
% 
% %     amplitude(:,1) = thisfilteredspindle(:,1);
% %     amplitude(:,2) = abs(h);
% % 
% %     phase(:,1) = thisfilteredspindle(:,1);
% %     phase(:,2) = angle(h);
% %     unwrapped(:,1) = thisfilteredspindle(:,1);
% %     unwrapped(:,2) = unwrap(phase(:,2));
% %     % Compute instantaneous frequency
% %     frequency = Diff(unwrapped,'smooth',0);
% %     frequency(:,2) = frequency(:,2)/(2*pi);
% 
%    
% % for each event, cut snippet from raw 
% %                     MTSpectrum.m, find freq with max power
% %                 cut snippet from spindlefilt, 
% %                     h = hilbert the delta filtered 
% %                     get phase as zugaro
% %                     get amplitude as zugaro
% %                     use max(amplitude) to get peak
% 
% %% Save as zugaro SpindleStats.m
% % plug into PlotSpindleStats.m
% % add time vs peaklag, vs amplitude, vs freq
% 
% end



