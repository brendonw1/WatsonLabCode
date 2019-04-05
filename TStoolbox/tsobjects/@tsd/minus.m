function s = minus(a,b)

%  Overload of the - operator
%  
%  	USAGE:
%  	s = minus(a,b) 
%  	%
%  	the - operator is defined to return a tsd with same timestamps and
%  	data that are the difference of the data. Returns error if timestamps of the
%  	two object don't coincide. One of the two operands may be a scalar


% copyright (c) 2004 Francesco P. Battaglia
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html

  if (isa(a, 'tsd') & isa(b, 'tsd'))

    if ~compatible_ts(a, b,eps)
      error('Timestamps mismatch')
    end
    
    
    s = tsd(a.t, a.data-b.data);
    
    
  elseif (isa(a, 'tsd') & isa(b, 'numeric'))
    if(prod(size(b))) ~= 1
      error('- operator defined for two tsd''s or for one tsd and one scalar');
    end
    
    s = tsd(a.t, a.data - b);
    
  elseif (isa(a, 'numeric') & isa(b, 'tsd'))
    if(prod(size(b))) ~= 1
      error('- operator defined for two tsd''s or for one tsd and one scalar');
    end
    
    s = tsd(b.t, a - b.data);
    
  else
    error('- operator defined for two tsd''s or for one tsd and one scalar');
  end
  