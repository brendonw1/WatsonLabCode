
% spikes_stats        waveforms, ACH, and spectra
%
% [ out ] = spikes_stats( filebase, shanknums, clunums, clustr, plotflag, Overwrite, periods )
%
% filebase          full path
% shanknums         any subset; defaults to all
% clunums           any subset; LoadCluRes format
% clustr            {'clc'}, 'clu' etc
% plotflag          {1} to plot (separate figure for each clu and summary for features)
% Overwrite         {0} to load w/o computing if previously computed; 1 to recompute and overwrite; -1 to just recompute 
% periods           {-1}. periods (in samples) to keep spikes from. overloaded: 
%                   -1 indicates to remove spikes during segments specified in val files; 
%                   -XX indicates to remove only during segments in val.tXX (can be a vector for multiple triggers).
%                   right now the combination of the two is not suppported (i.e. keep spikes in certain periods but not during
%                   stimulation etc). also not relevant for merged files 

% does              loads spikes and times, computes center of mass,
%                   spectrum and waveform features of peak waveform, and
%                   various timing statistics
%
% calls             LoadPar, LoadCluRes, readspk, my_spectrum, calc_cor,
%                   bincch, plot_spk_waveforms, calc_com, wfeatures
%
% see also          compute_cluster_quality, plot_ss

% 08-jan-12 ES

% revisions
% 16-jan-12 cluster quality measures added
% 17-jan-12 cell type measures added
% 24-jan-12 modifications in Overwrite
% 25-jan-12 waveform classification into PYR/IN added
% 30-jan-12 periods argument added (supports periods/trigger time removal)
%           freqs field filled (to support plot_ss)
% 28-feb-12 saves if overwrite or no sst file; skip if no spikes (assign
%           zero to all
% 08-jun-12 (1) changed algorithm to block-wise permitting structure for
%           handling huge *.spk.* files
%           (2) changed format to support r2009b
%           (3) handled case of no spikes at all
% 10-jun-12 (1) FET handling improved - single; blockwise mahal
% 06-sep-13 (1) p2pvoltage from xml file
% 29-sep-13 (1) reorder channels according to par channel (optional)

% to do:
% (1) add functionality to plot data for one (or more) clusters without
% loading anything - just using the saved sst file
% (2) add functionality to plot the cluster statistics along with all of
% the significantly modulated CCHs for that cluster
% (3) make the filebase independent of params

% 25-feb-13:
% idea - should actually assign a p-value to each classification based on
% the distance from the separatrix

% problems:
% (1) bursting cells clustered as 2 distinct clusters - can cause the first
% cluster to seem inh+exc (e.g. es25nov11_3 1.34->1.27)
% (2) FS IN: sometime form a synchronized network, then there are peaks in
% the CCHs (e.g. es26nov11_3: 2.12;3.17->1.11;3.6=42;65->10,54) that not
% always stradle zero-lag, so the cells may seem mixed or even purely exc
% (e.g. 
%
% (*) if this is a merged file, cluster statistics will be biased by
% spikes from within triggers (right now the removal is file-specific)

function [ sst, fig ] = spikes_stats( filebase, varargin )

verbose = 1;
%doFET0 = 1;
%blockwise = 0;

%-------------------- constants  --------------------%
padbuffer = [ -0.01 0.01 ]; % [sec]
%p2pvoltage = 8;         % amplitude scaling
minCluToKeep = 2;       % remove artefacts, noise
wintype = 'hanning';    % spectrum
nfft = 1024;            % spectrum

MAXLAG = 0.050;         % ACH
CCHBS = 0.001;          % ACH

ISI1 = 0.002;           % (sec) count number of ISIs smaller than 2 ms
ISI2 = 0.020;           % (sec) out of ISIs smaller than 20 ms
DT = 8;                 % (samples) detection dead time

nbins = 100;            % for firing rate stationarity analysis

BLOCKSIZE = 10 * 2^20;  % bytes/block; use 10 MB blocks
precision0 = 'int16';   % parameters for block-wise loading of data
precision1 = 'single';

BARCOLOR = [ 0 0 0 ];
CALIBWIDTH = 2;
CALIBCOLOR = [ 0 0.7 0 ];
ntoplot = 100;          % waveform plot
color = [ 0.7 0.7 1 ];  % waveform plot
colorrand = [ 1 0 0 ];  % white noise spectrum plot
LW = 2;                 % plots
mcolor = zeros( 1, 3 );
mcolor( color == max( color ) ) = 1;

%-------------------- par, clu, res  --------------------%
% load/save
if isa( filebase, 'cell' ) && length( filebase ) == 2
    adate = filebase{ 1 };
    fnum = filebase{ 2 };
    params = get_date_parameters( adate );
    par = params.par;
    if fnum > 0
        mfname = sprintf( '%s%s.%s', params.fileprefix, params.date, num3str( fnum ) );
    else
        if isa( params.merged, 'char' )
            mfname = params.merged;
        else
            mfnums = setdiff( unique( params.merged( :, 2 ) ), 0 );
            if sum( mfnums == -fnum )
                mfname = sprintf( '%s%s_%d', params.fileprefix, params.date, -fnum );
            end
        end
    end
    filebase = sprintf( '%s/%s/dat/%s/%s', params.drive, params.date, mfname, mfname );
end
if ~exist( filebase, 'file' ) && ~exist( fileparts( filebase ), 'dir' )
    error( 'missing filebase' )
end
[ shanknums, clunums, clustr, plotflag, Overwrite, periods, blockwise, byPar, doFET ] = DefaultArgs( varargin...
    ,{ [], [], 'clc', 0, 0, -1, 1, 0, 1 } );
SaveFn = [ filebase '.sst' ];
if ~Overwrite && FileExists( SaveFn )% && nargout > 0
    if verbose
        fprintf( 1, '%s: Loading %s\n', upper( mfilename ), SaveFn )
    end
    load(SaveFn,'-MAT');
    fig = NaN;
    return
end
par = LoadPar( sprintf( '%s.xml', filebase ) );
if isempty( shanknums )
    shanknums = 1 : par.nElecGps;
end
nchans_all = zeros( 1, length( shanknums ) );
for si = shanknums
    nchans_all( si ) = length( par.SpkGrps( si ).Channels );
end
nsamples = par.SpkGrps( 1 ).nSamples;
Fs = par.SampleRate;
p2pvoltage = par.VoltageRange;
CorrFactor = ( ISI2 - DT / Fs ) / ( ISI1 - DT / Fs );
scalefactor = 1 / 2^par.nBits * p2pvoltage * 1e6 / par.Amplification; % a2d units -> microVolts
switch wintype
    case 'hanning'
        win = hanning( nsamples );
    case 'rect'
        win = ones( nsamples, 1 );
    case 'hamming'
        win = hamming( nsamples );
end
if ~isa( clustr, 'char' ), error( 'input type mismatch: CLUSTR' ), end

% clu and res files (with the 0,1 clusters to ensure matching with the spk files)
[ Res Clu Map ] = LoadCluRes( filebase, shanknums, clunums, clustr, 0 );
if isempty( Res ) || sum( ismember( Clu, Map( Map( :, 3 ) >= minCluToKeep, 1 ) ) ) == 0
    fprintf( 1, 'No relevant spikes in %s, shanks %s\n', filebase, num2str( shanknums ) )
    sst = [];
    return
end
uclu = unique( Clu );

% select spikes
if periods( 1 ) < 0
    % remove spikes during stimulation
    [ Vals Trigs ] = LoadVals( filebase ); % load all val files
    if periods == -1 % any trigger
        tidx = true( size( Trigs ) );
    else % specific subsetclassify_waveform
        tidx = ismember( Trigs, abs( periods ) );
    end
    if ~isempty( tidx )
        uvals = dilutesegments( Vals( tidx, 1 : 2 ), 0, max( abs( padbuffer ) ) * Fs );
        uvals = uvals + ones( size( uvals, 1 ), 1 ) * [ floor( padbuffer( 1 ) * Fs ) ceil( padbuffer( 2 ) * Fs ) ];
        %uvals = uniteranges( Vals( tidx, 1 : 2 ) ); % combine all the segments
    else
        uvals = [];
    end
end

% set up the block-wise loading of spiking
% build the type casting string
precision = sprintf( '%s=>%s', precision0, precision1 );
% determine number of bytes/sample
a0 = ones( 1, 1, precision0 );
a1 = ones( 1, 1, precision1 );
sourceinfo = whos( 'a0' );
targetinfo = whos( 'a1' );
nbytes0 = sourceinfo.bytes;
nbytes1 = targetinfo.bytes;

% bins for stationarity analysis
fbin = round( ( max( Res ) - min( Res ) ) / ( nbins + 1 ) );
edges = min( Res ) : fbin : max( Res );
edges = edges( [ 1 : nbins; 2 : nbins + 1 ] )';
edges( nbins, 2 ) = edges( nbins, 2 ) + 1;

% initiliaze loop
sst.filebase = filebase;
shankclu = Map( :, 2 : 3 );
shankclu( shankclu( :, 2 ) < minCluToKeep, : ) = [];
sst.shankclu = shankclu;
sst.Tsec = ( max( Res ) - min( Res ) ) / Fs;
sst.freqs = [];
%nclus = length( uclu );
nclus = size( shankclu, 1 );
z = zeros( nclus, 1 );
sst.nspks = z; 
sst.mean = cell( nclus, 1 );
sst.sd = cell( nclus, 1 );
sst.spec = single( zeros( nfft / 2, nclus ) );
sst.ach = zeros( MAXLAG/CCHBS*2+1, nclus );
sst.max = single( zeros( nsamples, nclus ) );
sst.frateb = zeros( nbins, nclus );
sst.maxp2p = z;
sst.fmax = z;
sst.geo_com = single( z );
sst.snr = single( z );
sst.ID = z;
sst.Lratio = z;
sst.frate = z;
sst.ISIindex = z;
sst.ISIratio = z;
sst.ach_com = z;
sst.hw = z;
sst.tp = z;
sst.asy = z;
sst.pyr = ~true( nclus, 1 );


% go over shanks
i = 0;
ushanks = unique( Map( uclu, 2 ) )';
for shanknum = ushanks
    
    %-------------------- allocate shank-specific - clu, res, fet, spk indices--------------------%
    % determine the clu numbers to analyze from this shank
    shankclus = Map( Map( :, 2 ) == shanknum, 3 );
    shankclus = shankclus( shankclus >= minCluToKeep );
    shankclus = shankclus( : )';
    % general parameters
    nchans = nchans_all( shanknum );
    fprintf( 1, 'loading %s, shank %d, ', filebase, shanknum )
    if byPar
        ridx = resort( par.SpkGrps( shanknum ).Channels  );% reorder according to par file order
    else
        ridx = 1 : length( par.SpkGrps( shanknum ).Channels );
        %ridx = 1 : nchans_all( shanknum );
    end
    sourcefile = sprintf( '%s.spk.%d', filebase, shanknum );    
    if blockwise
        % determine number of spikes in the file
        spksize = nchans * nsamples * nbytes0;
        s = dir( sourcefile );
        spksource = s.bytes / spksize;
    else
        % load the entire file at once:
        spks = readspk( sprintf( '%s.spk.%d', filebase, shanknum ), nchans, nsamples );
        spksource = size( spks, 3 );
        spks = spks( ridx, :, : );
    end    
    fprintf( 1, '%d spikes', spksource )
    % keep the relevant (shank-specific) clu/res
    idx = ismember( Clu, Map( Map( :, 2 ) == shanknum, 1 ) );
    clu = Clu( idx );
    res = Res( idx );
    % if clu is a partial list, must load to match spks
    if spksource ~= size( clu, 1 )
        idxMap = 0;
        clu = LoadClu( sprintf( '%s.%s.%d', filebase, clustr, shanknum ) );
        res = LoadRes( sprintf( '%s.%s.%d', filebase, 'res', shanknum ) );
    else
        idxMap = 1;
    end
    % load the FET files
    if doFET
        fets = LoadFet( sprintf( '%s.fet.%d', filebase, shanknum ) );
        fets( :, size( fets, 2 ) + [ -4 : 0 ] ) = [];             % remove non-PCA features
        fets = single( fets ); % actually int16
    end
    % decide which spikes to keep:
    kidx = ~ismember( clu, 0 );%clu ~= 0; % remove 0 clusters (keep noise for fet)
    if periods( 1 ) < 0 && ~isempty( uvals )
        % remove any spike that is in any segment defined by a val file
        kidx( inranges( res, uvals ) ) = 0;
    elseif ~isempty( periods ) && size( periods, 2 ) == 2
        % alternatively, keep only spikes during specified periods
        gidx = false( size( kidx ) );
        gidx( inranges( res, periods ) ) = 1;
        kidx = kidx & gidx; % logical
        %kidx = union( find( kidx ), inranges( res, periods ) );
    end
    % actually dilute the clu/res/fet files
    res = res( kidx );
    clu = clu( kidx );
    if doFET
        fets = fets( kidx, : );
    end
    if ~blockwise
        spks = spks( :, :, kidx );
    end
    % now we have the clu, res, fet, and the indices of the proper spikes
    
    %-------------------- waveform analyses (blockwise) --------------------%
    if blockwise
        fkidx = find( kidx );
        % divide into blocks
        spkblk = floor( BLOCKSIZE / ( nchans * nsamples * nbytes1 ) ); % number of spikes/block in RAM
        nblocks = ceil( spksource / spkblk );
        blocks = [ 1 : spkblk : spkblk * nblocks; spkblk : spkblk : spkblk * nblocks ]';
        blocks( nblocks, 2 ) = spksource;
        fprintf( 1, '; %d blocks; Block number ', nblocks )
        % initialize variables for accumulation
        nclusShank = length( shankclus );
        nspks_CLU = zeros( 1, nclusShank );
        mspks_SUM = single( zeros( nchans, nsamples, nclusShank ) );
        mspks_SSQ = single( zeros( nchans, nsamples, nclusShank ) );
        spec_SUM = single( zeros( nfft / 2, nchans, nclusShank ) );
        snr_SUM = zeros( nchans, nclusShank );
        % open file for reading
        fp = fopen( sourcefile, 'r' );
        if fp == -1, error( 'fopen error' ), end
        % go over blocks
        for bidx = 1 : nblocks
            fprintf( 1, '%d ', bidx )
            nspkBlock = blocks( bidx, 2 ) - blocks( bidx, 1 ) + 1;
            startpos = ( blocks( bidx, 1 ) - 1 ) * spksize;
            datasize = [ nchans nsamples * nspkBlock ];
            rc = fseek( fp, startpos, 'bof' );
            if rc, error( 'fseek error' ), end
            spks = fread( fp, datasize, precision );
            % organize output
            spks = reshape( spks, [ nchans nsamples nspkBlock ] );
            % select subset of spikes and their corresponding labels
            spks = spks( :, :, kidx( blocks( bidx, 1 ) : blocks( bidx, 2 ) ) );
            % reorder spikes according to par file
            spks = spks( ridx, :, : );
            cluBlock = clu( find( fkidx >= blocks( bidx, 1 ), 1 ) : find( fkidx <= blocks( bidx, 2 ), 1, 'last' ) );
            % go over clusters and accumulate statistics
            ci = 0;
            for clunum = shankclus
                ci = ci + 1;
                if idxMap
                    idx = cluBlock == find( ismember( Map( :, 2 : 3 ), [ shanknum clunum ], 'rows' ) );
                else
                    idx = cluBlock == clunum;
                end
                nspks_CLU( ci ) = nspks_CLU( ci ) + sum( idx );
                if ~sum( idx )
                    continue
                end
                spk = spks( :, :, idx );
                % spike amplitude (average, then p2p)
                mspks_SUM( :, :, ci ) = mspks_SUM( :, :, ci ) + sum( spk, 3 ) * scalefactor;
                mspks_SSQ( :, :, ci ) = mspks_SSQ( :, :, ci ) + ( sum( spk .^ 2, 3 ) ) * scalefactor^2;
                for chan = 1 : nchans
                    % spectrum (per spike, per chan)
                    wav = squeeze( spk( chan, :, : ) ) * scalefactor;
                    [ pow2 f ] = my_spectrum( wav, nfft, Fs, win, 0, 0 );
                    spec_SUM( :, chan, ci ) = spec_SUM( :, chan, ci ) + sum( pow2( 2 : end, : ), 2 );
                    % mean spike snr (per spike, per chan)
                    snr_SUM( chan, ci ) = snr_SUM( chan, ci ) + sum( calc_spk_snrs( shiftdim( spk( chan, :, : ), 1 ) ) );
                end
            end
        end
        % close file
        fclose( fp );
    end
    fprintf( 1, '\n' )
    
    %-------------------- other statistics --------------------% 
    ci = 0;
    for clunum = shankclus
        ci = ci + 1; % in-shank counter
        i = i + 1; % global counter
        ri = find( ismember( Map( :, 2 : 3 ), [ shanknum clunum ], 'rows' ) ); % index in map
        %-------------------- allocate unit-specific  --------------------%
        if idxMap
            idx = clu == ri;
        else
            idx = clu == clunum;
        end
        nspks = sum( idx );       
        st = res( idx );
        if verbose
            fprintf( 1, 'computing for %d.%d (%d)', shanknum, clunum, nspks )
        end
        if ~nspks
            fprintf( 1, '\n' )
            continue
        end
        
        % summarize/compute waveform statistics for that cluster
        if blockwise
            % divide the accumulated statistics by the number of spikes in that cluster
            % spike amplitude (average, then p2p)
            mspk = mspks_SUM( :, :, ci ) / nspks_CLU( ci );
            sspk = sqrt( mspks_SSQ( :, :, ci ) / nspks_CLU( ci ) - mspk .^ 2 ); %SD = sqrt( <x^2> - <x>^2 );
            p2p = max( mspk, [], 2 ) - min( mspk, [], 2 );
            [ maxp2p, chan ] = max( p2p );
            % spectrum (per spike, on the largest amplitude channel, then average)
            mp = spec_SUM( :, chan, ci ) / nspks_CLU( ci );
            [ ign, midx ] = max( mp );
            fmax = f( midx ); % peak of spectrum
            % mean spike snr (per spike, then average; for the peak amp channel only)
            snr = snr_SUM( chan, ci ) / nspks_CLU( ci );
        else
            spk = spks( :, :, idx );
            % spike amplitude (average, then p2p)
            mspk = mean( spk, 3 ) * scalefactor;
            sspk = std( spk, [], 3 ) * scalefactor;
            p2p = max( mspk, [], 2 ) - min( mspk, [], 2 );
            [ maxp2p, chan ] = max( p2p );
            % spectrum (per spike, on the largest amplitude channel, then average)
            wav = squeeze( spk( chan, :, : ) ) * scalefactor;
            [ pow2 f ] = my_spectrum( wav, nfft, Fs, win, 0, 0 );
            mp = mean( pow2( 2 : end, : ), 2 );
            [ ign, midx ] = max( mp );
            fmax = f( midx ); % peak of spectrum
            % mean spike snr (per spike, then average)
            snr = mean( calc_spk_snrs( shiftdim( spk( chan, :, : ), 1 ) ) );
        end        
        % spike COM
        geo_com = calc_com( 1 : nchans_all( shanknum ), sum( mspk.^2, 2 ) );
        
        % morphological isolation
        dofet = 0;
        if doFET
            [ spkfets nfets ] = size( fets );
            fet = fets( idx, : );
            if sum( idx ) > nfets
                dofet = 1;
            end
        end
        if dofet
            fidx = find( sum( fet ) ~= 0 );
            if blockwise
                spkblk = floor( BLOCKSIZE / ( nfets * nbytes1 ) ); % number of spikes/block in RAM
                nblocks = ceil( spkfets / spkblk );
                blocks = [ 1 : spkblk : spkblk * nblocks; spkblk : spkblk : spkblk * nblocks ]';
                blocks( nblocks, 2 ) = spkfets;
                fprintf( 1, '; %d FET blocks; Block number ', nblocks )
                d2 = zeros( spkfets - sum( idx ), 1 );
                e0 = 0;
                for bidx = 1 : nblocks
                    fprintf( 1, '%d ', bidx )
                    lidx = false( spkfets, 1 );
                    lidx( blocks( bidx, 1 ) : blocks( bidx, 2 ) ) = 1;
                    lidx( idx ) = 0;
                    d2( e0 + [ 1 : sum( lidx ) ] ) = mahal( fets( lidx, fidx ), fet( :, fidx ) );
                    e0 = e0 + sum( lidx );
                end
            else
                d2 = mahal( fets( ~idx, fidx ), fet( :, fidx ) );
            end
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
        
        % compute timing statistics
        % ACH parameters
        [ cch cchbins ] = CCG( st, ones( size( st ) ), CCHBS * Fs, MAXLAG / CCHBS, Fs, [1], 'hz' );
        % firing rate
        frate = nspks / ( [ st( end ) - st( 1 ) ] / Fs );
        % ISI paramters
        dt = diff( st ) / Fs;
        ISIindex = CorrFactor * sum( dt < ISI1 ) / sum( dt < ISI2 ); % observed vs. expected spikes below ISI1
        ISIratio = sum( dt < ISI1 ) / ( nspks - 1 ); % fraction of ISIs below ISI1
        
        % time-resolved firing rate:
        frateb = zeros( nbins, 1 );
        for j = 1 : nbins
            frateb( j, : ) = sum( st >= edges( j, 1 ) & st < edges( j, 2 ) ) / fbin * Fs;
        end
        
        %-------------------- plot  --------------------%
        if plotflag
            fig( i ) = figure;
            
            % plot all waveforms (scaled)
            subplot( 1, 3, 1 )
            plot_spk_waveforms( spk, ntoplot, color, 1, scalefactor, [ 1 1 0 ] );
            title( sprintf( 's%d.c%d waveforms', shanknum, clunum ) )
            ylabel( 'Amplitude ({\mu}V)' ), xlabel( 'Time (ms)' )
            lh = line( [ -0.5 -0.5 -0.25 ], [ -50 -100 -100 ] ); % 0.25 ms/50 uV calibration
            set( lh, 'color', CALIBCOLOR, 'linewidth', CALIBWIDTH )
            axis off
            
            % plot mean waveform for peak channel
            subplot( 2, 3, 2 )
            if 0
                t = [ -nsamples / 2 : ( nsamples / 2 - 1 ) ] / Fs * 1e3; % ms
                line( t, mspk( chan, : ), 'LineWidth', LW );
                xlabel( 'Time (ms)' )
                set( gca, 'xlim', t( [ 1 end ] ) )
                lh = line( [ -0.5 -0.5 -0.25 ], [ -50 -100 -100 ] );
            else
                wfeatures( mspk( chan, : )', plotflag );
                xlabel( 'Time (samples)' )
                lh = line( nsamples * [ 0.25 0.25 0.5 ], [ -25 -75 -75 ] );
            end
            set( lh, 'color', CALIBCOLOR, 'linewidth', CALIBWIDTH )
            ylabel( 'Amplitude ({\mu}V)' ),
            title( sprintf( 'Channel %d waveform', chan ) )
            
            % plot spectrum for that channel
            subplot( 2, 3, 5 )
            line( f( 2 : end ), mp, 'color', mcolor, 'Linewidth', LW );
            set( gca, 'xscale', 'log', 'xlim', [ 10 Fs/2 ] );
            ylabel( 'Power ({\mu}V^2)' ), xlabel( 'Frequency (Hz)' )
            title( sprintf( 'Spectrum; peak at %d Hz', round( f( midx ) ) ) )
            
            % overlay spectrum of white noise
            gnoise = normrnd( 0, 1, nsamples, nspks );
            powrand = mean( my_spectrum( gnoise, nfft, Fs, win, 0, 0 ), 2 );
            line( f( 2 : end ), powrand( 2 : end ) / max( powrand ) * diff( ylim )...
                , 'color', colorrand, 'LineStyle', '--', 'LineWidth', LW );
            
            % plot ACH
            subplot( 2, 3, 3 );
            cchbins = [ fliplr( -CCHBS : -CCHBS : -MAXLAG )  0 : CCHBS : MAXLAG ];
            cchbins = cchbins * 1000; % ms
            bh = bar( cchbins, cch, 1 );
            xlim( cchbins( [ 1 end ] ) - diff( cchbins( 1 : 2 ) ) * [ -1 1 ] )
            ylims = [ 0 max( max( cch ), 1 ) * 1.2 ];
            ylim( ylims )
            set( bh, 'EdgeColor', BARCOLOR, 'FaceColor', BARCOLOR )
            ylabel( 'Spikes/s' )
            xlabel( 'Time (ms)' )
            set( gca, 'box', 'off', 'tickdir', 'out' )
            lh = line( [ -25 -15 ], mean( ylims ) * [ 1 1 ] ); % 10 ms calibration
            set( lh, 'color', CALIBCOLOR, 'linewidth', CALIBWIDTH )
            axis off
            title( sprintf( '%0.3g spikes/s', frate ) )
            
        end
        
        %-------------------- summarize --------------------%
        sst.nspks( i, : ) = nspks;
        sst.mean{ i, : } = mspk; % all mean waveforms
        sst.sd{ i, : } = sspk; % all SD waveforms
        sst.spec( :, i ) = mp;
        sst.ach( :, i ) = cch;
        
        sst.max( :, i ) = mspk( chan, : )'; % channel with peak
        sst.frateb( :, i ) = frateb;
        
        sst.maxp2p( i, : ) = maxp2p/1e3;    % max P2P (milliVolts)
        sst.fmax( i, : ) = fmax;            % peak spectrum (max P2P chan)
        sst.geo_com( i, : ) = geo_com;      % geometric COM
        sst.snr( i, : ) = snr;              % mean snr (max P2P chan)
        sst.ID( i, : ) = ID;                % Isolation distance
        sst.Lratio( i, : ) = Lratio;        % L-ratio
        sst.frate( i, : ) = frate;          % mean firing rate
        sst.ISIindex( i, : ) = ISIindex;    % ISI index (observed/expected)
        sst.ISIratio( i, : ) = ISIratio;    % ISI ratio (observed/total)

        fprintf( 1, '\n' )
        
    end % clunum
    
end % shanknum
%[ sst.shankclu sst.maxp2p sst.snr sst.ISIidx sst.ID sst.Lratio sst.ISIratio ]

% compute other statistics
ach_com = calc_com( [ 0 : 1 : round( MAXLAG / CCHBS ) ], sst.ach( round( MAXLAG / CCHBS ) + 1 : end, : ) );
if plotflag
    fig( i + 1 ) = figure;
end
[ hw asy tp ] = wfeatures( sst.max, plotflag );
hw = hw / Fs * 1000; % ms
tp = tp / Fs * 1000; % ms

sst.ach_com = ach_com( : );             % COM of ACH
sst.hw = hw( : );                       % waveform width at half-height (PYR wide)
sst.tp = tp( : );                       % trough-to-peak (PYR long)
sst.asy = asy( : );                     % waveform asymmetry (PYR asymmetric)
sst.pyr = classify_waveform( [ sst.fmax sst.tp ] ); % logical vector for pyr/IN classification
if ~exist( 'f', 'var' )
    sst.freqs = [];
else
    sst.freqs = f( 2 : end );
end

if Overwrite || ~FileExists( SaveFn )
    if verbose
        fprintf( 1, 'Saving %s\n', SaveFn )
    end
    save( SaveFn, 'sst', '-v6' );
end

return
%EOF

% 07-jun-12:
% for testing and modifying the code to block-wise loading of spikes:
%filebase = '/Volumes/Data/phaser4/mouse401/17mar12/dat/es17mar12.002/es17mar12.002'; OVerwrite = 0; periods = -1;
%sst = spikes_stats( filebase, [], [], [], [], Overwrite, periods );
filebase = '/Volumes/Data/phaser4/mouse401/17mar12/dat/es17mar12.004/es17mar12.004'; Overwrite = 1; periods = -1;
sst0 = spikes_stats_08apr12( filebase, [], [], [], [], Overwrite, periods );
sst1 = spikes_stats( filebase, [], [], [], [], Overwrite, periods );
allfields = fields( sst1 ); for i = 1 : length( allfields ), field = allfields{ i }; eq( i ) = eval( sprintf( 'isequal( sst0.%s, sst1.%s )', field, field ) ); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REFERENCES - cell type classification:

% Csicsvari 1998: CA1. large sample (). used mean of ACH (over 50 ms), firing rate, and
% amplitude asymmetry (of filtered trace; a-b; 0.25ms at +-0.18ms from negative peak).
% Also discuss width (between peaks of filtered trace) and say that less dissociating

% Henze 2002: CA3. small sample (22/26/10 PYR/IN/unclassified). 
% used temporal assymetry a/b (of raw trace) and half width (width at half height)

% Bartho 2004: SS and some PFC. used CC analysis, identified (0.2% of the
% CCHs were significant). Considered multiple features (rate; ACH: peak,
% COM, burstiness ratio; waveform: duration, assymetry, ratio of
% negative/positive peaks). 
% used duration (width at half amp; time from trough to peak)
% defined "excited" cells as IN, inhibiting as IN, and exciting as PYR
% also computed COM of waveforms to get an estimate of the cell body
% position (i.e. PYR->IN is reliable synapse but PYR->PYR is less)

% Fujisawa 2008: PFC. used CC analysis and identified ~50% of the cells
% (although only 0.8% of the CCHs were significant). Used jittering (+-5 ms)
% and significance based on global bands. 
% mention that never saw IN->IN (exciting) or IN->PYR (exciting)
 
% Sirota 2008: Parietal and some PFC. large sample (2297/343 PYR/IN).
% used CC analysis and generalized with waveform features (trough-peak
% latency, amplitude asymetry) of filtered traces (0.8-5 kHz) (says that 
% considered also half-width, trough-early peak latency, firing rate, 
% and auto-correlation features)

% REFERENCES - spike isolation:
% Henze 2000: amplitude threshold
% Fee 1996: ISIindex measure
% Schmitzer-Torbert 2005: Lratio, ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% final product (26jan12):
% (re-ran on 30jan12 after adding the periods argument and setting to -1)
% (ran again with 04,06feb12 on 02-mar-12 - single merged file)

%to actually run this on each file separately, type:
adate = '25nov11';
%adate = '26nov11';
adate = '04feb12';
adate = '06feb12';
adate = '14mar12';
params = get_date_parameters( adate );
Overwrite = 0;
periods = -1; % remove spikes during triggers
% individual files
for fnum = params.pfnums
    filebase = sprintf( '%s/%s/dat/%s%s.%s/%s%s.%s', params.drive, params.date...
        , params.fileprefix, params.date, num3str( fnum )...
        , params.fileprefix, params.date, num3str( fnum ) );
    
    fprintf( 1, 'spikes2spikes for %s...\n', filebase )
    s2s = spikes2spikes( filebase, [], [], [], [], [], [], [], [], Overwrite, periods );
    fprintf( 1, 'spikes_stats for %s...\n', filebase )
    sst = spikes_stats( filebase, [], [], [], [], Overwrite, periods );
end
% merged files
if isa( params.merged, 'char' )
    mfnums = -1;
    mfname = params.merged;
else
    mfnums = setdiff( unique( params.merged( :, 2 ) ), 0 );
end
for mfnum = mfnums( : ).'
    if mfnums ~= -1
        mfname = sprintf( '%s%s_%d', params.fileprefix, params.date, mfnum );
    end
    mfilebase = sprintf( '%s/%s/dat/%s/%s', params.drive, params.date, mfname, mfname );
    fprintf( 1, 'spikes2spikes for %s...\n', mfilebase )
    s2s = spikes2spikes( mfilebase, [], [], [], [], [], [], [], [], Overwrite, periods );
    fprintf( 1, 'spikes_stats for %s...\n', mfilebase )
    sst = spikes_stats( mfilebase, [], [], [], [], Overwrite, periods );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to run this on the summary data:
filebases = { '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_1/es25nov11_1'
    '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_2/es25nov11_2'
    '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_3/es25nov11_3'
    '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_4/es25nov11_4'
    '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_1/es26nov11_1'
    '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_2/es26nov11_2'
    '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_3/es26nov11_3'
    '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_4/es26nov11_4'
    };
filebases = filebases( [ 1 3 4 5 6 7 ] ); % CX, CA1pyr, DG; CX, CA1, DG
Overwrite = 0;
graphics = 1;
ilevel = 'B'; % this is what I've used before. results don't matter for B+/C but much less cells are with A
switch ilevel
    case 'C'
        isiTH = 0.4;    idTH = 40;  lrTH = 0.2;  nsTH = 100; snrTH = 2;  pvTH = 0.04;
    otherwise
        isiTH = 0.2;    idTH = 50;  lrTH = 0.05; nsTH = 400; snrTH = 2;  pvTH = 0.04;
end
idTH2 = 15;
PKEEP = [];
for i = 1 : length( filebases )
    filebase = filebases{ i };
    %filebase = '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_1/es26nov11_1';
    %filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_1/es25nov11_1';
    %filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_2/es25nov11_2';
    %filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_3/es25nov11_3';
    %filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_4/es25nov11_4';
    % sst = spikes_stats( filebase ); % saves *.sst file
    % s2s = spikes2spikes( filebase ); % saves *.s2s file
    sst = spikes_stats( filebase, [], [], [], [], Overwrite, periods );
    s2s = spikes2spikes( filebase, [], [], [], [], [], [], [], [], Overwrite, periods );
    mono = check_mono( filebase ); % does not save (superquick)
    
    % get a list of good units for that date
    gidx1 = sst.nspks >= nsTH & sst.maxp2p >= pvTH;% & sst.snr >= snrTH; % nspikes, amplitude
    gidx2 = sst.ISIindex <= isiTH; % temporal isolation
    gidx3 = sst.ID >= idTH | ( isnan( sst.ID ) & sst.Lratio <= lrTH ); % morphological isolation
    gidx4 = sst.ID >= idTH2;
    switch ilevel
        case 'A'
            gidx = find( gidx1 & gidx2 & gidx3 );
        case 'B+'
            gidx = find( gidx1 & ( gidx2 | gidx3 ) & gidx4 );
        case 'B'
            gidx = find( gidx1 & ( gidx2 | gidx3 ) );
        case 'C'
            gidx = find( gidx1 & ( gidx2 | gidx3 ) );
    end
    %gidx = find( sst.nspks > 1000 & sst.maxp2p > 0.05 & sst.ISIindex < 0.2 & ( sst.Lratio < 0.05 | sst.ID > 50 ) );
    %gidx = [ 1 : size( sst.shankclu, 1 ) ]';
    
    % keep only pairs with good units
    %mono.shankclu( gidx, : )
    mono.pairsExc = mono.pairsExc( ismember( mono.pairsExc( :, 1 ), gidx ) & ismember( mono.pairsExc( :, 2 ), gidx ), : );
    mono.pairsInh = mono.pairsInh( ismember( mono.pairsInh( :, 1 ), gidx ) & ismember( mono.pairsInh( :, 2 ), gidx ), : );
    mono.pairsSync = mono.pairsSync( ismember( mono.pairsSync( :, 1 ), gidx ) & ismember( mono.pairsSync( :, 2 ), gidx ), : );
    mono.pairsDesync = mono.pairsDesync( ismember( mono.pairsDesync( :, 1 ), gidx ) & ismember( mono.pairsDesync( :, 2 ), gidx ), : );
    exc = unique( mono.pairsExc( :, 1 ) );
    inh = unique( mono.pairsInh( :, 1 ) );
    mono.exc = setdiff( exc, inh ); 
    mono.inh = setdiff( inh, exc ); 
    mono.both = intersect( exc, inh );
    mono.unc = setdiff( gidx, [ exc; inh ] );
    
    % get the allocation of the units
    exc = mono.exc;
    inh = mono.inh;
    both = mono.both;
    unc = mono.unc;

    % get the targets
    clear excTargets inhTargets bothTargets1 bothTargets2
    for j = 1 : length( exc )
        excTargets{ j } = mono.pairsExc( mono.pairsExc( :, 1 ) == exc( j ), 2 ); 
        excTargets{ j } = intersect( excTargets{ j }, gidx );
    end
    for j = 1 : length( inh )
        inhTargets{ j } = mono.pairsInh( mono.pairsInh( :, 1 ) == inh( j ), 2 ); 
        inhTargets{ j } = intersect( inhTargets{ j }, gidx );
    end
    for j = 1 : length( both )
        bothTargets1{ j } = mono.pairsExc( mono.pairsExc( :, 1 ) == both( j ), 2 ); 
        bothTargets2{ j } = mono.pairsInh( mono.pairsInh( :, 1 ) == both( j ), 2 ); 
    end
    
    if graphics
        figure
        subplot( 2, 2, 1 )
        p12 = [ sst.hw sst.tp ];
        p12 = p12 + ( 2 * rand( size( p12 ) ) - 1 ).* p12 * 0.01;
        p1 = p12( :, 1 ); p2 = p12( :, 2 );
        ph = plot( p1( gidx ), p2( gidx ), 'o', p1( both ), p2( both ), '.g', p1( inh ), p2( inh ), '.b', p1( exc ), p2( exc ), '.r' );
        legend( { 'Unclassified', 'Both', 'Inh', 'Exc' }, 0 );
        %ylabel( 'Spectral peak (Hz)' ),
        xlabel( 'Half-width (ms)' )
        ylabel( 'Trough-peak (ms)' ),
        title( slash_( filebase ) )
        
        subplot( 2, 2, 2 )
        p12 = [ sst.frate sst.ach_com ];
        p12 = p12 + ( 2 * rand( size( p12 ) ) - 1 ).* p12 * 0.01;
        p1 = p12( :, 1 ); p2 = p12( :, 2 );
        ph = plot( p1( gidx ), p2( gidx ), 'o', p1( both ), p2( both ), '.g', p1( inh ), p2( inh ), '.b', p1( exc ), p2( exc ), '.r' );
        xlabel( 'Rate (Hz)' ),
        ylabel( 'ACH mean (ms)' )
        
        subplot( 2, 2, 3 )
        p12 = [ sst.fmax sst.asy ];
        p12 = p12 + ( 2 * rand( size( p12 ) ) - 1 ).* p12 * 0.01;
        p1 = p12( :, 1 ); p2 = p12( :, 2 );
        ph = plot( p1( gidx ), p2( gidx ), 'o', p1( both ), p2( both ), '.g', p1( inh ), p2( inh ), '.b', p1( exc ), p2( exc ), '.r' );
        xlabel( 'Peak freq (Hz)' )
        ylabel( 'Asymmetry' )
        
        subplot( 2, 2, 4 )
        p12 = [ sst.fmax sst.tp ];
        p12 = p12 + ( 2 * rand( size( p12 ) ) - 1 ).* p12 * 0.01;
        p1 = p12( :, 1 ); p2 = p12( :, 2 );
        ph = plot( p1( gidx ), p2( gidx ), 'o', p1( both ), p2( both ), '.g', p1( inh ), p2( inh ), '.b', p1( exc ), p2( exc ), '.r' );
        xlabel( 'Peak freq (Hz)' )
        ylabel( 'Trough-peak (ms)' ),
    end
    p12keep = [ sst.fmax sst.tp ];
    p12keep( exc, 3 ) = 1;
    p12keep( inh, 3 ) = 2;
    p12keep( both, 3 ) = 3;    
    p12keep = p12keep( gidx, : );
    PKEEP = [ PKEEP; p12keep ];
    
end

PKEEP0 = PKEEP;
TOPLOT = PKEEP( :, 1 : 2 ) + ( 2 * rand( size( PKEEP( :, 1 : 2 ) ) ) - 1 ) * 0.01 .* PKEEP( :, 1 : 2 );
figure
subplot( 2, 2, 1 )
kk = kmeans( TOPLOT, 2, 'Distance', 'cosine' );
plot( TOPLOT( kk == 1, 1 ), TOPLOT( kk == 1, 2 ), '.r', TOPLOT( kk == 2, 1 ), TOPLOT( kk == 2, 2 ), '.b' )
subplot( 2, 2, 2 )
plot( TOPLOT( PKEEP( :, 3 ) == 0, 1 ), TOPLOT( PKEEP( :, 3 ) == 0,2 ), 'ob' )
hold on
plot( TOPLOT( PKEEP( :, 3 ) == 1, 1 ), TOPLOT( PKEEP( :, 3 ) == 1,2 ), '.r' )
plot( TOPLOT( PKEEP( :, 3 ) == 2, 1 ), TOPLOT( PKEEP( :, 3 ) == 2,2 ), '.b' )
plot( TOPLOT( PKEEP( :, 3 ) == 3, 1 ), TOPLOT( PKEEP( :, 3 ) == 3,2 ), '.g' )
lh = line( [ 600 1450 ], [ 0.2 0.9 ], 'color', 'r' );
% % get the line equation
% xx = [ 600 1450 ]; yy = [ 0.2 0.9 ]; 
% a = diff( yy ) / diff( xx ); 
% b = yy( 1 ) - a * xx( 1 );  % y = ax+b
% xint = -b/a; % x-intercept
% xy = TOPLOT;
% atan( xy( :, 2 ) ./ ( xy( :, 1 ) - xint ) )
% pyr = atan( xy( :, 2 ) ./ ( xy( :, 1 ) - xint ) ) > atan( a );
pyr = classify_waveform( PKEEP );
subplot( 2, 2, 3 ), plot( TOPLOT( pyr == 1, 1 ), TOPLOT( pyr == 1, 2 ), '.r', TOPLOT( pyr == 0, 1 ), TOPLOT( pyr == 0, 2 ), '.b' )
xlim0 = xlim;
ylim0 = ylim;
lh = line( xlim0, a * xlim0 + b );
ylim( ylim0 );
title( sprintf( '%s: %d cells; %0.3g%% PYR', ilevel, length( pyr ), sum( pyr ) / length( pyr ) * 100 ) )

% to look at some cell in detail:
k = 1; inh( k ), inhTargets{ k }, cidx = inh( k ); [ sst.maxp2p( cidx ), sst.ISIindex( cidx ) sst.ID( cidx ) sst.Lratio( cidx ) ], [ sst.hw( cidx ), sst.tp( cidx ) sst.ach_com( cidx ) ]
k = 4; both( k ), bothTargets1{ k }, bothTargets2{ k }, cidx = both( k ); [ sst.maxp2p( cidx ), sst.ISIindex( cidx ) sst.ID( cidx ) sst.Lratio( cidx ) ], [ sst.hw( cidx ), sst.tp( cidx ) sst.ach_com( cidx ) ]

% critical - some pairs, such as 
% plot_s2s( s2s, [ 33 26 ], 0 )
% in 
% filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_3/es25nov11_3'
% are a sequence in a burst. This cell - 1.34 - is clearly a pyramidal cell
% (HW, TP, ACH..) - but the CCH with 1.27 is with a sharp peak at 3 ms,
% indicating a burst. Thus, the two units must be combined. Nevertheless,
% in an automatic analysis, the two units are both well isolated etc, and
% the CCH is like a delta-function thus the adjacent bins are sign. inh!
% and the referece cell is categorized as both inh and exc

% to run a partial subset with plotting without saving:
plot_s2s( s2s, [ 1 13; 1 7 ], 0 );
s = spikes_stats( filebase, [1], [ 1 6; 1 12 ], 'clc', 1, 0 );

% NOTE - 26nov11_4 43x53 has a zero-lag peak with inh. side lobes but was
% not excluded as exc by check_mono - debug this

% now select the relevant subset of well-isolated units
%[ out.shankclu out.maxp2p out.snr out.ISIidx out.ID out.Lratio out.ISIratio ]

filebase = '/Volumes/Data/phaser3/mouse365/25nov11/dat/es25nov11_4/es25nov11_4';
shanknum = 1;
clunum = 20;
make_spk_plots( filebase, shanknum, clunum )
clunums = { [ 10 20 ], [ 6 7 ], [ 13 14 ], [ 3 9 11 12 ] };
for i = 1 : length( clunums ); s = make_spk_plots( filebase, i, clunums{ i } ); if i == 1, sw = s; else, sw = [ sw s ]; end, end

filebase = '/Volumes/Data/phaser3/mouse428/26nov11/dat/es26nov11_1/es26nov11_1';
for i = 1 : 4, sw( i ) = make_spk_plots( filebase, i, [], 'clc', 0 ); end
s = sw( 1 ); 
for i = 2 : length( sw );
    s.shankclu = [ s.shankclu; sw( i ).shankclu ]; 
    s.nspks = [ s.nspks; sw( i ).nspks ];
    %s.mean = cat( 3, s.mean, sw( i ).mean );
    s.max = [ s.max sw( i ).max ]; 
    s.fmax = [ s.fmax; sw( i ).fmax ]; 
    s.spec = [ s.spec sw( i ).spec ]; 
    s.ach = [ s.ach sw( i ).ach ]; 
    s.frate = [ s.frate; sw( i ).frate ]; 
    s.spatial_com = [ s.spatial_com; sw( i ).spatial_com ]; 
    s.ach_com = [ s.ach_com; sw( i ).ach_com ];
    s.hw = [ s.hw; sw( i ).hw ]; 
    s.asy = [ s.asy; sw( i ).asy ];
end
s = rmfield( s, 'mean' );
% validate using mono-synaptic analysis
s2s = spikes2spikes( filebase, [], [], [], [], [], 0.001 );
mono = check_mono( filebase );
exc = mono.exc;
inh = mono.inh;

figure
p12 = [ s.fmax s.hw ];
p12 = p12 + rand( size( p12 ) ) .* p12 * 0.1;
p1 = p12( :, 1 ); p2 = p12( :, 2 );
ph = plot( p1, p2, 'o', p1( mono.both ), p2( mono.both ), '.g', p1( inh ), p2( inh ), '.r', p1( exc ), p2( exc ), '.b' );
legend( { 'Unclassified', 'Both', 'Inh', 'Exc' }, 0 );
xlabel( 'Spectral peak (Hz)' ), ylabel( 'Half-width (ms)' )
title( slash_( filebase ) )

% IN: 2, 5, 7, 10
% PYR: 1, 3, 4, 6, 8, 9
%
% waveform characteristics:
% PYR - wide waveform (peak spectrum around 800-900 Hz); 
%       before trough - gradual upsloping
%       after trough - upsloping
% IN - narrow waveform (peak spectrum above 1 kHz (1100-2500)); 
%       after trough - downsloping
%       before trough - downsloping, sometimes accompanied by a notch just before the trough 

% compute first moment of ACH:
for i = 1 : 10, 
    acm( i ) = calc_com( [ 0 : 51 ]', sw( i ).ach( 52 : 103 ) ); 
end

% compute peak of spectrum:
for i = 1 : 10, wf( :, i ) = sw( i ).mean; end
[ p f ] = my_spectrum( wf, 1024, 20000, hanning( 32 ), 0, 0 );
[ ign idx ] = max( p );
%f = 0 : 10000/512 : 10000;
w = 1./f( idx );

% scale waveforms to 0-1:
wfs = bsxfun( @rdivide, bsxfun( @minus, wf, min( wf ) ), max( wf ) - min( wf ) );



