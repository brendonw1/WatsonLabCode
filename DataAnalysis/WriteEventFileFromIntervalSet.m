function WriteEventFileFromIntervalSet (intervals,outputname)
% Makes a neuroscope-compatible event file (.evt) signifying start and stop
% times for "events" given in timestamps of ms
%
%INPUTS: 
% events: 2 column input matrix where column 1 is starttime for each event and column 2 is the stoptime of that event.  
% outputname: character string array with all characters for name of output, 
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

[starttimes, endtimes] = intervalSetToVectors(intervals);
WriteEventFileFromTwoColumnEvents([starttimes/10 endtimes/10],outputname)
