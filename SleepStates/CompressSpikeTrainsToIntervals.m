function NewS = CompressSpikeTrainsToIntervals(S,i,starttime)
% function NewS = CompressSpikeTrainsToIntervals(S,i)
% Will reconstruct a new tsdArray based on concatenating chunks from
% different times together.  More than just a restrict function since it
% actually totally removes timeblocks between intervals and actually
% subtracts event times from S to "rezero" them to the start of the
% interval they occur in, then adds that to the time of the end of the
% prior event.  
% INPUTS
% S: tsd or tsdArray of event times
% i: intervalSet of times to restrict to
% starttime: char string must be either "zero" or "first", specifies
%            whether the start times each tsd in the TSD is zero or is set 
%            to the first time of the intervalSet (default is zero)
%
% OUTPUTS
% NewS: tsdArray compressed to the intervalSet specified.
% 
% Brendon Watson 2014

Starts = Start(i);
Ends = End(i);

if ~exist('starttime','var')
    starttime = 'zero';
end
switch starttime(1:4)
    case 'zero'
        stime = 0;
    case 'firs'
        stime = FirstTime(i);
end

if isa(S,'tsd')
    lS = 1;
elseif isa(S,'tsdArray')
    lS = length(S);
end

if lS == 0
    newS{1} = tsd([],[]);
else
    for a = 1:lS%for each cell/element measured
    % for a = 1:size(S,2)%for each cell/element measured
        if isa(S,'tsd')
            tS = S;
        elseif isa(S,'tsdArray')
            tS = S{a};
        end

        Tt = TimePoints(tS);%all spikes this cell
        Tv = Data(tS);

        priorlength = 0;
        tnewT = [];
        tnewV = [];
        for b = 1:length(length(i))%for each interval
            tstart = Starts(b);
            tend = Ends(b);
            
            try
                tidx = InIntervals(Tt,[tstart tend]);%faster
            catch
                tidx = InIntervalsBW(Tt,[tstart tend]);%slower, but not needing mex file
            end
            ttt = Tt(tidx);%event times this cell in this interval
            tvt = Tv(tidx);%event values this cell in this interval

            tttt = ttt-tstart;%times in event from start of event
            tttt = tttt + priorlength;%add length of the summated prior events
            if prod(tvt == ttt)%if degenerate case of tsd, ie spiking, where value = time
                tvt = tttt;
            end %if else, just keep the values, ie lfp

            tnewT = cat(1,tnewT,tttt);
            tnewV = cat(1,tnewV,tvt);        

            priorlength = priorlength + (tend-tstart);
        end
        ttsd = tsd(tnewT+stime,tnewV);

        newS{a} = ttsd;
    %     if rem(a,10) == 0
    %         disp(['Cell ' num2str(a) ' out of ' num2str(size(S,1)) ' done'])
    %     end
    end
end

NewS = tsdArray(newS');


% for a = 1:size(S,1)
%     tS = S{a};
%     
%     priorlength = 0;
%     tnewT = [];
%     tnewV = [];
%     for b = 1:length(length(i))
%         ti = subset(i,b);
%         ts = Restrict(tS,ti);
%         
%         tt = TimePoints(ts)-Start(ti);%times in event from start of event
%         tt = tt + priorlength;%add length of the summated prior events
%         tv = Data(ts)-Start(ti);%data values in event
%         
%         tnewT = cat(1,tnewT,tt);
%         tnewV = cat(1,tnewV,tv);        
%         
%         priorlength = priorlength + Data(length(ti));
%     end
%     ttsd = tsd(tnewT,tnewV);
%     
%     newS{a} = ttsd;
%     if rem(a,10) == 0
%         disp(['Cell ' num2str(a) ' out of ' num2str(size(S,1)) ' done'])
%     end
% end
% 
% NewS = tsdArray(newS);