function FileStartStopsToStateEditorEvent(filebase)

if ~exist('filebase','var')
    choice = questdlg('No basename entered, use current directory name as file basename?','No Basename','Yes','Cancel','Yes');
    if strmatch(choice,'Cancel')
        return
    elseif strmatch(choice,'Yes')
         [pathstr, name, ext]=fileparts(cd);
         filebase = name;
    end
end

if FileExists([filebase, '-metaInfo.mat']);
    load([filebase, '-metaInfo.mat']);
else
    varargout = getDatAndVideoSessionInfo(filebase);
    metaInfo = varargout.metaInfo;
end

statefilename = [filebase '-states.mat'];
if FileExists(statefilename);
    load(statefilename,'states') %gives states, a vector of the state at each second
    if exist('events','var')
        maxevt = max(events(:,1));
    else
        events = [];
        maxevt = 0;
    end
else    
    events = [];
    maxevt = 0;
end

numnew = size(metaInfo.startTimeInSec,2);
for a = 1:numnew
    starts(a) = metaInfo.startTimeInSec{a};
end
events = cat(1,events,[(maxevt+1)+zeros(1,numnew)' starts']);

if exist('states','var') && exist('transitions','var')
    save(statefilename,'states','events','transitions')
elseif exist('states','var')
    save(statefilename,'states','events')
elseif exist('transitions','var')
    save(statefilename,'events','transitions')
else
    save(statefilename,'events')
end    

disp([statefilename ' modified to include file starts/stops as events'])
