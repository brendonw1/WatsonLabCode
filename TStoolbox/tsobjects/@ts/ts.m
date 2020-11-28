function tsa = ts(t, varargin)
% Constructor of TS object
% A TS object represents a time series of events. It is a subclass of tsd, with empty Data, reimplements only the Data
% function, for compatibility issues.
%
%  	USAGE
%  	ts = ts(t)
% 
%  	INPUTS:
%  	t: a sorted (in ascending order) vertical vector of timestamps
%
% note that in case of constructor called with no arguments, ts() returns a tsd with NaN timestamps,
%
% copyright (c) 2004 Francesco P. Battaglia
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html

if nargin == 0
   ts_tsd = tsd;
   
else
  ts_tsd = tsd(t, [], varargin{:}); 
end

tsa.type = 'ts';
  
tsa = class(tsa, 'ts', ts_tsd);

