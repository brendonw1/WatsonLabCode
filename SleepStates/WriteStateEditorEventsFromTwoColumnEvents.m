function WriteStateEditorEventsFromTwoColumnEvents(ev,filename)
% Makes a StateEditor-compatible event file signifying start and stop
% times for "events" given in timestamps of ms
%
%INPUTS: 
% events: 2 column input matrix where column 1 is starttime for each event and column 2 is the stoptime of that event.  
% outputname: string array with all characters for name of output, 
%
% OUTPUTS: 
% outputname: file written to current directory (unless a full file path is
% given) with following format: 
% Column 1: state type number (ie starts are #1, ends are #2)
% Column 2: timestamps in seconds
% Will be written as a .mat file, can be read with "l" command with
% StateEditor.  
% *Note this output file will contain blank "state" and "transitions"
% matrices, so load only events.
% Brendon Watson 2012-4

ev = ev';
ev = ev(1:end)';
events = [];
for a = 1:length(ev);
    events(a,2) = ev(a);
    if mod (a,2)==1;
        events(a,1) = 1;
    elseif mod(a,2)==0;
        events(a,1) = 2;
    end
end
% events = fliplr(events);

states = [];
transitions = [];

save(filename,'events','states','transitions');