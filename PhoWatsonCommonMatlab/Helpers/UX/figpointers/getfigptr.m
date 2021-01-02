function p = getfigptr(fig)

% GETFIGPTR  Get figure pointer.
%   P = GETFIGPTR(FIG) returns a cell array of param/value pairs that
%   can be used to restore the pointer of the figure with figure handle
%   FIG.
%
%   Note : if the FIG argument is ommitted, the function gets the pointer
%          of the current figure.
%
%   See also SETFIGPTR, SWITCHFIGPTR. 

%   Author: Jérôme Briot, Aug 2005 
%   Revision:
%   Comments:
%       This is an enhancement of the GETPTR.M file.
%       (<MATLABROOT>\toolbox\matlab\uitools)
%       Author: T. Krauss, 4/96
%       Copyright 1984-2001 The MathWorks, Inc. 
%       $Revision: 1.8 $ 
%

error(nargchk(0, 1, nargin))

if nargin==0
    
    fig=gcf;
    
end

if strcmp(get(fig,'pointer'),'custom')

    p = {'pointershapecdata',get(fig,'pointershapecdata'),...
         'pointershapehotspot',get(fig,'pointershapehotspot'),...
         'pointer','custom'};
else
    
    p = {'pointer',get(fig,'pointer')};
    
end



