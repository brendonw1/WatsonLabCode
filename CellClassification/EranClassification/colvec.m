% colvec            transforms into column vector/matrix
%
% x = colvec( x )
%
% if a vector, makes sure that a column vector
% higher-dimension arrays are not manipulated

% 03-mar-13 ES

function x = colvec( x )

sx = size( x );
if length( sx ) == 2 && sum( sx == 1 ) >= 1 && sx( 2 ) > 1
    x = x';
end
 
return

% EOF
