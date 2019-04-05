function saveallfigsas(filetype)
% Saves all current figures to disk according to the "filetype" input.  
% The filename is taken from the 'name' field of the figure.  This function
% is a wrapper around "saveas", see doc for that matlab function for more
% details including about filetypes.  As of now the available filtypes are
% listed below.  
%
% ai Adobe® Illustrator `88Support for this
% format will be removed in a future release.
% bmp Windows® bitmap
% emf Enhanced metafile
% eps EPS Level 1 >> USES EPSWRITE.m
% fig MATLAB figure (invalid for Simulink® block
% diagrams)
% jpg JPEG image (invalid for Simulink block
% diagrams)
% m MATLAB file (invalid for Simulink block
% diagrams)
% pbm Portable bitmap
% pcx Paintbrush 24-bit
% pdf Portable Document Format
% pgm Portable Graymap
% png Portable Network Graphics
% ppm Portable Pixmap
% tif TIFF image, compressed
%
% B Watson 2013.

if nargin == 0;
    filetype = 'fig';
end

allfigs = findobj('Type','figure');
for a = 1:length(allfigs);
    h = allfigs(a);
    name = get(h,'Name');
    if isempty(name);
        name = ['Figure',num2str(a)];
    end
%     if strcmp(filetype,'eps') | strcmp(filetype,'.eps')
%         epswrite(h,name)
%     else
        saveas(h,name,filetype);
%     end
end