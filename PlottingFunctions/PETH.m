function [tstarts, counts] = PETH (S, eventtime, timebefore, timeafter, binwidth, plotting)
% PETH_pg is better... use that


% All inputs in seconds, S should be a TSD array.
% 
% 
% sampfreq = 10000;
% % binwidth2 = binwidth * sampfreq; %convert seconds to sample points
% 
% if ~exist('plotting','var')
%     plotting = 0;
% end
% 
% timebefore = binwidth*floor(timebefore/binwidth); %round timebefore so it is equally divisible by the binwidth... so there will be a bin starting at the event time
% timeafter = binwidth*floor(timeafter/binwidth);
% % ebin = timebefore/binwidth + 1; %bin where event starts... output for ease
%  
% % ri = intervalSet(eventtime-timebefore, eventtime+timeafter);
% % R = Restrict(S,ri);
% 
% tstarts = eventtime-timebefore:binwidth:eventtime+(timeafter-binwidth);
% % tstops = eventtime-timebefore+binwidth:binwidth:eventtime+timeafter;
% tstops2 = eventtime-timebefore+binwidth:binwidth:eventtime+timeafter;
% counts = zeros(size(S,1),(timeafter+timebefore)/binwidth);
% for a = 1:size(S,1);
%     c =  histc(TimePoints(S{a}),tstops2*sampfreq)';
%     counts(a,:) = c(1:end-1);
% end
% 
% if plotting;
%     figure;
%     subplot(2,1,1);
%     imagesc(counts)
%     subplot(2,1,2);
%     bar(tstarts-binwidth*0.5,sum(counts,1));
% %     xlim([tstarts(1),tstops(end)])
%     xlim([tstarts(1) tstarts(end)])
%     hold on;
%     yl = ylim(gca);
%     plot([eventtime eventtime],yl,'c')
% end