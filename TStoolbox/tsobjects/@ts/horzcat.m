function s = horzcat(a, b, varargin)

% Horizontal concatenation of TSD objects (overload of the [a, b] operator)
% 
%	USAGE:
%
%	s = horzcat(a, b)
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

  
  if ~compatible_ts(a, b)
    error('timestamps mismatch');
  end
  
  
  if length(varargin) > 0
    for i = 1:length(varargin)
      if ~isa(varargin{i}, 'tsd')
	error('all arguments must be tsd''s');
      end
      if ~compatible_ts(a, varargin{i})
	error('timestamps mismatch');
      end
    end
  end  
  
  
  d = cat(2, a.data, b.data);
  
  if length(varargin) > 0
    for i = 1:length(varargin)
      dv = varargin{i};
      dv = dv.data;
      d = cat(2, d, dv );
    end
  end
  
  
  s = tsd(a.t, d);
  