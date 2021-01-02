function switchfigptr(ptr,fig)

% SWITCHFIGPTR Switch figure pointer.
%   SWITCHFIGPTR(CURSOR_NAME,FIG) stores the current pointer of
%   the figure with handle FIG and replaces it with the pointer
%   CURSOR_NAME according to the Pointer_name list. 
%   Use SWITCHFIGPTR(FIG) to get the stored pointer back and to set 
%   it current. 
%  
%   Notes #1: if the FIG argument is ommitted, the function 
%            focus on the pointer of the current figure.
%   Notes #2: if the stored pointer is no more available (the figure
%            can be closed and re-opened), it sets figure pointer 
%            to {arrow} (default)
%
%   Pointer_name list :
%        'hand'    - open hand for panning indication
%        'hand1'   - open hand with a 1 on the back
%        'hand2'   - open hand with a 2 on the back
%        'closedhand' - closed hand
%        'glass'   - magnifying glass
%        'lrdrag'  - left/right drag cursor
%        'ldrag'   - left drag cursor
%        'rdrag'   - right drag cursor
%        'uddrag'  - up/down drag cursor
%        'udrag'   - up drag cursor
%        'ddrag'   - down drag cursor
%        'add'     - arrow with + sign
%        'addzero' - arrow with 'o'
%        'addpole' - arrow with 'x'
%        'eraser'  - eraser
%        'help'    - arrow with question mark ?
%        'zoomin'  - magnifying glass with +
%        'zoomout'  - magnifying glass with -
%        'matlabdoc' - exemple of custom made pointer from the Matlab doc.
%        'none'    - no pointer
%        [ crosshair | fullcrosshair | {arrow} | ibeam | watch | topl | topr ...
%        | botl | botr | left | top | right | bottom | circle | cross | fleur ]
%             - standard figure cursors
%
%   See also SETFIGPTR, GETFIGPTR. 

%   Author: Jérôme Briot, Aug 2005 
%   Revision #1: Aug 2006 - 4 new pointers added (zoomin,zoomout,matlabdoc,none)
%   Comments:

error(nargchk(0, 2, nargin))

try 
    
	if (nargin==0)  | (nargin==1 & ishandle(ptr))
        
        if ~exist('ptr')
            ptr=gcf;
        end
            
        p=getappdata(gcf,'sfp_currentpointer');
        set(ptr,p{:})
        rmappdata(gcf,'sfp_currentpointer');
        
	else
        
        if nargin==1
            fig=gcf;
        end
        
        p = getfigptr(fig);
        setappdata(fig,'sfp_currentpointer',p);
        setfigptr(ptr);
        
	end
    
catch set(ptr,'pointer','default'); 
            
end