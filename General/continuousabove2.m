function varargout=continuousabove2_v2(data,abovethresh,mintime,maxtime)
% function varargout=continuousabove(data,abovethresh,mintime,maxtime);
%
% Finds periods in a linear trace that are above or equal to some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  
% Output 1 is indices of starts of those periods in data.  If a second
% output is specified, that will be the stoptimes.
% Differs from continuousabove.m by not needing a baseline input variable

if ~exist('mintime','var')
    mintime = 0;
end
if ~exist('maxtime','var')
    maxtime = inf;
end

above=find(data>=abovethresh);

if max(diff(diff(above)))==0 & length(above)>=mintime & length(above)<=maxtime;%if only 1 potential upstate found
    aboveperiods = [above(1) above(end)];
elseif length(above)>0;%if many possible upstates
	ends=find(diff(above)~=1);%find breaks between potential upstates
    ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
    ends(end+1)=length(above);%one of the ends comes at the last found point above baseline
    ends=sort(ends);
    lengths=diff(ends);%length of each potential upstate
    good=find(lengths>=mintime & lengths<=maxtime);%must be longer than 500ms but shorter than 15sec
    ends(1)=[];%lose the 0 added before
    e3=reshape(above(ends(good)),[length(good) 1]);
    l3=reshape(lengths(good)-1,[length(good) 1]);
    aboveperiods(:,2)=e3;%upstate ends according to the averaged reading
    aboveperiods(:,1)=e3-l3;%upstate beginnings according to averaged reading
else
    aboveperiods=[];
end

varargout{1}=aboveperiods;
if nargout==2;
    if isempty(aboveperiods);
        belowperiods = [];
    else
        stops=aboveperiods(:,2);
        stops(2:end+1,1)=stops;
        stops(1)=0;
        stops=stops+1;

        starts=aboveperiods(:,1);
        starts(end+1,1)=length(data)+1;
        starts=starts-1;

        belowperiods=cat(2,stops,starts);

        if belowperiods(1,2)<=belowperiods(1,1);
            belowperiods(1,:)=[];
        end
        if belowperiods(end,2)<=belowperiods(end,1);
            belowperiods(end,:)=[];
        end
    end

    varargout{2}=belowperiods;
end