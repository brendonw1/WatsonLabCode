function varargout=continuousbelow2(data,belowthresh,mintime,maxtime)
% function varargout=continuousbelow(data,baseline,belowthresh,mintime,maxtime);
%
% Finds periods in a linear trace that are below some baseline by some
% minimum amount (belowthresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.

if ~exist('mintime','var')
    mintime = 0;
end
if ~exist('maxtime','var')
    maxtime = Inf;
end


below=find(data<=belowthresh);

if max(diff(diff(below)))==0 && length(below)>=mintime && length(below)<=maxtime;%if only 1 potential upstate found
    belowperiods = [below(1) below(end)];
elseif length(below)>0;%if many possible upstates
	ends=find(diff(below)~=1);%find breaks between potential upstates
    ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
    ends(end+1)=length(below);%one of the ends comes at the last found point above baseline
    ends=sort(ends);
    lengths=diff(ends);%length of each potential upstate
    good=find(lengths>=mintime & lengths<=maxtime);%must be longer than 500ms but shorter than 15sec
    ends(1)=[];%lose the 0 added before
    e3=reshape(below(ends(good)),[length(good) 1]);
    l3=reshape(lengths(good)-1,[length(good) 1]);
    belowperiods(:,2)=e3;%upstate ends according to the averaged reading
    belowperiods(:,1)=e3-l3;%upstate beginnings according to averaged reading
else
    belowperiods=[];
end

varargout{1}=belowperiods;
if nargout==2;
    if isempty(belowperiods);
        aboveperiods = [];
    else
        stops=belowperiods(:,2);
        stops(2:end+1,1)=stops;
        stops(1)=0;
        stops=stops+1;

        starts=belowperiods(:,1);
        starts(end+1,1)=length(data)+1;
        starts=starts-1;

        aboveperiods=cat(2,stops,starts);

        if aboveperiods(1,2)<=aboveperiods(1,1);
            aboveperiods(1,:)=[];
        end
        if aboveperiods(end,2)<=aboveperiods(end,1);
            aboveperiods(end,:)=[];
        end
    end

    varargout{2}=aboveperiods;
end