function f = UPstates_basicSpindlePlots(iss,SpindleData)

f=figure;
% a. spike counts per event
subplot(5,1,1)
plot(sum(iss.spkcounts,2))
title('Total spikes per UP')
axis tight
% b. durations per event
subplot(5,1,2)
plot(SpindleData.data.duration)
title('Duration per UP (sec)')
axis tight
% c. spike rates per event(a/b)
subplot(5,1,3)
plot(sum(iss.spkcounts,2)./SpindleData.data.duration)
title('Total spikes per sec for each spindle')
axis tight
% d. peak amplitude per event
subplot(5,1,4)
plot(SpindleData.data.peakAmplitude)
title('Peak Amplitude per spindle (sec)')
axis tight
% e. Frequency at peak amplitude time per event
subplot(5,1,5)
plot(SpindleData.data.peakFrequency)
title('Frequency at peak per spindle')
axis tight


celltype = inputname(1);
switch celltype
    case 'iss'
        celltype = 'All';
    case 'isse'
        celltype = 'E';
    case 'issi'
        celltype = 'I';
    case 'issed'
        celltype = 'EDef';
    case 'issid'
        celltype = 'IDef';
end        
AboveTitle(['BasicStats for Spindles and ' celltype ' Cells'])