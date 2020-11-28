function s = vertcat(a, b, varargin);
% Vertical concatenation of TS objects (overload of the [a; b] operator)
% 
%	USAGE:
%
%	s = vertcat(a, b)
% 
% 	INPUTS:
%
%  	a, b (and eventually as many other ts as needed): TS objects
%	 
% 	OUTPUTS:
%
%  	s: the concatenated TS object
%
% copyright (c) 2004 Francesco P. Battaglia
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html

  if length(varargin) > 0
    for i = 1:length(varargin)
      if ~isa(varargin{i}, 'tsd')
	error('all arguments must be tsd''s');
      end
    end
  end
  
  
  s = cat(a,b);
  
  if length(varargin) > 0
    for i = 1:length(varargin)
      s = cat(s, varargin{i});
    end
  end
  