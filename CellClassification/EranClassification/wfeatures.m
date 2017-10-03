% wfeatures         waveform features (half-width, temporal assymetry)
%
% [ hw, asy, tp, hwidx, hidx ] = wfeatures( x, plotflag )
%
% hw, asy, tp - half width, assymetry at half-height, trough-to-peak time
% asymetry is measured at half-amp (rather than at basline) to improve SNR 
%   assymetry is first part/second part, i.e. smaller than 1 means slow
%   repolarization (PYR)
% hwidx, hidx - indices for the various regions (for plotting purposes only) 
%
% works on raw waveform; can also work on band-pass filtered waveforms
%
% calls             fft_upsample, local_max

% 10-jan-12 ES

% revisions
% 17-jan-12 added trough-to-peak time measure
% 09-jun-12 changed format to support r2009b
% 15-jan-13 note: bug fix! tp was measured from trough to peak of all 
%           subsequent samples, but should have been measured to FIRST peak 
% 30-jan-13 extended to support positive waveforms.. (finalized on 20-may-13)

function [ hw, asy, tp, hwidx, hidx ] = wfeatures( x, plotflag )

nargs = nargin;
if nargs < 1 || isempty( x ), error( 'missing input' ), end
if ndims( x ) > 2, error( 'should have waveforms in columns' ), end
if size( x, 1 ) == 1, x = x( : ); end
if nargs < 2 || isempty( plotflag ), plotflag = 0; end
USF = 4;

% note - the upsampling occasionally introduces extra troughs/peaks
% (oscillations)... thus best to: (1) extend a few samples at each
% direction before (by mirroring); (2) smooth 3-point MA (but do not
% smooth the actual peak)
% nMA = 3;
% npad = 2;
% 
% n0 = size( x, 1 );
% win = ones( nMA, 1 ); 
% win = win / sum( win );
% xpad = [ x( npad : -1 : 1, : ); x; x( n0 - npad + 1 : n0, : ) ];
% idx1 = 1 : ( floor( n0/2 ) + npad );
% idx0 = floor( n0/2 ) + npad + 1;
% idx2 = ( floor( n0/2 ) + npad + 2 ) : ( n0 + 2 * npad );
% xpad = [ firfilt( xpad( idx1, : ), win ); xpad( idx0, : ); firfilt( xpad( idx2, : ), win ) ];
% xups = fft_upsample( xpad, USF );
% kidx = npad * USF + 1 : ( n0 + npad ) * USF;
% xups = xups( kidx, : );
% 
% not perfect because if leave trough unchanged, there is even more
% ringing. if trough is changed in amp, then the upsampling requirements
% are not preserved.. need to think a bit more, maybe linear interpolation
% with edge expansion (mirroring?

x = fft_upsample( x, USF ); % upsample

[ n m ] = size( x ); % number of samples for baseline estimation
bvals = mean( x( 1 : floor( n / 3 ), : ), 1 ); % baseline
[ tvals ttimes ] = min( x ); % trough
oidx = ttimes >  2 * n / 3 | ttimes < n / 3;
if sum( oidx )
    oidx = find( oidx );
    for i = oidx
        xcenter = x( floor( n / 3 ) : ceil( 2 * n / 3 ), i ); 
        [ ign tim ] = max( abs( xcenter ) );
        ttimes( i ) = tim + floor( n / 3 ) - 1;
        tvals( i ) = x( ttimes( i ), i );
    end
end
hamps = ( tvals + bvals ) / 2; % half amp

if m > 1 && length( unique( ttimes ) ) == 1 && sum( hamps < 0 ) == m % simultaneous troughs
    ttime = ttimes( 1 );
    % (1) half width
    cv1 = cumsum( bsxfun( @gt, x, hamps ) );
    hw = sum( bsxfun( @eq, cv1, cv1( ttime, : ) ) ) - 1;
    % (2) assymetry:
    %cv2 = cumsum( bsxfun( @gt, x, bvals ) );
    cv2 = cumsum( bsxfun( @gt, x, hamps ) );
    h1 = sum( bsxfun( @eq, cv2( 1 : ttime - 1, : ), cv2( ttime, : ) ) ) - 1;
    h2 = sum( bsxfun( @eq, cv2( ttime + 1 : n, : ), cv2( ttime, : ) ) );
    asy = h1 ./ h2;
    % (3) trough-to-peak
    mt = local_max( x( ttime : n, : ) ); 
    tp = zeros( m, 1 );
    for i = 1 : m
        tp( i ) = mt( find( mt( :, 2 ) == i, 1 ), 1 );
    end
    %[ ign, tp ] = max( x( ttime : n, : ) );
    if plotflag
        hwidx = bsxfun( @eq, cv1, cv1( ttime, : ) );
        h1idx = bsxfun( @eq, cv2( 1 : ttime - 1, : ), cv2( ttime, : ) );
        h2idx = bsxfun( @eq, cv2( ttime + 1 : n, : ), cv2( ttime, : ) );
        for i = 1 : m
            hwidx( find( hwidx( :, i ), 1 ), i ) = 0;
            h1idx( find( h1idx( :, i ), 1 ), i ) = 0;
        end
        hidx = [ h1idx; 2 * ones( 1, m ); 3 * h2idx ];
    end
else % distinct (can be induced by upsampling)
    hw = zeros( m, 1 );
    h1 = hw;
    h2 = hw;
    tp = hw;
    for i = 1 : m
        ttime = ttimes( i );
        if hamps( i ) < 0
            v = x( :, i ) > hamps( i );
            cv1 = cumsum( v );
            hw( i ) = sum( cv1 == cv1( ttime ) ) - 1;
            %v = x( :, i ) > bvals( i );
            %v = x( :, i ) > hamps( i );
        else
            v = x( :, i ) < hamps( i );
            cv1 = cumsum( v );
            hw( i ) = sum( cv1 == cv1( ttime ) ) - 1;
            %v = x( :, i ) < hamps( i );
        end
        cv2 = cumsum( v ); 
        h1( i ) = sum( cv2( 1 : ttime - 1 ) == cv2( ttime ) ) - 1; 
        h2( i ) = sum( cv2( ttime + 1 : n ) == cv2( ttime ) ); 
        %[ ign, tp( i ) ] = max( x( ttime : n, i ) );
        if hamps( i ) < 0
            mt = local_max( x( ttime : n, i ) ); 
        else
            mt = local_max( x( ttime : n, i ), 'min' ); 
        end
        if isempty( mt )
            if hamps( i ) < 0
                [ ign, tp( i ) ] = max( x( ttime : n, i ) );
            else
                [ ign, tp( i ) ] = min( x( ttime : n, i ) );
            end
        else
            tp( i ) = mt( 1 );
        end
        if plotflag
            hwidx( :, i ) = cv1 == cv1( ttime );
            hwidx( find( hwidx( :, i ), 1 ), i ) = 0;
            h1idx = cv2( 1 : ttime - 1 ) == cv2( ttime );
            h1idx( find( h1idx , 1 ) ) = 0;
            h2idx = cv2( ttime + 1 : n ) == cv2( ttime );
            hidx( :, i ) = [ h1idx; 2; 3 * h2idx ];
        end
    end
    asy = h1 ./ h2;
end
hw = hw( : ) / USF; 
tp = tp / USF;
asy = asy( : );

% plot
if plotflag
    newplot
    if m <= 2
        for i = 1 : m
            if m > 1
                subplot( 2, 2, 2 + i )
            end
            x1 = x( :, i );
            line( ( 1 : n ) / USF, x1, 'color','k', 'linewidth', 2 );
            separators( [ bvals( i ) hamps( i ) tvals( i ) ], [], [], 'y' );
            separators( ttimes( i ) / USF, [], [], 'x' );
            separators( ttimes( i ) / USF + tp( i ), [], [], 'x' );
            line( find( hwidx( :, i )  ) / USF, hamps( i ) * ones( 1, sum( hwidx( :, i ) ) ), 'color', [ 1 0 0 ], 'linewidth', 2 );
            %line( find( hidx( :, i ) == 1 ), bvals( i ) * ones( 1, sum( hidx( :, i ) == 1 ) ), 'color', [ 0 0 1 ], 'linewidth', 2 );
            %line( find( hidx( :, i ) == 3 ), bvals( i ) * ones( 1, sum( hidx( :, i ) == 3 ) ), 'color', [ 0 0.7 0 ], 'linewidth', 2 );
            line( find( hidx( :, i ) == 1 ) / USF, hamps( i ) * ones( 1, sum( hidx( :, i ) == 1 ) ), 'color', [ 0 0 1 ], 'linewidth', 2 );
            line( find( hidx( :, i ) == 3 ) / USF, hamps( i ) * ones( 1, sum( hidx( :, i ) == 3 ) ), 'color', [ 0 0.7 0 ], 'linewidth', 2 );
            xlim( [ 1 n ] / USF )
        end
    end
    if m > 1
        subplot( 2, 2, 1 )
        plot( asy, hw, 'o' )
        xlabel( 'Assymetry' )
        ylabel( 'Half width (samples)' )
        subplot( 2, 2, 2 )
        plot( tp, hw, 'o' )
        xlabel( 'Trough-peak' )
        ylabel( 'Half width (samples)' )
    end
end

return

figure
i = 1;
clf
x1 = x( :, i );
plot( 1 : n, x1, '-k' );
separators( [ bvals( i ) hamps( i ) tvals( i ) ], [], [], 'y' );
separators( ttimes( i ), [], [], 'x' );
line( find( hwidx( :, i )  ), hamps( i ) * ones( 1, sum( hwidx( :, i ) ) ), 'color', [ 1 0 0 ], 'linewidth', 2 );
line( find( hidx( :, i ) == 1 ), bvals( i ) * ones( 1, sum( hidx( :, i ) == 1 ) ), 'color', [ 0 0 1 ], 'linewidth', 2 );
line( find( hidx( :, i ) == 3 ), bvals( i ) * ones( 1, sum( hidx( :, i ) == 3 ) ), 'color', [ 0 0.7 0 ], 'linewidth', 2 );


