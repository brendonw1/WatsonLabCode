% classify_waveform         from peak spectrum and trough-peak time
%
% call [ wide pval ] = classify_waveform( xy, ft )
%
% xy is a two column vector:
%   first column peak frequency of the spike spectrum (Hz)
%   second column trough-peak time (ms)
%   both are for unfiltered waveforms
%   classification is by a linear separatrix
%
% alternatively, if ft = 0, then
%   first column is the trough-peak time (ms)
%   second column is the spike width (1/freq*1000)
%   then classification is by GMM and a p-value is assigned
%
% the two methods have about 99% correspondence
% 
% these parameters discriminate much better than half-width, asymmetry,
% rate, first moment of the ACH or any combination thereof
% see spike_stats.m for methods to compute these parameters from raw data
%
% wide is a logical vector, 1 for a "pyramidal" cell (wide waveform, long
% trough-to-peak time), 0 for an "interneuron" (narrow waveform, short
% peak-to-trough)
%
% NOTE: the separatrix were derived from mono-synaptic connectivity
% patterns in CX and CA1 of mice and rats and from light activation of PV
% cells in PV mice, but may not hold for other brain regions/species

% 25-jan-12 ES

% 25-may-13 GMM added

function [ wide pval fsep ] = classify_waveform( xy, ft )

if nargin < 1 || isempty( xy )
    wide = [];
    pval = [];
    return;
end
if nargin < 2 || isempty( ft )
    ft = 1;
end
ft = ft( 1 );
if size( xy, 2 ) ~= 2
    error( 'input size mismatch' )
end

if ft % frequency, trough-to-peak
    % linear separatrix
    xx = [ 600 1450 ];
    yy = [ 0.2 0.9 ];
    a = diff( yy ) / diff( xx ); 
    b = yy( 1 ) - a * xx( 1 );  % y = ax+b
    xint = -b/a; % x-intercept
    wide = atan( xy( :, 2 ) ./ ( xy( :, 1 ) - xint ) ) > atan( a );
    pval = NaN * ones( size( wide ) );
else % trough-to-peak, spike width by 1/f
    % GMM
    mixp =  [   0.14815     0.85185 ];
    mu =    [   0.328       0.90036
                0.6491      1.078 ];
    Sigma(:,:,1) = [
                0.0085982   0.0052262
                0.0052262   0.0056747 ];
    Sigma(:,:,2) = [
                0.0020751   0.0013943
                0.0013943   0.0049193 ];
            
    figure;   
    hold on;
    X = [mvnrnd(mu(1,:),Sigma(:,:,1),1000);mvnrnd(mu(2,:),Sigma(:,:,2),1000)];
    
    scatter(X(:,1),X(:,2),10,'.')
%     scatter(X(:,1),0.25*X(:,2),10,'.')
%     scatter(X(:,1),0.3*X(:,2),10,'.')
    plot(xy(:,1),xy(:,2),'.') 
    
    gm = gmdistribution( mu, Sigma, mixp );   
    p = posterior( gm, xy );
    [ ign cls ] = max( p, [], 2 );
    pval = min( p, [], 2 );
    %unc = pval > pTH;
    %cls( unc ) = 0;
    wide = cls == 2;
end

if nargout > 2
    if ft
        fsep = @(x,y) b + a*x - y;
    else
        K = 48.905;
        L = [   -335.3  117.01 ]';
        Q = [   166.3   36.272
                36.272  -72.892 ];
        fsep = @(x,y) K + L(1)*x + L(2)*y ...
            + Q(1,1)*x.^2 + (Q(1,2)+Q(2,1))*x.*y + Q(2,2)*y.^2;
    end
end

return

% EOF

% to actually plot the separatrix: 
xx = [ 0.1 0.9 ]; yy = [ 0.6 1.4 ];
fh = ezplot( fsep, [ xx yy ] ); 
set( fh, 'color', [ 0 0 0 ] );
title( '' )