% [ Lratio, ID, ISIindex ] = calcClusterQuality( clu, res, fet, clunum )
%
% pseudo-code (assumes all files were loaded)
%
% References:
% Fee 1996: ISIindex measure
% Schmitzer-Torbert 2005: Lratio, ID (Isolation Distance)

% 08-jan-12 Eran Stark

function [ Lratio, ID, ISIindex ] = calcClusterQuality( clu, res, fet, clunum )

ISI1 = 0.002;           % [sec] count number of ISIs smaller than 2 ms
ISI2 = 0.020;           % [sec] out of ISIs smaller than 20 ms
DT = 8;                 % [samples] detection dead time
Fs = 20000;             % [Hz]
CorrFactor = ( ISI2 - DT / Fs ) / ( ISI1 - DT / Fs );

Lratio = [];
ID = [];
ISIindex = [];

if nargin < 4 || isempty( clu ) || isempty( res ) || isempty( fet ) || isempty( clunum )
    error( 'empty' )
end
[ spkfets nfets ] = size( fet );
if ~isequal( spkfets, numel( clu ), numel( res ) )
    error( 'mismatch' )
end
if length( clunum ) ~= 1
    error( 'mismatch' )
end

idx = clu == clunum;
fet1 = fet( idx, : );
st = res( idx );
nspks = sum( idx );
if ~nspks
    return
end

if sum( idx ) > nfets
    dofet = 1;
else
    dofet = 0;
end
if dofet
    fidx = find( sum( fet1 ) ~= 0 );
    d2 = mahal( fet( ~idx, fidx ), fet1( :, fidx ) );
    if sum( ~idx ) > sum( idx )
        sd2 = sort( d2 );
        ID = sd2( sum( idx ) );
    else
        ID = NaN;
    end
    Lratio = sum( 1 - chi2cdf( d2, length( fidx ) ) ) / sum( idx );
else
    ID = NaN;
    Lratio = NaN;
end

dt = diff( st ) / Fs;
ISIindex = CorrFactor * sum( dt < ISI1 ) / sum( dt < ISI2 ); % observed vs. expected spikes below ISI1

return

% EOF