function WriteEventFileFromTwoColumnEvents (events,outputname)
% Makes a neuroscope-compatible event file (.evt) signifying start and stop
% times for "events" given in timestamps of ms
%
%INPUTS: 
% events: 2 column input matrix where column 1 is starttime for each event and column 2 is the stoptime of that event.  
% outputname: string array with all characters for name of output, 
%   * Note neuroscope likes a format of basename.xxx.evt where xxx is any three
% characters of your choice
%
% OUTPUTS: 
% outputname: file written to current directory (unless a full file path is
% given) with following format: (See neuroscope file formats page for info)
% timestampforevent1start 'on'
% timestampforevent1stop  'off'
% timestampforevent2start 'on'
% timestampforevent2stop 'on'
% etc...
%
% Brendon Watson 2012-4

ev = events';
ev = ev(1:end)';
for a = 1:length(ev);
    outputcell{a,1} = ev(a);
    if mod (a,2)==1;
        outputcell{a,2} = 'on';
    elseif mod(a,2)==0;
        outputcell{a,2} = 'off';
    end
    
end


[nrows,ncols]= size(outputcell);

if ~strcmp(outputname(end-3:end),'.evt')
    filename = [outputname,'.evt'];
else
    filename = outputname;
end

fid = fopen(filename, 'w');
for row=1:nrows
    fprintf(fid, '%d %s\n', outputcell{row,:});
end
fclose(fid);