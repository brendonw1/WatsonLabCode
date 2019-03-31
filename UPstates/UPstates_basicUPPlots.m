function f = UPstates_basicUPPlots(iss,durs)

f=figure;
% a. spike counts per event
subplot(3,1,1)
plot(sum(iss.spkcounts,2))
title('Total spikes per spindle')
axis tight
% b. durations per event
subplot(3,1,2)
plot(durs)
title('Duration per spindle (sec)')
axis tight
% c. spike rates per event(a/b)
subplot(3,1,3)
plot(sum(iss.spkcounts,2)./durs)
title('Total spikes per sec for each spindle')
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