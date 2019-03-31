function [tstarts, counts] = PETH_pg (S, eventtime, timebefore, timeafter, binwidth, plotting)
% All inputs in seconds
% 

sampfreq = 10000;
% binwidth2 = binwidth * sampfreq; %convert seconds to sample points

if ~exist('plotting','var')
    plotting = 0;
end

timebefore = binwidth*floor(timebefore/binwidth); %round timebefore so it is equally divisible by the binwidth... so there will be a bin starting at the event time
timeafter = binwidth*floor(timeafter/binwidth);
% ebin = timebefore/binwidth + 1; %bin where event starts... output for ease
 
% ri = intervalSet(eventtime-timebefore, eventtime+timeafter);
% R = Restrict(S,ri);

tstarts = eventtime-timebefore:binwidth:eventtime+(timeafter-binwidth);
% tstops = eventtime-timebefore+binwidth:binwidth:eventtime+timeafter;
tstops2 = eventtime-timebefore+binwidth:binwidth:eventtime+timeafter;
sz = size(S);%need to do this because of difference in size command for tsdarray vs tsd (ie if give single cell input)
switch class(S)
    case 'ts'
        sz = 1;
        counts = zeros(sz,(timeafter+timebefore)/binwidth);
        for a = 1:sz;
            c =  histc(TimePoints(S),tstops2*sampfreq)';
            counts(a,:) = c;
        end
    case 'tsdArray'
        sz = sz(1);
        counts = zeros(sz,(timeafter+timebefore)/binwidth);
        for a = 1:sz;
            c =  histc(TimePoints(S{a}),tstops2*sampfreq)';
            counts(a,:) = c;
        end
end
        

if plotting;
    figure;
    subplot(3,1,1);
    imagesc(counts)
    title('all cells, each cell is a row. Non-normalized')
    
    subplot(3,1,2)
    imagesc(bwnormalize_array(counts))
    title('all cells, each cell is a row. Normalized to max&min per cell')
    
    subplot(3,1,3);
    bar(tstarts-binwidth*0.5,sum(counts,1));
%     xlim([tstarts(1),tstops(end)])
    xlim([tstarts(1) tstarts(end)])
    hold on;
    yl = ylim(gca);
    plot([eventtime eventtime],yl,'c')
    title('Summation of all spikes in each bin... all cells')
end